import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/glass_container.dart';
import 'music_player_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 100, left: -50, child: AmbientGlow(color: context.colors.primary, width: 300, height: 300, blurRadius: 100)),
        Positioned(top: 400, right: -50, child: AmbientGlow(color: context.colors.secondary, width: 300, height: 300, blurRadius: 100)),
        
        SafeArea(
          child: CustomScrollView(
            slivers: [
              // Top Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Moodify',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: context.colors.primaryContainer,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.search, color: context.colors.primaryContainer),
                          SizedBox(width: 16),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colors.primary.withOpacity(0.2), width: 2),
                              image: DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=150&q=80'),
                                fit: BoxFit.cover,
                              )
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 16),
                    // Search Bar
                    GlassContainer(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: context.colors.onSurfaceVariant),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration.collapsed(
                                hintText: 'Search songs, artists, or albums',
                                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant.withOpacity(0.5)),
                              ),
                              style: TextStyle(color: context.colors.onSurface, fontSize: 18),
                            ),
                          ),
                          Icon(Icons.mic, color: context.colors.onSurfaceVariant),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Trending Genres
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildChip('Lo-fi', context.colors.primary),
                        _buildChip('Synthwave', context.colors.secondary),
                        _buildChip('Ambient', context.colors.tertiary),
                        _buildSimpleChip(context, 'Techno'),
                        _buildSimpleChip(context, 'Vaporwave'),
                      ],
                    ),
                    SizedBox(height: 48),
                    
                    // Recent Searches
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Searches', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('Clear all', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.secondary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    GlassContainer(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 12),
                      color: context.colors.surfaceContainerLow.withOpacity(0.4),
                      child: Row(
                        children: [
                          Icon(Icons.history, color: context.colors.onSurfaceVariant),
                          SizedBox(width: 16),
                          Expanded(child: Text('After Hours - The Weeknd')),
                          Icon(Icons.close, color: context.colors.onSurfaceVariant, size: 20),
                        ],
                      ),
                    ),
                    GlassContainer(
                      padding: EdgeInsets.all(16),
                      color: context.colors.surfaceContainerLow.withOpacity(0.4),
                      child: Row(
                        children: [
                          Icon(Icons.history, color: context.colors.onSurfaceVariant),
                          SizedBox(width: 16),
                          Expanded(child: Text('Arctic Monkeys')),
                          Icon(Icons.close, color: context.colors.onSurfaceVariant, size: 20),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 48),
                    
                    // Recommended
                    Text('Recommended for your Mood', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('"Currently feeling Euphoric"', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant, fontStyle: FontStyle.italic)),
                    SizedBox(height: 24),
                    
                    // Recommended Grid (Bento)
                    _buildFeaturedCard(context),
                    SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            height: 200,
                            padding: EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Ethereal Clouds', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: context.colors.secondary, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('AMBIENT • 12 TRACKS', style: Theme.of(context).textTheme.labelSmall),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildAvatar(context, 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&w=150&q=80'),
                                    Transform.translate(offset: const Offset(-8, 0), child: _buildAvatar(context, 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=150&q=80')),
                                    Transform.translate(
                                      offset: Offset(-16, 0),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.surfaceContainerHighest, border: Border.all(color: context.colors.surfaceContainer)),
                                        child: Center(child: Text('+5', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    GlassContainer(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?auto=format&fit=crop&w=150&q=80',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Liquid Dreams', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                Text('Floating Point', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.equalizer, color: context.colors.primary, size: 16),
                                    SizedBox(width: 8),
                                    Text('TRENDING NOW', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.primary)),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 120), // Padding for nav bar
                  ]),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
  
  Widget _buildSimpleChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MusicPlayerScreen(tracks: const [], initialIndex: 0))),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?auto=format&fit=crop&w=800&q=80'),
            fit: BoxFit.cover,
          )
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, context.colors.background.withOpacity(0.9)],
            )
          ),
          padding: EdgeInsets.all(24),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: GlassContainer(
                  width: 56,
                  height: 56,
                  borderRadius: 28,
                  child: Icon(Icons.play_arrow, color: context.colors.onSurface, size: 28),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: context.colors.primary, borderRadius: BorderRadius.circular(16)),
                    child: Text('MOOD: HIGH ENERGY', style: TextStyle(color: context.colors.inverseSurface, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                  SizedBox(height: 16),
                  Text('Midnight Pulse', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
                  Text('Neon Shadows', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: context.colors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String url) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surfaceContainer, width: 2),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}
