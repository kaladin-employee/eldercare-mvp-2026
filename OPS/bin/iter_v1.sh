#!/usr/bin/env bash
set -u

ROOT="$HOME/agent-workspace/ElderCareApp"
BASE="$ROOT/OPS/vault/LATEST"
PW_DIR="$HOME/.openclaw-tools/playwright"
APP="$ROOT/apps/web"

mkdir -p "$BASE"
LOG="$BASE/iter_v1.log"
echo "LOG=$LOG" | tee "$LOG"
exec > >(tee -a "$LOG") 2>&1

open_log_selected(){
  if command -v nautilus >/dev/null 2>&1; then nautilus --no-desktop --select "$LOG" >/dev/null 2>&1 & disown || true; fi
}
trap "echo DONE. Log: $LOG; open_log_selected" EXIT

echo "=== $(date -Is) ==="

echo "[1] Ensure dev server up"
if ! curl -sS -I --max-time 2 http://127.0.0.1:5173/ >/dev/null 2>&1; then
  echo "Starting dev server..."
  cd "$APP" || exit 2
  nohup pnpm dev --host 127.0.0.1 --port 5173 > "$BASE/devserver.log" 2>&1 &
  sleep 2
fi
curl -sS -I --max-time 2 http://127.0.0.1:5173/ | head -n 5 || exit 3

echo
echo "[2] Start http2 tunnel (foreground in separate window recommended)"
# If you want background tunnels later, we can add a robust bg mode.
echo "Run in a dedicated tmux window:"
echo "  cloudflared tunnel --protocol http2 --url http://127.0.0.1:5173"
echo

echo "[3] Use existing tunnel URL from tunnel_url.txt (or paste it)"
URL=""
[ -f "$BASE/tunnel_url.txt" ] && URL="$(cat "$BASE/tunnel_url.txt" || true)"
if [ -z "$URL" ]; then
  read -r -p "Paste trycloudflare URL: " URL
  echo "$URL" > "$BASE/tunnel_url.txt"
fi
echo "TUNNEL_URL=$URL"

echo
echo "[4] Playwright public smoke test"
cat > "$BASE/pwa_smoke_public.cjs" <<JS
const { chromium } = require("${PW_DIR}/node_modules/playwright");
(async () => {
  const url = process.env.URL + "/checkin";
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ ignoreHTTPSErrors: true });
  const page = await context.newPage();
  await page.goto(url, { waitUntil: "domcontentloaded", timeout: 60000 });
  console.log("FINAL URL:", page.url());
  console.log("TITLE:", await page.title());
  await page.screenshot({ path: "${BASE}/pwa_checkin_public.png", fullPage: true });
  await browser.close();
})().catch(e => { console.error(e); process.exit(2); });
JS

URL="$URL" node "$BASE/pwa_smoke_public.cjs"
ls -la "$BASE/pwa_checkin_public.png"
echo "PASS"
