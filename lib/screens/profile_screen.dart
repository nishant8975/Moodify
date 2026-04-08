import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/glass_container.dart';
import '../main.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _userData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _email => Supabase.instance.client.auth.currentUser?.email ?? 'User';
  String get _displayName => _userData?['full_name'] ?? _email.split('@').first;
  String? get _avatarUrl => _userData?['avatar_url'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: context.colors.surfaceContainerHigh.withOpacity(0.6)),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.primaryContainer),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: context.colors.primaryContainer), onPressed: _loadUserData),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: AmbientGlow(color: context.colors.primary, width: 400, height: 400, blurRadius: 150),
          ),
          
          SafeArea(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    // User Header
                    GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(32),
                      color: context.colors.surfaceContainer.withOpacity(0.6),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [context.colors.primary, context.colors.tertiary]),
                                  boxShadow: [BoxShadow(color: context.colors.primary.withOpacity(0.5), blurRadius: 40)],
                                ),
                              ),
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: context.colors.onSurface.withOpacity(0.1), width: 4),
                                  image: DecorationImage(
                                    image: NetworkImage(_avatarUrl ?? 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=300&q=80'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(_displayName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(_email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer.withOpacity(0.2),
                              border: Border.all(color: context.colors.primary.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium, color: context.colors.primary, size: 16),
                                const SizedBox(width: 8),
                                Text('PREMIUM MEMBER', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Appearance Section
                    _buildSectionHeader(context, 'APPEARANCE'),
                    const SizedBox(height: 8),
                    _buildSettingsTile(
                      context, 
                      title: 'Light Mode', 
                      icon: Icons.dark_mode, 
                      iconColor: context.colors.primary,
                      trailing: ValueListenableBuilder<ThemeMode>(
                        valueListenable: themeNotifier,
                        builder: (_, mode, _) {
                          return Switch(
                            value: mode == ThemeMode.light,
                            onChanged: (val) {
                              themeNotifier.value = val ? ThemeMode.light : ThemeMode.dark;
                            },
                            activeThumbColor: context.colors.primary,
                            activeTrackColor: context.colors.primary.withOpacity(0.3),
                          );
                        }
                      ),
                      isTop: true,
                      isBottom: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Account Settings
                    _buildSectionHeader(context, 'ACCOUNT SETTINGS'),
                    const SizedBox(height: 8),
                    _buildSettingsTile(
                      context, 
                      title: 'Personal Information', 
                      icon: Icons.person, 
                      iconColor: context.colors.primary,
                      trailing: Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
                      isTop: true,
                      onTap: () async {
                        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                        _loadUserData();
                      },
                    ),
                    _buildSettingsTile(
                      context, 
                      title: 'Email & Security', 
                      icon: Icons.security, 
                      iconColor: context.colors.secondary,
                      trailing: Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
                    ),
                    _buildSettingsTile(
                      context, 
                      title: 'Subscription Plan', 
                      icon: Icons.card_membership, 
                      iconColor: context.colors.tertiary,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Monthly Pro', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
                        ],
                      ),
                      isBottom: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sound Settings
                    _buildSectionHeader(context, 'SOUND SETTINGS'),
                    const SizedBox(height: 8),
                    _buildSettingsTile(
                      context, 
                      title: 'Audio Quality', 
                      icon: Icons.high_quality, 
                      iconColor: context.colors.primary,
                      trailing: Text('Ultra (Hi-Res)', style: TextStyle(color: context.colors.primary, fontSize: 14)),
                      isTop: true,
                    ),
                    _buildSettingsTile(
                      context, 
                      title: 'Equalizer', 
                      icon: Icons.equalizer, 
                      iconColor: context.colors.secondary,
                      trailing: Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
                    ),
                    _buildSettingsTile(
                      context, 
                      title: 'Spatial Audio', 
                      icon: Icons.spatial_audio, 
                      iconColor: context.colors.tertiary,
                      trailing: Switch(
                        value: true,
                        onChanged: (val) {},
                        activeThumbColor: context.colors.secondary,
                        activeTrackColor: context.colors.secondary.withOpacity(0.3),
                      ),
                      isBottom: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // App Settings
                    _buildSectionHeader(context, 'APP SETTINGS'),
                    const SizedBox(height: 8),
                    _buildSettingsTile(
                      context, 
                      title: 'Data Saver', 
                      icon: Icons.data_saver_on, 
                      iconColor: context.colors.primary,
                      trailing: Switch(
                        value: false,
                        onChanged: (val) {},
                        activeThumbColor: context.colors.primary,
                      ),
                      isTop: true,
                    ),
                    _buildSettingsTile(
                      context, 
                      title: 'Notifications', 
                      icon: Icons.notifications, 
                      iconColor: context.colors.secondary,
                      trailing: Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
                    ),
                    _buildSettingsTile(
                      context, 
                      title: 'Playback Settings', 
                      icon: Icons.play_circle, 
                      iconColor: context.colors.tertiary,
                      trailing: Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
                      isBottom: true,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Danger Zone
                    GestureDetector(
                      onTap: () {},
                      child: GlassContainer(
                        color: context.colors.errorContainer.withOpacity(0.1),
                        border: Border.all(color: context.colors.error.withOpacity(0.1)),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.colors.errorContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.restart_alt, color: context.colors.error),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reset All Preferences', style: TextStyle(color: context.colors.error, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('Restore all settings to their factory defaults', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: Icon(Icons.logout, color: context.colors.onSurface),
                      label: Text('Logout', style: TextStyle(color: context.colors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                    ).wrapWithGradient(context),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
          )
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }
  
  Widget _buildSettingsTile(BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget trailing,
    bool isTop = false,
    bool isBottom = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow.withOpacity(0.4),
        border: Border(
          bottom: isBottom ? BorderSide.none : BorderSide(color: context.colors.onSurface.withOpacity(0.1), width: 1),
        ),
        borderRadius: BorderRadius.vertical(
          top: isTop ? Radius.circular(16) : Radius.zero,
          bottom: isBottom ? Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.vertical(
            top: isTop ? Radius.circular(16) : Radius.zero,
            bottom: isBottom ? Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension GradientButton on ElevatedButton {
  Widget wrapWithGradient(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary, context.colors.inversePrimary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: context.colors.primary.withOpacity(0.3), blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: this,
    );
  }
}
