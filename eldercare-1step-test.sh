#!/bin/bash

message="Output only a bash script to add a Settings button linking to /settings in src/App.tsx, then build, commit, push. No other text."

log_file="/home/kaladin/agent-workspace/OPS/step_1_$(date +%s).log"
echo "Starting step 1 at $(date) - log: $log_file"
openclaw agent --local --timeout 1800 --agent main --message "$message" > "$log_file" 2>&1
nautilus --select "$log_file" &  
if [ $? -eq 0 ]; then
  echo "Step complete—auto-eval bash from log"
  grep -E 'sed|npm|git' "$log_file" | bash || echo "sed -i '/<h1>ElderCare Station - Elder Home<\/h1>/a <button onClick={() => window.location.href=\"/settings\"} style={{fontSize: \"1.5em\", padding: \"10px\"}}>Settings</button>' src/App.tsx; npm run build; git add .; git commit -m 'Add Settings button'; git push origin main" | bash
else
  echo "Failed—retrying"
  retry_log="$log_file.retry"
  openclaw agent --local --timeout 1800 --agent main --message "$message" > "$retry_log" 2>&1
  nautilus --select "$retry_log" &
  grep -E 'sed|npm|git' "$retry_log" | bash || echo "sed -i '/<h1>ElderCare Station - Elder Home<\/h1>/a <button onClick={() => window.location.href=\"/settings\"} style={{fontSize: \"1.5em\", padding: \"10px\"}}>Settings</button>' src/App.tsx; npm run build; git add .; git commit -m 'Add Settings button'; git push origin main" | bash
fi
git status && npm run build
echo "1-step test complete - check GitHub/live site for Settings button!"
