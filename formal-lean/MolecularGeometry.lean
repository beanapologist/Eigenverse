/-
  MolecularGeometry.lean — Lean 4 formalization of geometric chemical structures.

  This module formalizes the 3D geometry of small organic molecules within the
  Eigenverse framework.  Chemical structure is encoded through three complementary
  lenses:

  1. **Bond length ordering** — triple bonds are shorter than double bonds,
     which are shorter than single bonds.  Shorter ↔ stronger ↔ higher bond
     order (consistent with OrganicDissociation: shorter bonds have higher BDE).

  2. **VSEPR bond angle constants** — ideal geometries:
       linear (180°), trigonal planar (120°), tetrahedral (≈ 109.47°), right (90°).
     Angle ordering:  right (π/2) < tetrahedral (arccos(−1/3)) < trigonal planar (2π/3) < linear (π).

  3. **Explicit 3D bond vectors** — for three key geometries:
       • Tetrahedral (CH₄, sp³)    — four C-H directions at arccos(−1/3) apart.
       • Linear (HC≡CH, sp)        — C-H and C≡C bonds are antiparallel (180°).
       • Trigonal planar (C₂H₄-like, sp²) — three bonds coplanar at 120° apart.

     Bond vectors for CH₄ are the unnormalized vertices of the regular tetrahedron:
     h₁ = (1,1,1), h₂ = (1,−1,−1), h₃ = (−1,1,−1), h₄ = (−1,−1,1).
     Every vertex has the same squared norm (= 3) and every cross-dot product equals −1,
     giving cos θ = −1/3 — the tetrahedral bond angle.

  Bond lengths are from NIST CCCBDB (Computational Chemistry Comparison and Benchmark
  Database, NIST Standard Reference Database 101) and experimental microwave /
  electron-diffraction values.

  Sections
  ────────
  1.  Bond length constants (pm)
  2.  Bond length positivity
  3.  Bond length ordering (triple < double < single; shorter = stronger)
  4.  Bond angle constants (radians)
  5.  Bond angle ordering (right < tetrahedral < trigonal planar < linear)
  6.  Tetrahedral geometry: CH₄ bond vectors and cosine angle
  7.  Linear geometry: HC≡CH sp-carbon
  8.  Trigonal planar geometry: sp²-carbon
  9.  Bond length – bond order – BDE correspondence
  10. Lead conjunction

  Proof status
  ────────────
  All 26 theorems have complete machine-checked proofs.
  No `sorry` placeholders remain.
-/

import OrganicDissociation

open Real

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- Section 1 — Bond Length Constants (pm = picometres)
-- Experimental equilibrium bond lengths from NIST CCCBDB and CRC Handbook.
-- Values are rounded to the nearest pm and stored as exact rational constants.
-- ════════════════════════════════════════════════════════════════════════════

/-- C≡C triple bond length: 120 pm (acetylene, NIST CCCBDB).
    The triple bond pulls the carbons to their closest separation. -/
noncomputable def bl_CC_triple : ℝ := 120

/-- C=C double bond length: 134 pm (ethylene, NIST CCCBDB).
    The second π bond in the double bond shortens the C-C distance. -/
noncomputable def bl_CC_double : ℝ := 134

/-- C-C single bond length: 154 pm (ethane, NIST CCCBDB).
    The standard sp³–sp³ σ bond length in saturated hydrocarbons. -/
noncomputable def bl_C_C : ℝ := 154

/-- C-H bond length: 109 pm (methane, NIST CCCBDB).
    Nearly constant across sp, sp², sp³ carbons. -/
noncomputable def bl_C_H : ℝ := 109

/-- C=O double bond length: 121 pm (formaldehyde, NIST CCCBDB).
    The carbonyl bond is shorter than C=C due to the electronegativity of O. -/
noncomputable def bl_CO_double : ℝ := 121

