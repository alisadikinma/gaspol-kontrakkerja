> **For Claude:** REQUIRED SKILL: Use gaspol-execute to implement this plan.
> **CRITICAL:** This plan specifies real integrations. During execution,
> NEVER substitute placeholders for real data sources without explicit
> user approval. If a data source doesn't exist yet, STOP and ask.
> **Progress ledger — HARD PER-PHASE GATE:** `.gaspol/progress/PROGRESS-KKJ-1.md` (created by `gaspol-plan` at plan-write time). After EACH phase and **BEFORE** starting the next, STOP and do BOTH: (a) tick that phase's `## Checklist` line, (b) append a `## Log` line ending with the handoff cursor. This is **blocking**, like a test gate: no next phase until both are written. **Never batch all updates at the end.** Update ONLY this file — never the shared `.gaspol/progress.md`.
> **Self-contained:** this plan is the COMPLETE spec. It must be executable by an agent with **no other context**. Every file path, contract, config key, and convention it needs is written here **verbatim**.

**Ticket:** KKJ-1
**Ledger:** .gaspol/progress/PROGRESS-KKJ-1.md
**Spec:** docs/plans/2026-10-03-KKJ-1-gaspol-kontrakkerja-spec.md

## Goal

Build the Claude Code plugin `gaspol-kontrakkerja` (working dir `/Users/alisadikin/Drive-D/claude-plugin/gaspol-kontrakkerja`): a pipeline that drafts Indonesian employment contracts (PKWT, PKWTT), freelancer service agreements, and an IP/confidentiality attachment (NDA + IP assignment + non-compete) for PT INDUSIA, a software house. Every clause carries a cited legal basis. A blocking gate rejects fragile or unlawful clauses. Output is a PDF (for signing) and a DOCX (for editing/revision), both on INDUSIA letterhead. Knowledge comes from NotebookLM CLI deep research, distilled into `references/hukum/` (law) and `references/pasal/` (clause library). The plugin never claims "dijamin aman"; the PDF's drafter note says rule-check passed as of a date and advocate review is recommended.

## Architecture Context

Project CLAUDE.md (`/Users/alisadikin/Drive-D/claude-plugin/gaspol-kontrakkerja/CLAUDE.md`) holds the ticket counter only (Prefix `KKJ`, Last ticket `KKJ-1`). The folder is **not a git repo** and has no source code yet. Therefore: no "Commit" steps in this plan (n/a, no git); ledger `## Phase log` writes `n/a (no git)` as the SHA. Do NOT run `git init` without asking the user (Utang terbuka item).

