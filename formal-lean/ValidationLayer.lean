/-
  ValidationLayer.lean — Empirical validation of the Eigenverse framework
  against measured particle physics data (PDG/CODATA).

  This file occupies the top tier of the three-layer architecture:

    ┌──────────────────────────────────────────────────────────────────┐
    │  Math Layer       │  μ⁸=1, C(r)≤1, C(φ²)=2/3, δS=1+√2         │  ✅
    │  Bridge Layer     │  CODATA constants, consistency definitions   │  BridgeLayer.lean
    │  Validation Layer │  PDG masses, empirical Koide, Δ < ε proofs  │  ← this file
    └──────────────────────────────────────────────────────────────────┘

  The central result is `koide_empirical`: the Koide quotient for the PDG
  lepton masses satisfies |Q(mₑ, mμ, mτ) − 2/3| < 10⁻³.  Combined with
  `koide_theoretical_value : C(φ²) = 2/3` from BridgeLayer.lean, this
  closes the loop:

      mathematical prediction:  C(φ²) = 2/3   (exact, machine-checked)
      empirical measurement:    Q(PDG) ≈ 2/3   (|Q − 2/3| ≈ 6 × 10⁻⁶)
      bridge theorem:           |C(φ²) − Q| < 10⁻³  (machine-checked)

  Proof strategy for `koide_empirical`
  ─────────────────────────────────────
  The Koide quotient involves Real.sqrt of each mass.  We establish rational
  interval bounds for each square root using Real.sqrt_sq (√(x²) = x for
  x ≥ 0) and Real.sqrt_le_sqrt (monotonicity).  From these we obtain bounds
  on the denominator D = (√mₑ + √mμ + √mτ)², and then use div_lt_iff and
  lt_div_iff to convert the ratio bound to a linear inequality closed by
  norm_num.

  Sections
  ────────
  1.  PDG lepton masses  (mₑ, mμ, mτ in MeV, PDG 2022)
  2.  Square-root helper bounds  (private lemmas)
  3.  Empirical Koide test  (|Q − 2/3| < 10⁻³)
  4.  Theory–experiment bridge  (|C(φ²) − Q| < 10⁻³)
  5.  Mass-ratio consistency  (proton/electron ratio cross-check)

  Proof status
  ────────────
  All theorems have complete machine-checked proofs.
  No `sorry` placeholders remain.
-/

import BridgeLayer

open Complex Real

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- Section 1 — PDG Lepton Masses (MeV)
-- All values from Particle Data Group (PDG) 2022 Review of Particle Physics.
-- Stored as exact rational fractions (no floating point).
--
-- mₑ   = 0.51099895    MeV  = 51099895   / 100000000
-- mμ   = 105.6583755   MeV  = 1056583755 / 10000000
-- mτ   = 1776.86       MeV  = 177686     / 100
--
-- Ref: Workman et al. (PDG 2022). Prog. Theor. Exp. Phys. 2022, 083C01.
-- ════════════════════════════════════════════════════════════════════════════

/-- PDG 2022 electron mass: mₑ = 0.51099895 MeV. -/
noncomputable def m_e   : ℝ :=   51099895 / 100000000

/-- PDG 2022 muon mass: mμ = 105.6583755 MeV. -/
noncomputable def m_mu  : ℝ := 1056583755 / 10000000

/-- PDG 2022 tau lepton mass: mτ = 1776.86 MeV. -/
noncomputable def m_tau : ℝ :=     177686 / 100

/-- The electron mass is strictly positive. -/
theorem m_e_pos : 0 < m_e := by unfold m_e; norm_num

/-- The muon mass is strictly positive. -/
theorem m_mu_pos : 0 < m_mu := by unfold m_mu; norm_num

/-- The tau lepton mass is strictly positive. -/
theorem m_tau_pos : 0 < m_tau := by unfold m_tau; norm_num