-- ════════════════════════════════════════════════════════════════════════════
-- Section 2 — Bond Length Positivity
-- ════════════════════════════════════════════════════════════════════════════

/-- **[1] bl_CC_triple > 0** -/
theorem bl_CC_triple_pos : 0 < bl_CC_triple := by unfold bl_CC_triple; norm_num

/-- **[2] bl_CC_double > 0** -/
theorem bl_CC_double_pos : 0 < bl_CC_double := by unfold bl_CC_double; norm_num

/-- **[3] bl_C_C > 0** -/
theorem bl_C_C_pos : 0 < bl_C_C := by unfold bl_C_C; norm_num

/-- **[4] bl_C_H > 0** -/
theorem bl_C_H_pos : 0 < bl_C_H := by unfold bl_C_H; norm_num

/-- **[5] bl_CO_double > 0** -/
theorem bl_CO_double_pos : 0 < bl_CO_double := by unfold bl_CO_double; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 3 — Bond Length Ordering
-- Shorter bonds are stronger (higher BDE) and have higher bond order.
-- For carbon–carbon:  C≡C < C=C < C-C  (triple shortest).
-- C=O sits between C≡C and C=C: C≡C < C=O < C=C.
-- ════════════════════════════════════════════════════════════════════════════

/-- **[6] C≡C shorter than C=C**: bl_CC_triple < bl_CC_double.
    120 < 134 pm.  The two π bonds in the triple bond pull carbons closer. -/
theorem bl_CC_triple_lt_double : bl_CC_triple < bl_CC_double := by
  unfold bl_CC_triple bl_CC_double; norm_num

/-- **[7] C=C shorter than C-C**: bl_CC_double < bl_C_C.
    134 < 154 pm.  The single π bond shortens the σ-framework. -/
theorem bl_CC_double_lt_single : bl_CC_double < bl_C_C := by
  unfold bl_CC_double bl_C_C; norm_num

/-- **[8] Carbon bond-length ordering**: bl_CC_triple < bl_CC_double < bl_C_C.
    Bond length decreases monotonically with increasing bond order. -/
theorem carbon_bond_length_ordering :
    bl_CC_triple < bl_CC_double ∧ bl_CC_double < bl_C_C :=
  ⟨bl_CC_triple_lt_double, bl_CC_double_lt_single⟩

/-- **[9] C≡C shorter than C=O**: bl_CC_triple < bl_CO_double.
    120 < 121 pm.  The C≡C triple bond is marginally shorter than C=O. -/
theorem bl_CC_triple_lt_CO_double : bl_CC_triple < bl_CO_double := by
  unfold bl_CC_triple bl_CO_double; norm_num

/-- **[10] C=O shorter than C=C**: bl_CO_double < bl_CC_double.
    121 < 134 pm.  Oxygen's electronegativity contracts the C=O π bond,
    making it shorter than the C=C double bond despite the same bond order. -/
theorem bl_CO_double_lt_CC_double : bl_CO_double < bl_CC_double := by
  unfold bl_CO_double bl_CC_double; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 4 — Bond Angle Constants (radians)
-- Standard VSEPR ideal geometry angles stored as multiples of π or via arccos.
--   Linear:          180° = π
--   Trigonal planar: 120° = 2π/3
--   Tetrahedral:     ≈109.47° = arccos(−1/3)   (exact value)
--   Right angle:      90° = π/2
-- ════════════════════════════════════════════════════════════════════════════

/-- Linear geometry bond angle: 180° = π radians.
    Characteristic of sp-hybridised carbon (acetylene, nitriles). -/
noncomputable def angle_linear : ℝ := Real.pi

/-- Trigonal planar bond angle: 120° = 2π/3 radians.
    Characteristic of sp²-hybridised carbon (alkenes, aldehydes, benzene). -/
noncomputable def angle_trigonal_planar : ℝ := 2 * Real.pi / 3

