#!/bin/bash

rules="Read full files before editing. Do one tiny step only. Execute edits directly (use nano or eval to write files). After: npm run build to test locally, then git add . && git commit -m 'Baby step \$step_num: \$desc' && git push -u origin main. Verify on https://eldercare-mvp-2026.pages.dev/. Add _redirects if routes fail. NEVER pause or ask for input."

steps=(
  "Add emergency button to Elder home (one-tap, copies phone numbers to clipboard)."
  "Add dark mode toggle (high contrast for elder, save to localStorage)."
  "Add /settings route with sliders/toggles for font size, voice speed, reminders."
)

for i in "${!steps[@]}"; do
  step_num=$((i+1))
  desc="${steps[$i]}"
  message="Do baby step $step_num: $desc. Follow rules: $rules Never ask or pause - complete step, build, commit, and push now."
  log_file="/home/kaladin/agent-workspace/OPS/step_${step_num}_$(date +%s).log"
  echo "Starting step $step_num at $(date) - log: $log_file"
  openclaw agent --local --timeout 900 --agent main --message "$message" > "$log_file" 2>&1
  nautilus --select "$log_file" &  # Popup file manager with log selected for drag/drop
  if [ $? -eq 0 ]; then
    echo "Step $step_num complete at $(date)"
  else
    echo "Step $step_num failed - see $log_file - retrying once"
    retry_log="$log_file.retry"
    openclaw agent --local --timeout 900 --agent main --message "$message" > "$retry_log" 2>&1
    nautilus --select "$retry_log" &  # Popup for retry log
  fi
  sleep 10
done

echo "3-step test complete at $(date) - check deployments!"
