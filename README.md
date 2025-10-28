# Gistvox Embed Widget

Embeddable audio player for Gistvox posts that can be integrated into any website.

## Live URL
https://embed.gistvox.com

## Usage

### Basic Embed
```html
<iframe src="https://embed.gistvox.com/?id=POST_ID"
        width="100%" 
        height="500"
        frameborder="0"
        allow="autoplay; clipboard-write"
        loading="lazy"></iframe>
```

### Parameters
- `id` (required): Post ID to embed
- `theme`: `light` or `dark` (default: light)
- `minimal`: `true` for minimal UI (default: false)
- `autoplay`: `true` to autoplay (default: false)

### Example
```html
<iframe src="https://embed.gistvox.com/?id=402de1d5-9796-4095-8511-46c27069481d&theme=dark&minimal=true"
        width="100%" 
        height="400"
        frameborder="0"></iframe>
```

## Development

### Local Development
```bash
# Install dependencies (if any)
npm install

# Run locally
npx serve

# Open http://localhost:3000
```

### Deployment
```bash
# Deploy to Vercel
vercel --prod

# Or push to GitHub and auto-deploy
git push origin main
```

## Platform Compatibility

✅ **Supported**
- WordPress (self-hosted)
- WordPress.com (Business plan+)
- Webflow
- Squarespace
- Wix
- Ghost
- Shopify
- Static HTML sites

❌ **Not Supported**
- Medium (whitelist only)
- Notion (whitelist only)

## Security Headers

The `vercel.json` configuration ensures:
- `X-Frame-Options: ALLOWALL` - Allows embedding on any domain
- `Content-Security-Policy: frame-ancestors *` - Modern embedding permission
- `Access-Control-Allow-Origin: *` - CORS support

## Files

- `index.html` - Main embed widget
- `vercel.json` - Vercel configuration with headers
- `README.md` - This file

## Testing

Test embed at: https://embed.gistvox.com/test.html

## License

© 2024 Gistvox. All rights reserved.
