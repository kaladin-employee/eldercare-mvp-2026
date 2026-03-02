#!/bin/bash

# Strict rules for agent (embedded in each message)
rules="Read-first: cat full file before edit. One tiny step only. After step: git add . && git commit -m 'Baby step \$i: desc' && git push -u origin main. Keep npm run dev running, verify on https://eldercare-mvp-2026.pages.dev/. NEVER pause or ask for input."

# 40 baby steps array
steps=(
  "Add react-router-dom routes: /, /checkin, /history."
  "Add mode switch (?mode=elder or caregiver) + localStorage."
  "Elder mode CSS: large fonts (24px+), high contrast, big buttons (60px+)."
  " /checkin Elder: 6 one-tap buttons (OK, Meds, Meal, Good, Help, Emergency) with colors."
  "Buttons save to localStorage with timestamp."
  " /history Elder: show logged check-ins as big cards."
  "Add digital clock/date on home Elder."
  "Voice input button (Web Speech API) for check-in."
  "Med reminder timer (every 4h, local notification)."
  "Touch-friendly polish for Elder UI."
  "Caregiver dashboard /caregiver: list recent check-ins."
  "Caregiver alert (red banner if no check-in >12h)."
  "Share link generator (URL with data)."
  "Basic auth sim for caregiver (username/pass)."
  "Sunset theme (oranges/blues) for whole app."
  "Offline support (cached check-ins via service worker)."
  "PWA install prompt + custom icon 'ElderCare Station'."
  " /meds Elder: one-tap 'Taken' for daily pills."
  " /meals Elder: one-tap logging (Breakfast, etc.)."
  "Activity buttons (Walked, etc.)."
  "Caregiver charts (Chart.js streaks)."
  "Emergency button (phone numbers + clipboard)."
  "Dark mode toggle (elder contrast)."
  "Settings page (font slider, reminders)."
  "All routes offline + PWA cache."
  "Cloudflare config (_redirects for routes)."
  "Home Elder polish (greeting, static weather)."
  "Caregiver toast sim on check-in."
  "Responsive final polish (huge taps)."
  "README.md with instructions."
  "Polish voice speed in settings."
  "Polish family sharing link."
  "Full PWA testing on Cloudflare."
  "Add any missed sunset doctrine features."
  "Final offline polish."
  "Final theme polish."
  "Final elder UI polish."
  "Final caregiver dashboard polish."
  "Final commit and verify live deploy."
  "Done - output 'All steps complete'."
)

# Loop through all steps autonomously
for i in "${!steps[@]}"; do
  step_num=$((i+1))
  message="Do baby step $step_num: ${steps[i]}. Follow rules: $rules Never ask or pause - complete step and push now."
  log_file="/home/kaladin/agent-workspace/OPS/step_${step_num}_$(date +%s).log"
  echo "Starting step $step_num at $(date) - log: $log_file"
  openclaw agent --local --timeout 900 --agent main --message "$message" > "$log_file" 2>&1
  if [ $? -eq 0 ]; then
    echo "Step $step_num complete at $(date) - check GitHub/live URL"
  else
    echo "Step $step_num failed - see $log_file - retrying once"
    openclaw agent --local --timeout 900 --agent main --message "$message" > "$log_file.retry" 2>&1
  fi
  sleep 10  # Short pause to avoid rate limits
done

echo "All steps complete at $(date) - full app built!"
