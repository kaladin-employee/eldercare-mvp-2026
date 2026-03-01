#!/usr/bin/env bash
set -u

ROOT="$HOME/agent-workspace/ElderCareApp"
VAULT="$ROOT/OPS/vault"
QUEUE="$ROOT/OPS/queue"
BIGTEST="$ROOT/OPS/bin/big_test.sh"

# Ensure tmux, but do not nest
if [ -z "${TMUX:-}" ]; then
  tmux new -As eldercare
  tmux set-option -g mouse on
  tmux set-option -g history-limit 200000
  tmux set-option -g remain-on-exit on
fi

# Ensure HTTPS origin + gh credential helper (works; avoids SSH identity mismatch)
cd "$ROOT" || exit 1
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/kaladin-employee/eldercareapp-kaladin.git 2>/dev/null || true
gh auth setup-git >/dev/null 2>&1 || true
git config user.name "Kaladin"
git config user.email "kaladin@local"

STOP="$QUEUE/STOP"
mkdir -p "$QUEUE"
echo "=== $(date -Is) kaladin daemon v2 ==="
echo "ROOT=$ROOT"
echo "QUEUE=$QUEUE"
echo "STOP=$STOP"

while true; do
  if [ -f "$STOP" ]; then
    echo "STOP file detected: $STOP"
    break
  fi

  TASK="$(ls -1 "$QUEUE"/*.task 2>/dev/null | head -n 1 || true)"
  if [ -z "$TASK" ]; then
    echo "No tasks. Sleeping 15s..."
    sleep 15
    continue
  fi

  # Fresh LATEST per task
  TS="$(date +%Y%m%d_%H%M%S)"
  RUN_DIR="$VAULT/runs/$TS"
  LATEST="$VAULT/LATEST"
  mkdir -p "$RUN_DIR"
  rm -f "$LATEST"
  ln -s "$RUN_DIR" "$LATEST"
  BASE="$LATEST"

  LOG="$BASE/DAEMON_V2.log"
  touch "$LOG"
  exec > >(tee -a "$LOG") 2>&1

  echo ""
  echo "=== TASK: $TASK ==="
  sed -n "1,200p" "$TASK" || true
  cp -a "$TASK" "$BASE/task_input.task" 2>/dev/null || true

  echo ""
  echo "[APPLY] placeholder change: write proof marker (no code edit yet)"
  mkdir -p "$ROOT/OPS/smoke"
  echo "task $(basename "$TASK") ran at $(date -Is)" > "$ROOT/OPS/smoke/last_task.txt"

  echo ""
  echo "[BIG_TEST]"
  if [ -x "$BIGTEST" ]; then
    "$BIGTEST" || true
  else
    echo "Missing $BIGTEST at $BIGTEST"
  fi

  echo ""
  echo "[COMMIT+PUSH]"
  cd "$ROOT" || exit 1
  git add OPS/smoke/last_task.txt 2>/dev/null || true
  git commit -m "kaladin: $(basename "$TASK")" >/dev/null 2>&1 || true
  git push >/dev/null 2>&1 || true

  mv "$TASK" "$BASE/task_done.task" 2>/dev/null || rm -f "$TASK" || true
  echo "TASK COMPLETE. Loop continues..."
  sleep 5

  # restore output to terminal for the waiting loop
  exec >/dev/tty 2>/dev/tty
done

echo "Daemon stopped."
