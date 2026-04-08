import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/glass_container.dart';
import '../models/track_model.dart';
import 'music_player_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  List<TrackModel> _searchResults = [];
  bool _isSearching = false;
  String _selectedGenre = '';

  final List<Map<String, dynamic>> _genres = [
    {'name': 'Lo-fi', 'query': 'lofi chill'},
    {'name': 'Synthwave', 'query': 'synthwave retro'},
    {'name': 'Ambient', 'query': 'ambient sleep'},
    {'name': 'Techno', 'query': 'techno dance'},
    {'name': 'Jazz', 'query': 'jazz cafe'},
    {'name': 'Classical', 'query': 'classical piano'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _searchResults = []; _selectedGenre = ''; });
      return;
    }
    setState(() => _isSearching = true);
    try {
      // Search directly against iTunes API via Edge Function
      final response = await Supabase.instance.client.functions.invoke(
        'curate_mood_playlist',
        body: {'journal_text': query},
      );
      if (response.data != null) {
        final list = response.data as List;
        setState(() => _searchResults = list.map((t) => TrackModel.fromMap(t as Map<String, dynamic>)).toList());
      }
    } catch (_) {
      setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 100, left: -50, child: AmbientGlow(color: context.colors.primary, width: 300, height: 300, blurRadius: 100)),
        Positioned(top: 400, right: -50, child: AmbientGlow(color: context.colors.secondary, width: 300, height: 300, blurRadius: 100)),
        SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Explore', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      const SizedBox(height: 16),
                      // Live Search Bar
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: context.colors.onSurfaceVariant),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: _search,
                                onChanged: (v) { if (v.isEmpty) setState(() => _searchResults = []); },
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Search songs, artists, moods...',
                                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant.withOpacity(0.5)),
                                ),
                                style: TextStyle(color: context.colors.onSurface, fontSize: 16),
                              ),
                            ),
                            if (_isSearching)
                              SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary))
                            else
                              GestureDetector(
                                onTap: () => _search(_searchController.text),
                                child: Icon(Icons.arrow_forward_ios, color: context.colors.primary, size: 18),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Genre Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _genres.map((g) {
                            final isSelected = _selectedGenre == g['name'];
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedGenre = g['name'] as String);
                                _searchController.text = g['query'] as String;
                                _search(g['query'] as String);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? context.colors.primary.withOpacity(0.3) : context.colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                  border: isSelected ? Border.all(color: context.colors.primary.withOpacity(0.6)) : null,
                                ),
                                child: Text(g['name'] as String, style: TextStyle(
                                  color: isSelected ? context.colors.primary : context.colors.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                )),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_searchResults.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final track = _searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MusicPlayerScreen(tracks: _searchResults, initialIndex: index)),
                            ),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(16),
                              color: context.colors.surfaceContainerLow.withOpacity(0.4),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
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
                                        Text(track.genre, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.primary)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(track.durationFormatted, style: Theme.of(context).textTheme.labelSmall),
                                  const SizedBox(width: 8),
                                  Icon(Icons.play_circle_outline, color: context.colors.primary),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _searchResults.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.travel_explore, size: 72, color: context.colors.onSurfaceVariant.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('Search for songs, artists, or moods',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text('Or tap a genre chip above to browse',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant.withOpacity(0.6)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
