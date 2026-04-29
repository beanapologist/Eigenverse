/-
  OrganicDissociation.lean — Lean 4 formalization of the organic chemistry
  dissociation hierarchy within the Eigenverse framework.

  This module formalizes the bond dissociation hierarchy for common covalent
  bonds in organic chemistry: the ordering of eight bond types by their mean
  bond dissociation energy (BDE), connecting to the Eigenverse tunneling /
  funneling framework established in ChemicalBonds and ClosurePrediction.

  In the Eigenverse model the organic dissociation hierarchy maps naturally
  onto the abstract framework:

      Higher BDE → lower frustration → stronger binding → dissociates later
      Lower  BDE → higher frustration → weaker binding  → dissociates first

  The tunneling sector (Im > 0) is the dissociation fail point: weaker bonds
  with higher frustration are the first to reach the Im = 0 threshold
  (`tunneling_vanishes_implies_unbound`, ChemicalBonds theorem [29]).

  Bond types ordered by increasing BDE (weakest → strongest):

      C-N   C-C   C-O   C-H   O-H   C=C   C=O   C≡C
      305   347   360   413   463   614   745   839  kJ/mol

  Bond dissociation energies are mean bond enthalpies (kJ/mol) from
  NIST Chemistry WebBook (Standard Reference Data) and Lide, D.R. (ed.)
  CRC Handbook of Chemistry and Physics, 84th Edition (2003–2004).

  Sections
  ────────
  1.  Bond dissociation energy constants (BDE, kJ/mol)
  2.  BDE positivity
  3.  Single-bond dissociation hierarchy  (C-N < C-C < C-O < C-H < O-H)
  4.  Multiple-bond dissociation hierarchy (single < double < triple)
  5.  Cross-type comparisons
  6.  Complete organic dissociation ordering
  7.  Lead conjunction

  Proof status
  ────────────
  All 22 theorems have complete machine-checked proofs.
  No `sorry` placeholders remain.
-/

import ClosurePrediction
import Chemistry

open Complex Real

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- Section 1 — Bond Dissociation Energy Constants (kJ/mol)
-- Mean bond enthalpies from NIST Chemistry WebBook and CRC Handbook, 84th ed.
-- Values are stored as exact rational constants in kJ/mol.
-- ════════════════════════════════════════════════════════════════════════════

/-- Mean bond dissociation energy of C-N (single bond): BDE(C-N) = 305 kJ/mol.
    Source: CRC Handbook, 84th ed.  C-N single bonds are the weakest among the
    eight common organic bonds; they occur in amines and amino acid backbones. -/
noncomputable def bde_C_N : ℝ := 305

/-- Mean bond dissociation energy of C-C (single bond): BDE(C-C) = 347 kJ/mol.
    Source: CRC Handbook, 84th ed.  The backbone σ bond of organic chemistry;
    present in all alkanes and saturated organic chains. -/
noncomputable def bde_C_C : ℝ := 347

/-- Mean bond dissociation energy of C-O (single bond): BDE(C-O) = 360 kJ/mol.
    Source: CRC Handbook, 84th ed.  Common in alcohols (R-OH) and ethers (R-O-R). -/
noncomputable def bde_C_O : ℝ := 360

/-- Mean bond dissociation energy of C-H (single bond): BDE(C-H) = 413 kJ/mol.
    Source: CRC Handbook, 84th ed.  The fundamental bond of organic hydrocarbons;
    present in every common organic functional group. -/
noncomputable def bde_C_H : ℝ := 413

/-- Mean bond dissociation energy of O-H (single bond): BDE(O-H) = 463 kJ/mol.
    Source: CRC Handbook, 84th ed.  Characteristic of alcohols and water; the
    strongest single bond among the eight here. -/
noncomputable def bde_O_H : ℝ := 463

/-- Mean bond dissociation energy of C=C (double bond): BDE(C=C) = 614 kJ/mol.
    Source: CRC Handbook, 84th ed.  The alkene π-bond adds to the σ-bond;
    occurs in ethylene (H₂C=CH₂) and aromatic systems. -/
noncomputable def bde_CC_double : ℝ := 614

/-- Mean bond dissociation energy of C=O (double bond): BDE(C=O) = 745 kJ/mol.
    Source: CRC Handbook, 84th ed.  Strong carbonyl bond in aldehydes, ketones,
    and carboxylic acids; oxygen's electronegativity enhances the π bond. -/
noncomputable def bde_CO_double : ℝ := 745

/-- Mean bond dissociation energy of C≡C (triple bond): BDE(C≡C) = 839 kJ/mol.
    Source: CRC Handbook, 84th ed.  The strongest common organic bond; found in
    alkynes such as acetylene (HC≡CH) and nitriles when combined with C≡N. -/
noncomputable def bde_CC_triple : ℝ := 839

-- ════════════════════════════════════════════════════════════════════════════
-- Section 2 — BDE Positivity
-- All bond dissociation energies are strictly positive: every bond requires
-- energy to break (endothermic homolysis).
-- ════════════════════════════════════════════════════════════════════════════