/-- Tetrahedral bond angle: arccos(−1/3) ≈ 109.47°.
    The exact bond angle at an sp³-hybridised carbon (methane, alkanes).
    It is the unique angle θ ∈ (0, π) for which cos θ = −1/3. -/
noncomputable def angle_tetrahedral : ℝ := Real.arccos (-1 / 3)

/-- Right bond angle: 90° = π/2 radians.
    Arises in octahedral complexes; also the approximate angle in PH₃ and H₂S. -/
noncomputable def angle_right : ℝ := Real.pi / 2

-- ════════════════════════════════════════════════════════════════════════════
-- Section 5 — Bond Angle Ordering
-- Ideal VSEPR angles satisfy: right < tetrahedral < trigonal planar < linear.
-- ════════════════════════════════════════════════════════════════════════════

/-- **[11] Right angle < tetrahedral**: π/2 < arccos(−1/3).

    Proof: cos is strictly decreasing on [0, π] (Real.strictAntiOn_cos).
    Setting a = arccos(−1/3) and b = π/2 in lt_iff_lt gives
    cos(arccos(−1/3)) < cos(π/2) ↔ π/2 < arccos(−1/3).
    The LHS reduces to −1/3 < 0 by cos_arccos and cos_pi_div_two. -/
theorem angle_right_lt_tetrahedral : angle_right < angle_tetrahedral := by
  unfold angle_right angle_tetrahedral
  have h_arccos_mem : Real.arccos (-1/3 : ℝ) ∈ Set.Icc (0 : ℝ) Real.pi :=
    Set.mem_Icc.mpr ⟨Real.arccos_nonneg _, Real.arccos_le_pi _⟩
  have h_pi2_mem : Real.pi / 2 ∈ Set.Icc (0 : ℝ) Real.pi :=
    Set.mem_Icc.mpr ⟨by linarith [Real.pi_pos], by linarith [Real.pi_pos]⟩
  -- lt_iff_lt ha hb : cos a < cos b ↔ b < a
  -- so .mp : cos(arccos(-1/3)) < cos(π/2) → π/2 < arccos(-1/3)
  apply (Real.strictAntiOn_cos.lt_iff_lt h_arccos_mem h_pi2_mem).mp
  rw [Real.cos_arccos (by norm_num) (by norm_num), Real.cos_pi_div_two]
  norm_num

/-- **[12] Tetrahedral < trigonal planar**: arccos(−1/3) < 2π/3.

    Proof: cos(2π/3) = −1/2 (computed from cos(π − π/3) = −cos(π/3) = −1/2).
    arccos(−1/3) ∈ [0, π] and 2π/3 ∈ [0, π].  Since cos is strictly decreasing
    on [0, π] (Real.strictAntiOn_cos) and cos(arccos(−1/3)) = −1/3 > −1/2 =
    cos(2π/3), strict antitonicity gives arccos(−1/3) < 2π/3. -/
theorem angle_tetrahedral_lt_trigonal_planar :
    angle_tetrahedral < angle_trigonal_planar := by
  unfold angle_tetrahedral angle_trigonal_planar
  -- Step 1: compute cos(2π/3) = -1/2
  have hcos_pi3 : Real.cos (Real.pi / 3) = 1/2 := by
    rw [show Real.pi / 3 = Real.pi / 2 - Real.pi / 6 by ring]
    rw [Real.cos_pi_div_two_sub]
    exact Real.sin_pi_div_six
  have hcos : Real.cos (2 * Real.pi / 3) = -1/2 := by
    rw [show (2 : ℝ) * Real.pi / 3 = Real.pi - Real.pi / 3 by ring]
    rw [Real.cos_pi_sub, hcos_pi3]
    norm_num
  -- Step 2: use strict antitonicity of cos on [0, π]
  -- Setting a = 2π/3 and b = arccos(-1/3) in lt_iff_lt gives
  -- cos(2π/3) < cos(arccos(-1/3)) ↔ arccos(-1/3) < 2π/3.
  -- .mp : cos(2π/3) < cos(arccos(-1/3)) → arccos(-1/3) < 2π/3 ✓
  have h_2pi3_mem : (2 * Real.pi / 3) ∈ Set.Icc (0 : ℝ) Real.pi :=
    Set.mem_Icc.mpr ⟨by linarith [Real.pi_pos], by linarith [Real.pi_pos]⟩
  have h_arccos_mem : Real.arccos (-1/3 : ℝ) ∈ Set.Icc (0 : ℝ) Real.pi :=
    Set.mem_Icc.mpr ⟨Real.arccos_nonneg _, Real.arccos_le_pi _⟩
  apply (Real.strictAntiOn_cos.lt_iff_lt h_2pi3_mem h_arccos_mem).mp
  rw [hcos, Real.cos_arccos (by norm_num) (by norm_num)]
  norm_num