Pattern source (read-only, do not edit): `~/.claude/plugins/cache/gaspol-one/gaspol-brdwriter/0.1.1/` — layout `.claude-plugin/plugin.json`, `skills/<name>/SKILL.md`, `references/`, `templates/`, `tests/run-all.sh`, `evals/`, `research/`. Skills name plugin files as `../../references/...` / `../../templates/...` (relative to the skill folder, because an installed skill runs in the user's project directory).

Existing assets to reuse (Data Integration Map below):
- Vault note `/Users/alisadikin/Drive-D/Obsidian-Vault/30-Knowledge/playbook-kontrak-kerja-id.md` — doctrine seed (wadah test, non-compete valid per MA 3549 K/Pdt/2023, IP Art. 36 UU 28/2014, trade-secret "upaya layak", penalty Art. 1309, PKWT compensation PP 35/2021). Citations are re-verified, never copied blind.
- Vault note `/Users/alisadikin/Drive-D/Obsidian-Vault/10-Identity/company-legal.md` — PT INDUSIA entity data (name, address, NIB, NPWP, SK Menkumham, signatory).
- Render pattern `/Users/alisadikin/Drive-D/my-data/INDUSIA/Karyawan/Herry/build.sh` + `style.css` (markdown -> pandoc -> Chrome headless -> A4 PDF). That script hardcodes paths and letterhead; the plugin gets its own parametrised copy.
- Existing NotebookLM notebook id prefix `608b5183` (basis of skill `notaris-legalitas`). Reuse it; create a new one named `KONTRAK-ID 2026-10`.
- Tools present: `notebooklm` CLI (`~/.local/bin/notebooklm`, logged in), `pandoc` (`/opt/homebrew/bin/pandoc`), Chrome (`/Applications/Google Chrome.app`), Firecrawl MCP.

### Conventions (inline, verbatim)

**Test harness.** Bash + grep + awk only. `tests/run-all.sh` has an EXPLICIT list of test scripts; a missing script is RED (prints `MISSING <name>`), never skipped; ends with `ALL GREEN` or `SOME RED`, exit 0/1. Each phase that adds a test script also adds it to that list.

**`references/hukum/<domain>.md` format.** Frontmatter then body:
```
---
domain: <slug>
verified: YYYY-MM-DD
sources: [<url or notebook source title>, ...]
---
# <Domain title>
- <rule sentence> [dasar: <UU/PP/KUHPer article or court decision number>]
```
Every rule line ends with `[dasar: ...]`. Six files: `ketenagakerjaan`, `perdata`, `hki-rahasia-dagang`, `pidana`, `data-pribadi`, `pajak-jaminan-sosial`. Plus `signing-authority.md` (UU PT: who may sign for the PT, one short file, same format).

**`references/pasal/<group>.md` format.** One `##` entry per clause, id `P-<GROUP>-<NN>`:
```
## P-RHS-01 <clause name>
**Dasar hukum:** <article / decision>
**Tujuan:** <protected interest>
**Berlaku untuk:** PKWT, PKWTT, FL   (any subset; FL = freelancer)
**Varian standar:** <clause text, Indonesian>
**Varian ketat:** <clause text, Indonesian>
**Pengecualian wajib:** <exceptions the clause must carry, or "tidak ada">
**Risiko:** <what breaks if drafted wrongly>
**Verified:** YYYY-MM-DD
```
Groups (file = group): `kerahasiaan` (RHS), `hki` (HKI), `non-kompetisi` (NK), `clean-room` (CR), `copyleft` (CL), `data-klien` (DK), `aset-akses` (AA), `ganti-rugi` (GR), `forum-sengketa` (FS), `pemutusan` (PM), `pajak` (PJ).

**Run files in a user's working folder:** `brief.md` (from kontrak-brainstorm), `kontrak.md` (from kontrak-draft), `review.md` (from kontrak-gate), `KONTRAK-<CODE>-<NNN>.pdf` and `KONTRAK-<CODE>-<NNN>.docx` (from kontrak-finish). Router decides by which exist and their modification times.

**Fact tags in `brief.md`:** every fact line ends with one tag: `[user]`, `[vault]`, `[riset]`, `[ASUMSI]`. Gate treats `[ASUMSI]` on a legal-critical fact as BLOCKING.

**Legal-basis tag in `kontrak.md`:** directly under each clause, one blockquote line: `> **Catatan penyusun — dasar:** P-XXX-NN; <article>`. The render script strips every line starting `> **Catatan penyusun` and everything from a `# CATATAN PENYUSUN` heading to end of file (same rule as the Herry `build.sh`).

**`review.md` format:** `## Verdict: PASS` or `## Verdict: BLOCKING`, a findings table (`| Gate | Status | Evidence | Fix |`), a line `reviewed_at: YYYY-MM-DD`, and `kontrak_sha256: <sha256 of kontrak.md>`. "Current PASS" = verdict PASS AND the sha matches the present `kontrak.md`.

### Gate list (G1-G9, BLOCKING on any) — copy verbatim into `skills/kontrak-gate/SKILL.md`
- **G1 Wadah:** wadah (PKWT / PKWTT / freelancer) contradicts the facts. Fixed working hours or attendance in a freelancer agreement; probation in a PKWT (Art. 58 UU 13/2003, batal demi hukum); PKWT used for permanent core work.
- **G2 Dasar hukum:** a clause without a `Catatan penyusun — dasar:` line, or citing a clause id absent from `references/pasal/`.
- **G3 Jebakan terlarang:** withholding diploma/ID/original documents; wage below UMK while a work relationship exists (prohibition Art. 88E(2) UU 13/2003 jo. UU 6/2023; criminal sanction per Art. 185 as amended by UU 1/2026 — cite from `references/hukum/ketenagakerjaan.md`, never a figure from memory); removing mandatory rights (BPJS enrolment, PKWT compensation, THR, overtime); penalty above ~1 month fee/wage (Art. 1309 KUHPer: judge may reduce if the main obligation was partly performed) without a stated reduction-proof rationale; time limit on ownership of IP or source code.
- **G4 Non-kompetisi:** non-compete without an explicit written purpose of protecting trade secrets / legitimate business interest; or scope not specific (activity, duration, area).
- **G5 Usia:** candidate under 21 (KUHPer Art. 330) with no guardian "mengetahui dan menyetujui" signature block.
- **G6 HKI:** IP assignment not explicit (Art. 16(2) UU 28/2014 requires only a written agreement; "comprehensive, permanent, irrevocable" is INDUSIA's own clause design, not a statutory requirement); "Hasil Karya" defined narrowly (must cover source code, object code, repository + commit history, database + schema, scripts, configuration, prompts, models + weights, datasets, algorithms, technical documentation, SOP, test results, derivative works; across all projects/customers/business lines); moral-rights handling missing (Art. 5: moral rights stay with creator — clause obtains non-assertion consent only); no copyleft-hygiene warranty.
- **G7 Penegakan:** no "upaya layak" confidentiality clause (Art. 3 UU 30/2000); no set-off clause (Art. 1425 KUHPer) where damages exist; no dispute forum stated correctly (PHI for employment; PN for freelancer agreement).
- **G8 Angka & kesegaran:** a number (UMK, rate, percentage, amount) without a verification date; any referenced `references/hukum/*.md` with `verified:` older than 180 days relative to today.
- **G9 Penandatangan:** the PT signatory has no stated authority basis (per `references/hukum/signing-authority.md` and vault `company-legal`); party identity fields incomplete; criminal-law text used as a threat to force civil payment instead of as a plain notice.

## Tech Stack

Markdown skill files (Claude Code plugin), bash tests (bash + grep + awk), pandoc + Chrome headless for PDF, NotebookLM CLI for research, Firecrawl MCP for live facts. No application runtime code. `detect-stack` printed **no stack markers** (exit 0, zero lines): verification is plan-declared only.

## Data Integration Map

| Feature | Data Source | Hook/API | Exists? | Action |
|---|---|---|---|---|
| Company data + letterhead values | `/Users/alisadikin/Drive-D/Obsidian-Vault/10-Identity/company-legal.md` | file read at finish time | Yes | Read at run time; fill `{{...}}` placeholders in `templates/kop.html`; never embed values in skills |
| Legal doctrine seed | `/Users/alisadikin/Drive-D/Obsidian-Vault/30-Knowledge/playbook-kontrak-kerja-id.md` | file read | Yes | Starting point; re-verify every citation via research |
| Law, 6 domains + signing authority | NotebookLM notebooks `608b5183…` (existing) + `KONTRAK-ID 2026-10` (new) | `notebooklm` CLI | Notebook 1 yes, notebook 2 No | Create notebook 2 in Phase B; distill into `references/hukum/` |
| Primary-source cross-check | peraturan.go.id / peraturan.bpk.go.id, putusan3.mahkamahagung.go.id, jdih.kemnaker.go.id | Firecrawl MCP (`firecrawl_search`, `firecrawl_scrape`) | Yes | Cross-check key articles in Phase C |
| Clause library | `references/pasal/*.md` | file read by kontrak-draft | No | Create in Phases G-H (real clauses with real basis) |
| UMK / rates at contract time | Firecrawl live fetch | `firecrawl_search` | Yes | Fetched per contract, stored only in that contract's `brief.md` with date |
| PDF render | `scripts/build.sh` + `templates/style.css` (adapted from Herry's) | pandoc + Chrome headless | Source yes | Create parametrised copy in Phase J |
| DOCX render | skill `anthropic-skills:docx` (same route as gaspol-brdwriter's brd-finish) fed by the stripped, letterhead-filled markdown | Skill tool | Yes | Invoke from kontrak-finish in Phase J; letterhead as document header |
| Logo | `/Users/alisadikin/Drive-D/my-data/INDUSIA/PT/brand-industria-logo.png` | env `KONTRAK_LOGO`, default this path | Yes | Do not copy into repo |
| Plugin manifest | `.claude-plugin/plugin.json` | — | No | Create in Phase A |

## Out of scope (one line)
Shareholder agreements / AD (see vault `startup-notariil-conversion-method`), consultant-company (PT-to-PT) service contracts, payroll computation, e-signature integration, `git init`.

---

### Phase A: Scaffold + test harness

**Estimated time:** 10 minutes

**Files:**
- Create: `.claude-plugin/plugin.json`, `.gitignore`, `README.md`
- Create: `tests/run-all.sh`, `tests/frontmatter.sh`, `tests/guard-generic.sh`
- Create dirs: `skills/`, `references/hukum/`, `references/pasal/`, `templates/`, `scripts/`, `evals/`, `research/`

**Steps:**
1. Write failing test for the harness itself: `tests/frontmatter.sh` asserts `.claude-plugin/plugin.json` exists with keys `name` = `gaspol-kontrakkerja`, `version`, `description`, and that `tests/run-all.sh` prints `ALL GREEN`. Expected error: `plugin.json: No such file or directory`.
2. Run `bash tests/run-all.sh`, confirm it prints `MISSING` / `SOME RED` for the expected reason.
3. Create `plugin.json` modelled on brdwriter's (author `Ali Sadikin`, version `0.1.0`, license MIT, keywords `kontrak`, `ketenagakerjaan`, `hki`, `indonesia`). Create `.gitignore` containing `work/`, `*.pdf`, `.gaspol/`, `*.docx` (working folders hold candidate personal data).
4. Write `tests/guard-generic.sh`: fails if any file under the repo (excluding `docs/`, `research/`) contains a 16-digit number (NIK pattern `[0-9]{16}`), the words `Herry`, `ktp-`, `npwp-`, or a literal NPWP/NIB value (letterhead values must be `{{...}}` placeholders).
5. Write `tests/run-all.sh` with explicit list `frontmatter.sh guard-generic.sh`; `set -uo pipefail`; missing script = RED.
6. Run `bash tests/run-all.sh`; confirm `ALL GREEN`.
7. Commit: n/a (no git). Record in ledger Phase log: `n/a (no git)`.

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] `plugin.json` is valid JSON (`python3 -c "import json;json.load(open('.claude-plugin/plugin.json'))"` exits 0)
- [ ] No placeholder/TODO comments in new files

---

### Phase B: NotebookLM notebook + primary sources

**Estimated time:** 20 minutes (external waits for source processing; not reducible)

**Files:**
- Create: `research/sources.md` (list of every source URL added, with date and what it is)
- Create: `tests/research-shape.sh`

**Steps:**
1. Write failing test `tests/research-shape.sh`: asserts `research/sources.md` exists, has a line `notebook-id:` for the new notebook, and has at least 20 source lines each matching `^- https?://`. Expected error: `research/sources.md: No such file or directory`.
2. Run test, confirm it fails for the expected reason.
3. Run `notebooklm list`; confirm the notebook with id starting `608b5183` exists. If it is missing from the list, STOP and ask the user (do not silently create a replacement).
4. Run `notebooklm create "KONTRAK-ID 2026-10"`; record its full id in `research/sources.md` as `notebook-id: <id>`; `notebooklm use <partial-id>`.
5. Find primary-source URLs with `firecrawl_search` (restrict `includeDomains` to `peraturan.go.id`, `peraturan.bpk.go.id`, `jdih.kemnaker.go.id`, `putusan3.mahkamahagung.go.id`, `pajak.go.id`, `bpjsketenagakerjaan.go.id`, `dpr.go.id`, `mkri.id`). Required coverage, one URL per item minimum: UU 13/2003; UU 6/2023 (Cipta Kerja); PP 35/2021; PP 36/2021 (pengupahan); KUHPer Buku III (Art. 1239, 1304, 1309, 1320, 1425, 1446) and Art. 330, 1601-1601x; UU 28/2014 (Hak Cipta); UU 30/2000 (Rahasia Dagang); UU 13/2016 (Paten); UU 1/2023 (KUHP baru) incl. its effective date; UU 11/2008 jo. UU 1/2024 (ITE); UU 27/2022 (PDP); UU 40/2007 (PT) signing-authority articles; PMK 168/2023 (PPh 21); PPh 23 rule for services; BPJS regulations; MA decisions 3549 K/Pdt/2023, 1248 PK/Pdt/2024, PN Jakarta Barat 832/Pdt.G/2023/PN.Jkt.Brt; MK decision 168/PUU-XXI/2023 and any new UU Ketenagakerjaan issued after it; Kemnaker UMK 2026 reference.
6. Add each with `notebooklm source add <url>`; append the same URL to `research/sources.md` as `- <url> — <what it is> — added YYYY-MM-DD`. A URL that fails to add is logged as `FAILED` with the reason and replaced with an alternative primary URL.
7. Run `notebooklm source wait`; confirm via `notebooklm source list` that every source is processed (none `error`). Failed sources: retry once, then replace.
8. Run the test; confirm it passes. Add `research-shape.sh` to `tests/run-all.sh`.
9. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] `notebooklm source list` shows ≥20 processed sources, zero in error state
- [ ] Every required coverage item in step 5 has a source line (or an explicit `NOT FOUND` line with reason)
- [ ] No placeholder/TODO comments in new files

---

### Phase C: Deep research questions + primary-source cross-check

**Estimated time:** 30 minutes (research output; split across two sittings if needed)

**Files:**
- Create: `research/ask-<domain>.md` for 7 domains (raw answers with the notebook's citations verbatim)
- Create: `research/crosscheck.md`
- Create: `tests/crosscheck-shape.sh`

**Steps:**
1. Write failing test `tests/crosscheck-shape.sh`: asserts `research/ask-*.md` exists for all 7 domains and that `research/crosscheck.md` has one row per key article listed in step 5 with status `MATCH` or `DIVERGED`, none `UNCHECKED`. Expected error: `research/ask-ketenagakerjaan.md: No such file or directory`.
2. Run test, confirm it fails for the expected reason.
3. For each question below run `notebooklm ask "<question>" --json` against the new notebook (`-n <new-id>`); for the ketenagakerjaan, perdata and HKI domains ALSO ask notebook `608b5183` (`-n 608b5183`) and note disagreements. Save question + answer + the citations in `research/ask-<domain>.md`. Every question demands "cite article number or decision number for each statement".
   - **ketenagakerjaan:** (a) Has a new UU Ketenagakerjaan replaced UU 13/2003 following MK 168/PUU-XXI/2023? If yes, effective date and PKWT changes. (b) PKWT conditions: allowed work types, max duration, extension, registration, compensation formula (PP 35/2021). (c) Test for work relationship (three elements) and why fixed hours defeat a freelancer label. (d) Probation rules for PKWTT (max 3 months) and ban for PKWT (Art. 58). (e) Wage floor rules, 75% base-wage rule, criminal sanction for below-UMK. (f) PHK grounds, severance, PKWT early termination (Art. 62, PP 35/2021 Art. 17). (g) Forum: PHI jurisdiction. (h) Minimum age and guardian rules for 18-20-year-olds.
   - **perdata:** (a) Art. 1320 validity conditions and Art. 1446 voidability for minors-by-KUHPer (<21). (b) Art. 1601/1601a/1601b/1601x (employment vs. work-for-hire). (c) Art. 1239 (obligation to do) and why forced performance is impossible. (d) Art. 1304 penalty clause, Art. 1309 judicial reduction, case law on reduction. (e) Art. 1425 set-off. (f) Standard-clause (klausul baku) limits relevant to employer-drafted contracts. (g) Withholding of original documents: legal status.
   - **hki-rahasia-dagang:** (a) Art. 36, 16(2), 5, 18 UU 28/2014 on ownership in employment and commissioned work, and software as a work. (b) Trade-secret elements, "upaya layak", Art. 3 and 13 UU 30/2000, remedies Art. 11. (c) Non-compete validity: MA 3549 K/Pdt/2023, 1248 PK/Pdt/2024 and any later decision; conditions of validity. (d) NDA enforcement case law incl. 832/Pdt.G/2023/PN.Jkt.Brt. (e) Open-source/copyleft liability under UU 28/2014.
   - **pidana:** (a) KUHP baru UU 1/2023 effective date and the transition from the old KUHP. (b) Articles on embezzlement (penggelapan), theft of data/trade secrets, breach of confidentiality, with penalties. (c) UU ITE (UU 1/2024) illegal access, data interference, with penalties. (d) UU 30/2000 criminal provisions for trade-secret breach. (e) Limits: using criminal threats to coerce civil payment.
   - **data-pribadi:** (a) UU 27/2022 controller/processor duties, employee obligations, breach notification, sanctions. (b) Contract clauses needed for staff handling customer personal data.
   - **pajak-jaminan-sosial:** (a) PPh 21 for permanent employee (TER) vs. non-employee continuous (PMK 168/2023, 50% DPP). (b) PPh 23 for service payments to a company (context only). (c) BPJS Ketenagakerjaan and Kesehatan: mandatory enrolment for employees, freelancer status. (d) SPT Masa nihil rule for December. (e) Which tax figures change yearly.
   - **signing-authority (UU PT):** (a) Who may sign for a PT (direksi, Art. 98 UU 40/2007), when commissioner or power of attorney is needed, evidence of authority.
4. Cross-check: use `firecrawl_scrape` on peraturan.go.id / BPK / MA pages to confirm each key article below says what the notebook says. Record `research/crosscheck.md` rows `| Article | Notebook says | Primary source says | URL | MATCH/DIVERGED |`. Key articles: UU 13/2003 Art. 58, 62, 185; PP 35/2021 Art. 8, 14, 15, 16, 17; UU 28/2014 Art. 5, 16(2), 36; UU 30/2000 Art. 3, 11, 13; KUHPer Art. 330, 1304, 1309, 1425, 1446; MA 3549 K/Pdt/2023 holding; KUHP baru effective date; UU 27/2022 breach-notification article. A `DIVERGED` row is resolved by trusting the primary source and annotating the notebook answer in the ask file.
5. Fetch live: UMK Kota Batam 2026 and the PTKP/BPJS facts; record them in `research/ask-pajak-jaminan-sosial.md` with fetch date. These are examples for the library, not stored as permanent constants.
6. Run the test; confirm it passes. Add `crosscheck-shape.sh` to `tests/run-all.sh`.
7. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] Every answer in `research/ask-*.md` cites article or decision numbers (no uncited statement kept)
- [ ] `research/crosscheck.md` has zero `UNCHECKED` rows; every `DIVERGED` row has a resolution note
- [ ] Question (a) of ketenagakerjaan answered explicitly (new UU yes/no with date) — if yes, STOP and tell the user before Phase D (PKWT basis may change)
- [ ] No placeholder/TODO comments in new files

---

### Phase D1: references/hukum — ketenagakerjaan, perdata, pajak-jaminan-sosial, signing-authority

**Estimated time:** 15 minutes

**Files:**
- Create: `references/hukum/ketenagakerjaan.md`, `perdata.md`, `pajak-jaminan-sosial.md`, `signing-authority.md`
- Create: `tests/hukum-shape.sh`, `tests/freshness.sh`

**Steps:**
1. Write failing test `tests/hukum-shape.sh`: for each of the 7 expected files in `references/hukum/` (`ketenagakerjaan perdata hki-rahasia-dagang pidana data-pribadi pajak-jaminan-sosial signing-authority`) assert it exists, frontmatter has `domain:`, `verified: YYYY-MM-DD`, `sources:`, and every body bullet ends with `[dasar: ...]`. Expected error: `references/hukum/ketenagakerjaan.md: No such file or directory`. Also write `tests/freshness.sh`: RED if any `verified:` date is more than 180 days before today (use `date -j -f "%Y-%m-%d"` on macOS).
2. Run `bash tests/hukum-shape.sh`, confirm it fails for the expected reason.
3. Distill `research/ask-*.md` + `research/crosscheck.md` into the four files using the format in "Conventions". Only statements that survived cross-check. Set `verified:` to the cross-check date. Yearly-changing numbers are NOT stated as constants; the file says "verifikasi ulang tiap kontrak" with `[dasar: ...]`.
4. Seed from the vault playbook only where the cross-check confirmed it; where the playbook and the primary source disagree, the primary source wins and the file adds a `Koreksi:` bullet.
5. Run the two tests for the files that exist so far (the shape test is expected RED for the 3 files of Phase D2; temporarily run it with the list restricted by an env var `HUKUM_ONLY="ketenagakerjaan perdata pajak-jaminan-sosial signing-authority"`).
6. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `HUKUM_ONLY="ketenagakerjaan perdata pajak-jaminan-sosial signing-authority" bash tests/hukum-shape.sh` exits 0
- [ ] `bash tests/freshness.sh` exits 0
- [ ] Every bullet has a `[dasar: ...]` tag; none states a yearly figure as a constant
- [ ] No placeholder/TODO comments in new files

---

### Phase D2: references/hukum — hki-rahasia-dagang, pidana, data-pribadi

**Estimated time:** 15 minutes

**Files:**
- Create: `references/hukum/hki-rahasia-dagang.md`, `pidana.md`, `data-pribadi.md`
- Modify: `tests/run-all.sh` (add `hukum-shape.sh`, `freshness.sh`)

**Steps:**
1. Write failing test: run `bash tests/hukum-shape.sh` with no `HUKUM_ONLY` set. Expected error: `references/hukum/hki-rahasia-dagang.md: No such file or directory` (and `pidana.md`, `data-pribadi.md`).
2. Run it, confirm failure is exactly those three missing files.
3. Distill the three domains from `research/`. `pidana.md` states the KUHP baru effective date and which articles replace the old ones, and includes the bullet "Pidana dalam kontrak = pemberitahuan, bukan ancaman untuk menagih utang perdata" with its basis from the research.
4. `hki-rahasia-dagang.md` must contain: ownership default in employment/commission (Art. 36) and why an explicit assignment is required (Art. 16(2)); moral rights (Art. 5); trade-secret "upaya layak" (Art. 3); non-compete validity decisions with their numbers; NDA precedent.
5. Add `hukum-shape.sh` and `freshness.sh` to `tests/run-all.sh`. Run `bash tests/run-all.sh`.
6. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN` (all 7 hukum files present and fresh)
- [ ] `pidana.md` states the KUHP baru effective date with its basis
- [ ] `hki-rahasia-dagang.md` cites Art. 36, 16(2), 5 UU 28/2014 and Art. 3 UU 30/2000
- [ ] No placeholder/TODO comments in new files

---

### Phase E1: Clause library — kerahasiaan, hki, non-kompetisi, clean-room, copyleft, data-klien

**Estimated time:** 15 minutes

**Files:**
- Create: `references/pasal/kerahasiaan.md`, `hki.md`, `non-kompetisi.md`, `clean-room.md`, `copyleft.md`, `data-klien.md`
- Create: `tests/pasal-shape.sh`

**Steps:**
1. Write failing test `tests/pasal-shape.sh`: every `references/pasal/*.md` has ≥1 entry; every `## P-` entry has all 8 fields (`Dasar hukum`, `Tujuan`, `Berlaku untuk`, `Varian standar`, `Varian ketat`, `Pengecualian wajib`, `Risiko`, `Verified`), none empty; ids are unique across files and match `P-[A-Z]+-[0-9]{2}`; every `Dasar hukum` article string appears (substring, normalised) inside some `references/hukum/*.md` `[dasar: ...]` tag. Expected error: `references/pasal: no such file or directory`.
2. Run, confirm the expected failure.
3. Write entries (Indonesian clause text; each with real basis from `references/hukum/`). Minimum content:
   - `kerahasiaan` (RHS): definition of Informasi Rahasia incl. client data, source code, architecture, credentials; duty of "upaya layak" (explicit sentence that this clause is the owner's reasonable effort, Art. 3 UU 30/2000); source code + trade secret confidentiality **without time limit**, general information 2 years; permitted-disclosure exceptions (legal compulsion, already public); return/destroy on end; remedies per Art. 13 UU 30/2000.
   - `hki` (HKI): broad "Hasil Karya" definition (use the exact list in G6); written, comprehensive, permanent, irrevocable economic-rights assignment (Art. 16(2) UU 28/2014) across all projects/customers/lines with no per-project addendum; moral rights non-assertion; **risk note (research Phase C): Art. 18 UU 28/2014 returns a karya tulis/music right to the creator after 25 years for outright/unlimited assignments; software is not named, so the `Risiko` field must state this and the clause must use a licence-back/ confirmation-of-assignment mechanism chosen from `references/hukum/hki-rahasia-dagang.md`**; no time limit on use/sale/publication ban; applies to FL and employees; pre-existing-IP carve-out with licence-back.
   - `non-kompetisi` (NK): purpose sentence naming trade-secret protection; specific activity + duration + area; adult-signatory note; link to MA 3549 K/Pdt/2023; violation = wanprestasi.
   - `clean-room` (CR): no reuse of former-employer or other-client code; no reuse of INDUSIA/customer code for others; separate personal devices/repos rule.
   - `copyleft` (CL): warranty of no GPL/AGPL component without written approval; third-party licence log duty.
   - `data-klien` (DK): UU 27/2022 duties for staff handling customer personal data; access on need-to-know; no copying to personal storage; breach reporting within a stated internal window; notice (not threat) of ITE/KUHP consequences.
4. Run `bash tests/pasal-shape.sh` for these six files; fix until green. Add to `tests/run-all.sh`.
5. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/pasal-shape.sh` exits 0
- [ ] `hki.md` "Hasil Karya" definition lists every item in G6
- [ ] `non-kompetisi.md` entries all carry an explicit trade-secret purpose sentence
- [ ] No placeholder/TODO comments in new files

---

### Phase E2: Clause library — aset-akses, ganti-rugi, forum-sengketa, pemutusan, pajak

**Estimated time:** 15 minutes

**Files:**
- Create: `references/pasal/aset-akses.md`, `ganti-rugi.md`, `forum-sengketa.md`, `pemutusan.md`, `pajak.md`

**Steps:**
1. Write failing test: extend `tests/pasal-shape.sh` with an expected-group check — files `kerahasiaan hki non-kompetisi clean-room copyleft data-klien aset-akses ganti-rugi forum-sengketa pemutusan pajak` all exist, and each Berlaku untuk value is a subset of `PKWT, PKWTT, FL`. Expected error: `references/pasal/aset-akses.md: No such file or directory`.
2. Run, confirm the expected failure.
3. Write entries:
   - `aset-akses` (AA): return of devices/credentials/repos on end; access revoked; **no** holding of ijazah/KTP/original documents (stated as a prohibition the company binds itself to).
   - `ganti-rugi` (GR): damage clause capped around 1 month fee/wage for asset damage (Art. 1304/1309); IP/trade-secret breaches excluded from the cap; set-off against unpaid remuneration (Art. 1425); mandatory reasonable exits (sick with doctor note, force majeure, employer breach, hazardous assignment).
   - `forum-sengketa` (FS): employment -> musyawarah, bipartit, mediasi, PHI; freelancer agreement -> musyawarah then PN (domicile stated).
   - `pemutusan` (PM): PKWT early end and compensation (PP 35/2021 Art. 15-17); worker resigns before term (Art. 62); PKWTT notice/PHK reference; freelancer termination notice.
   - `pajak` (PJ): FL = PPh 21 non-employee with letter-of-sole-income attachment; employee = PPh 21 pegawai tetap/TER; BPJS wording "sesuai peraturan yang berlaku" with **no percentages**; UMK clause referencing "UMK yang berlaku, diverifikasi pada tanggal penandatanganan".
4. Run `bash tests/run-all.sh`; fix until green.
5. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] `ganti-rugi.md` entries: cap ≈ 1 month, exits listed, set-off present, IP breach excluded from cap
- [ ] `pajak.md` contains no tax/BPJS percentage figure
- [ ] No placeholder/TODO comments in new files

---

### Phase F: Templates + fixtures (before any skill)

**Estimated time:** 15 minutes

**Files:**
- Create: `templates/brief-template.md`, `templates/kontrak-pkwt.md`, `templates/kontrak-pkwtt.md`, `templates/kontrak-freelancer.md`, `templates/lampiran-ip.md`, `templates/kop.html`
- Create: `references/examples/good-kontrak.md`, `references/examples/bad-kontrak.md`
- Create: `tests/fixture-shape.sh`

**Steps:**
1. Write failing test `tests/fixture-shape.sh`: `bad-kontrak.md` contains the six planted-defect markers `<!-- DEFECT D1 -->` … `<!-- DEFECT D6 -->`, each on the defective clause: D1 probation clause inside a PKWT (G1/Art. 58); D2 clause withholding original diploma (G3); D3 penalty equal to 12 months wage (G3/Art. 1309); D4 source-code confidentiality limited to 1 year and IP use ban limited to 1 year (G3/G6); D5 candidate born so that age is 19 with no guardian block (G5); D6 a UMK figure with no verification date (G8). `good-kontrak.md` contains zero `DEFECT` markers and every clause has a `Catatan penyusun — dasar:` line. Expected error: `references/examples/bad-kontrak.md: No such file or directory`.
2. Run, confirm the expected failure.
3. Write the three contract templates and `lampiran-ip.md` as skeletons whose clause slots are `{{CLAUSE:P-XXX-NN}}` markers (draft fills them from the library) plus party/term placeholders `{{PIHAK_KEDUA_NAMA}}`, `{{TANGGAL_MULAI}}`, etc. Placeholders only in templates; never in a finished `kontrak.md`.
4. Write `templates/kop.html` with the letterhead markup from Herry's `build.sh` but every company value as a placeholder: `{{PT_NAMA}}`, `{{PT_ALAMAT}}`, `{{PT_NIB}}`, `{{PT_NPWP}}`, `{{PT_SK_MENKUMHAM}}`, `{{PT_TELP}}`, `{{PT_EMAIL}}`, `{{PT_TAGLINE}}`, and `{{LOGO_B64}}`.
5. Write `bad-kontrak.md` (fictional party "Budi Contoh", fictional data only — no real person) and `good-kontrak.md` (same facts, all defects fixed, every clause tagged with real P-ids and articles from the library).
6. Run `bash tests/fixture-shape.sh`; add to `tests/run-all.sh`; run all.
7. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] `bad-kontrak.md` has exactly six `DEFECT` markers D1-D6; `good-kontrak.md` has none
- [ ] `guard-generic.sh` still green (no real personal or company data in templates/fixtures)
- [ ] No placeholder/TODO comments in new files (template `{{...}}` slots excepted — they are the contract)

---

### Phase G: Skill kontrak-brainstorm

**Estimated time:** 15 minutes

**Files:**
- Create: `skills/kontrak-brainstorm/SKILL.md`
- Modify: `tests/frontmatter.sh` (also check each `skills/*/SKILL.md` has `name:` equal to folder name and a `description:`), create `tests/skill-content.sh`, `tests/refs-resolve.sh`

**Steps:**
1. Write failing test `tests/skill-content.sh` for this skill: SKILL.md contains the strings `AskUserQuestion`, `wadah`, `brief.md`, `[ASUMSI]`, `references/hukum/ketenagakerjaan.md`, `playbook-kontrak-kerja-id`, and refuses (text "STOP") to invent a wage, a date, or a party identity. `tests/refs-resolve.sh`: every `../../references/...` / `../../templates/...` path in any SKILL.md resolves from the skill folder. Expected error: `skills/kontrak-brainstorm/SKILL.md: No such file or directory`.
2. Run, confirm the expected failure.
3. Write the skill. Frontmatter `name: kontrak-brainstorm`, `description:` with Indonesian trigger words (buat kontrak kerja, perjanjian freelancer, PKWT, NDA, kontrak karyawan, lampiran IP). Behaviour contract:
   - Announce at start in Indonesian.
   - Read vault `company-legal.md` and `playbook-kontrak-kerja-id.md` first; if vault is unreadable say so, ask; never treat unreadable as empty.
   - Interview ONE question per message via AskUserQuestion, max 3 questions per turn only if the user asked to batch. Fact set to cover: party identity (name, birth date -> age, address, ID type, NPWP yes/no), role and work product, hours/place/tools/supervision (the three-element test), exclusivity and other clients, duration, remuneration (amount asked from user, never invented; UMK fetched live via Firecrawl with date), access level to source code and client data, whether the person will build INDUSIA-owned IP, pre-existing IP, non-compete need.
   - Decide **wadah** from facts using the test in `../../references/hukum/ketenagakerjaan.md`; present the reasoning in plain Indonesian; if the user insists on a wadah the facts contradict, explain the consequence once and let G1 decide later (do not silently comply).
   - Under-21 candidate -> add guardian-signature requirement to the brief.
   - Write `brief.md` from `../../templates/brief-template.md`; every fact tagged `[user]/[vault]/[riset]/[ASUMSI]`; list "Hal yang belum diketahui" explicitly.
   - Never invent a price, date, name, or ID number: STOP and ask.
4. Run `bash tests/skill-content.sh`, `tests/refs-resolve.sh`, `tests/frontmatter.sh`; add the two new scripts to `tests/run-all.sh`; run all.
5. Dry-run: invoke the skill on the fictional "Budi Contoh" scenario in a scratch folder under the session scratchpad; confirm it produces a `brief.md` with all tags and a wadah decision.
6. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] Dry-run `brief.md` has every fact tagged and a stated wadah reasoning
- [ ] Skill text forbids inventing wage/date/identity (grep proves the STOP rule)
- [ ] No placeholder/TODO comments in new files

---

### Phase H: Skill kontrak-draft

**Estimated time:** 15 minutes

**Files:**
- Create: `skills/kontrak-draft/SKILL.md`
- Modify: `tests/skill-content.sh`

**Steps:**
1. Write failing test: extend `tests/skill-content.sh` — kontrak-draft SKILL.md contains `brief.md`, `references/pasal/`, `Catatan penyusun — dasar:`, `lampiran-ip.md`, a refusal rule ("refuse" / "STOP") when `brief.md` is missing or has an `[ASUMSI]` on a legal-critical fact, the sentence that the word "dijamin" must never appear in the output, and the drafter-note requirement (rule-check date + advocate review recommended). Expected error: `skills/kontrak-draft/SKILL.md: No such file or directory`.
2. Run, confirm the expected failure.
3. Write the skill. Contract: refuses without `brief.md`; picks template by wadah; fills each `{{CLAUSE:P-XXX-NN}}` by selecting the clause variant (standard vs strict: strict when role has source-code or client-data access); every clause gets the `> **Catatan penyusun — dasar:** P-XXX-NN; <article>` line; attaches `lampiran-ip.md` to all three types; adds guardian block when brief says age <21; adds PT signatory block per `references/hukum/signing-authority.md` and vault `company-legal`; ends with a `# CATATAN PENYUSUN` section listing assumptions, verification dates of every referenced hukum file, and the sentence "Draf ini lolos pemeriksaan aturan per <tanggal>. Tinjauan advokat disarankan sebelum tanda tangan."; numbering renumbered fully (never `2a.`, `4a.` — Markdown does not support them); prorata uses calendar days with the formula written out; BPJS and tax wording without percentages; no `{{` left in output; criminal-law text only as a notice.
4. Run `bash tests/run-all.sh`.
5. Dry-run from the Phase G dry-run `brief.md`: produce `kontrak.md`; grep it: zero `{{`, every clause followed by a `dasar:` line, zero occurrences of `dijamin`.
6. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] Dry-run `kontrak.md`: `grep -c '{{'` = 0; `grep -ci dijamin` = 0; each clause heading has a following `dasar:` line
- [ ] Draft refuses when `brief.md` absent (dry-run in an empty scratch folder)
- [ ] No placeholder/TODO comments in new files

---

### Phase I: Skill kontrak-gate + eval against fixtures

**Estimated time:** 20 minutes

**Files:**
- Create: `skills/kontrak-gate/SKILL.md`, `evals/01-bad-fixture.md`, `evals/02-good-fixture.md`
- Modify: `tests/skill-content.sh`

**Steps:**
1. Write failing test: extend `tests/skill-content.sh` — gate SKILL.md contains all of `G1` … `G9` with their names, `PASS`, `BLOCKING`, `kontrak_sha256`, `reviewed_at`, `180`, and the rule "loop back to kontrak-draft until PASS". Expected error: `skills/kontrak-gate/SKILL.md: No such file or directory`.
2. Run, confirm the expected failure.
3. Write the skill: reads `kontrak.md`, `brief.md`, `../../references/pasal/*`, `../../references/hukum/*`; checks G1-G9 exactly as in the "Gate list" section of this plan (copy verbatim); each finding cites the clause and the evidence; emits `review.md` in the format in "Conventions"; verdict BLOCKING on any failed gate; never edits `kontrak.md`; after BLOCKING says what to fix and routes back to kontrak-draft.
4. Write `evals/01-bad-fixture.md` (expected: run gate on `references/examples/bad-kontrak.md` -> BLOCKING, findings must include G1 (D1), G3 (D2, D3), G6 or G3 (D4), G5 (D5), G8 (D6)) and `evals/02-good-fixture.md` (expected PASS).
5. Run the eval for real: copy each fixture into a scratch folder as `kontrak.md` (plus a minimal `brief.md`), dispatch a subagent that follows the gate skill, compare to expectations. A bad fixture that passes, or a defect not caught, means FIX THE GATE SKILL and re-run; never edit the fixture to make the gate pass.
6. Run `bash tests/run-all.sh`.
7. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] Eval 01: gate returns BLOCKING and catches all six defects D1-D6 (evidence quoted in `review.md`)
- [ ] Eval 02: gate returns PASS on `good-kontrak.md`
- [ ] No placeholder/TODO comments in new files

