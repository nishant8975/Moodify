# Moodify - Technical Architecture & Documentation

## Overview
Moodify is an intelligent, cross-platform Flutter mobile application that generates dynamic music playlists based on a user's typed journal entry or current mood. 

To hide complex API logic and maintain secure access keys, the app utilizes **Supabase** as a Backend-as-a-Service (BaaS). A **Supabase Edge Function** acts as the core orchestration layer connecting Google's Gemini AI and the open iTunes Search API to deliver playable music streams directly to the mobile device.

---

## 1. System Architecture Diagram

```text
 ┌───────────────┐           ┌────────────────────┐
 │               │           │                    │
 │ Flutter App   │ ───────►  │  Supabase Auth &   │
 │ (UI & Audio)  │ ◄───────  │  Database (BaaS)   │
 │               │           │                    │
 └──────┬────────┘           └─────────┬──────────┘
        │                              │
        │ invoke('curate_mood')        │ (Secure DB write)
        ▼                              ▼
 ┌───────────────┐           ┌────────────────────┐
 │               │ ───────►  │ Gemini Pro API     │ (Parses journal into Acoustic Tags)
 │ Supabase Edge │ ◄───────  └────────────────────┘
 │ Function      │ 
 │               │           ┌────────────────────┐
 │ (Serverless)  │ ───────►  │ iTunes Search API  │ (Searches Tags, Returns 30s Audio)
 │               │ ◄───────  └────────────────────┘
 └───────────────┘
```

---

## 2. Tech Stack Components

### 2.1 The Frontend (Flutter)
* **`supabase_flutter`**: Used for User Authentication (Sign up, Sign in) and executing PostgreSQL queries (saving favorites, fetching playlists).
* **`flutter_dotenv`**: Safely loads public API configurations (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) from the `.env` file into the app during initialization without exposing them to source control.
* **`just_audio`** (Planned/Implemented): Native media player responsible for accepting HTTP `.m4a` streams and playing them in the UI.

### 2.2 The Backend (Supabase)
* **PostgreSQL Database**: Holds all users, historical journal entries, and tracks so that the app retains a local record of what the user listened to.
* **Row Level Security (RLS)**: Enforces that users can only query, delete, or view their *own* journals, playlists, and history. Tracks are globally accessible to all authenticated users.
* **Edge Functions (Deno / TypeScript)**: Highly-scalable API endpoints that live on Supabase servers. In our case, `curate_mood_playlist`.

### 2.3 Integration Layers (External APIs)
* **Google Gemini Pro (`generativelanguage.googleapis.com`)**: Analyzes unstructured journal text (e.g., *"I had a really rough day, it's raining and I want to sleep"*) and computes a JSON array of specific musical tags (`["sad", "lo-fi", "rain", "acoustic"]`).
* **iTunes Search API (`itunes.apple.com/search`)**: Extremely generous, completely free API that does not require an authentication token. We query this API utilizing the tags provided by Gemini. It returns Track Names, Artist Names, High-Res Cover Images, and most importantly, a `previewUrl` (a 30-second `.m4a` audio stream).

---

## 3. Core Data Flow (How It Works)

### Scenario: User generates a Playlist
1. **User Input:** The user types a text entry in the Flutter UI and clicks "Generate Music".
2. **Action Trigger:** The Flutter app calls `SupabaseService.curateMoodPlaylist()`, invoking the Supabase Edge Function over HTTPS.
3. **AI Evaluation:** The Edge Function creates a prompt holding the User's text and sends it to the **Gemini AI API**. Gemini replies with JSON containing an emotion and comma-separated genres.
4. **Music Matching:** The Edge Function takes those tags and performs an HTTP GET request to the **iTunes Search API** (`?term=lo-fi+acoustic&entity=song`).
5. **Database Sync:** The Edge Function isolates the top 10 returned tracks. It uses its internal `SERVICE_ROLE_KEY` to Upsert (Update or Insert) these track definitions into the Supabase `public.tracks` database. This ensures Moodify operates its own cached catalog of tracks.
6. **Delivery:** The Edge function returns a structured array of the tracks back to Flutter.
7. **Playback:** The Flutter UI populates its `ListView` and feeds the audio `previewUrl` to `just_audio` to begin playback.

---

## 4. Database Schema Structure

The app's persistent data is divided into relational tables:

| Table | Description |
| :--- | :--- |
| **`users`** | Synchronizes automatically via a Database Trigger when a user signs up using Supabase Auth. Stores Avatar URL, Full Name, Bio, Username, and Location. |
| **`mood_entries`** | Holds the raw text of the Journal entry the user wrote and the cached tags Gemini produced. Tied to `user_id`. |
| **`tracks`** | The central registry of every song the app has encountered. Contains the title, artist, audio stream URL, and cover picture. |
| **`playlists` & `playlist_tracks`** | Allows users to create multiple groups of Tracks. Tied to `user_id`. |
| **`favorites`** | A quick-reference lookup mapping `user_id` to a beloved `track_id`. Updates the UI in real-time. |
| **`listening_history`** | An analytics table recording every timestamp a track is played by a user. |

---

## 5. UI Integration & Screens
* **`ExploreScreen`**: Implements a live search bar that queries iTunes via the Edge Function. Users can also filter by pre-defined genre chips.
* **`ProfileScreen` & `EditProfileScreen`**: Allows users to view and update their personalized account metadata stored in the `public.users` table.
* **`PlaylistScreen` (Library)**: Fetches and displays a user's `favorites` and past `mood_entries` as a personalized music library.
* **`JournalEntryScreen` & `MoodSelectionScreen`**: The entry points for the AI music curation flow. Writes to `mood_entries` and triggers playlist generation.

---

## 6. Environment & Running the App

### Requirements
1. **Flutter SDK**
2. **Supabase Account** configured with the SQL Schema.
3. **Google AI Studio Key** (`GEMINI_API_KEY`).

### Configuration Checklist
The Flutter project requires a `.env` file in the root directory formatted as:
```env
SUPABASE_URL=https://<your-project-id>.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

The Supabase Edge Function requires the secret added to the Supabase Cloud dashboard to function properly:
```
# Added via Supabase Dashboard -> Edge Functions -> Secrets
GEMINI_API_KEY=AIzaSyB...
```

To run the application locally:
```bash
flutter pub get
flutter run
```
