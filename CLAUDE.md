# gaspol-kontrakkerja — plugin rules (for Claude)

Drafts Indonesian employment and freelancer contracts for PT INDUSIA (software house) with
IP and client-data protection. Every clause carries a legal basis; a blocking gate rejects
fragile clauses. Output: PDF (signing) and DOCX (editing) on letterhead. Design:
`docs/plans/2026-10-03-KKJ-1-gaspol-kontrakkerja-spec.md`, plan: `…-plan.md`.

Status: v0.1.0, all phases of KKJ-1 built. Pending risk: a new UU Ketenagakerjaan may land
around 31 Oct 2026 (MK 168/PUU-XXI/2023 deadline); the PKWT basis must then be re-researched.

## Skills and what each reads/writes

| Skill | Reads | Writes |
|---|---|---|
| `gaspol-kontrakkerja` (router) | run files in the working folder (names, mtimes, `shasum -a 256 kontrak.md`) | nothing |
| `kontrak-brainstorm` | vault `10-Identity/company-legal.md`, `30-Knowledge/playbook-kontrak-kerja-id.md`; `references/hukum/ketenagakerjaan.md`; `templates/brief-template.md`; live UMK via Firecrawl | `brief.md` |
| `kontrak-draft` | `brief.md`, `templates/kontrak-*.md` + `lampiran-ip.md`, `references/pasal/*`, `references/hukum/signing-authority.md`, `ketenagakerjaan.md`, vault `company-legal.md` | `kontrak.md` |
| `kontrak-gate` | `kontrak.md`, `brief.md`, `references/pasal/*`, `references/hukum/*`, vault `company-legal.md` | `review.md` |
| `kontrak-finish` | `kontrak.md`, `review.md`, `brief.md`, vault `company-legal.md`, `scripts/clean.sh`, `build.sh`, `md2docx.js`, `templates/kop.html`, `style.css`; skill `anthropic-skills:docx` | `KONTRAK-<CODE>-<NNN>.pdf` and `.docx` |

Skills name plugin files as `../../references/…`, `../../templates/…`, `../../scripts/…`
(relative to the skill folder; an installed skill runs in the user's project folder).
SKILL.md frontmatter is `name` + `description` only; `name` equals the folder name.

## Run files (working folder, one contract per folder)

`brief.md` → `kontrak.md` → `review.md` → `KONTRAK-<CODE>-<NNN>.pdf/.docx`. Fact tags in brief:
`[user]` `[vault]` `[riset]` `[ASUMSI]` (an `[ASUMSI]` on a legal-critical fact blocks the draft
and the gate). "Current PASS" = `review.md` first line `## Verdict: PASS` and `kontrak_sha256`
equal to `shasum -a 256 kontrak.md`. Nothing is rendered without it.

## Contracts that tests enforce (`bash tests/run-all.sh`, explicit list, missing script = RED)

- **Fixtures:** `references/examples/bad-kontrak.md` keeps six planted defects `D1`–`D6`
  (`<!-- DEFECT Dn -->`). They are NEVER fixed; a gate that passes the bad fixture is fixed
  instead. `good-kontrak.md` has none and must PASS. Fixture parties are fictional.
- **Freshness:** every `references/hukum/*.md` carries `verified: YYYY-MM-DD`; more than 180 days
  old is RED (`tests/freshness.sh`) and gate G8 fails. Every body bullet ends with `[dasar: …]`.
- **Clause library:** `references/pasal/<group>.md`, entries `## P-<GROUP>-<NN>` with eight
  non-empty fields; ids unique; every `Dasar hukum` appears in some `references/hukum` `[dasar: …]`.
  No tax or BPJS percentage anywhere.
- **Template slots:** templates use `{{CLAUSE:P-XXX-NN}}` and `{{PIHAK_KEDUA_NAMA}}`-style
  placeholders (the slot contract); a finished `kontrak.md` has zero `{{`. Letterhead values
  in `templates/kop.html` are `{{PT_...}}` placeholders filled from the vault note at render time.
- **Drafter notes:** one `> **Catatan penyusun — dasar:** P-XXX-NN; …` line under each clause
  heading; `# CATATAN PENYUSUN` closes the file; both stripped by `scripts/clean.sh`.
- **GATE-STATUS marker:** `kontrak-draft` ends the file with one line starting
  `<!-- GATE-STATUS -->` ("DISUSUN per …, menunggu kontrak-gate"). Only `scripts/clean.sh`, on its
  working copy and with a current PASS, replaces it with "Draf ini lolos pemeriksaan aturan per
  <reviewed_at>…". The word "dijamin" is never in a contract.
- **kontrak.md stays byte-identical after PASS:** finish never edits it (sha before = after).
- **Generic repo:** `tests/guard-generic.sh` fails on a NIK-like 16-digit number, a 13-digit NIB,
  a formatted NPWP, or personal names/tokens. Company values come from the vault at run time.
- **Skills:** `tests/skill-content.sh` (required strings per skill and README honesty rules),
  `tests/refs-resolve.sh` (every `../../…` path resolves), `tests/frontmatter.sh`,
  `tests/build-smoke.sh` (PDF build on a stub vault note, exit 2 cases).

## Rendering

`scripts/build.sh <kontrak.md> <out.pdf> [company-legal.md]` (pandoc, Chrome headless); logo from
`$KONTRAK_LOGO`; exit 2 on a missing logo, vault note or letterhead value. DOCX:
`node scripts/md2docx.js <clean.md> <company-legal.md> <out.docx> <logo>` (npm `docx`, `NODE_PATH`).

## gaspol Ticket Counter

Prefix: KKJ
Last ticket: KKJ-1