/-- Lepton mass hierarchy: mₑ < mμ < mτ. -/
theorem lepton_mass_ordering : m_e < m_mu ∧ m_mu < m_tau := by
  unfold m_e m_mu m_tau; norm_num

/-- The electron is the lightest lepton: mₑ < mτ. -/
theorem m_e_lt_m_tau : m_e < m_tau := by
  exact (lepton_mass_ordering.1.trans lepton_mass_ordering.2)

/-- The sum of PDG lepton masses is positive. -/
theorem lepton_mass_sum_pos : 0 < m_e + m_mu + m_tau := by
  linarith [m_e_pos, m_mu_pos, m_tau_pos]

-- ════════════════════════════════════════════════════════════════════════════
-- Section 2 — Square-Root Helper Bounds (private)
-- Each lepton mass square root is bounded between two rational values.
-- These bounds are established using the monotonicity of Real.sqrt and
-- the identity Real.sqrt_sq : √(x²) = x for x ≥ 0.
--
-- The bounds used:
--   0.7148 ≤ √mₑ  ≤ 0.7149   (since 0.7148² ≤ mₑ ≤ 0.7149²)
--   10.279 ≤ √mμ  ≤ 10.280   (since 10.279² ≤ mμ ≤ 10.280²)
--   42.152 ≤ √mτ  ≤ 42.153   (since 42.152² ≤ mτ ≤ 42.153²)
--
-- All numerical bounds verified by norm_num on exact rationals.
-- ════════════════════════════════════════════════════════════════════════════

private lemma sqrt_m_e_lb : (0.7148 : ℝ) ≤ Real.sqrt m_e := by
  rw [← Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 0.7148)]
  exact Real.sqrt_le_sqrt (by unfold m_e; norm_num)

private lemma sqrt_m_e_ub : Real.sqrt m_e ≤ (0.7149 : ℝ) := by
  rw [← Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 0.7149)]
  exact Real.sqrt_le_sqrt (by unfold m_e; norm_num)

private lemma sqrt_m_mu_lb : (10.279 : ℝ) ≤ Real.sqrt m_mu := by
  rw [← Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 10.279)]
  exact Real.sqrt_le_sqrt (by unfold m_mu; norm_num)

private lemma sqrt_m_mu_ub : Real.sqrt m_mu ≤ (10.280 : ℝ) := by
  rw [← Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 10.280)]
  exact Real.sqrt_le_sqrt (by unfold m_mu; norm_num)

private lemma sqrt_m_tau_lb : (42.152 : ℝ) ≤ Real.sqrt m_tau := by
  rw [← Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 42.152)]
  exact Real.sqrt_le_sqrt (by unfold m_tau; norm_num)

private lemma sqrt_m_tau_ub : Real.sqrt m_tau ≤ (42.153 : ℝ) := by
  rw [← Real.sqrt_sq (by norm_num : (0 : ℝ) ≤ 42.153)]
  exact Real.sqrt_le_sqrt (by unfold m_tau; norm_num)

-- ════════════════════════════════════════════════════════════════════════════
-- Section 3 — Empirical Koide Test
-- The Koide quotient Q(mₑ, mμ, mτ) = (mₑ+mμ+mτ)/(√mₑ+√mμ+√mτ)²
-- for the PDG 2022 lepton masses satisfies |Q − 2/3| < 10⁻³.
-- The actual value is Q ≈ 0.66666055, so |Q − 2/3| ≈ 6.1 × 10⁻⁶.
-- ════════════════════════════════════════════════════════════════════════════

/-- *** The empirical Koide test: |Q(mₑ, mμ, mτ) − 2/3| < 10⁻³. ***

    The Koide quotient for the PDG 2022 lepton masses lies within 10⁻³ of
    the exact value 2/3.  The actual deviation is ≈ 6.1 × 10⁻⁶, which is
    100× smaller than the stated bound; the bound 10⁻³ is chosen to admit
    a clean machine-checked proof while still demonstrating consistency.

    Proof outline:
    1.  Establish rational bounds for each √mᵢ from the helper lemmas above.
    2.  Bound the sum S = √mₑ + √mμ + √mτ ∈ [53.1458, 53.1479].
    3.  Bound the denominator D = S² using pow_le_pow_left (monotone squaring).
    4.  Use div_lt_iff / lt_div_iff to convert |M/D − 2/3| < 10⁻³ to a pair
        of linear-arithmetic goals, each closed by norm_num. -/
