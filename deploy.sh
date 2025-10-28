#!/bin/bash

echo "🚀 Deploying Gistvox Embed Widget with CSP Fix..."

# Add all changes
git add -A

# Commit with message (skip if no changes)
git commit -m "fix: CSP headers for embedding" || echo "No changes to commit"

# Push to GitHub (triggers Vercel auto-deploy)
echo "📤 Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Pushed to GitHub! Vercel will auto-deploy in ~30 seconds."
echo ""
echo "🔍 Next steps:"
echo "1. Wait 30-60 seconds for Vercel deployment"
echo "2. Check deployment at: https://vercel.com/your-username/gistvox-embed-vercel"
echo "3. Test headers: curl -I https://embed.gistvox.com"
echo "4. Test embedding in any website"
echo ""
echo "📝 If still blocked, check CSP_FIX_DEPLOY.md for alternative solutions"