/-- **[1] BDE(C-N) > 0** -/
theorem bde_C_N_pos : 0 < bde_C_N := by unfold bde_C_N; norm_num

/-- **[2] BDE(C-C) > 0** -/
theorem bde_C_C_pos : 0 < bde_C_C := by unfold bde_C_C; norm_num

/-- **[3] BDE(C-O) > 0** -/
theorem bde_C_O_pos : 0 < bde_C_O := by unfold bde_C_O; norm_num

/-- **[4] BDE(C-H) > 0** -/
theorem bde_C_H_pos : 0 < bde_C_H := by unfold bde_C_H; norm_num

/-- **[5] BDE(O-H) > 0** -/
theorem bde_O_H_pos : 0 < bde_O_H := by unfold bde_O_H; norm_num

/-- **[6] BDE(C=C) > 0** -/
theorem bde_CC_double_pos : 0 < bde_CC_double := by unfold bde_CC_double; norm_num

/-- **[7] BDE(C=O) > 0** -/
theorem bde_CO_double_pos : 0 < bde_CO_double := by unfold bde_CO_double; norm_num

/-- **[8] BDE(C≡C) > 0** -/
theorem bde_CC_triple_pos : 0 < bde_CC_triple := by unfold bde_CC_triple; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 3 — Single-Bond Dissociation Hierarchy
-- Among single bonds the dissociation order is:
--   C-N (305) < C-C (347) < C-O (360) < C-H (413) < O-H (463)
-- C-N has the highest frustration (weakest, first to dissociate);
-- O-H has the lowest frustration (strongest single bond, last to dissociate).
-- ════════════════════════════════════════════════════════════════════════════

/-- **[9] C-N weaker than C-C**: BDE(C-N) < BDE(C-C).
    305 < 347 kJ/mol.  C-N bonds dissociate at lower energies than C-C. -/
theorem bde_CN_lt_CC : bde_C_N < bde_C_C := by
  unfold bde_C_N bde_C_C; norm_num

/-- **[10] C-C weaker than C-O**: BDE(C-C) < BDE(C-O).
    347 < 360 kJ/mol.  The C-C backbone is slightly weaker than C-O. -/
theorem bde_CC_lt_CO : bde_C_C < bde_C_O := by
  unfold bde_C_C bde_C_O; norm_num

/-- **[11] C-O weaker than C-H**: BDE(C-O) < BDE(C-H).
    360 < 413 kJ/mol.  Oxygen single bonds are weaker than C-H. -/
theorem bde_CO_lt_CH : bde_C_O < bde_C_H := by
  unfold bde_C_O bde_C_H; norm_num

/-- **[12] C-H weaker than O-H**: BDE(C-H) < BDE(O-H).
    413 < 463 kJ/mol.  O-H is the strongest single bond in this set. -/
theorem bde_CH_lt_OH : bde_C_H < bde_O_H := by
  unfold bde_C_H bde_O_H; norm_num

/-- **[13] Single-bond hierarchy**: C-N < C-C < C-O < C-H < O-H.
    The complete ordering of the five common organic single bonds by BDE. -/
theorem single_bond_dissociation_hierarchy :
    bde_C_N < bde_C_C ∧ bde_C_C < bde_C_O ∧
    bde_C_O < bde_C_H ∧ bde_C_H < bde_O_H :=
  ⟨bde_CN_lt_CC, bde_CC_lt_CO, bde_CO_lt_CH, bde_CH_lt_OH⟩

-- ════════════════════════════════════════════════════════════════════════════
-- Section 4 — Multiple-Bond Dissociation Hierarchy
-- Higher bond order → stronger bond → higher BDE.
-- For carbon–carbon:  BDE(C-C) < BDE(C=C) < BDE(C≡C)
-- For carbon–oxygen:  BDE(C-O) < BDE(C=O)
-- The added π bond(s) contribute substantial binding energy beyond the σ bond.
-- ════════════════════════════════════════════════════════════════════════════

/-- **[14] C-C single weaker than C=C double**: BDE(C-C) < BDE(C=C).
    347 < 614 kJ/mol.  The π bond of the double bond adds ~267 kJ/mol. -/
theorem bde_CC_single_lt_double : bde_C_C < bde_CC_double := by
  unfold bde_C_C bde_CC_double; norm_num

/-- **[15] C=C double weaker than C≡C triple**: BDE(C=C) < BDE(C≡C).
    614 < 839 kJ/mol.  The second π bond of the triple bond adds ~225 kJ/mol. -/
theorem bde_CC_double_lt_triple : bde_CC_double < bde_CC_triple := by
  unfold bde_CC_double bde_CC_triple; norm_num

/-- **[16] Carbon bond-order hierarchy**: BDE(C-C) < BDE(C=C) < BDE(C≡C).
    Bond strength increases monotonically with bond order for carbon. -/
theorem carbon_bond_order_hierarchy :
    bde_C_C < bde_CC_double ∧ bde_CC_double < bde_CC_triple :=
  ⟨bde_CC_single_lt_double, bde_CC_double_lt_triple⟩