theorem koide_empirical :
    |koideQuotient m_e m_mu m_tau - 2 / 3| < 1 / 1000 := by
  -- Step 1: bounds on the √-sum S = √mₑ + √mμ + √mτ
  have hS_lb : (53.1458 : ℝ) ≤ Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau :=
    by linarith [sqrt_m_e_lb, sqrt_m_mu_lb, sqrt_m_tau_lb]
  have hS_ub : Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau ≤ (53.1479 : ℝ) :=
    by linarith [sqrt_m_e_ub, sqrt_m_mu_ub, sqrt_m_tau_ub]
  have hS_nn : (0 : ℝ) ≤ Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau :=
    by linarith [Real.sqrt_nonneg m_e, Real.sqrt_nonneg m_mu, Real.sqrt_nonneg m_tau]
  -- Step 2: D = (√mₑ + √mμ + √mτ)² is positive
  have hD_pos : (0 : ℝ) < (Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau) ^ 2 := by
    have hS_pos : (0 : ℝ) < Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau := by
      linarith
    exact pow_pos hS_pos 2
  -- Step 3: rational bounds on D using monotone squaring
  --   D_lb = 53.1458² = 2824.47605764 ≤ D ≤ 53.1479² = 2824.69927441 = D_ub
  have hD_lb : (2824.47605764 : ℝ) ≤
      (Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau) ^ 2 :=
    le_trans (by norm_num : (2824.47605764 : ℝ) ≤ (53.1458 : ℝ) ^ 2)
      (pow_le_pow_left (by norm_num : (0 : ℝ) ≤ 53.1458) hS_lb 2)
  have hD_ub : (Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau) ^ 2 ≤
      (2824.69927441 : ℝ) :=
    le_trans (pow_le_pow_left hS_nn hS_ub 2)
      (by norm_num : (53.1479 : ℝ) ^ 2 ≤ 2824.69927441)
  -- Step 4: prove the absolute value bound by splitting into two cases
  unfold koideQuotient
  rw [abs_lt]
  refine ⟨?_, ?_⟩
  · -- Lower bound: −1/1000 < M/D − 2/3,  i.e.,  (2/3 − 1/1000)·D < M
    have hprod_ub : (2 / 3 - 1 / 1000 : ℝ) *
        (Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau) ^ 2 ≤
        (2 / 3 - 1 / 1000) * 2824.69927441 :=
      mul_le_mul_of_nonneg_left hD_ub (by norm_num : (0 : ℝ) ≤ 2 / 3 - 1 / 1000)
    have hval : (2 / 3 - 1 / 1000 : ℝ) * 2824.69927441 <
        m_e + m_mu + m_tau := by unfold m_e m_mu m_tau; norm_num
    linarith [(lt_div_iff hD_pos).mpr (by linarith)]
  · -- Upper bound: M/D − 2/3 < 1/1000,  i.e.,  M < (2/3 + 1/1000)·D
    have hprod_lb : (2 / 3 + 1 / 1000 : ℝ) * 2824.47605764 ≤
        (2 / 3 + 1 / 1000) *
        (Real.sqrt m_e + Real.sqrt m_mu + Real.sqrt m_tau) ^ 2 :=
      mul_le_mul_of_nonneg_left hD_lb (by norm_num : (0 : ℝ) ≤ 2 / 3 + 1 / 1000)
    have hval : m_e + m_mu + m_tau <
        (2 / 3 + 1 / 1000 : ℝ) * 2824.47605764 := by unfold m_e m_mu m_tau; norm_num
    linarith [(div_lt_iff hD_pos).mpr (by linarith)]

