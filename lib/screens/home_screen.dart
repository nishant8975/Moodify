import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../models/track_model.dart';
import 'mood_selection_screen.dart';
import 'music_player_screen.dart';
import 'journal_entry_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<TrackModel> tracks;
  final String mood;

  const HomeScreen({super.key, this.tracks = const [], this.mood = ''});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -100, left: -100, child: AmbientGlow(color: context.colors.primary, width: 400, height: 400, blurRadius: 120)),
        Positioned(top: 400, right: -100, child: AmbientGlow(color: context.colors.secondary, width: 500, height: 500, blurRadius: 120)),
        CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.colors.surfaceContainerHigh.withOpacity(0.4),
              pinned: true,
              expandedHeight: 80,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.primaryContainer),
                              child: Icon(Icons.graphic_eq, color: context.colors.onPrimaryContainer, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text('Moodify', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                          ],
                        ),
                        Icon(Icons.notifications_outlined, size: 20, color: context.colors.onSurface.withOpacity(0.7)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMoodHero(context),
                  const SizedBox(height: 32),
                  _buildBentoGrid(context),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR MOOD', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.secondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(mood.isNotEmpty ? mood : 'Good Vibes', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40)),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MoodSelectionScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.colors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          'CHANGE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
              child: Text('See analytics', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (tracks.isNotEmpty)
          SizedBox(
            height: 380,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tracks.length > 5 ? 5 : tracks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (context, index) {
                final track = tracks[index];
                return _buildTrackCard(context, track);
              },
            ),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.music_note, size: 48, color: context.colors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No tracks loaded yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrackCard(BuildContext context, TrackModel track) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MusicPlayerScreen(tracks: tracks, initialIndex: tracks.indexOf(track)))),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: context.colors.surfaceContainerLow,
            image: track.coverUrl != null
                ? DecorationImage(image: NetworkImage(track.coverUrl!), fit: BoxFit.cover)
                : null,
            boxShadow: [BoxShadow(color: context.colors.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [context.colors.inverseSurface.withOpacity(0.85), Colors.transparent, Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.colors.onSurface.withOpacity(0.1)),
                  ),
                  child: Text(track.genre.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.primary)),
                ),
                const SizedBox(height: 12),
                Text(track.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(track.artist, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.colors.onSurface.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: context.colors.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.edit_note, color: context.colors.primary),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mood Journal', style: Theme.of(context).textTheme.titleLarge),
                      Text('Log your thoughts', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.onSurface.withOpacity(0.05)),
                ),
                child: Text(
                  '"How are you feeling today? Tap to add a journal entry and let Moodify understand your mood..."',
                  style: TextStyle(fontStyle: FontStyle.italic, color: context.colors.onSurface.withOpacity(0.7)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JournalEntryScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Entry'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (tracks.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.colors.onSurface.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Queue', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                ...tracks.take(5).map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildRecentTrack(context, t),
                )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentTrack(BuildContext context, TrackModel track) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MusicPlayerScreen(tracks: tracks, initialIndex: tracks.indexOf(track)))),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.colors.surfaceContainerHigh,
              image: track.coverUrl != null ? DecorationImage(image: NetworkImage(track.coverUrl!), fit: BoxFit.cover) : null,
            ),
            child: track.coverUrl == null ? Icon(Icons.music_note, color: context.colors.onSurfaceVariant) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(track.artist, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(track.durationFormatted, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 8),
          Icon(Icons.play_circle_outline, color: context.colors.primary.withOpacity(0.7)),
        ],
      ),
    );
  }
}
