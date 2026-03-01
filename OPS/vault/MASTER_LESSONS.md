
## Lessons Learned / Pattern Hazards (append-only)

### tmux / shell execution
- Never run `tmux new ...` inside an existing tmux session (nested tmux breaks commands). Use `tmux attach -t eldercare` and create new windows with `Ctrl-b c`.
- Avoid giant inline one-liners with complex quoting (they get corrupted). Prefer short scripts or minimal blocks with `exec > >(tee -a "$LOG") 2>&1`.

### Logging discipline
- During active debugging, write outputs to **OPS/vault/LATEST/** to avoid “30 folders open”.
- Always create the log file first, then `exec > >(tee -a "$LOG") 2>&1`, plus a trap to open file manager selecting the log.

### Dev server / npm / monorepo pitfalls
- npm workspace collisions happened because backup folders under `apps/` duplicated package names. Quarantine backups out of `apps/`.
- If npm injects workspace flags unexpectedly, run installs/starts from the correct app directory and avoid mixing `--no-workspaces` with `--workspace`.

### Cloudflared / tunnel pitfalls
- `apt-get install cloudflared` failed on this distro; install via Cloudflare `.deb` from GitHub releases.
- curl HTTP/2 downloads can fail with `PROTOCOL_ERROR`; force `--http1.1` + resume `-C -` + retries.
- A user-local cloudflared binary segfaulted; prefer the `.deb` install path and verify `cloudflared --version`.
- QUIC tunnels can trigger Playwright TLS errors (`ERR_SSL_BAD_RECORD_MAC_ALERT`). Use `cloudflared tunnel --protocol http2 ...` and set Playwright `ignoreHTTPSErrors: true`.

### “Big Test” known-good recipe
- Clean slate: kill port 5173 listener + cloudflared tunnels.
- Start Vite on 127.0.0.1:5173.
- Start cloudflared **http2** tunnel and capture trycloudflare URL.
- Run Playwright against `<URL>/checkin`, save `pwa_checkin_public.png` to LATEST.


### Python here-doc triple-quote nesting hazard (SyntaxError)
- Failure signature: `SyntaxError: invalid syntax` pointing at `p = Path(r"""%s""")` (or similar) inside a Python heredoc.
- Root cause: nesting triple-quoted strings inside an outer triple-quoted string (e.g., building a script with `script = r"""..."""` and then embedding another `r"""..."""` inside it) corrupts Python parsing.
- Rule: **never embed triple quotes inside triple quotes** in these automation installers.
- Fix patterns:
  - Use single quotes for inner strings (`Path("...")`) or `repr(path)`.
  - Or write files with Python `write_text()` using `\\n` joins (no triple quotes).
  - Or store templates in external files and copy them.