-- ════════════════════════════════════════════════════════════════════════════
-- Section 4 — Theory–Experiment Bridge
-- Connecting the mathematical prediction C(φ²) = 2/3 to the empirical
-- Koide quotient Q ≈ 2/3.  Both sides equal 2/3 within 10⁻³.
-- ════════════════════════════════════════════════════════════════════════════

/-- *** Theory matches experiment: |C(φ²) − Q(PDG)| < 10⁻³. ***

    The Kernel coherence function evaluated at the golden ratio squared,
    C(φ²) = 2/3, differs from the empirical PDG lepton Koide quotient by
    less than 10⁻³.

    This is the central validation theorem of the Eigenverse framework:
    a mathematical quantity derived purely from the eigenvalue structure
    (C(φ²) = 2/3, proved in ParticleMass.lean without reference to any
    physical measurement) agrees with the experimentally measured lepton
    mass ratio to within 0.1%. -/
theorem koide_theory_matches_experiment :
    |C (φ ^ 2) - koideQuotient m_e m_mu m_tau| < 1 / 1000 := by
  rw [koide_coherence_bridge, abs_sub_comm]
  exact koide_empirical

/-- The empirical Koide quotient lies in (2/3 − 10⁻³, 2/3 + 10⁻³).

    These are the direct bounds from `koide_empirical`:
        1997/3000 = 2/3 − 1/1000 < Q < 2/3 + 1/1000 = 2003/3000. -/
theorem koide_empirical_range :
    (1997 : ℝ) / 3000 < koideQuotient m_e m_mu m_tau ∧
    koideQuotient m_e m_mu m_tau < 2003 / 3000 := by
  have h := koide_empirical
  rw [abs_lt] at h
  constructor <;> linarith

/-- The empirical Koide quotient exceeds the equal-mass lower bound 1/3. -/
theorem koide_empirical_above_degenerate :
    1 / 3 < koideQuotient m_e m_mu m_tau := by
  linarith [koide_empirical_range.1]

/-- The empirical Koide quotient is less than 1 (upper bound from §1 of
    ParticleMass.lean). -/
theorem koide_empirical_lt_one :
    koideQuotient m_e m_mu m_tau < 1 := by
  linarith [koide_empirical_range.2]

-- ════════════════════════════════════════════════════════════════════════════
-- Section 5 — Mass-Ratio Cross-Check
-- The proton/electron mass ratio R ≈ 1836 is already in the math layer
-- (ParticleMass.lean §6).  Here we verify that the PDG lepton mass scale
-- is consistent with R:  mμ/mₑ ≈ 206.8 < R.
-- This is a sanity check showing that the lepton mass scale is far below
-- the hadronic scale set by R.
-- ════════════════════════════════════════════════════════════════════════════

/-- The muon-to-electron mass ratio from PDG values. -/
noncomputable def muon_electron_ratio : ℝ := m_mu / m_e

/-- The muon-to-electron mass ratio is positive. -/
theorem muon_electron_ratio_pos : 0 < muon_electron_ratio := by
  unfold muon_electron_ratio
  exact div_pos m_mu_pos m_e_pos

/-- The muon-to-electron mass ratio is much larger than 1: the muon is
    much heavier than the electron. -/
theorem muon_heavier_than_electron_by_factor_200 : 200 < muon_electron_ratio := by
  unfold muon_electron_ratio m_mu m_e
  norm_num

/-- The muon-to-electron mass ratio is less than the proton/electron ratio R:
    the muon is lighter than the proton.
    mμ/mₑ ≈ 206.8 < 1836 = R. -/
theorem muon_electron_ratio_lt_proton_ratio :
    muon_electron_ratio < protonElectronRatio := by
  unfold muon_electron_ratio m_mu m_e protonElectronRatio
  norm_num

end -- noncomputable section
