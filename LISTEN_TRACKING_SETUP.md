# Listen Tracking Setup for Embed Widget

## Overview
The embed widget now tracks anonymous listens without requiring user authentication. Each play button click increments the post's listen count once per browser session.

## Step 1: Deploy SQL Functions to Supabase

1. Go to your Supabase Dashboard
2. Navigate to SQL Editor
3. Run this SQL to create the tracking functions:

```sql
-- Function to allow anonymous users to increment listen count
CREATE OR REPLACE FUNCTION increment_listen_count_anon(p_post_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_new_count integer;
    v_post_exists boolean;
BEGIN
    -- Check if post exists
    SELECT EXISTS(SELECT 1 FROM posts WHERE id = p_post_id) INTO v_post_exists;
    
    IF NOT v_post_exists THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Post not found',
            'count', 0
        );
    END IF;
    
    -- Increment the listen count atomically
    UPDATE posts 
    SET listens_count = COALESCE(listens_count, 0) + 1
    WHERE id = p_post_id
    RETURNING listens_count INTO v_new_count;
    
    -- Optional: Log the anonymous listen
    INSERT INTO post_listens (
        post_id,
        user_id,
        duration_listened,
        is_complete,
        completion_rate,
        created_at
    ) VALUES (
        p_post_id,
        NULL, -- NULL for anonymous users
        0,
        true,
        1.0,
        now()
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'count', v_new_count
    );
END;
$$;

-- Grant execute permission to anon role
GRANT EXECUTE ON FUNCTION increment_listen_count_anon(uuid) TO anon;

-- Simpler fallback version
CREATE OR REPLACE FUNCTION increment_listen_count_simple(p_post_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_new_count integer;
BEGIN
    UPDATE posts 
    SET listens_count = COALESCE(listens_count, 0) + 1
    WHERE id = p_post_id
    RETURNING listens_count INTO v_new_count;
    
    RETURN COALESCE(v_new_count, 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
$$;

GRANT EXECUTE ON FUNCTION increment_listen_count_simple(uuid) TO anon;
```

## Step 2: Deploy Updated Embed Widget

```bash
# Push to GitHub
cd /Users/pichpanharithnhek/AllProjects/GistVox-Abram/gistvox-embed-vercel
git push origin main

# Vercel will auto-deploy in ~30 seconds
```

## Step 3: Test Listen Tracking

### Test in Browser Console

1. Open: https://embed.gistvox.com/?id=00c3c293-5973-4307-9938-84669a277447
2. Open Browser DevTools (F12)
3. Click the play button
4. Check Console for: `"Tracking listen for post: ..."`
5. Check Network tab for RPC call to `increment_listen_count_anon`
6. The listen count in stats should update immediately

### Test Session Protection

1. Click play multiple times → Should only count once
2. Refresh page, click play → Should NOT count again (session storage)
3. Open incognito/private window → Should count as new listen
4. Clear session storage → Should count as new listen

### Manual Test via SQL

```sql
-- Check current listen count
SELECT id, title, listens_count 
FROM posts 
WHERE id = '00c3c293-5973-4307-9938-84669a277447';

-- Test the function directly
SELECT increment_listen_count_anon('00c3c293-5973-4307-9938-84669a277447');

-- Verify count increased
SELECT id, title, listens_count 
FROM posts 
WHERE id = '00c3c293-5973-4307-9938-84669a277447';
```

## How It Works

1. **First Play Click**: 
   - Calls `trackListen()` function
   - Checks if already tracked in session
   - Calls Supabase RPC to increment count
   - Stores flag in sessionStorage
   - Updates displayed count in UI

2. **Session Protection**:
   - Uses `sessionStorage` to prevent multiple counts
   - Key: `gistvox_listened_${postId}`
   - Persists until browser tab is closed
   - Each new tab/window = new session

3. **Anonymous Tracking**:
   - No user authentication required
   - Uses `SECURITY DEFINER` to run with function owner privileges
   - Anon role has EXECUTE permission
   - Optional logging to `post_listens` with NULL user_id

## Monitoring

### Check Listen Analytics

```sql
-- See recent anonymous listens
SELECT 
    p.title,
    COUNT(*) as anonymous_listens,
    DATE(pl.created_at) as date
FROM post_listens pl
JOIN posts p ON p.id = pl.post_id
WHERE pl.user_id IS NULL
GROUP BY p.title, DATE(pl.created_at)
ORDER BY date DESC, anonymous_listens DESC
LIMIT 20;

-- Compare embed vs app listens
SELECT 
    CASE 
        WHEN user_id IS NULL THEN 'Embed'
        ELSE 'App'
    END as source,
    COUNT(*) as listen_count
FROM post_listens
WHERE created_at > now() - interval '7 days'
GROUP BY source;
```

## Troubleshooting

### Function Not Found Error
```
Could not find function increment_listen_count_anon
```
**Solution**: Run the SQL function creation script in Step 1

### Permission Denied Error
```
permission denied for function increment_listen_count_anon
```
**Solution**: Ensure GRANT statement was executed for anon role

### Count Not Updating
- Check browser console for errors
- Verify Supabase URL and anon key are correct
- Check if post ID exists in database
- Clear session storage and try again

### Too Many Counts
- Ensure sessionStorage is working
- Check if multiple embed instances on same page
- Verify trackListen() not called multiple times

## Security Considerations

1. **Rate Limiting**: Consider adding rate limiting at Supabase level
2. **Bot Protection**: Monitor for suspicious patterns
3. **Validation**: Function validates post exists before incrementing
4. **Session-Based**: One count per browser session prevents spam

## Future Improvements

1. Track listen duration (partial vs complete)
2. Add geographic analytics
3. Track embed domain source
4. Add rate limiting per IP
5. Track unique listeners vs total listens

---

**Status**: ✅ Ready for Production

The embed widget now tracks listens just like the mobile app, but anonymously!
