#!/bin/bash
set -e

# Function to run a single step with agent suggestion + execution
run_step() {
  STEP_NUM=$1
  TASK_DESC="$2"
  echo "=== Step $STEP_NUM: $TASK_DESC ==="

  # Use builder agent to suggest code (assuming openclaw CLI is installed/configured)
  SUGGESTION=$(openclaw agent builder --prompt "Suggest minimal code changes for: $TASK_DESC. Output only the diff or file contents.")

  # Execute suggestion (simplified: assume it's a file write)
  if [[ $SUGGESTION == *"src/App.tsx"* ]]; then
    echo "$SUGGESTION" > src/App.tsx
  fi  # Add more if/then for other files as needed

  # Test build locally
  npm run build || { echo "Build failed! Fix manually."; exit 1; }

  # Commit and push
  git add .
  git commit -m "Chunk 1 - Step $STEP_NUM: $TASK_DESC" || true
  git push -u origin main
  echo "Committed and pushed. Check live: https://eldercare-mvp-2026.pages.dev"
}

# 10 Steps for Chunk 1
run_step 1 "Remove default Vite logo and counter from src/App.tsx, add basic header: 'ElderCare Station'"
run_step 2 "Add React Router: Install if needed, set up basic routes / (elder home) and /caregiver"
run_step 3 "In src/App.tsx, add mode switch via query param (?mode=caregiver) and localStorage"
run_step 4 "Apply basic sunset theme: Oranges/blues CSS in index.css (high contrast, large fonts)"
run_step 5 "Add digital clock to elder home screen using useState and setInterval"
run_step 6 "Add one-tap 'OK' button on elder home: Logs to console with timestamp"
run_step 7 "Save check-ins to localStorage (array of {type, time})"
run_step 8 "Display last check-in on caregiver dashboard"
run_step 9 "Add red alert if no check-in in >12 hours (simple time check)"
run_step 10 "Update README.md with quick start guide"

# Update docs
echo "\n### Run $(date)\nChunk: 1 (Steps 1-10)\nStatus: Complete\nLive URL: https://eldercare-mvp-2026.pages.dev\n" >> README.md
git add README.md && git commit -m "Update run history" && git push -u origin main
