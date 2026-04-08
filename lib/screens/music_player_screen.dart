import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/glass_container.dart';
import '../models/track_model.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<TrackModel> tracks;
  final int initialIndex;

  const MusicPlayerScreen({super.key, required this.tracks, this.initialIndex = 0});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late AudioPlayer _audioPlayer;
  late int _currentIndex;
  bool _isPlaying = false;
  bool _isFavorited = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  TrackModel get _currentTrack => widget.tracks[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _audioPlayer = AudioPlayer();
    _setupAudioListeners();
    _loadTrack();
    _checkFavorite();
  }

  void _setupAudioListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
      if (state.playing) {
        _rotationController.repeat();
      } else {
        // Only stop if the controller is not disposed
        try { _rotationController.stop(); } catch (_) {}
      }
    });
    _audioPlayer.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _audioPlayer.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur ?? Duration.zero);
    });
    _audioPlayer.processingStateStream.listen((state) {
      if (!mounted) return;
      if (state == ProcessingState.completed) _skipNext();
    });
  }

  Future<void> _loadTrack() async {
    try {
      await _audioPlayer.setUrl(_currentTrack.audioUrl);
      await _audioPlayer.play();
      _logHistory();
    } catch (_) {}
  }

  Future<void> _logHistory() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await Supabase.instance.client.from('listening_history').insert({
        'user_id': uid,
        'track_id': _currentTrack.id,
      });
    } catch (_) {}
  }

  Future<void> _checkFavorite() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final result = await Supabase.instance.client
          .from('favorites')
          .select()
          .eq('user_id', uid)
          .eq('track_id', _currentTrack.id)
          .maybeSingle();
      if (mounted) setState(() => _isFavorited = result != null);
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    // Ensure track exists in DB first
    try {
      await Supabase.instance.client.from('tracks').upsert({
        'id': _currentTrack.id, 'title': _currentTrack.title,
        'artist': _currentTrack.artist, 'audio_url': _currentTrack.audioUrl,
        'cover_url': _currentTrack.coverUrl, 'duration_seconds': _currentTrack.durationSeconds,
        'genre': _currentTrack.genre,
      }, onConflict: 'id');

      if (_isFavorited) {
        await Supabase.instance.client.from('favorites').delete()
            .eq('user_id', uid).eq('track_id', _currentTrack.id);
      } else {
        await Supabase.instance.client.from('favorites').insert({
          'user_id': uid, 'track_id': _currentTrack.id,
        });
      }
      if (mounted) setState(() => _isFavorited = !_isFavorited);
    } catch (_) {}
  }

  void _playPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _skipNext() {
    if (_currentIndex < widget.tracks.length - 1) {
      setState(() => _currentIndex++);
      _loadTrack();
      _checkFavorite();
    }
  }

  void _skipPrev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadTrack();
      _checkFavorite();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0 ? _position.inMilliseconds / _duration.inMilliseconds : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: AmbientGlow(color: context.colors.primary, width: 400, height: 400, blurRadius: 120)),
          Positioned(bottom: -50, right: -50, child: AmbientGlow(color: context.colors.secondary, width: 350, height: 350, blurRadius: 100)),
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: Icon(Icons.expand_more, color: context.colors.onSurface, size: 32), onPressed: () => Navigator.of(context).pop()),
                      Column(
                        children: [
                          Text('NOW PLAYING', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2)),
                          Text(_currentTrack.genre, style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      IconButton(icon: Icon(Icons.more_vert, color: context.colors.onSurface, size: 28), onPressed: () {}),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Album Art
                        Container(
                          width: MediaQuery.of(context).size.width - 64,
                          height: MediaQuery.of(context).size.width - 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: context.colors.surfaceContainerHigh,
                            boxShadow: [
                              BoxShadow(color: context.colors.inverseSurface.withOpacity(0.5), blurRadius: 50, offset: const Offset(0, 20)),
                              BoxShadow(color: context.colors.primary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) => Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateZ(_rotationController.value * 0.05),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _currentTrack.coverUrl != null
                                    ? Image.network(_currentTrack.coverUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                    : Icon(Icons.music_note, size: 80, color: context.colors.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Track Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_currentTrack.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(_currentTrack.artist, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.colors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleFavorite,
                              child: GlassContainer(
                                width: 56, height: 56, borderRadius: 28,
                                child: Icon(
                                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: _isFavorited ? context.colors.tertiary : context.colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Progress Bar
                        GestureDetector(
                          onTapDown: (d) {
                            final width = MediaQuery.of(context).size.width - 64;
                            final ratio = d.localPosition.dx / width;
                            _audioPlayer.seek(Duration(milliseconds: (_duration.inMilliseconds * ratio).toInt()));
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(height: 8, decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(4))),
                              FractionallySizedBox(
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [context.colors.primary, context.colors.secondary]),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [BoxShadow(color: context.colors.secondary.withOpacity(0.4), blurRadius: 10)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(_position), style: Theme.of(context).textTheme.labelSmall),
                            Text(_formatDuration(_duration), style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(icon: Icon(Icons.shuffle, color: context.colors.onSurface.withOpacity(0.54)), onPressed: () {}),
                            IconButton(icon: Icon(Icons.skip_previous, size: 40, color: context.colors.onSurface), onPressed: _skipPrev),
                            GestureDetector(
                              onTap: _playPause,
                              child: Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [context.colors.primary, context.colors.inversePrimary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  boxShadow: [BoxShadow(color: context.colors.primary.withOpacity(0.4), blurRadius: 20)],
                                ),
                                child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 48, color: context.colors.onPrimaryContainer),
                              ),
                            ),
                            IconButton(icon: Icon(Icons.skip_next, size: 40, color: context.colors.onSurface), onPressed: _skipNext),
                            IconButton(icon: Icon(Icons.repeat, color: context.colors.onSurface.withOpacity(0.54)), onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
