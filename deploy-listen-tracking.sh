#!/bin/bash

# Deploy listen tracking updates to Vercel
echo "🎵 Deploying Gistvox Embed with Listen Tracking..."

# Commit any remaining changes
git add -A
git commit -m "feat: Listen tracking implementation" || echo "No new changes to commit"

# Push to GitHub (Vercel will auto-deploy)
echo "📤 Pushing to GitHub..."
git push origin main

echo "✅ Pushed to GitHub! Vercel will auto-deploy in ~30 seconds."
echo ""
echo "📊 Next Steps:"
echo "1. Run the SQL function in Supabase (see LISTEN_TRACKING_SETUP.md)"
echo "2. Test at: https://embed.gistvox.com/?id=00c3c293-5973-4307-9938-84669a277447"
echo "3. Open DevTools Console to see tracking logs"
echo "4. Check Supabase Dashboard for updated listen counts"
echo ""
echo "🎉 Listen tracking is ready!"