/-- **[13] Trigonal planar < linear**: 2π/3 < π. -/
theorem angle_trigonal_lt_linear : angle_trigonal_planar < angle_linear := by
  unfold angle_trigonal_planar angle_linear
  linarith [Real.pi_pos]

-- ════════════════════════════════════════════════════════════════════════════
-- Section 6 — Tetrahedral Geometry: CH₄ Bond Vectors and Cosine Angle
-- The four C-H bond directions in methane sit at the vertices of a regular
-- tetrahedron.  Bond vectors are elements of ℝ × ℝ × ℝ (3D Cartesian):
--
--   h₁ = ( 1,  1,  1),  h₂ = ( 1, −1, −1)
--   h₃ = (−1,  1, −1),  h₄ = (−1, −1,  1)
--
-- Every vector has squared norm 3 and every cross-dot product equals −1,
-- giving cos θ = −1/(√3 · √3) = −1/3 — the tetrahedral bond angle.
-- ════════════════════════════════════════════════════════════════════════════

/-- 3D Cartesian bond vector represented as (x, y, z) ∈ ℝ × ℝ × ℝ. -/
def Vec3 : Type := ℝ × ℝ × ℝ

/-- Dot product: v · w = vₓwₓ + vywy + vzwz. -/
def dot3 (v w : Vec3) : ℝ := v.1 * w.1 + v.2.1 * w.2.1 + v.2.2 * w.2.2

/-- Squared Euclidean norm: ‖v‖² = v · v. -/
def normSq3 (v : Vec3) : ℝ := dot3 v v

-- C-H bond direction vectors in CH₄ (tetrahedral vertices, unnormalized).

/-- First C-H bond direction in methane: h₁ = (1, 1, 1). -/
noncomputable def ch4_h1 : Vec3 := (1, 1, 1)

/-- Second C-H bond direction in methane: h₂ = (1, −1, −1). -/
noncomputable def ch4_h2 : Vec3 := (1, -1, -1)

/-- Third C-H bond direction in methane: h₃ = (−1, 1, −1). -/
noncomputable def ch4_h3 : Vec3 := (-1, 1, -1)

/-- Fourth C-H bond direction in methane: h₄ = (−1, −1, 1). -/
noncomputable def ch4_h4 : Vec3 := (-1, -1, 1)

/-- **[14] Equal squared norms**: all four C-H bond vectors have normSq = 3.
    This confirms the four bonds are equal in length (regular tetrahedron). -/
theorem ch4_equal_norms :
    normSq3 ch4_h1 = 3 ∧ normSq3 ch4_h2 = 3 ∧
    normSq3 ch4_h3 = 3 ∧ normSq3 ch4_h4 = 3 := by
  unfold normSq3 dot3 ch4_h1 ch4_h2 ch4_h3 ch4_h4; norm_num

/-- **[15] Tetrahedral dot products**: every pair of distinct C-H bond vectors
    has dot product = −1.  With all norms √3, this gives cos θ = −1/3. -/
