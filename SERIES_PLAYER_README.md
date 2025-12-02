# GistVox Embed Player - Deployment Guide

This repository contains two separate embed players for GistVox:

1. **Single Post Player** (`index.html`) - Original player for individual audio posts
2. **Series Player** (`series.html`) - NEW Spotify-style playlist player for series/stories

## 🎵 Single Post Player

### Features
- Clean, card-style UI
- Audio playback controls with skip forward/backward
- Progress bar with drag-to-seek
- Share and "Open in App" buttons
- Animated visualizer when playing
- Engagement stats display
- Listen tracking via Supabase

### Usage

```html
<iframe 
  src="https://embed.gistvox.com/?id=POST_ID_HERE"
  style="width:100%;height:500px;border:0;"
  allow="autoplay; clipboard-write"
  loading="lazy"
  title="Gistvox Audio">
</iframe>
```

### URL Parameters
- `id` (required) - The post UUID
- `theme` - `light` or `dark` (default: light)
- `minimal` - `true` to hide branding and stats (default: false)
- `autoplay` - `true` to auto-play (default: false)

### Example
```
https://embed.gistvox.com/?id=1f7ded1f-1513-4f0f-b895-23ae728bf1d8&theme=light&minimal=false
```

---

## 🎼 Series Player (NEW - Spotify Style)

### Features
- **Spotify-inspired dark theme UI**
- Large album-style cover art display
- Complete series metadata (creator, year, stats)
- Chapter list with play counts and durations
- Fixed bottom player bar (Spotify-style)
- Sequential playback (auto-advances to next chapter)
- Previous/Next track controls
- Progress bar with click-to-seek and drag support
- Share functionality
- Individual chapter listen tracking

### Usage

```html
<iframe 
  src="https://embed.gistvox.com/series?id=SERIES_ID_HERE"
  style="width:100%;height:700px;border:0;"
  allow="autoplay; clipboard-write"
  loading="lazy"
  title="Gistvox Series Player">
</iframe>
```

### URL Parameters
- `id` (required) - The series UUID
- `autoplay` - `true` to auto-play from first chapter (default: false)

### Example
```
https://embed.gistvox.com/series?id=550e8400-e29b-41d4-a716-446655440000
```

### UI Components

#### Header Section
- 232x232px cover image (or icon fallback)
- Series title (large, bold)
- Series description (3-line clamp)
- Creator info with avatar
- Stats: year, chapter count, total duration, total listens

#### Chapter List
- Grid layout showing:
  - Chapter number with play button on hover
  - Chapter title and creator name
  - Listen count (formatted with commas)
  - Duration (MM:SS format)
- Highlights currently playing chapter
- Click any chapter to play

#### Fixed Player Bar (Bottom)
- Now playing info (cover + title)
- Playback controls (prev, play/pause, next)
- Progress bar with time display
- Responsive design

---

## 📊 Database Structure

### Series Table
Based on `supabase-schema.json`:

```sql
series (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES users(id),
  title varchar(255),
  description text,
  cover_image_url text,
  tags jsonb,
  total_chapters integer,
  total_duration integer,
  is_complete boolean,
  created_at timestamp,
  updated_at timestamp
)
```

### Posts Table (Chapters)
Posts linked to series via:

```sql
posts (
  id uuid PRIMARY KEY,
  series_id uuid REFERENCES series(id),
  chapter_number integer,
  chapter_title varchar(255),
  audio_url text,
  audio_duration integer,
  listens_count integer,
  -- ... other post fields
)
```

---

## 🚀 Deployment

### Vercel Deployment

1. **Push to GitHub**
```bash
git add .
git commit -m "Add Spotify-style series player"
git push origin main
```

2. **Deploy Script**
```bash
./deploy.sh
```

Or manually:
```bash
vercel --prod
```

### File Structure
```
gistvox-embed-vercel/
├── index.html           # Single post player
├── series.html          # Series player (NEW)
├── embed.html           # Single post embed example
├── embed-series.html    # Series embed example (NEW)
├── favicon.ico
├── vercel.json
└── README.md           # This file
```

---

## 🎨 Design Philosophy

### Single Post Player
- **Inspiration**: Modern audio card UI (SoundCloud, Twitter audio)
- **Theme**: Light, clean, mobile-first
- **Use Case**: Sharing individual audio posts

### Series Player
- **Inspiration**: Spotify Web Player
- **Theme**: Dark, immersive, desktop-optimized
- **Use Case**: Sharing complete series/audiobook/podcast-style content

---

## 🔧 Configuration

### Supabase Setup
Update these constants in both players:

```javascript
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```

### Required Supabase Function
Both players use the `track_embed_listen` function:

```sql
CREATE OR REPLACE FUNCTION track_embed_listen(p_post_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_count integer;
BEGIN
  -- Increment listens_count
  UPDATE posts 
  SET listens_count = listens_count + 1 
  WHERE id = p_post_id;
  
  -- Get new count
  SELECT listens_count INTO v_count 
  FROM posts 
  WHERE id = p_post_id;
  
  RETURN jsonb_build_object('success', true, 'count', v_count);
END;
$$;
```

---

## 📱 Responsive Design

### Single Post Player
- Optimized for: 320px - 480px (mobile primary)
- Breakpoint: 480px
- Max width: 380px

### Series Player
- Optimized for: 768px+ (desktop/tablet primary)
- Breakpoint: 768px
- Max width: 900px
- Mobile: Stacked layout, simplified chapter list

---

## 🧪 Testing

### Single Post
1. Open `embed.html` in browser
2. Or use: `https://embed.gistvox.com/?id=VALID_POST_ID`

### Series
1. Open `embed-series.html` in browser
2. Replace `YOUR_SERIES_ID_HERE` with valid series UUID
3. Or use: `https://embed.gistvox.com/series?id=VALID_SERIES_ID`

---

## 📝 Notes

- Both players are **completely independent**
- No shared code between players
- Series player does NOT affect single post functionality
- Both use same Supabase backend
- Both support listen tracking
- Both work in iframe embeds
- Both support share functionality

---

## 🐛 Troubleshooting

### "Series not found"
- Check series UUID is valid 36-character UUID
- Verify series exists in Supabase `series` table
- Check Supabase permissions (RLS policies)

### "No chapters loading"
- Verify posts are linked to series via `series_id`
- Check `chapter_number` is set on posts
- Ensure posts have `audio_url` populated

### Player bar not showing
- Player bar appears only after playing a chapter
- Check browser console for errors
- Verify audio URL is accessible

### Share not working
- Check clipboard permissions
- Mobile: Should use native share API
- Desktop: Falls back to clipboard copy

---

## 🎯 Future Enhancements

### Possible additions:
- [ ] Volume control in series player
- [ ] Shuffle and repeat modes
- [ ] Download chapter option
- [ ] Queue management
- [ ] Playback speed control
- [ ] Sleep timer
- [ ] Keyboard shortcuts

---

## 📄 License

Proprietary - GistVox Inc.

---

## 👥 Support

For issues or questions:
- Email: support@gistvox.com
- Docs: https://docs.gistvox.com

---

**Last Updated**: December 2025