---

### Phase J: Render scripts (PDF + DOCX) + skill kontrak-finish

**Estimated time:** 20 minutes

**Files:**
- Create: `scripts/clean.sh` (strip rules + letterhead placeholder fill, shared by PDF and DOCX paths), `scripts/build.sh` (PDF), `templates/style.css` (copy of `/Users/alisadikin/Drive-D/my-data/INDUSIA/Karyawan/Herry/style.css`), `skills/kontrak-finish/SKILL.md`
- Create: `tests/build-smoke.sh`

**Steps:**
1. Write failing test `tests/build-smoke.sh`: runs `bash scripts/build.sh references/examples/good-kontrak.md "$TMPDIR/out.pdf"` with a stub vault note fixture; asserts the PDF exists, is >10 KB, `pdftotext` (or `mdls`/`strings` fallback) shows no `{{` and no `Catatan penyusun`, and the drafter-note section is absent; also asserts `scripts/clean.sh` output has no `{{`, no `Catatan penyusun`, and contains the company name read from the stub vault note (this cleaned markdown is the shared input of both formats). Expected error: `scripts/build.sh: No such file or directory`.
2. Run, confirm the expected failure.
3. Write `scripts/build.sh` adapted from Herry's script: arguments `<kontrak.md> <out.pdf> [company-legal.md]`; NO hardcoded personal paths — logo from `$KONTRAK_LOGO` (default `/Users/alisadikin/Drive-D/my-data/INDUSIA/PT/brand-industria-logo.png`), CSS from `../templates/style.css`, letterhead from `../templates/kop.html` with `{{...}}` values filled by reading `company-legal.md` (default `/Users/alisadikin/Drive-D/Obsidian-Vault/10-Identity/company-legal.md`); temp files via `mktemp -d`; strip rules as in Conventions; signature-block `::: ttd` wrapper, `page-break-before` for lampiran as in Herry's script; missing logo or vault note -> exit 2 with a clear message (never render a letterhead with blank values).
4. Write the skill: refuses without a current PASS (`review.md` verdict PASS AND `kontrak_sha256` equals `shasum -a 256 kontrak.md`); reads vault `company-legal.md`; runs `scripts/build.sh`; produces BOTH formats from the same cleaned markdown: PDF via `scripts/build.sh`, DOCX via the `anthropic-skills:docx` skill (letterhead as document header, signature table, no drafter notes); names outputs `KONTRAK-<CODE>-<NNN>.pdf` and `KONTRAK-<CODE>-<NNN>.docx` (CODE from brief: initials + type, NNN sequence in folder); looks at the rendered first page and signature page (convert with `pdftoppm` or Chrome screenshot) to confirm logo visible and signature block not split; offers (not forces) writing durable lessons to the vault via `gaspol-learn`/vault note.
5. Run `bash tests/run-all.sh`.
6. Render the real smoke: `good-kontrak.md` -> PDF and DOCX; open PDF page images and confirm letterhead + signatures; unzip the DOCX (`unzip -p out.docx word/document.xml`) and confirm no `{{`, no `Catatan penyusun`, company name present, and the signature table is present.
7. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] DOCX rendered from `good-kontrak.md` opens (valid zip with `word/document.xml`), has no `{{`, no `Catatan penyusun`, and the signature table
- [ ] PDF rendered from `good-kontrak.md` shows the letterhead with logo, no `{{`, no drafter notes, signature block on one page (viewed, not assumed)
- [ ] `build.sh` exits 2 with a message when the logo path or vault note is missing (tested)
- [ ] Skill refuses when `review.md` is absent, BLOCKING, or sha-stale (grep proves the rule; dry-run proves it)
- [ ] No placeholder/TODO comments in new files