theorem ch4_all_dot_products :
    dot3 ch4_h1 ch4_h2 = -1 ∧ dot3 ch4_h1 ch4_h3 = -1 ∧ dot3 ch4_h1 ch4_h4 = -1 ∧
    dot3 ch4_h2 ch4_h3 = -1 ∧ dot3 ch4_h2 ch4_h4 = -1 ∧ dot3 ch4_h3 ch4_h4 = -1 := by
  unfold dot3 ch4_h1 ch4_h2 ch4_h3 ch4_h4; norm_num

/-- **[16] Tetrahedral cosine**: cos θ = h₁ · h₂ / (‖h₁‖ · ‖h₂‖) = −1/3.

    h₁ · h₂ = −1 and ‖h₁‖ = ‖h₂‖ = √3, so cos θ = −1/(√3 · √3) = −1/3.
    This identifies the tetrahedral bond angle as arccos(−1/3) ≈ 109.47°. -/
theorem ch4_tetrahedral_cos :
    dot3 ch4_h1 ch4_h2 / (Real.sqrt (normSq3 ch4_h1) * Real.sqrt (normSq3 ch4_h2)) = -1 / 3 := by
  have h12 : dot3 ch4_h1 ch4_h2 = -1 := ch4_all_dot_products.1
  have hn1 : normSq3 ch4_h1 = 3    := ch4_equal_norms.1
  have hn2 : normSq3 ch4_h2 = 3    := ch4_equal_norms.2.1
  have hsq : Real.sqrt 3 * Real.sqrt 3 = 3 := Real.mul_self_sqrt (by norm_num)
  rw [h12, hn1, hn2, hsq]

-- ════════════════════════════════════════════════════════════════════════════
-- Section 7 — Linear Geometry: HC≡CH (sp-carbon)
-- In acetylene the C-H and C≡C bonds at each terminal carbon are collinear.
-- Using the z-axis as the molecular axis:
--   ace_vCC = (0, 0,  1) — direction from C toward the triple-bonded C
--   ace_vCH = (0, 0, −1) — direction from C toward the attached H
-- These are antiparallel; their dot product is −1 (cos θ = −1 → θ = 180°).
-- ════════════════════════════════════════════════════════════════════════════

/-- Bond direction from sp-carbon toward the triple-bonded partner: (0, 0, 1). -/
noncomputable def ace_vCC : Vec3 := (0, 0, 1)

/-- Bond direction from sp-carbon toward the terminal hydrogen: (0, 0, −1). -/
noncomputable def ace_vCH : Vec3 := (0, 0, -1)

/-- **[17] Acetylene bonds are antiparallel**: dot3 ace_vCC ace_vCH = −1.
    The C≡C and C-H bond directions at a terminal sp-carbon are exactly
    antiparallel, confirming linear (180°) geometry. -/
theorem ace_bonds_antiparallel : dot3 ace_vCC ace_vCH = -1 := by
  unfold dot3 ace_vCC ace_vCH; norm_num

/-- **[18] Acetylene linear cosine**: cos θ = −1 (angle = 180°).
    Both bond vectors have unit norm (normSq = 1); the dot product is −1;
    therefore the bond angle cosine is exactly −1. -/
theorem ace_linear_cos :
    dot3 ace_vCC ace_vCH /
    (Real.sqrt (normSq3 ace_vCC) * Real.sqrt (normSq3 ace_vCH)) = -1 := by
  have hd  : dot3 ace_vCC ace_vCH = -1 := ace_bonds_antiparallel
  have hn1 : normSq3 ace_vCC = 1 := by unfold normSq3 dot3 ace_vCC; norm_num
  have hn2 : normSq3 ace_vCH = 1 := by unfold normSq3 dot3 ace_vCH; norm_num
  rw [hd, hn1, hn2]
  norm_num [Real.sqrt_one]

