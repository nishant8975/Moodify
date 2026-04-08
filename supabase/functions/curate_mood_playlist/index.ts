import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") || "";
const JAMENDO_CLIENT_ID = Deno.env.get("JAMENDO_CLIENT_ID") || "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  journal_text: string;
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { journal_text } = await req.json() as RequestBody;

    if (!journal_text) {
      throw new Error("Missing journal_text constraint");
    }

    // 1. Send text to Gemini to extract mood/tags
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GEMINI_API_KEY}`;
    const geminiPrompt = `
      The user wrote a journal entry about their mood:
      "${journal_text}"
      
      Based on this, return a JSON string containing an acoustic feeling.
      Output ONLY valid JSON like this:
      {
        "mood": "happy",
        "tags": ["pop", "upbeat", "dance"]
      }
    `;

    const geminiRes = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: geminiPrompt }] }],
      }),
    });

    if (!geminiRes.ok) {
       console.error("Gemini failed");
       throw new Error("Failed to communicate with AI");
    }

    const geminiData = await geminiRes.json();
    let aiResponseText = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text;
    
    // Clean markdown if wrapped in ```json
    aiResponseText = aiResponseText.replace(/```json/g, '').replace(/```/g, '').trim();
    const parsedMood = JSON.parse(aiResponseText);
    const tags = Array.isArray(parsedMood.tags) ? parsedMood.tags.join("+") : "lofi";

    // 2. Fetch tracks from iTunes Search API (Zero Auth Required!)
    // We append the mood/tags to the search term
    const itunesUrl = `https://itunes.apple.com/search?term=${encodeURIComponent(tags)}&entity=song&limit=15`;
    const itunesRes = await fetch(itunesUrl);
    
    if (!itunesRes.ok) throw new Error("Failed to fetch music from iTunes");
    
    const itunesData = await itunesRes.json();
    let tracksBuffer = itunesData.results?.filter((t: any) => !!t.previewUrl) || [];
    tracksBuffer = tracksBuffer.slice(0, 10);

    // 3. Sync to Supabase Database using Service Role (to bypass RLS for UPSERT)
    // Map iTunes tracks to our DB schema
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    
    const dbTracks = tracksBuffer.map((t: any) => ({
      id: "itunes_" + t.trackId,
      title: t.trackName || 'Unknown',
      artist: t.artistName || 'Unknown',
      audio_url: t.previewUrl || '',
      cover_url: t.artworkUrl100?.replace('100x100bb', '300x300bb') || null, // Get higher resolution cover
      duration_seconds: Math.floor((t.trackTimeMillis || 0) / 1000),
      genre: t.primaryGenreName || parsedMood.mood || "Unknown",
    }));

    if (dbTracks.length > 0) {
      const { error } = await supabase.from('tracks').upsert(dbTracks, { onConflict: 'id' });
      if (error) console.error("Error upserting tracks:", error);
    }

    // 4. Return the tracks to Flutter
    return new Response(JSON.stringify(dbTracks), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error: any) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
