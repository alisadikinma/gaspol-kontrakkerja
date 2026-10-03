# Eval 02 — gate on the good fixture

**Input:** `references/examples/good-kontrak.md` copied to a scratch folder as `kontrak.md`, same minimal `brief.md` as eval 01. Fixture byte-identical (last line is the fixture's own drafter note).

**Method:** separate sonnet subagent, same prompt as eval 01, no hints.

**Expected:** `## Verdict: PASS`, all nine gate rows PASS, `kontrak_sha256` matches.

**Fixture fix made before the eval:** the good fixture (party aged 19, guardian block present) still carried the library sentence "telah dewasa menurut hukum" in Lampiran I Pasal 12. Replaced with the kontrak-draft guardian-consent wording ("belum genap 21 (dua puluh satu) tahun, sehingga klausul ini ditandatangani dengan persetujuan Wali …"). `bad-kontrak.md` was not touched; it keeps the sentence as an extra catch.

## Round 1

Verdict PASS, nine rows PASS, sha matched. Non-blocking notes only (UMK not comparable because the brief stores no figure; set-off advokat note; vault entity differs from fictional PT; new UU Ketenagakerjaan pending). No gate change needed.