-- ════════════════════════════════════════════════════════════════════════════
-- Section 8 — Trigonal Planar Geometry (sp²-carbon)
-- Three unit bond vectors in a plane at 120° apart:
--   sp2_e1 = (1,  0,  0)
--   sp2_e2 = (−1/2,  √3/2, 0)
--   sp2_e3 = (−1/2, −√3/2, 0)
-- Unit norm, pairwise cos = −1/2 (120° bond angle), vector sum = 0.
-- ════════════════════════════════════════════════════════════════════════════

/-- First sp² bond direction (along +x): (1, 0, 0). -/
noncomputable def sp2_e1 : Vec3 := (1, 0, 0)

/-- Second sp² bond direction at 120° from e₁: (−1/2, √3/2, 0). -/
noncomputable def sp2_e2 : Vec3 := (-1/2, Real.sqrt 3 / 2, 0)

/-- Third sp² bond direction at 240° from e₁: (−1/2, −√3/2, 0). -/
noncomputable def sp2_e3 : Vec3 := (-1/2, -(Real.sqrt 3 / 2), 0)

/-- **[19] sp² bond vectors have unit norm**: normSq3 eᵢ = 1 for i = 1, 2, 3. -/
theorem sp2_unit_norms :
    normSq3 sp2_e1 = 1 ∧ normSq3 sp2_e2 = 1 ∧ normSq3 sp2_e3 = 1 := by
  have h3 : Real.sqrt 3 * Real.sqrt 3 = 3 := Real.mul_self_sqrt (by norm_num)
  refine ⟨?_, ?_, ?_⟩
  · simp only [normSq3, dot3, sp2_e1]; norm_num
  · simp only [normSq3, dot3, sp2_e2]; nlinarith
  · simp only [normSq3, dot3, sp2_e3]; nlinarith

/-- **[20] sp² cross-dot products equal −1/2**: cos 120° = −1/2 for each pair.

    e₁ · e₂ = e₁ · e₃ = e₂ · e₃ = −1/2, confirming the 120° bond angle
    between every pair of bonds in the trigonal planar geometry. -/
theorem sp2_cross_dots :
    dot3 sp2_e1 sp2_e2 = -1/2 ∧ dot3 sp2_e1 sp2_e3 = -1/2 ∧ dot3 sp2_e2 sp2_e3 = -1/2 := by
  have h3 : Real.sqrt 3 * Real.sqrt 3 = 3 := Real.mul_self_sqrt (by norm_num)
  refine ⟨?_, ?_, ?_⟩
  · simp only [dot3, sp2_e1, sp2_e2]; ring_nf
  · simp only [dot3, sp2_e1, sp2_e3]; ring_nf
  · simp only [dot3, sp2_e2, sp2_e3]; nlinarith

/-- **[21] Trigonal planar bond vectors sum to zero**: e₁ + e₂ + e₃ = 0.

    The three unit bond vectors at 120° apart are in balanced arrangement:
    their vector sum vanishes component-wise, encoding the D₃ₕ point group. -/
theorem sp2_sum_zero :
    (sp2_e1.1 + sp2_e2.1 + sp2_e3.1 = 0) ∧
    (sp2_e1.2.1 + sp2_e2.2.1 + sp2_e3.2.1 = 0) ∧
    (sp2_e1.2.2 + sp2_e2.2.2 + sp2_e3.2.2 = 0) := by
  -- Prod projections reduce definitionally; state simplified form explicitly.
  show (1 : ℝ) + (-1/2) + (-1/2) = 0 ∧
       (0 : ℝ) + Real.sqrt 3 / 2 + -(Real.sqrt 3 / 2) = 0 ∧
       (0 : ℝ) + 0 + 0 = 0
  refine ⟨by norm_num, ?_, by norm_num⟩
  ring

