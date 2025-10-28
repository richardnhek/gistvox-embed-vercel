# Deploy Gistvox Embed to Vercel - Step by Step

## Step 1: Push to GitHub

```bash
# Create repo on GitHub first (via GitHub.com)
# Name: gistvox-embed-vercel

# Then in terminal:
cd /Users/pichpanharithnhek/AllProjects/GistVox-Abram/gistvox-embed-vercel

# Add GitHub remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/gistvox-embed-vercel.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 2: Deploy to Vercel

### Option A: Connect GitHub Repo (Recommended)
1. Go to https://vercel.com/new
2. Import Git Repository
3. Select `gistvox-embed-vercel`
4. Deploy (it will auto-detect settings from vercel.json)

### Option B: Direct CLI Deploy
```bash
cd /Users/pichpanharithnhek/AllProjects/GistVox-Abram/gistvox-embed-vercel
npx vercel --prod

# When asked:
# - Set up and deploy? Y
# - Which scope? (select yours)
# - Link to existing project? N
# - Project name? gistvox-embed
# - Directory? ./
# - Override? N
```

## Step 3: Add Custom Domain

1. In Vercel Dashboard → Your Project → Settings → Domains
2. Add domain: `embed.gistvox.com`
3. It will show DNS instructions

## Step 4: Update DNS

In your DNS provider, change from GitHub Pages to Vercel:

**Remove:**
```
CNAME embed → YOUR_USERNAME.github.io
```

**Add:**
```
CNAME embed → cname.vercel-dns.com
```

## Step 5: Verify Everything Works

After 5-10 minutes for DNS propagation:

```bash
# Check headers are correct
curl -I https://embed.gistvox.com | grep -i frame-options
# Should show: x-frame-options: ALLOWALL

# Test different post IDs
open https://embed.gistvox.com/?id=402de1d5-9796-4095-8511-46c27069481d
open https://embed.gistvox.com/?id=00c3c293-5973-4307-9938-84669a277447

# Each should show DIFFERENT posts now!
```

## Step 6: Test Embedding

Create a test HTML file:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Embed Test</title>
</head>
<body>
    <h1>Testing Different Posts</h1>
    
    <h2>Post 1</h2>
    <iframe src="https://embed.gistvox.com/?id=402de1d5-9796-4095-8511-46c27069481d"
            width="100%" height="500" frameborder="0"></iframe>
    
    <h2>Post 2</h2>
    <iframe src="https://embed.gistvox.com/?id=00c3c293-5973-4307-9938-84669a277447"
            width="100%" height="500" frameborder="0"></iframe>
</body>
</html>
```

## What's Fixed

✅ **Dynamic Post IDs**: Now reads from URL parameter instead of hardcoded
✅ **Proper Headers**: Vercel allows full embedding control
✅ **Clean Separation**: Embed has its own repo, not mixed with Flutter
✅ **Auto-Deploy**: Push to GitHub → Auto deploys to Vercel

## Future Updates

To update the embed widget:
```bash
# Make changes to index.html
git add .
git commit -m "Update: description of changes"
git push origin main

# Vercel auto-deploys in ~30 seconds
```

## Troubleshooting

If embeds still show same post:
1. Clear browser cache (Cmd+Shift+R)
2. Check URL has `?id=` parameter
3. Verify in Network tab that correct ID is being fetched

If embeds are blocked:
1. Check `curl -I https://embed.gistvox.com`
2. Must see `X-Frame-Options: ALLOWALL`
3. If not, check vercel.json is deployed

---

**DO THIS NOW**: The separate repo is ready. Deploy to Vercel and update DNS!
