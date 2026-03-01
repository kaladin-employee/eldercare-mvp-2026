#!/usr/bin/env bash
set -u
ROOT="$HOME/agent-workspace/ElderCareApp"
VAULT="$ROOT/OPS/vault"
TS="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="$VAULT/runs/$TS"
LATEST="$VAULT/LATEST"
mkdir -p "$RUN_DIR"
rm -f "$LATEST"
ln -s "$RUN_DIR" "$LATEST"
BASE="$LATEST"
LOG="$BASE/BIG_TEST.log"
echo "LOG=$LOG" | tee "$LOG"
exec > >(tee -a "$LOG") 2>&1

open_log_selected(){ command -v nautilus >/dev/null 2>&1 && nautilus --no-desktop --select "$LOG" >/dev/null 2>&1 & disown || true; }
trap "echo DONE. Log: $LOG; open_log_selected" EXIT

echo "=== $(date -Is) ==="
uname -a
echo

echo "[CLEAN] kill devserver 5173"
PID="$(lsof -ti tcp:5173 2>/dev/null | head -n1 || true)"
echo "PID_5173=${PID:-none}"
[ -n "$PID" ] && kill -KILL "$PID" 2>/dev/null || true

echo "[CLEAN] kill cloudflared"
pkill -f "cloudflared tunnel" 2>/dev/null || true
echo

echo "[DEV] start vite"
APP="$ROOT/apps/web"
cd "$APP" || exit 2
nohup pnpm dev --host 127.0.0.1 --port 5173 > "$BASE/devserver.log" 2>&1 &
echo $! > "$BASE/devserver.pid"
sleep 2
curl -sS -I --max-time 2 http://127.0.0.1:5173/ | head -n 8 || { tail -n 120 "$BASE/devserver.log"; exit 3; }
echo

echo "[TUNNEL] start cloudflared http2 (background)"
nohup cloudflared tunnel --protocol http2 --url http://127.0.0.1:5173 > "$BASE/cloudflared_http2.log" 2>&1 &
echo $! > "$BASE/cloudflared.pid"
sleep 3
tail -n 80 "$BASE/cloudflared_http2.log" || true

echo "[TUNNEL] extract URL"
URL="$(grep -aoE "https://[a-z0-9-]+\.trycloudflare\.com" "$BASE/cloudflared_http2.log" | tail -n 1 || true)"
echo "TUNNEL_URL=$URL"
echo "$URL" > "$BASE/tunnel_url.txt"
[ -n "$URL" ] || exit 4
echo

echo "[PLAYWRIGHT] public /checkin screenshot"
PW_DIR="$HOME/.openclaw-tools/playwright"
cat > "$BASE/pwa_smoke_public.cjs" <<JS
const { chromium } = require("${PW_DIR}/node_modules/playwright");
(async () => {
  const url = process.env.URL + "/checkin";
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ ignoreHTTPSErrors: true });
  const page = await context.newPage();
  await page.goto(url, { waitUntil: "domcontentloaded", timeout: 60000 });
  await page.screenshot({ path: "${BASE}/pwa_checkin_public.png", fullPage: true });
  await browser.close();
})().catch(e => { console.error(e); process.exit(2); });
JS

URL="$URL" node "$BASE/pwa_smoke_public.cjs"
ls -la "$BASE/pwa_checkin_public.png"
echo "PASS"
