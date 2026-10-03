# gaspol-kontrakkerja

Claude Code plugin that drafts Indonesian work contracts for a software house (built for PT INDUSIA):
PKWT, PKWTT, freelancer service agreements, and an attachment (Lampiran I) with NDA, IP assignment and
non-compete. Every clause carries a cited legal basis. A blocking gate rejects fragile clauses before a
PDF (for signing) and a DOCX (for editing) are produced on the company letterhead.

Status: v0.1.0. Contract text and skills are in Bahasa Indonesia; this README is English.

## Pipeline

| Skill | Does | Writes |
|---|---|---|
| `gaspol-kontrakkerja` | Router. Picks the next skill from the run files in the working folder. | nothing |
| `kontrak-brainstorm` | Reads the vault, interviews one question at a time, decides the wadah (PKWT, PKWTT, freelancer) from the facts, not the label. | `brief.md` |
| `kontrak-draft` | Fills a template from the clause library (`references/pasal/`), one legal-basis line under every clause. | `kontrak.md` |
| `kontrak-gate` | Nine gates (G1-G9), quoted evidence per finding. BLOCKING loops back to draft until PASS. | `review.md` |
| `kontrak-finish` | Only with a current PASS (verdict PASS and `kontrak_sha256` equals the sha of `kontrak.md`). Renders both formats. | `KONTRAK-<CODE>-<NNN>.pdf`, `.docx` |

One working folder holds one contract. Personal data of the signatory lives only in that folder
(`*.pdf`, `*.docx`, `work/` and `.gaspol/` are gitignored).

## What it does not guarantee

This plugin does not guarantee that a contract is free of legal problems. A PASS means the rule-check
passed as of the date in `review.md`. It is not legal advice and not a validity opinion. What it does:

- every clause cites a legal basis taken from the clause library, which is distilled from researched and
  cross-checked sources (`references/hukum/`, each file dated by `verified:`);
- a blocking gate rejects known fragile or forbidden clauses (probation in a PKWT, withheld documents, wage
  below UMK, penalty far above one month, time-limited IP ownership, missing guardian for a signatory under
  21, and more);
- the PDF carries the sentence that advocate review is recommended before signing.

The word "dijamin" is never written into a contract. There is no guarantee in the output: tidak ada
jaminan bahwa kontrak bebas masalah hukum. Have an advocate review the final text.

Clauses that rest on weak grounds (the drafter's own design, secondary sources, no explicit article) are
flagged in the `Risiko` field of each entry in `references/pasal/`, and `kontrak-draft` lists the installed
ones in the drafter-notes section of `kontrak.md` (stripped from the PDF and DOCX).

## PT INDUSIA specifics

Company data is never stored in the plugin. It is read at run time from the user's vault note
`/Users/alisadikin/Drive-D/Obsidian-Vault/10-Identity/company-legal.md`. Expected format: a bullet list
`- **<Key>**: value`, and the address as the first non-empty line under a `## Alamat` heading.

| Field | Where | Required |
|---|---|---|
| `- **Nama**:` | legal company name | yes |
| `## Alamat` | first line under the heading | yes |
| `- **NIB**:` | NIB number | yes |
| `- **NPWP**:` | company NPWP | yes |
| `- **SK Pengesahan**:` | Menkumham approval number | yes |
| `- **Telp**:` | phone | yes |
| `- **Email**:` | email | yes |
| `- **Merek**:` | brand word on the letterhead | optional; without it the legal name is the wordmark |
| `- **Tagline**:` | letterhead tagline | optional; without it the cell is dropped |

A missing required value stops the render with exit code 2 (a letterhead is never printed with blanks).
The signatory and the basis of authority are also read from the vault note and checked against
`references/hukum/signing-authority.md`.

Logo: environment variable `KONTRAK_LOGO` (PNG path). The default is the INDUSIA brand logo on the
author's machine; set it on any other machine. The logo is never copied into the repo.

## Requirements

- Claude Code with the `anthropic-skills:docx` skill for the DOCX.
- `pandoc` and Google Chrome (headless) for the PDF. `CHROME` overrides the Chrome path.
- `pdftoppm` (poppler) to view the rendered pages. Optional, but the finish skill wants to look at them.
- `node` and the npm package `docx` for `scripts/md2docx.js`. It ships with the docx skill; if it fails to
  load, run `npm install docx` in a temp folder and set `NODE_PATH` to that `node_modules`.
- Firecrawl MCP for the live UMK lookup during the interview (value, source URL and fetch date go into `brief.md`).
- The vault notes above. NotebookLM CLI only when refreshing the law library.

## Refresh the law library

`references/hukum/*.md` carry `verified: YYYY-MM-DD`. The gate fails (G8) and the test
`tests/freshness.sh` goes red when any file is older than 180 days. To refresh:

1. Re-run the research with the NotebookLM CLI against the sources listed in `research/sources.md`
   (add new primary sources first, `notebooklm source add`, then `notebooklm ask` per domain as in
   `research/ask-*.md`).
2. Cross-check key articles against the primary source (`research/crosscheck.md`), trust the primary source.
3. Update the affected `references/hukum/*.md` and `references/pasal/*.md`, then set `verified:` to the
   cross-check date.
4. `bash tests/run-all.sh` must print `ALL GREEN`.

## Pending risk

A new UU Ketenagakerjaan may land around October 2026: the Constitutional Court (MK 168/PUU-XXI/2023)
gave the legislature about two years, so the deadline is roughly 31 October 2026. As of 2026-10-03
no replacement exists and UU 13/2003 as amended remains in force. When a new law is issued, the PKWT
basis (allowed work types, duration, compensation) must be re-researched before any PKWT is issued;
`kontrak-brainstorm` warns about this at the start of every run.

## Tests

`bash tests/run-all.sh` runs an explicit list of bash tests (a missing script is RED). The fixtures
`references/examples/bad-kontrak.md` (six planted defects) and `good-kontrak.md` are the gate's evals
(`evals/`). Fixture party data is fictional.

License: MIT.
