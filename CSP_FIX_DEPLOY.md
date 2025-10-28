# CSP Header Fix for Embed Widget

## Problem
The embed widget was being blocked with error:
```
Refused to frame 'https://embed.gistvox.com/' because an ancestor violates the following Content Security Policy directive: "frame-ancestors *"
```

## Root Causes
1. **Invalid X-Frame-Options header**: `ALLOWALL` is not a valid value
2. **CSP frame-ancestors conflict**: Having both X-Frame-Options and CSP can cause conflicts

## Solution Applied

### Updated vercel.json
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "frame-ancestors *"
        },
        {
          "key": "Access-Control-Allow-Origin",
          "value": "*"
        },
        // ... other headers
      ]
    }
  ]
}
```

### Key Changes
1. **Removed X-Frame-Options header entirely** - CSP frame-ancestors supersedes it
2. **Simplified CSP to `frame-ancestors *`** - Allows embedding from any origin

## Deploy Now

```bash
# Push to GitHub (triggers Vercel auto-deploy)
git push origin main

# Or manually deploy with Vercel CLI
vercel --prod
```

## Verify Headers After Deploy

```bash
# Check headers are correct
curl -I https://embed.gistvox.com

# Should see:
# Content-Security-Policy: frame-ancestors *
# (No X-Frame-Options header)
```

## Test Embedding

Create a test HTML file locally:
```html
<!DOCTYPE html>
<html>
<head><title>Embed Test</title></head>
<body>
  <h1>Testing Gistvox Embed</h1>
  <iframe 
    src="https://embed.gistvox.com/?id=00c3c293-5973-4307-9938-84669a277447"
    width="400"
    height="600"
    frameborder="0">
  </iframe>
</body>
</html>
```

## Alternative Solutions (If Still Blocked)

### Option 1: Most Permissive CSP
```json
{
  "key": "Content-Security-Policy",
  "value": "frame-ancestors 'self' http: https: data: blob: 'unsafe-inline' 'unsafe-eval';"
}
```

### Option 2: No CSP Headers At All
Remove the CSP header entirely and let browsers default to allowing embedding:
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Access-Control-Allow-Origin",
          "value": "*"
        },
        {
          "key": "Access-Control-Allow-Methods",
          "value": "GET, POST, OPTIONS"
        }
        // No CSP or X-Frame-Options
      ]
    }
  ]
}
```

### Option 3: Use Vercel Edge Function (Advanced)
If static headers don't work, create a middleware to dynamically set headers:
```javascript
// middleware.js
export default function middleware(request) {
  const response = NextResponse.next();
  
  // Remove any conflicting headers
  response.headers.delete('X-Frame-Options');
  
  // Set permissive CSP
  response.headers.set('Content-Security-Policy', "frame-ancestors *");
  
  return response;
}
```

## Why This Fix Works

1. **CSP supersedes X-Frame-Options**: Modern browsers prioritize CSP over X-Frame-Options
2. **`frame-ancestors *`**: Explicitly allows embedding from any origin
3. **No conflicts**: Removing X-Frame-Options eliminates header conflicts
4. **Vercel compatibility**: This configuration works with Vercel's header system

## Important Notes

- **Security Trade-off**: Allowing all origins means anyone can embed your widget
- **Cache**: May take 5-10 minutes for CDN cache to clear
- **Testing**: Always test in incognito/private mode to avoid cache issues

---

**Status**: Ready to deploy! Push to GitHub or run `vercel --prod`
