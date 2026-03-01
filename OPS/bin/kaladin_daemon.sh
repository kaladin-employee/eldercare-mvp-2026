\
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

# Fresh LATEST
TS="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="$VAULT/runs/$TS"
LATEST="$VAULT/LATEST"
mkdir -p "$RUN_DIR"
rm -f "$LATEST"
ln -s "$RUN_DIR" "$LATEST"

BASE="$LATEST"
LOG="$BASE/DAEMON.log"
touch "$LOG"
exec > >(tee -a "$LOG") 2>&1

open_log_selected() {
  local f="$1"
  [ -f "$f" ] || return 0
  if command -v nautilus >/dev/null 2>&1; then
    nautilus --no-desktop --select "$f" >/dev/null 2>&1 & disown || true
  fi
}

trap 'echo "DONE. Log: '"$LOG"'"; open_log_selected "'"$LOG"'"' EXIT

echo "=== $(date -Is) Kaladin daemon start ==="
echo "BASE=$BASE"

STOP="$QUEUE/STOP"
mkdir -p "$QUEUE"

while true; do
  if [ -f "$STOP" ]; then
    echo "STOP file detected: $STOP"
    break
  fi

  TASK="$(ls -1 "$QUEUE"/*.task 2>/dev/null | head -n 1 || true)"
  if [ -z "$TASK" ]; then
    echo "No tasks. Sleeping 30s..."
    sleep 30
    continue
  fi

  echo
  echo "=== TASK: $TASK ==="
  sed -n "1,200p" "$TASK" || true

  # New LATEST per task
  TS="$(date +%Y%m%d_%H%M%S)"
  RUN_DIR="$VAULT/runs/$TS"
  mkdir -p "$RUN_DIR"
  rm -f "$LATEST"
  ln -s "$RUN_DIR" "$LATEST"
  BASE="$LATEST"
  echo "TASK_BASE=$BASE"

  cp -a "$TASK" "$BASE/task_input.task" 2>/dev/null || true

  echo "[BIG_TEST]"
  if [ -x "$BIGTEST" ]; then
    "$BIGTEST" || true
  else
    echo "Missing $BIGTEST. Expected at: $BIGTEST"
  fi

  echo "[GIT] local commit artifacts"
  (cd "$ROOT" && git config user.name "Kaladin" && git config user.email "kaladin@local") || true
  (cd "$ROOT" && git add "$BASE" >/dev/null 2>&1 || true)
  (cd "$ROOT" && git commit -m "kaladin: task run $(basename "$TASK")" >/dev/null 2>&1 || true)

  mv "$TASK" "$BASE/task_done.task" 2>/dev/null || rm -f "$TASK" || true
  echo "TASK COMPLETE. Next loop..."
  sleep 5
done

echo "Daemon stopped."
