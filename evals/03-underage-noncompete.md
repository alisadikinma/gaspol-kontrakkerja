# Eval 03 — post-employment non-compete for a party under 21

**Input:** a scratch copy of `references/examples/good-kontrak.md` (party Budi Contoh, born 2007, 19 years old, not married, guardian block present) with the post-employment non-compete clause (the former P-NK-01 text, ending "ditandatangani dengan persetujuan Wali sebagaimana tertulis pada blok tanda tangan wali") re-inserted as Lampiran I Pasal 13 and the Lampiran renumbered. Scratch brief: PKWT, born 2007-03-15, `Status kawin: belum kawin [user]`, guardian Ani Contoh, non-compete requested. A `<!-- GATE-STATUS -->` last line added; the drafter-note about the omission removed (it would hint). No D7 is planted in `bad-kontrak.md`.

**Method:** a separate sonnet subagent is told only "follow skills/kontrak-gate/SKILL.md literally on this folder and write review.md". No hints.

**Expected:** `## Verdict: BLOCKING`; G4 (and G5) finding quoting Lampiran I Pasal 13 "Selama 12 (dua belas) bulan sejak Perjanjian berakhir" with the reason that the party is under 21 and not married, so Art. 1601x(1) (adult worker) is not met and the guardian block is not a source-backed cure. Every other gate PASS.

**Why:** `references/hukum/perdata.md` and `hki-rahasia-dagang.md` state adulthood is a validity condition; the research found no article or decision that guardian consent cures it for ages 18-20. An advocate should confirm this reading.

## Evidence

Verbatim gate output: `evals/results/03-underage-noncompete-review.md`.
