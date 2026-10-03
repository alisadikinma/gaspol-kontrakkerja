**Ticket:** KKJ-1

# gaspol-kontrakkerja — design spec

## Design

### Goal
A Claude Code plugin that drafts contracts for PT INDUSIA's people: PKWT, PKWTT, freelancer service
agreement, and an IP/confidentiality attachment (NDA + IP assignment + non-compete). Protects client
data and source code. Every clause is traceable to Indonesian law. Output: PDF (signing) and DOCX (editing), both on INDUSIA letterhead (decision 2026-10-03, user).

Path: architectural. Plugin is INDUSIA-specific (company data read from the vault, never hardcoded).

### Honest guarantee boundary
The plugin cannot guarantee "safe from legal problems". It guarantees: (1) every clause has a cited
legal basis, (2) a blocking gate rejects known fragile or unlawful clauses, (3) numbers carry a
verification date. The signed PDF carries a drafter's note: rule-check passed as of date X; advocate
review recommended before signing. The word "dijamin" is never used. One-sided clauses that courts
reduce or annul (e.g. Art. 1309 KUHPer) are treated as defects, not as company benefit.

### Skills (pipeline, modelled on gaspol-brdwriter)
| Skill | Job | Output |
|---|---|---|
| `gaspol-kontrakkerja` | Router; reads run files in working folder; never writes contract text | none |
| `kontrak-brainstorm` | Interview facts (hours, tools, place, exclusivity, age, access to source/client data); decide wadah (PKWT / PKWTT / freelancer) from facts, not from the title | `brief.md` |
| `kontrak-draft` | Assemble contract from the clause library per `brief.md` | `kontrak.md` |
| `kontrak-gate` | Blocking review: legal basis, traps, numbers, freshness | `review.md` (PASS/BLOCKING) |
| `kontrak-finish` | Requires PASS; render PDF via build.sh + style.css and DOCX via `anthropic-skills:docx` | PDF + DOCX |

No PDF without a current PASS. The IP attachment attaches to all three contract types; strictness
scales with the role's access to source code and client data.

### Knowledge (research via NotebookLM CLI, not memory)
1. `notebooklm list`; reuse notebook `608b5183` (notaris-legalitas basis).
2. Create `KONTRAK-ID 2026-10`; add primary sources (peraturan.go.id, JDIH, MA decision directory, DJP, BPJS).
3. `source wait`, then `ask` per domain; every answer must cite article or decision number.
4. Firecrawl for live facts (UMK, rates). Key articles cross-checked against peraturan.go.id.

`references/hukum/` — one file per domain, each with `verified: YYYY-MM-DD`:
ketenagakerjaan (UU 13/2003, UU 6/2023, PP 35/2021); perdata (KUHPer 1320, 1601, 1239, 1304, 1309, 1425);
HKI & rahasia dagang (UU 28/2014, UU 30/2000, MA 3549 K/Pdt/2023, 1248 PK/Pdt/2024);
pidana (KUHP baru UU 1/2023 in force 2 Jan 2026, UU ITE); data pribadi (UU 27/2022);
pajak & jaminan sosial (PMK 168/2023, BPJS, PPh 23). UU PT: signing authority only.
Research must check whether a new UU Ketenagakerjaan has been issued (MK 168/PUU-XXI/2023); if so,
the PKWT basis changes. Starting point: vault `playbook-kontrak-kerja-id`; its citations are re-verified, not copied blind.

`references/pasal/` — one entry per clause: text (standard + strict variant), legal basis, protected
purpose, applicable contract types, mandatory exceptions, risk if mis-drafted. Groups: confidentiality,
IP assignment, non-compete, clean-room / no code reuse, copyleft hygiene, client data (PDP), return of
assets/access, damages, dispute forum, termination, tax.
Criminal law appears as notice only, never as a threat to force payment of a civil debt.

### Gate — blocks on any of
1. Wadah mismatches facts (fixed hours in freelancer; probation in PKWT).
2. Clause without legal-basis tag.
3. Forbidden traps: withholding diploma/ID, wage below UMK, removing mandatory rights (BPJS, compensation), large penalty (Art. 1309), time limit on IP/source-code ownership.
4. Non-compete without a written trade-secret protection purpose.
5. Candidate under 21 without guardian signature (KUHPer 330).
6. IP assignment not explicit (Art. 16(2) UU 28/2014) or "Hasil Karya" defined narrowly.
7. No "reasonable effort" evidence for trade secret (Art. 3 UU 30/2000) or no set-off clause (Art. 1425).
8. Number without verification date; reference older than 180 days.
9. PT signatory lacks authority.

### Data Integration Map
| Component | Data source | Existing? | Notes |
|---|---|---|---|
| Company data, letterhead | vault `company-legal` | yes | read at run time, not embedded |
| Legal doctrine seed | vault `playbook-kontrak-kerja-id` | yes | citations re-verified |
| Law, 6 domains | NotebookLM -> `references/hukum/` | to build | `verified:` dates |
| Clause library | `references/pasal/` | to build | from research |
| PDF render | `build.sh` + `style.css` (repo `my-data/INDUSIA`) | yes | needs pandoc + Chrome |
| UMK / rates | Firecrawl at contract time | live | not stored permanently |

### Testing
Bash tests like brdwriter (`tests/run-all.sh` must print `ALL GREEN`): frontmatter, reference
resolution, freshness, no personal data in repo. Fixtures: `bad-kontrak.md` with planted defects
(probation in PKWT, diploma withheld, large penalty, IP limited to 1 year, age 19 without guardian,
number without date) that the gate must catch; `good-kontrak.md` must pass.

### Risks
- Invented articles: primary sources, legal-basis tags, cross-check to peraturan.go.id.
- Law changes: verification dates, 180-day warning.
- Candidate personal data leaking: `.gitignore` for working folders.

### Build order
NotebookLM research -> `references/hukum/` -> `references/pasal/` -> skills -> fixtures + tests -> PDF render.
