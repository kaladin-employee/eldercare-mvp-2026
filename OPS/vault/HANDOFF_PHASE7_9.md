Below is a **single, exhaustive “handoff document”** you can copy/paste into a new chat. It’s structured to eliminate rework: it includes the current state, the established workflows, the “never again” hazard list, and what each uploaded log proved (in outcome terms, not fluff). It also includes the next steps and the exact success criteria.
  
# ElderCareApp / OpenClaw Kaladin Handoff Document (Phase 7–9)
 
## 0) Goal of this workstream
 
Build a reliable local automation pipeline on Ubuntu (“Kaladin”) for ElderCareApp using OpenClaw:
 
- Local LLM via LM Studio (OpenAI-compatible at `127.0.0.1:1234/v1`)
- OpenClaw gateway + managed browser profile (“openclaw”)
- Agent automation that can: 
  - modify repo under `~/agent-workspace/ElderCareApp`
  - run build commands
  - verify via browser (public web works; local web has SSRF constraints)
  - produce logs + artifacts + commits
- Reduce thrash using: 
  - tmux always
  - `oclog` logs for every major command
  - a persistent vault under `ElderCareApp/OPS/vault` with `LATEST` pointer

## 1) Established “Phase Start” workflow (MUST DO before any run)
 
### 1A) Always use tmux for any non-trivial work
`tmux new -As eldercare tmux set -g mouse on tmux set -g history-limit 200000 tmux set -g remain-on-exit on tmux rename-window -t eldercare:0 ops tmux new-window -t eldercare -n logs`

### 1B) Always refresh the vault before each phase run
- Vault location: `~/agent-workspace/ElderCareApp/OPS/vault`
- Refresh command creates: `OPS/vault/runs/<timestamp>/` and updates `OPS/vault/LATEST -> that run`
- The vault captures: 
  - openclaw CLI version/help
  - gateway status + logs excerpt
  - config snapshot (redacted) and “doctor-normalized” config
  - LM Studio `/v1/models` proof
  - browser proof (open example.com + snapshot)
  - port/PID status (1234/5173/18800 etc.)

**Rule:** every runner begins by reading `OPS/vault/LATEST` and enforcing gates.

## 2) Tools/logging conventions (MUST FOLLOW)
 
### 2A) Always wrap major commands with `oclog`
- `oclog <name> bash -lc '<commands>'` creates:
  - `~/agent-workspace/OPS/<name>_<timestamp>.log`
  - opens file manager selecting that log for easy drag/drop
- Installed `oclog` script lives in `~/.local/bin/oclog` (and PATH should include `~/.local/bin`)

### 2B) Never lose logs
If a command is not wrapped in `oclog`, rerun with `oclog` to capture stderr/out.

## 3) Pattern hazards ledger (NEVER AGAIN rules)
1. Timeout inversion hazard: outer wrapper timeout must be >= inner agent timeout.
2. Self-kill hazard: never `pkill -f ...` patterns that can match the script itself; kill by PID/port.
3. Snap Chromium CDP hazard: prefer Google Chrome `.deb` and set `browser.executablePath=/usr/bin/google-chrome-stable`.
4. Logs-first hazard: every major run must use `oclog`.
5. No repo assumptions: always detect/scaffold repo/framework first.
6. No Next.js assumptions: detect real frontend stack from `apps/**/package.json`.
7. No localhost browser assumption: SSRF may block; use tunnels when needed.
8. No brittle parsing: tunnel URL extraction must be robust (JSON logs + parse), not grep.
9. No CLI guessing: always inspect `openclaw --help` and `openclaw agent --help`.
10. Model server gate: if LM Studio `/v1/models` is down, every agent run fails.
11. Model IDs are dynamic inputs: re-query `/v1/models` every run.
12. Never invent model IDs: use exact IDs returned by `/v1/models`.
13. Pin ONE provider: for embedded/local runs, use one OpenAI-compatible provider pointing to LM Studio.
14. Auth profile loop: ensure `~/.openclaw/agents/builder/agent/auth-profiles.json` exists.
15. Session routing hazard: prefer embedded `openclaw agent --local ...`.
16. Tools allow ≠ workspace allow: workspace roots must include repo.
17. Browser tool surface limitation: open/snapshot/screenshot; discovery from scratch needs link-rich seeds or a search tool.

## 4–10) (Remaining sections are exactly as provided in chat.)
