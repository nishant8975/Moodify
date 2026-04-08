import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/glass_container.dart';
import '../models/track_model.dart';
import 'music_player_screen.dart';
import 'main_screen.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _journalController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _generatePlaylist() async {
    final text = _journalController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write something first!')));
      return;
    }
    setState(() => _isLoading = true);

    try {
      // 1. Save entry to Supabase
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        await Supabase.instance.client.from('mood_entries').insert({
          'user_id': uid,
          'mood_name': 'Journal',
          'journal_note': text,
          'generated_tags': null,
        });
      }

      // 2. Invoke Edge Function
      final response = await Supabase.instance.client.functions.invoke(
        'curate_mood_playlist',
        body: {'journal_text': text},
      );

      List<TrackModel> tracks = [];
      if (response.data != null) {
        final list = response.data as List;
        tracks = list.map((t) => TrackModel.fromMap(t as Map<String, dynamic>)).toList();
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainScreen(initialTracks: tracks, initialMood: 'Journaled')),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: context.colors.surfaceContainerHigh.withOpacity(0.4)),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.primaryContainer),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Mood Journal', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: context.colors.primaryContainer, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned(top: -100, left: -100, child: AmbientGlow(color: context.colors.primary, width: 400, height: 400, blurRadius: 150)),
          Positioned(bottom: 100, right: -50, child: AmbientGlow(color: context.colors.secondary, width: 300, height: 300, blurRadius: 120)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: context.colors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('What\'s on your mind?', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Write freely. Moodify\'s AI will read your entry and pick the perfect music for how you\'re feeling.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _journalController,
                      maxLines: 10,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
                      decoration: InputDecoration(
                        hintText: '"Today felt like... the rain made me think about..."',
                        hintStyle: TextStyle(color: context.colors.onSurfaceVariant.withOpacity(0.6), fontStyle: FontStyle.italic),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generatePlaylist,
                      icon: _isLoading
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: context.colors.onPrimaryContainer, strokeWidth: 2))
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isLoading ? 'Curating your playlist...' : 'Generate My Playlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 20,
                        shadowColor: context.colors.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