---

### Phase K: Router skill + README + CLAUDE.md sync + final run

**Estimated time:** 15 minutes

**Files:**
- Create: `skills/gaspol-kontrakkerja/SKILL.md`
- Modify: `README.md`, `CLAUDE.md`, `tests/skill-content.sh`

**Steps:**
1. Write failing test: extend `tests/skill-content.sh` — router SKILL.md contains the routing table rows for `brief.md`, `kontrak.md`, `review.md`, the five skill names, and the sentence that nothing reaches a PDF without a current PASS; and `README.md` states the honest-guarantee boundary and contains no occurrence of `dijamin` except inside a "tidak ..." negation line. Expected error: `skills/gaspol-kontrakkerja/SKILL.md: No such file or directory`.
2. Run, confirm the expected failure.
3. Write the router (pattern: brdwriter router): announce in Indonesian; routing table by run files and mtimes — nothing -> kontrak-brainstorm; `brief.md` only -> kontrak-draft; `kontrak.md` newer than `review.md` or no review -> kontrak-gate; `review.md` BLOCKING -> kontrak-draft; current PASS -> kontrak-finish; PDF newer than PASS -> done. Router never writes contract text.
4. Write `README.md`: what it does, the pipeline, honest-guarantee boundary, how to refresh `references/hukum/` (re-run research phases, update `verified:`), requirement list (pandoc, Chrome, vault, NotebookLM only for refresh).
5. Update `CLAUDE.md`: skills/reads/writes table, test contracts (fixture defects D1-D6 are never fixed; `references/hukum` freshness 180 days; `{{...}}` slot contract), ticket counter unchanged.
6. Run `bash tests/run-all.sh`; confirm `ALL GREEN`.
7. End-to-end dry-run in a scratch folder: router -> brainstorm (fictional person) -> draft -> gate -> (PASS) -> finish -> PDF. If the gate returns BLOCKING, loop to draft until PASS; record how many rounds.
8. Commit: n/a (no git).

**Verification:**
- [ ] detect-stack: no stack markers for this project — verification is plan-declared only
- [ ] `bash tests/run-all.sh` prints `ALL GREEN`
- [ ] End-to-end dry-run produced a PDF only after a current PASS
- [ ] README states the guarantee boundary; no unqualified "dijamin"
- [ ] `CLAUDE.md` lists all skills and test contracts
- [ ] No placeholder/TODO comments in new files
