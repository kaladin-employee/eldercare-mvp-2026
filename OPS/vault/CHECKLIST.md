# Phase Start Checklist (authoritative)

## Always (before any phase runner)
1) tmux reattach + settings (mouse/history/remain-on-exit)
2) vault_refresh_phase9 (updates OPS/vault/LATEST)

## OpenClaw critical gates
A) Prefer local embedded agent turns for automation:
   - Use: openclaw agent --local ...
   - Reason: avoids needing --to/--session-id routing and avoids “no sessions” stalls.
B) Model server gate:
   - LM Studio OpenAI server reachable: curl http://127.0.0.1:1234/v1/models
C) Browser gate:
   - openclaw browser start + open https://example.com + snapshot works

## Pattern hazards (never again)
- Outer timeout must exceed inner agent timeout
- Never pkill -f (kill by PID/port)
- Snap Chromium breaks CDP; use chrome .deb
- Every run wrapped with oclog (log + file manager select)

## Model ID rule (LM Studio)
- Model IDs should be treated as dynamic inputs:
  - Always re-query: curl http://127.0.0.1:1234/v1/models
  - Never assume ordering (first model may change after restart/load/unload).
  - Select the intended model explicitly (prefer 7B for builder; 3B optional).
## Phase Start Checklist

- Use tmux (reattach + mouse/history/remain-on-exit)
- Run vault refresh (OPS/vault/LATEST)
- Gate: LM Studio responds: curl http://127.0.0.1:1234/v1/models
- Gate: browser works on public web: open example.com + snapshot
- Prefer embedded mode for local automation: openclaw agent --local ...

## Reasonable-max access baseline
- workspaceRoots = ~/agent-workspace
- tools.allow includes group:fs, group:runtime, browser
- denyPaths includes ~/.ssh ~/.gnupg ~/.aws ~/.kube Chrome/Chromium profiles
- denyCommands includes ssh/scp/gpg/aws/kubectl/docker
