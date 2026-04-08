import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        _fullNameController.text = response['full_name'] ?? '';
        _usernameController.text = response['username'] ?? '';
        _bioController.text = response['bio'] ?? '';
        _locationController.text = response['location'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('users').upsert({
        'id': user.id,
        'full_name': _fullNameController.text,
        'username': _usernameController.text,
        'bio': _bioController.text,
        'location': _locationController.text,
        'email': user.email,
        'avatar_url': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=300&q=80', // Keep existing for now
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.colors.surface.withOpacity(0.4),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.primaryContainer),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: AmbientGlow(color: context.colors.primary, width: 400, height: 400, blurRadius: 120),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: AmbientGlow(color: context.colors.secondary, width: 400, height: 400, blurRadius: 120),
          ),
          
          SafeArea(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    // Profile Photo
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [context.colors.primary, context.colors.secondary]),
                                  boxShadow: [BoxShadow(color: context.colors.primaryContainer, blurRadius: 40, spreadRadius: -20)],
                                ),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: context.colors.onSurface.withOpacity(0.24), width: 2),
                                    image: const DecorationImage(
                                      image: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=300&q=80'),
                                      fit: BoxFit.cover,
                                    )
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.edit, color: context.colors.onPrimaryContainer, size: 20),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('Change Profile Photo', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Form Fields
                    _buildInputField(context, 'FULL NAME', _fullNameController, Icons.person),
                    const SizedBox(height: 24),
                    _buildInputField(context, 'USERNAME', _usernameController, Icons.alternate_email, prefixText: '@ '),
                    const SizedBox(height: 24),
                    _buildInputField(context, 'BIO', _bioController, null, maxLines: 3),
                    const SizedBox(height: 24),
                    _buildInputField(context, 'LOCATION', _locationController, Icons.location_on),
                    
                    const SizedBox(height: 48),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [context.colors.primary, context.colors.inversePrimary]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: context.colors.primary.withOpacity(0.3), blurRadius: 30, offset: Offset(0, 10))],
                          ),
                          alignment: Alignment.center,
                          child: Text('Save Changes', style: TextStyle(color: context.colors.onPrimaryFixed, fontSize: 18, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
          )
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, TextEditingController controller, IconData? icon, {int maxLines = 1, String? prefixText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.primary.withOpacity(0.8), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (prefixText != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 4),
                  child: Text(prefixText, style: TextStyle(color: context.colors.primaryDim, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  style: TextStyle(color: context.colors.onSurface, fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 16 : 0),
                  ),
                ),
              ),
              if (icon != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Icon(icon, color: context.colors.onSurfaceVariant),
                )
            ],
          ),
        ),
      ],
    );
  }
}
