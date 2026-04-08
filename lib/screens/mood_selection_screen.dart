import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/glass_container.dart';
import '../models/track_model.dart';
import 'main_screen.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  int _selectedMoodIndex = -1;
  bool _isLoading = false;

  final List<Map<String, dynamic>> moods = [
    {'name': 'Happy',    'icon': Icons.sentiment_very_satisfied, 'tags': 'happy upbeat pop dance'},
    {'name': 'Relaxed',  'icon': Icons.spa,                      'tags': 'relaxed chill lofi calm'},
    {'name': 'Focused',  'icon': Icons.psychology,               'tags': 'focus study concentration ambient'},
    {'name': 'Sad',      'icon': Icons.mood_bad,                 'tags': 'sad melancholy acoustic slow'},
    {'name': 'Energetic','icon': Icons.local_fire_department,    'tags': 'energetic workout hype edm'},
    {'name': 'Romantic', 'icon': Icons.favorite,                 'tags': 'romantic love soul jazz'},
  ];

  final List<Color?> moodColors = [
    Colors.yellow[400],
    Colors.teal[300],
    Colors.indigo[400],
    Colors.blue[400],
    Colors.orange[400],
    Colors.pink[300],
  ];

  Future<void> _onContinue() async {
    if (_selectedMoodIndex < 0) return;
    setState(() => _isLoading = true);

    final mood = moods[_selectedMoodIndex];
    final moodName = mood['name'] as String;
    final tags = mood['tags'] as String;

    try {
      // 1. Save mood entry to Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('mood_entries').insert({
          'user_id': userId,
          'mood_name': moodName,
          'journal_note': null,
          'generated_tags': tags,
        });
      }

      // 2. Fetch tracks via Edge Function using mood tags as journal text
      final response = await Supabase.instance.client.functions.invoke(
        'curate_mood_playlist',
        body: {'journal_text': 'I am feeling $moodName. $tags'},
      );

      List<TrackModel> tracks = [];
      if (response.data != null) {
        final list = response.data as List;
        tracks = list.map((t) => TrackModel.fromMap(t as Map<String, dynamic>)).toList();
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen(initialTracks: tracks, initialMood: moodName)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: -50, left: -50, child: AmbientGlow(color: context.colors.primary, width: 300, height: 300)),
          Positioned(bottom: -50, right: -50, child: AmbientGlow(color: context.colors.secondary, width: 350, height: 350)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: context.colors.primaryContainer,
                            child: Icon(Icons.graphic_eq, color: context.colors.onPrimaryContainer, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text('Moodify', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const MoodSelectionScreen()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Text('How are you \nfeeling?', style: Theme.of(context).textTheme.displayMedium),
                        const SizedBox(height: 16),
                        Text(
                          'Select a mood to let Moodify curate the perfect soundscape for your current state.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 48),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 1.0, crossAxisSpacing: 16, mainAxisSpacing: 16,
                          ),
                          itemCount: moods.length,
                          itemBuilder: (context, index) {
                            final mood = moods[index];
                            final color = moodColors[index] ?? context.colors.primary;
                            final isSelected = _selectedMoodIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedMoodIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
                                child: GlassContainer(
                                  borderRadius: 40,
                                  color: isSelected ? color.withOpacity(0.2) : null,
                                  border: Border.all(
                                    color: isSelected ? color.withOpacity(0.5) : context.colors.onSurface.withOpacity(0.1),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 20)],
                                        ),
                                        child: Icon(mood['icon'] as IconData, size: 32, color: color),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(mood['name'] as String, style: Theme.of(context).textTheme.titleLarge),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                        Center(
                          child: AnimatedOpacity(
                            opacity: _selectedMoodIndex != -1 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: (_selectedMoodIndex != -1 && !_isLoading) ? _onContinue : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 20,
                                shadowColor: context.colors.primary.withOpacity(0.5),
                              ),
                              child: _isLoading
                                  ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: context.colors.onPrimaryContainer, strokeWidth: 2))
                                  : Text('Continue', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: context.colors.onPrimaryContainer)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
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
