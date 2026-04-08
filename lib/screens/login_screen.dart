import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_glow.dart';
import '../widgets/glass_container.dart';
import 'mood_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MoodSelectionScreen()),
        );
      }
    } on AuthException catch (e) {
      setState(() { _errorMessage = e.message; });
    } catch (e) {
      setState(() { _errorMessage = 'An unexpected error occurred'; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -50, left: -50,
            child: AmbientGlow(color: context.colors.primary, width: 400, height: 400, blurRadius: 150),
          ),
          Positioned(
            bottom: -100, right: -50,
            child: AmbientGlow(color: context.colors.secondary, width: 450, height: 450, blurRadius: 150),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: context.colors.primary.withOpacity(0.4), blurRadius: 30)],
                      ),
                      child: Icon(Icons.graphic_eq, color: context.colors.onPrimaryContainer, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text('Moodify', style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp ? 'Create your account.' : 'Synchronize your sound to your soul.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 40),
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(context, 'Email Address', Icons.alternate_email, 'name@domain.com', false, _emailController),
                          const SizedBox(height: 24),
                          _buildTextField(context, 'Password', Icons.lock, '••••••••', true, _passwordController),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(_errorMessage!, style: TextStyle(color: context.colors.error, fontSize: 13)),
                          ],
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 10,
                              shadowColor: context.colors.primary.withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: context.colors.onPrimaryContainer, strokeWidth: 2))
                                : Text(
                                    _isSignUp ? 'Create Account' : 'Sign In',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: context.colors.onPrimaryContainer),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => setState(() { _isSignUp = !_isSignUp; _errorMessage = null; }),
                      child: RichText(
                        text: TextSpan(
                          text: _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: _isSignUp ? 'Sign In' : 'Create Account',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.secondary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon, String hint, bool isPassword, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            if (isPassword)
              Text('FORGOT?', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.onSurfaceVariant.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: context.colors.onSurfaceVariant),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: context.colors.onSurfaceVariant),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: context.colors.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
          style: TextStyle(color: context.colors.onSurface),
        ),
      ],
    );
  }
}
