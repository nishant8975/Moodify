import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/track_model.dart';
import 'home_screen.dart';
import 'playlist_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final List<TrackModel> initialTracks;
  final String initialMood;

  const MainScreen({super.key, this.initialTracks = const [], this.initialMood = ''});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<TrackModel> tracks;
  late String mood;

  @override
  void initState() {
    super.initState();
    tracks = widget.initialTracks;
    mood = widget.initialMood;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(tracks: tracks, mood: mood),
              ExploreScreen(),
              PlaylistScreen(),
              ProfileScreen(),
            ],
          ),
          // Custom Bottom Navigation Bar
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerLow.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [BoxShadow(color: context.colors.primary.withOpacity(0.1), blurRadius: 50, offset: const Offset(0, 20))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.home, 'Home'),
                        _buildNavItem(1, Icons.search, 'Search'),
                        _buildNavItem(2, Icons.library_music, 'Library'),
                        _buildNavItem(3, Icons.person, 'Profile'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected ? [BoxShadow(color: context.colors.primary.withOpacity(0.4), blurRadius: 15)] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? context.colors.primary : context.colors.onSurface.withOpacity(0.5)),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? context.colors.primary : context.colors.onSurface.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
