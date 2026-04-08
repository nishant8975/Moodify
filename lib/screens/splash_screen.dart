import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import 'login_screen.dart';
import 'mood_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => session != null ? const MoodSelectionScreen() : const LoginScreen(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 50, left: 50, child: AmbientGlow(color: context.colors.primary, width: 300, height: 300, blurRadius: 100)),
          Positioned(bottom: -50, right: -50, child: AmbientGlow(color: context.colors.secondary, width: 350, height: 350, blurRadius: 120)),
          Positioned(top: 300, right: -50, child: AmbientGlow(color: context.colors.tertiary, width: 250, height: 250, blurRadius: 80)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) => Transform.scale(scale: 1.0 + (_animController.value * 0.05), child: child),
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 2),
                      color: context.colors.primaryContainer.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _bar(context.colors.primary, 30),
                          const SizedBox(width: 6),
                          _bar(context.colors.primaryContainer, 60),
                          const SizedBox(width: 6),
                          _bar(context.colors.secondary, 90),
                          const SizedBox(width: 6),
                          _bar(context.colors.primaryContainer, 50),
                          const SizedBox(width: 6),
                          _bar(context.colors.primary, 70),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Text('Moodify', style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  shadows: [Shadow(color: context.colors.onSurface.withOpacity(0.5), blurRadius: 20)],
                )),
                const SizedBox(height: 16),
                Text('Music that understands your mood',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(Color color, double height) => Container(
    width: 6, height: height,
    decoration: BoxDecoration(
      color: color, borderRadius: BorderRadius.circular(3),
      boxShadow: [BoxShadow(color: color.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)],
    ),
  );
}
