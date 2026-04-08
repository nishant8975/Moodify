import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Authentication
  Future<AuthResponse> signUpWithEmail(String email, String password, String fullName) async {
    return await _client.auth.signUp(
      email: email, 
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Database interactions
  Future<void> saveMoodEntry(String moodName, String journalNote, String generatedTags) async {
    await _client.from('mood_entries').insert({
      'user_id': _client.auth.currentUser!.id,
      'mood_name': moodName,
      'journal_note': journalNote,
      'generated_tags': generatedTags,
    });
  }

  Future<List<Map<String, dynamic>>> getPlaylists() async {
    return await _client.from('playlists').select();
  }

  Future<void> toggleFavorite(String trackId) async {
    final userId = _client.auth.currentUser!.id;
    // Check if it already exists
    final response = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('track_id', trackId)
        .maybeSingle();

    if (response == null) {
      // Not favorited, string to add
      await _client.from('favorites').insert({
        'user_id': userId,
        'track_id': trackId,
      });
    } else {
      // Already favorited, delete it
      await _client.from('favorites').delete()
          .eq('user_id', userId)
          .eq('track_id', trackId);
    }
  }

  Future<void> logListeningHistory(String trackId) async {
    await _client.from('listening_history').insert({
      'user_id': _client.auth.currentUser!.id,
      'track_id': trackId,
    });
  }

  // Invoking Edge Function (which we will create for the API curation)
  Future<List<Map<String, dynamic>>> curateMoodPlaylist(String journalText) async {
    final response = await _client.functions.invoke(
      'curate_mood_playlist',
      body: {'journal_text': journalText},
    );
    // Assuming the function returns a list of tracks
    return List<Map<String, dynamic>>.from(response.data);
  }
}