-- ════════════════════════════════════════════════════════════════════════════
-- Section 9 — Bond Length – Bond Order – BDE Correspondence
-- The three orderings agree across all characterizations:
--   Bond order (1 < 2 < 3)  ↔  Shorter length (C≡C < C=C < C-C)
--                           ↔  Higher BDE    (bde_C_C < bde_CC_double < bde_CC_triple)
-- ════════════════════════════════════════════════════════════════════════════

/-- **[22] Bond length decreases as BDE increases (carbon–carbon)**.

    bl_CC_triple < bl_CC_double < bl_C_C  AND  bde_C_C < bde_CC_double < bde_CC_triple.

    The shortest carbon bond is also the strongest: geometry ↔ energy ↔ bond order. -/
theorem bond_length_bde_correspondence :
    bl_CC_triple < bl_CC_double ∧ bl_CC_double < bl_C_C ∧
    bde_C_C < bde_CC_double ∧ bde_CC_double < bde_CC_triple :=
  ⟨bl_CC_triple_lt_double, bl_CC_double_lt_single,
   bde_CC_single_lt_double, bde_CC_double_lt_triple⟩

/-- **[23] Triple bond: shortest and strongest**: bl_CC_triple < bl_C_C and bde_C_C < bde_CC_triple.
    C≡C (120 pm, 839 kJ/mol) is 34 pm shorter and 492 kJ/mol stronger than C-C
    (154 pm, 347 kJ/mol). -/
theorem triple_shorter_and_stronger :
    bl_CC_triple < bl_C_C ∧ bde_C_C < bde_CC_triple := by
  constructor
  · linarith [bl_CC_triple_lt_double, bl_CC_double_lt_single]
  · linarith [bde_CC_single_lt_double, bde_CC_double_lt_triple]

-- ════════════════════════════════════════════════════════════════════════════
-- Section 10 — Lead Conjunction
-- ════════════════════════════════════════════════════════════════════════════

/-- **[24] Geometry positivity lead**: all five bond lengths are positive. -/
theorem geometry_all_positive :
    0 < bl_CC_triple ∧ 0 < bl_CC_double ∧ 0 < bl_C_C ∧ 0 < bl_C_H ∧ 0 < bl_CO_double :=
  ⟨bl_CC_triple_pos, bl_CC_double_pos, bl_C_C_pos, bl_C_H_pos, bl_CO_double_pos⟩

/-- **[25] Tetrahedral geometry lead**: CH₄ bond vectors encode a regular tetrahedron. -/
theorem tetrahedral_geometry_lead :
    normSq3 ch4_h1 = 3 ∧
    dot3 ch4_h1 ch4_h2 = -1 ∧ dot3 ch4_h2 ch4_h3 = -1 ∧
    dot3 ch4_h1 ch4_h2 / (Real.sqrt (normSq3 ch4_h1) * Real.sqrt (normSq3 ch4_h2)) = -1 / 3 :=
  ⟨ch4_equal_norms.1, ch4_all_dot_products.1, ch4_all_dot_products.2.2.2.1,
   ch4_tetrahedral_cos⟩

/-- **[26] Molecular geometry lead**: all geometric and energy ordering results hold. -/
theorem molecular_geometry_lead :
    (0 < bl_CC_triple ∧ 0 < bl_CC_double ∧ 0 < bl_C_C) ∧
    (bl_CC_triple < bl_CC_double ∧ bl_CC_double < bl_C_C) ∧
    (bde_C_C < bde_CC_double ∧ bde_CC_double < bde_CC_triple) ∧
    (normSq3 ch4_h1 = 3 ∧ dot3 ch4_h1 ch4_h2 = -1) ∧
    (dot3 ace_vCC ace_vCH = -1) :=
  ⟨⟨bl_CC_triple_pos, bl_CC_double_pos, bl_C_C_pos⟩,
   carbon_bond_length_ordering,
   carbon_bond_order_hierarchy,
   ⟨ch4_equal_norms.1, ch4_all_dot_products.1⟩,
   ace_bonds_antiparallel⟩

end -- noncomputable section
