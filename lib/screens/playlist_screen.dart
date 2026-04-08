import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../models/track_model.dart';
import 'music_player_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<TrackModel> _favorites = [];
  List<Map<String, dynamic>> _recentMoods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) { setState(() => _isLoading = false); return; }

    try {
      // Load favorites (join with tracks)
      final favsResponse = await Supabase.instance.client
          .from('favorites')
          .select('track_id, tracks(*)')
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      final favTracks = (favsResponse as List).map((row) {
        final trackData = row['tracks'] as Map<String, dynamic>?;
        if (trackData == null) return null;
        return TrackModel.fromMap(trackData);
      }).whereType<TrackModel>().toList();

      // Load recent journal mood entries
      final moodsResponse = await Supabase.instance.client
          .from('mood_entries')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _favorites = favTracks;
          _recentMoods = List<Map<String, dynamic>>.from(moodsResponse as List);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 0, left: 50, child: AmbientGlow(color: context.colors.primary, width: 300, height: 300, blurRadius: 100)),
          Positioned(top: 200, right: 0, child: AmbientGlow(color: context.colors.secondary, width: 400, height: 400, blurRadius: 120)),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: context.colors.surfaceContainerHigh.withOpacity(0.4)),
                  ),
                ),
                title: Text('My Library', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                actions: [
                  IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() => _isLoading = true); _loadData(); }),
                ],
              ),

              SliverToBoxAdapter(
                child: _isLoading
                    ? const Padding(padding: EdgeInsets.all(64), child: Center(child: CircularProgressIndicator()))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Favorites Section
                            _buildSectionHeader(context, Icons.favorite, 'Liked Songs', '${_favorites.length} tracks'),
                            const SizedBox(height: 16),
                            if (_favorites.isEmpty)
                              _buildEmptyState(context, 'No liked songs yet', 'Heart a track in the player to save it here')
                            else
                              ..._favorites.map((track) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildTrackItem(context, track, _favorites),
                              )),

                            const SizedBox(height: 32),

                            // Recent Moods Section
                            _buildSectionHeader(context, Icons.psychology, 'Mood History', '${_recentMoods.length} entries'),
                            const SizedBox(height: 16),
                            if (_recentMoods.isEmpty)
                              _buildEmptyState(context, 'No mood entries yet', 'Select a mood or write a journal entry')
                            else
                              ..._recentMoods.map((mood) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildMoodItem(context, mood),
                              )),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: context.colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: context.colors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.onSurface.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.music_off, size: 32, color: context.colors.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTrackItem(BuildContext context, TrackModel track, List<TrackModel> allTracks) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MusicPlayerScreen(tracks: allTracks, initialIndex: allTracks.indexOf(track)),
      )),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLow.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.onSurface.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: track.coverUrl != null
                  ? Image.network(track.coverUrl!, width: 56, height: 56, fit: BoxFit.cover)
                  : Container(width: 56, height: 56, color: context.colors.surfaceContainerHigh, child: Icon(Icons.music_note, color: context.colors.onSurfaceVariant)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(track.artist, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.favorite, color: context.colors.tertiary, size: 18),
            const SizedBox(width: 8),
            Icon(Icons.play_circle_outline, color: context.colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodItem(BuildContext context, Map<String, dynamic> mood) {
    final moodName = mood['mood_name'] ?? 'Unknown';
    final note = mood['journal_note'];
    final createdAt = mood['created_at'] != null ? DateTime.tryParse(mood['created_at'] as String) : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.onSurface.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: context.colors.secondary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.mood, color: context.colors.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(moodName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (note != null && note.toString().isNotEmpty)
                  Text(note.toString(), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (createdAt != null)
            Text('${createdAt.day}/${createdAt.month}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
