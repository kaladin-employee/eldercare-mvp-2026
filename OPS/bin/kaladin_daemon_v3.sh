#!/usr/bin/env bash
set -u
ROOT="/home/kaladin/agent-workspace/ElderCareApp"
OPS="/OPS"
BIN="/bin"
QUEUE="/queue"
VAULT="/vault"
MASTER="/DAEMON_MASTER.log"
BIG="/big_test.sh"

mkdir -p "" ""
cd "" || { echo "Missing repo at "; exit 2; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not a git repo: "; exit 3; }
gh auth setup-git >/dev/null 2>&1 || true
git config user.name "Kaladin"
git config user.email "kaladin@local"

STOP="/STOP"
echo "=== 2026-02-28T14:00:59+08:00 DAEMON_V3 START ===" | tee -a ""
echo "ROOT=" | tee -a ""
echo "QUEUE=" | tee -a ""

while true; do
  if [ -f "" ]; then echo "STOP detected" | tee -a ""; break; fi
  TASK=""
  if [ -z "" ]; then echo "No tasks. Sleeping 15s..." | tee -a ""; sleep 15; continue; fi
  echo "" | tee -a ""
  echo "=== TASK:  ===" | tee -a ""
  sed -n "1,160p" "" | tee -a "" || true
  if [ ! -x "" ]; then echo "Missing " | tee -a ""; mv "" ".fail" 2>/dev/null || true; sleep 2; continue; fi
  echo "[RUN] big_test" | tee -a ""
  "" 2>&1 | tee -a ""
  BASE="/LATEST"
  URL=""
  if [ -z "" ] || [ ! -f "/pwa_checkin_public.png" ]; then
    echo "BIG_TEST_FAILED (missing URL or PNG) -> .fail" | tee -a ""
    mv "" ".fail" 2>/dev/null || true
    sleep 2
    continue
  fi
  echo "[GIT] commit+push proof marker" | tee -a ""
  mkdir -p "/smoke"
  echo "last task  at 2026-02-28T14:00:59+08:00" > "/smoke/last_task.txt"
  cd ""
  git add OPS/smoke/last_task.txt >/dev/null 2>&1 || true
  git commit -m "kaladin: " >/dev/null 2>&1 || true
  git push >/dev/null 2>&1 || true
  mv "" "/task_done.task" 2>/dev/null || rm -f "" || true
  echo "TASK COMPLETE" | tee -a ""
  sleep 5
done
echo "DAEMON_V3 STOPPED" | tee -a ""
