# Phase 9 — Competitor Research Proof (agent must browse)

Goal:
Prove autonomous browser-based research. You MUST discover existing elder care / caregiver check-in / senior safety apps by browsing the public web.

Hard requirements:
1) Use the browser tool to search and open sources. Do NOT rely on prior knowledge.
2) Identify at least 6 relevant apps/services (mix of consumer + caregiver-focused).
3) For each, capture:
   - Name
   - What it does (1-2 sentences)
   - Pricing model (free/trial/subscription) if stated
   - Key features (3-6 bullets)
   - Onboarding/pairing model (how caregiver + elder connect), if described
   - Platform support (iOS/Android/Web), if stated
   - Source URLs (at least 2 per app when possible)
4) Create artifacts:
   - Save findings to: research/competitor_scan.md
   - Save a short executive summary to: research/competitor_summary.md
   - Save a structured JSON table to: research/competitor_scan.json
5) Browser proof:
   - For each app, after opening a source page, capture a browser snapshot JSON and store under:
     OPS/research_artifacts/20260227-141659/<slug>_snapshot.json
   - Also capture one screenshot per app if supported (best-effort).
6) Commit:
   - Commit with message:
     "Phase9: competitor scan (agent browser proof)"
   - Include artifact directory path in commit body.

Quality bar:
- Facts must be tied to URLs you visited.
- No filler. If pricing or platform is unknown, write "Unknown" and cite what you checked.

