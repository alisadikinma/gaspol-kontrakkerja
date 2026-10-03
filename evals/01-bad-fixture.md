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

## Round 1

Verdict BLOCKING (G1, G2, G3, G5, G6, G8 failed; G4, G7, G9 passed). Caught: D1 (G1), D2 (G3), D3 (G3), D4 (G3 and G6), D5 (G5), D6 (G8), plus "telah dewasa" (G5) and a G2 finding that Pasal 10 rests on P-AA-01 while P-AA-03 is the id that prohibits withholding. Missed: none. Gate skill unchanged; no rounds needed after this.
