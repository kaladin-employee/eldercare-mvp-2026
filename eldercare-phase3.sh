#!/bin/bash

principles="Follow Apple HIG/Ive principles: Simplicity (remove clutter), Clarity (legible UI), Deference (focus on tasks), Depth (subtle motion), Harmony (adaptive elements), Consistency (touch-friendly). Output only bash script for step (e.g., echo '...' >> file; npm run build; git add .; git commit -m 'desc'; git push origin main). No other text."

steps=(
  "Create STYLE_GUIDE.md with Apple HIG/Ive principles summary."
  "Add global CSS reset for consistency."
  "Define theme vars for sunset palette, typography, spacing."
  "Apply to Elder Home for hierarchy/depth."
  "Refine buttons to Apple-like rounded/tactile."
  "Update clock/date for simplicity/legibility."
  "Polish routes for deference/minimal nav."
  "Add subtle transitions for elegance."
  "Ensure accessibility with high contrast/large touches."
  "Final commit/verify deploy with README update."
)

for i in "${!steps[@]}"; do
  step_num=$((i+1))
  desc="${steps[$i]}"
  message="Baby step $step_num: $desc. $principles Output bash script only."
  log_file="/home/kaladin/agent-workspace/OPS/step_${step_num}_$(date +%s).log"
  echo "Starting step $step_num at $(date) - log: $log_file"
  openclaw agent --local --timeout 1800 --agent main --message "$message" > "$log_file" 2>&1
  nautilus --select "$log_file" &  
  if [ $? -eq 0 ]; then
    echo "Step complete—auto-eval"
    grep -E 'sed|echo|npm|git' "$log_file" | bash
  else
    echo "Failed—retrying"
    retry_log="$log_file.retry"
    openclaw agent --local --timeout 1800 --agent main --message "$message" > "$retry_log" 2>&1
    nautilus --select "$retry_log" &
    grep -E 'sed|echo|npm|git' "$retry_log" | bash
  fi
  sleep 10
done

echo "Phase 3 complete - check live site for elegant UI!"