/-- **[17] C-O single weaker than C=O double**: BDE(C-O) < BDE(C=O).
    360 < 745 kJ/mol.  Oxygen's electronegativity markedly strengthens the
    carbonyl double bond relative to the ether/alcohol single bond. -/
theorem bde_CO_single_lt_double : bde_C_O < bde_CO_double := by
  unfold bde_C_O bde_CO_double; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 5 — Cross-Type Comparisons
-- Key inequalities that span the single/double boundary:
--   the strongest single bond (O-H) is weaker than the weakest double bond (C=C),
--   and C=C is weaker than C=O.
-- ════════════════════════════════════════════════════════════════════════════

/-- **[18] O-H single weaker than C=C double**: BDE(O-H) < BDE(C=C).
    463 < 614 kJ/mol.  Every double bond is stronger than every single bond
    in this eight-bond set: the π + σ combination dominates even the polar O-H. -/
theorem bde_OH_lt_CC_double : bde_O_H < bde_CC_double := by
  unfold bde_O_H bde_CC_double; norm_num

/-- **[19] C=C double weaker than C=O double**: BDE(C=C) < BDE(C=O).
    614 < 745 kJ/mol.  The C=O carbonyl is substantially stronger than C=C due
    to the electronegativity difference and partial ionic character of C=O. -/
theorem bde_CC_double_lt_CO_double : bde_CC_double < bde_CO_double := by
  unfold bde_CC_double bde_CO_double; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 6 — Complete Organic Dissociation Ordering
-- The full hierarchy from weakest (first to dissociate) to strongest (last):
--   C-N < C-C < C-O < C-H < O-H < C=C < C=O < C≡C
-- This is the machine-checked organic dissociation hierarchy.
-- ════════════════════════════════════════════════════════════════════════════

/-- **[20] Complete organic dissociation hierarchy**:
    C-N < C-C < C-O < C-H < O-H < C=C < C=O < C≡C (kJ/mol).

    The eight-entry ordering covers the most common covalent bond types in
    organic chemistry.  Bonds to the left (higher frustration) dissociate at
    lower energies; bonds to the right (lower frustration) dissociate last.

    Connection to the Eigenverse framework (ClosurePrediction §5):
      • Single bonds (left of O-H) parallel the Koide scale: higher frustration
        FK, contributing at leading order 1/Z.
      • Multiple bonds (C=C, C=O, C≡C) parallel the Silver scale: lower
        frustration FS < FK, contributing at sub-leading order 1/Z².

    Proof: norm_num on the explicit rational BDE constants. -/
theorem organic_dissociation_hierarchy :
    bde_C_N < bde_C_C ∧ bde_C_C < bde_C_O ∧
    bde_C_O < bde_C_H ∧ bde_C_H < bde_O_H ∧
    bde_O_H < bde_CC_double ∧ bde_CC_double < bde_CO_double ∧
    bde_CO_double < bde_CC_triple := by
  unfold bde_C_N bde_C_C bde_C_O bde_C_H bde_O_H bde_CC_double bde_CO_double bde_CC_triple
  norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 7 — Lead Conjunction
-- The organic dissociation lead theorem unifies positivity and ordering.
-- ════════════════════════════════════════════════════════════════════════════

/-- **[21] BDE all-positive**: all eight bond dissociation energies are > 0.
    Every covalent bond requires positive energy input to undergo homolysis. -/
theorem organic_bde_all_positive :
    0 < bde_C_N ∧ 0 < bde_C_C ∧ 0 < bde_C_O ∧ 0 < bde_C_H ∧
    0 < bde_O_H ∧ 0 < bde_CC_double ∧ 0 < bde_CO_double ∧ 0 < bde_CC_triple :=
  ⟨bde_C_N_pos, bde_C_C_pos, bde_C_O_pos, bde_C_H_pos,
   bde_O_H_pos, bde_CC_double_pos, bde_CO_double_pos, bde_CC_triple_pos⟩

/-- **[22] Organic dissociation lead**: BDEs positive AND full hierarchy holds.

    This conjunction captures the complete machine-checked status of the organic
    dissociation hierarchy: all eight BDE values are positive, and the strict
    ordering C-N < C-C < C-O < C-H < O-H < C=C < C=O < C≡C is verified. -/
theorem organic_dissociation_lead :
    (0 < bde_C_N ∧ 0 < bde_C_C ∧ 0 < bde_C_O ∧ 0 < bde_C_H ∧
     0 < bde_O_H ∧ 0 < bde_CC_double ∧ 0 < bde_CO_double ∧ 0 < bde_CC_triple) ∧
    (bde_C_N < bde_C_C ∧ bde_C_C < bde_C_O ∧
     bde_C_O < bde_C_H ∧ bde_C_H < bde_O_H ∧
     bde_O_H < bde_CC_double ∧ bde_CC_double < bde_CO_double ∧
     bde_CO_double < bde_CC_triple) :=
  ⟨organic_bde_all_positive, organic_dissociation_hierarchy⟩

end -- noncomputable section
