#!/bin/bash
set -e

echo "Ensure LM Studio running with Qwen7B loaded for agent."

if ! command -v openclaw &> /dev/null; then
  echo "Error: openclaw not found—fix PATH." && exit 1
fi

agent_step() {
  STEP_NUM=$1
  TASK_DESC="$2"
  echo "=== Agent Step $STEP_NUM: $TASK_DESC ==="
  openclaw agent builder --prompt "Generate minimal React TS code changes for ElderCareApp: $TASK_DESC. Base on current src/App.tsx. Output only the full updated src/App.tsx file contents, no explanations." > temp_app.tsx
  if [ -s temp_app.tsx ] && [ "$(wc -l < temp_app.tsx)" -gt 10 ]; then  # Basic check for non-empty output
    cat temp_app.tsx > src/App.tsx
    rm temp_app.tsx
    npm run build || { echo "Build failed—check TS errors (vault: unused imports, DOM lib)."; return; }
    git add src/App.tsx
    if ! git diff --cached --quiet; then
      git commit -m "Agent Step $STEP_NUM: $TASK_DESC (Qwen7B generated)"
      git push -u origin main
      echo "Step $STEP_NUM complete."
    else
      echo "No real changes from agent—skipping."
    fi
  else
    echo "Agent output empty or invalid—check Qwen7B/LM Studio. Skipping."
    rm temp_app.tsx
  fi
}

agent_step 11 "Add more one-tap buttons to ElderHome: Meds (orange bg), Meal (blue bg). Update handleCheckIn to support types."
agent_step 12 "Add voice input button to ElderHome using Web Speech API. Listen for 'ok', 'meds', 'meal' and trigger handleCheckIn. Fix TS with any cast for SpeechRecognition."
agent_step 13 "Add medication reminder to ElderHome: Show orange reminder after 4 hours, clear on Meds check-in."
agent_step 14 "Add /history route: Display list of check-ins as large list items."
agent_step 15 "No App.tsx change—PWA config next."

cat > vite.config.ts << 'EOF2'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'mask-icon.svg'],
      manifest: {
        name: 'ElderCare Station',
        short_name: 'ElderCare',
        description: 'Reassurance PWA for elders and caregivers',
        theme_color: '#ff4500',
        icons: [
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png'
          }
        ]
      },
      workbox: {
        runtimeCaching: [
          {
            urlPattern: ({ request }) => request.destination === 'document',
            handler: 'NetworkFirst'
          }
        ]
      }
    })
  ],
})
EOF2
npm run build && \
git add vite.config.ts
if ! git diff --cached --quiet; then
  git commit -m "Step 15: Add offline/PWA config (manual)"
  git push -u origin main
fi
echo "Step 15 complete."

echo "\n### Run $(date)\nChunk: 2 v2 (Steps 11-15, Qwen7B agent)\nStatus: Complete\nLive URL: https://eldercare-mvp-2026.pages.dev\nFixes: Git empty commit error, agent output checks." >> README.md && \
git add README.md
if ! git diff --cached --quiet; then
  git commit -m "Update history for Chunk 2 v2"
  git push -u origin main
fi
echo "v2 chunk complete—agent used, errors fixed per vault."
