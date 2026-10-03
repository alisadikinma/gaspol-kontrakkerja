# Eval 01 — gate on the bad fixture

**Input:** `references/examples/bad-kontrak.md` copied to a scratch folder as `kontrak.md`, with a minimal consistent `brief.md` (PKWT, born 2007, guardian required, upah Rp 6.500.000, no stored UMK figure). The scratch copy has the `<!-- DEFECT Dn -->` markers and the fixture-note line in `# CATATAN PENYUSUN` removed (they would hint the answer) and a `<!-- GATE-STATUS -->` last line added, as kontrak-draft would write it. The fixture file itself is untouched.

**Method:** a separate sonnet subagent is told only "follow skills/kontrak-gate/SKILL.md literally on this folder and write review.md". No hint of the defects.

**Expected:** `## Verdict: BLOCKING`, `kontrak_sha256` equal to the scratch `kontrak.md`, and findings with quoted evidence:

| Defect | Gate | Evidence expected |
|---|---|---|
| D1 probation in PKWT (Pasal 2) | G1 | "masa percobaan selama 3 (tiga) bulan" |
| D2 original diploma held (Pasal 10) | G3 | "menyimpan ijazah asli" |
| D3 penalty 12 months wage (Pasal 11) | G3 | "penalti tetap sebesar 12 (dua belas) bulan upah" |
| D4 source-code confidentiality and IP use limited to 1 year (Lampiran I Pasal 3) | G3 and/or G6 | "hanya berlaku selama 1 (satu) tahun" |
| D5 age 19, no guardian block | G5 | birth date vs. signature block |
| D6 UMK figure with no date (Pasal 3) | G8 | "UMK) Kota Batam sebesar Rp 4.000.000" |

**Additional expected catch (not planted as D1-D6):** Lampiran I Pasal 12 "Pihak Kedua menyatakan telah dewasa menurut hukum" while under 21 — G5/G1 contradiction.

## Evidence

Verbatim gate output: `evals/results/01-bad-fixture-review.md` (separate sonnet subagent, no defect hints; scratch brief is a fictional-data fixture brief with a dated UMK record).

Result, round 2 (round 1 was blocked only by the scratch brief, see below): verdict BLOCKING; caught D1 (G1), D2 (G2 and G3), D3 (G3), D4 (G3 and G6), D5 (G5), D6 (G8), plus the extra "telah dewasa" catch (G5). Missed: none. Gate skill needed no change for this fixture.

Fix-round 1 re-run (new rules: Status kawin, post-employment restriction under 21, P-HKI-04, place of work): verdict BLOCKING; D1 (G1), D2 and D3 (G3), D4 (G3/G6), D5 (G5), D6 (G8) all caught, plus the extra "telah dewasa" catch and the new G1 finding (no place of work) and G4 finding (post-employment clause for an unmarried 19-year-old). Scratch brief gained `Status kawin: belum kawin`. Verbatim output refreshed in `evals/results/01-bad-fixture-review.md`.
