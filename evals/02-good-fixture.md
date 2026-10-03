# Eval 02 — gate on the good fixture

**Input:** `references/examples/good-kontrak.md` copied to a scratch folder as `kontrak.md`, same minimal `brief.md` as eval 01. Fixture byte-identical (last line is the fixture's own drafter note).

**Method:** separate sonnet subagent, same prompt as eval 01, no hints.

**Expected:** `## Verdict: PASS`, all nine gate rows PASS, `kontrak_sha256` matches.

**Fixture fix made before the eval:** the good fixture (party aged 19, guardian block present) still carried the library sentence "telah dewasa menurut hukum" in Lampiran I Pasal 12. Replaced with the kontrak-draft guardian-consent wording ("belum genap 21 (dua puluh satu) tahun, sehingga klausul ini ditandatangani dengan persetujuan Wali …"). `bad-kontrak.md` was not touched; it keeps the sentence as an extra catch.

## Evidence

Verbatim gate output: `evals/results/02-good-fixture-review.md` (separate sonnet subagent, no hints; scratch copy = fixture plus a `<!-- GATE-STATUS -->` last line).

Round 1 returned BLOCKING (G3, G8, G9) because the scratch brief said "no UMK figure stored" and tagged the fictional PT as `[vault]`, so the gate rightly found claims the brief did not back. The brief, not the fixture or the gate, was wrong: a fixture brief must be consistent with its fictional contract (UMK value, source, date recorded; party data tagged `[user]` as fictional). Round 2 with that brief: verdict PASS, nine rows PASS, sha matched. The G2 row cites Pasal 10's Art. 1307 together with Art. 1309 (P-GR-01) as correct use, so the Art. 1307 rule (KKJ-1 fix round) does not false-positive.
