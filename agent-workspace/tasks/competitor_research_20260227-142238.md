# Phase 9 — Competitor Research Proof (agent must browse; no hints)

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
   - research/competitor_scan.md
   - research/competitor_summary.md
   - research/competitor_scan.json
5) Browser proof:
   - For each app, after opening a source page, save a browser snapshot JSON under:
     OPS/research_artifacts/20260227-142238/<slug>_snapshot.json
   - Best-effort: one screenshot per app into the same folder.
6) Commit:
   - Message: "Phase9: competitor scan (agent browser proof)"
   - Commit body must include: OPS/research_artifacts/20260227-142238

Quality bar:
- Facts must be tied to URLs you visited.
- If unknown, write "Unknown" and cite what you checked.
