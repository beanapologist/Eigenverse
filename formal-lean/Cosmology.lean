/-
  Cosmology.lean — Lean 4 formalization of wormhole geometry in general relativity.

  Wormholes are hypothetical structures in general relativity that act as tunnels
  connecting distant regions of spacetime.  They are solutions to Einstein's field
  equations G_{μν} = 8π T_{μν} (in units G = c = 1).

  The most prominent traversable wormhole is described by the Morris–Thorne metric
  (Morris & Thorne 1988):

      ds² = −e^{2Φ(r)} dt² + dr²/(1 − b(r)/r) + r²(dθ² + sin²θ dφ²)

  where:
    • Φ(r) — redshift function (gravitational time dilation; often set to 0 for
              the tidal-force-free case)
    • b(r) — shape function (defines the wormhole throat at b(r₀) = r₀)
    • r₀   — throat radius (the minimum proper radial distance; the narrowest point)

  Key structural results
  ──────────────────────
  §1.  Temporal metric component: e^{2Φ} > 0 always; for Φ = 0, e^{2·0} = 1.
  §2.  Throat geometry: the denominator 1 − b(r)/r vanishes at the throat and
       is positive away from it; the radial metric component g_rr = (1−b/r)⁻¹
       is positive and finite for all r > r₀.
  §3.  Flare-out condition: for constant b(r) = b₀, the derivative b'(r₀) = 0 < 1,
       ensuring the wormhole geometry expands on both sides of the throat.
  §4.  Asymptotic flatness: for constant b, the ratio b(r)/r → 0 as r → ∞,
       and the radial denominator → 1, recovering flat Minkowski space.
  §5.  Toy wormhole metric: the simplified metric with Φ = 0 and angular
       coefficient b₀² + r² has a positive-definite, non-degenerate spatial part.
  §6.  Einstein–Rosen bridge: the Schwarzschild shape function b(r) = 2M satisfies
       the throat condition at r = 2M (the Schwarzschild radius/event horizon).

  Historical note
  ───────────────
  The original Einstein–Rosen bridge (1935) is a non-traversable wormhole arising
  from the maximally extended Schwarzschild solution.  It requires no exotic matter
  but collapses too quickly for traversal.  Traversable wormholes (Morris–Thorne
  1988) require exotic matter with negative energy density near the throat —
  a violation of the null energy condition (NEC).

  Sections
  ────────
  1.  Temporal metric component  e^{2Φ}
  2.  Throat geometry: metric denominators and g_rr
  3.  Flare-out condition for traversability
  4.  Asymptotic flatness
  5.  Toy wormhole metric (Φ = 0, angular coefficient b₀² + r²)
  6.  Einstein–Rosen bridge (Schwarzschild case b(r) = 2M)
  7.  Cosmic energy budget (Planck 2018 ΛCDM best fit)

  Proof status
  ────────────
  All 34 theorems have complete machine-checked proofs.
  No `sorry` placeholders remain.
-/

import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic

open Real

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- Definitions
-- ════════════════════════════════════════════════════════════════════════════

/-- The positive temporal coefficient e^{2Φ(r)} appearing in the Morris–Thorne line element.

    The full temporal component of the metric is g_tt = −e^{2Φ(r)}, so the
    redshift function Φ(r) controls gravitational time dilation.  This function
    returns the positive factor e^{2Φ(r)} only; the negative sign is part of the
    full metric tensor.  For Φ(r) = 0 (tidal-force-free wormhole) this coefficient
    equals 1, meaning clocks run at the same rate at every point. -/
noncomputable def mt_temporal_coeff (Φ : ℝ → ℝ) (r : ℝ) : ℝ := Real.exp (2 * Φ r)

/-- The radial metric denominator 1 − b(r)/r in the Morris–Thorne line element.

    The full radial component is g_rr = 1/(1 − b(r)/r).  The denominator
    vanishes at the throat (where b(r₀) = r₀), producing a coordinate
    singularity — not a physical one — that marks the narrowest cross-section
    of the wormhole. -/
noncomputable def mt_radial_denom (b : ℝ → ℝ) (r : ℝ) : ℝ := 1 - b r / r

/-- The radial metric component g_rr = (1 − b(r)/r)⁻¹ of the Morris–Thorne metric.

    This is positive and finite away from the throat, reflecting the non-singular
    spatial geometry of a traversable wormhole.  At the throat the denominator
    vanishes (see `mt_throat_denom_zero`), making g_rr formally infinite — but
    the proper radial length through the throat remains finite. -/
noncomputable def mt_grr (b : ℝ → ℝ) (r : ℝ) : ℝ := (mt_radial_denom b r)⁻¹

/-- The toy wormhole angular metric coefficient b₀² + r².

    In the simplified Morris–Thorne metric with Φ = 0 and radial coordinate
    ranging over all reals, the angular part of the line element becomes
    (b₀² + r²)(dθ² + sin²θ dφ²).  Here b₀ = r₀ is the throat radius and r
    ranges from −∞ to +∞, with the two asymptotic regions meeting at r = 0. -/
noncomputable def toy_angular_coeff (b₀ r : ℝ) : ℝ := b₀ ^ 2 + r ^ 2

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Temporal metric component
-- The redshift factor e^{2Φ} controls gravitational time dilation.
-- Unlike black holes, the Morris–Thorne metric has no temporal event horizon.
-- ════════════════════════════════════════════════════════════════════════════

/-- The temporal metric coefficient is always strictly positive for any redshift Φ.

    Since exp(x) > 0 for all real x, the component g_tt = −e^{2Φ} is always
    nonzero.  This means the Morris–Thorne metric has no event horizon arising
    from the temporal component, distinguishing traversable wormholes from
    black holes. -/
theorem mt_temporal_pos (Φ : ℝ → ℝ) (r : ℝ) : 0 < mt_temporal_coeff Φ r :=
  Real.exp_pos _

/-- For zero redshift Φ(r) = 0, the temporal coefficient e^{2·0} = 1.

    The tidal-force-free case Φ = 0 gives a wormhole where gravitational time
    dilation is absent: an observer at any radial position measures the same
    proper time per coordinate time.  This is the most commonly studied model
    for illustrative purposes. -/
theorem mt_zero_redshift_temporal (r : ℝ) : mt_temporal_coeff (fun _ => 0) r = 1 := by
  simp [mt_temporal_coeff]

/-- For non-negative redshift Φ(r) ≥ 0, the temporal coefficient satisfies e^{2Φ} ≥ 1.

    When Φ ≥ 0 the wormhole spacetime is "redshifting": an observer near the
    throat ages more slowly compared to an observer at infinity.  The coefficient
    exceeds 1, meaning clocks near the throat run slower than clocks far away. -/
theorem mt_temporal_ge_one (Φ : ℝ → ℝ) (r : ℝ) (hΦ : 0 ≤ Φ r) :
    1 ≤ mt_temporal_coeff Φ r := by
  simp only [mt_temporal_coeff]
  exact Real.one_le_exp (mul_nonneg (by norm_num) hΦ)

-- ════════════════════════════════════════════════════════════════════════════
-- §2  Throat geometry: metric denominators and g_rr
-- The throat condition b(r₀) = r₀ produces a coordinate singularity.
-- Away from the throat, the spatial metric is positive definite.
-- ════════════════════════════════════════════════════════════════════════════

/-- At the wormhole throat, the throat condition b(r₀) = r₀ causes the radial
    denominator to vanish: 1 − b(r₀)/r₀ = 0.

    This is a coordinate singularity — not a curvature singularity.  The proper
    radial distance through the throat (∫ dr/√(1−b/r)) remains finite.  This is
    what distinguishes a wormhole from a black hole: the singularity is removable
    by a suitable change of coordinates (e.g., the proper radial coordinate l). -/
theorem mt_throat_denom_zero (r₀ : ℝ) (hr₀ : r₀ ≠ 0) (b : ℝ → ℝ) (hb : b r₀ = r₀) :
    mt_radial_denom b r₀ = 0 := by
  simp [mt_radial_denom, hb, div_self hr₀]

/-- Away from the throat, for r > r₀ > 0 with constant shape function b(r) = r₀,
    the radial denominator is strictly positive: 1 − r₀/r > 0.

    For r₀ < r, we have r₀/r < 1, so 1 − r₀/r > 0.  This ensures the radial
    metric component g_rr is well-defined and positive for all r > r₀, confirming
    the spatial part of the metric is non-degenerate away from the throat. -/
theorem mt_radial_denom_pos (r₀ r : ℝ) (hr₀ : 0 < r₀) (hr : r₀ < r) :
    0 < mt_radial_denom (fun _ => r₀) r := by
  show 0 < 1 - r₀ / r
  rw [sub_pos, div_lt_one (lt_trans hr₀ hr)]
  exact hr

/-- The radial metric component g_rr = (1 − b(r)/r)⁻¹ is strictly positive
    for r > r₀ > 0 with constant shape function.

    This confirms that the spatial part of the Morris–Thorne metric is positive
    definite away from the throat, giving a well-behaved Riemannian geometry on
    each constant-time hypersurface.  This is in sharp contrast to a black hole,
    where g_rr → ∞ at the (non-traversable) event horizon. -/
theorem mt_grr_pos (r₀ r : ℝ) (hr₀ : 0 < r₀) (hr : r₀ < r) :
    0 < mt_grr (fun _ => r₀) r :=
  inv_pos.mpr (mt_radial_denom_pos r₀ r hr₀ hr)

/-- The radial denominator equals 1 when the shape function is zero (b(r) = 0).

    Setting b = 0 removes the wormhole: the Morris–Thorne metric reduces to the
    flat Minkowski line element ds² = −e^{2Φ}dt² + dr² + r²dΩ².  This confirms
    the parameterisation is consistent with flat space as a limiting case. -/
theorem mt_radial_denom_flat_space (r : ℝ) :
    mt_radial_denom (fun _ => 0) r = 1 := by
  simp [mt_radial_denom]

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Flare-out condition for traversability
-- The flare-out condition b'(r₀) < 1 ensures the wormhole geometry opens up
-- on both sides of the throat, permitting passage.
-- ════════════════════════════════════════════════════════════════════════════

/-- The constant shape function b(r) = b₀ has derivative zero at every point.

    This is the `HasDerivAt` characterisation: the Fréchet derivative of the
    constant map equals 0 everywhere.  This is used to verify the flare-out
    condition b'(r₀) < 1 for the constant-shape-function model. -/
theorem mt_constant_shape_hasDerivAt (b₀ r₀ : ℝ) :
    HasDerivAt (fun _ : ℝ => b₀) 0 r₀ :=
  hasDerivAt_const r₀ b₀

/-- The pointwise derivative of the constant shape function is zero everywhere. -/
theorem mt_constant_shape_deriv (b₀ r₀ : ℝ) :
    deriv (fun _ : ℝ => b₀) r₀ = 0 :=
  (hasDerivAt_const r₀ b₀).deriv

/-- Flare-out condition for the constant shape function: b'(r₀) = 0 < 1.

    The flare-out condition b'(r₀) < 1 is necessary for traversability: it
    ensures the wormhole geometry "opens up" — that the cross-sectional area
    2πr increases as one moves away from the throat.  For a constant shape
    function b(r) = b₀ the derivative is 0, which is strictly less than 1.
    This makes the constant-shape wormhole the canonical toy model for a
    traversable wormhole satisfying the flare-out condition. -/
theorem mt_constant_flare_out (b₀ r₀ : ℝ) :
    deriv (fun _ : ℝ => b₀) r₀ < 1 := by
  rw [mt_constant_shape_deriv]
  norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- §4  Asymptotic flatness
-- For constant b(r) = r₀, the ratio b(r)/r → 0 as r → ∞.
-- The metric approaches Minkowski space at large distances from the throat.
-- ════════════════════════════════════════════════════════════════════════════

/-- Asymptotic flatness: for constant shape b(r) = r₀, the ratio r₀/r → 0 as r → ∞.

    For any ε > 0, choosing R = r₀/ε guarantees r₀/r < ε for all r > R.
    This confirms that the Morris–Thorne geometry is asymptotically flat: far
    from the throat, the spacetime looks like ordinary Minkowski space, so
    observers far from the wormhole mouth measure ordinary flat physics. -/
theorem mt_asymptotic_flat (r₀ ε : ℝ) (hr₀ : 0 < r₀) (hε : 0 < ε) :
    ∃ R : ℝ, ∀ r : ℝ, R < r → r₀ / r < ε := by
  refine ⟨r₀ / ε, fun r hR => ?_⟩
  have hr : 0 < r := lt_trans (div_pos hr₀ hε) hR
  rw [div_lt_iff hr]
  have h : ε * (r₀ / ε) = r₀ := by field_simp
  linarith [mul_lt_mul_of_pos_left hR hε]

/-- Asymptotic flatness of the radial denominator: for constant shape b(r) = r₀,
    the denominator 1 − r₀/r approaches 1 as r → ∞, so g_rr → 1.

    For any ε > 0, choosing R = r₀/ε guarantees |mt_radial_denom − 1| < ε for
    r > R.  This means the radial metric component approaches unity far from
    the wormhole, confirming the metric returns to flat space. -/
theorem mt_grr_denom_approaches_one (r₀ ε : ℝ) (hr₀ : 0 < r₀) (hε : 0 < ε) :
    ∃ R : ℝ, ∀ r : ℝ, R < r → |mt_radial_denom (fun _ => r₀) r - 1| < ε := by
  refine ⟨r₀ / ε, fun r hR => ?_⟩
  have hr : 0 < r := lt_trans (div_pos hr₀ hε) hR
  simp only [mt_radial_denom]
  rw [show (1 : ℝ) - r₀ / r - 1 = -(r₀ / r) by ring, abs_neg,
      abs_of_pos (div_pos hr₀ hr), div_lt_iff hr]
  have h : ε * (r₀ / ε) = r₀ := by field_simp
  linarith [mul_lt_mul_of_pos_left hR hε]

/-- The shape ratio b(r)/r = r₀/r is strictly decreasing in r for fixed r₀ > 0.

    As r increases away from the throat, the ratio r₀/r falls, and the geometry
    becomes progressively more like flat space.  This monotone decrease is the
    quantitative expression of asymptotic flatness: the wormhole's influence on
    the metric weakens as 1/r at large distances. -/
theorem mt_shape_ratio_decreasing (r₀ r₁ r₂ : ℝ) (hr₀ : 0 < r₀)
    (hr₁ : 0 < r₁) (hr₁₂ : r₁ < r₂) : r₀ / r₂ < r₀ / r₁ := by
  have hr₂ : 0 < r₂ := lt_trans hr₁ hr₁₂
  rw [div_lt_div_iff hr₂ hr₁]
  exact mul_lt_mul_of_pos_left hr₁₂ hr₀

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Toy wormhole metric (Φ = 0)
-- The simplified metric ds² = −dt² + dr² + (b₀²+r²)(dθ²+sin²θ dφ²)
-- provides a clean toy model for the Morris–Thorne wormhole.
-- ════════════════════════════════════════════════════════════════════════════

/-- The toy wormhole angular coefficient b₀² + r² is strictly positive for all r
    when b₀ > 0.

    The angular part of the toy metric is (b₀² + r²)(dθ² + sin²θ dφ²).  Since
    b₀² + r² ≥ b₀² > 0, the angular part is non-degenerate everywhere: the
    wormhole has a nonzero proper circumference 2π√(b₀²+r²) at every radius r. -/
theorem toy_angular_pos (b₀ r : ℝ) (hb : 0 < b₀) : 0 < toy_angular_coeff b₀ r := by
  show 0 < b₀ ^ 2 + r ^ 2
  have hb2 : 0 < b₀ ^ 2 := sq_pos_of_pos hb
  linarith [sq_nonneg r]

/-- The toy angular coefficient b₀² + r² is bounded below by b₀² for all r.

    At the throat (r = 0) the coefficient equals b₀², its minimum value.  The
    minimum angular coefficient b₀² corresponds to the throat circumference
    2π·b₀, which is the narrowest circle of the wormhole geometry. -/
theorem toy_angular_lower_bound (b₀ r : ℝ) :
    b₀ ^ 2 ≤ toy_angular_coeff b₀ r := by
  show b₀ ^ 2 ≤ b₀ ^ 2 + r ^ 2
  linarith [sq_nonneg r]

/-- The toy angular coefficient is symmetric about r = 0 (the throat).

    The symmetry b₀² + r² = b₀² + (−r)² reflects the Z₂ symmetry of the
    toy wormhole: the two asymptotic regions r → +∞ and r → −∞ are
    geometrically identical mirror images of each other, connected through
    the throat at r = 0. -/
theorem toy_angular_symmetric (b₀ r : ℝ) :
    toy_angular_coeff b₀ r = toy_angular_coeff b₀ (-r) := by
  simp [toy_angular_coeff, neg_sq]

/-- The toy angular coefficient b₀² + r₁² ≤ b₀² + r₂² when r₁² ≤ r₂².

    The angular coefficient increases monotonically in r² away from the throat.
    This expresses the "flaring out" geometry: cross-sections of the wormhole
    grow in proper area as one moves away from r = 0, consistent with the
    flare-out condition required for traversability. -/
theorem toy_angular_monotone (b₀ r₁ r₂ : ℝ) (h : r₁ ^ 2 ≤ r₂ ^ 2) :
    toy_angular_coeff b₀ r₁ ≤ toy_angular_coeff b₀ r₂ := by
  show b₀ ^ 2 + r₁ ^ 2 ≤ b₀ ^ 2 + r₂ ^ 2
  linarith

-- ════════════════════════════════════════════════════════════════════════════
-- §6  Einstein–Rosen bridge (Schwarzschild case)
-- The original 1935 Einstein–Rosen bridge uses the Schwarzschild shape
-- function b(r) = 2M.  It satisfies the throat condition but is non-traversable:
-- the throat pinches off too quickly for any signal to cross.
-- ════════════════════════════════════════════════════════════════════════════

/-- The Schwarzschild shape function b(r) = 2M satisfies the throat condition
    at r = 2M: b(2M) = 2M.

    The Schwarzschild radius r_s = 2M is the throat of the Einstein–Rosen bridge
    arising from the maximally extended Schwarzschild solution.  Unlike the
    Morris–Thorne metric, no exotic matter is required, but the bridge collapses
    too quickly for anything to traverse it. -/
theorem schwarzschild_throat_condition (M : ℝ) :
    (fun _ : ℝ => 2 * M) (2 * M) = 2 * M := rfl

/-- At the Schwarzschild throat r = 2M (for M ≠ 0), the radial denominator
    1 − b(2M)/(2M) = 0 vanishes.

    This singularity of the radial metric component coincides with the event
    horizon of the Schwarzschild black hole.  Unlike the Morris–Thorne coordinate
    singularity (which is traversable), the Schwarzschild horizon traps all
    in-falling matter and radiation, making the Einstein–Rosen bridge non-traversable. -/
theorem schwarzschild_throat_denom_zero (M : ℝ) (hM : M ≠ 0) :
    mt_radial_denom (fun _ => 2 * M) (2 * M) = 0 := by
  have h2M : (2 : ℝ) * M ≠ 0 := mul_ne_zero (by norm_num) hM
  simp [mt_radial_denom, div_self h2M]

/-- The Einstein–Rosen throat radius 2M is strictly positive for positive mass M.

    A physically meaningful Schwarzschild black hole has M > 0, so its throat
    is a two-sphere of positive radius 2M and area 16πM².  As M → 0 the throat
    collapses to a point and the wormhole geometry degenerates. -/
theorem einstein_rosen_throat_pos (M : ℝ) (hM : 0 < M) : 0 < 2 * M :=
  by linarith

-- ════════════════════════════════════════════════════════════════════════════
-- §7  Cosmic energy budget (Planck 2018 ΛCDM best fit)
-- The energy content of the observable universe divides into three components:
--   • Dark energy (cosmological constant Λ):  Ω_Λ  ≈ 68.3 %  (683/1000)
--   • Cold dark matter (non-baryonic):         Ω_dm ≈ 26.8 %  (268/1000)
--   • Baryonic (ordinary) matter:              Ω_b  ≈  4.9 %  ( 49/1000)
-- These are the Planck 2018 CMB best-fit values for a spatially flat universe.
-- Flatness: Ω_total = Ω_Λ + Ω_dm + Ω_b = 1 (to this level of approximation).
-- Source: Planck 2018 Results VI, A&A 641, A6 (2020), Table 2.
-- ════════════════════════════════════════════════════════════════════════════

/-- Dark energy fraction of the total cosmic energy density (Planck 2018 ΛCDM).

    Ω_Λ = 683/1000 ≈ 68.3 %.  The cosmological constant Λ acts as a
    homogeneous, isotropic vacuum energy that drives the accelerated expansion
    of the universe first observed in 1998 (Riess et al.; Perlmutter et al.). -/
noncomputable def omega_de : ℝ := 683 / 1000

/-- Cold dark matter fraction of the total cosmic energy density (Planck 2018 ΛCDM).

    Ω_dm = 268/1000 ≈ 26.8 %.  Dark matter is non-luminous, non-baryonic,
    and interacts only gravitationally.  Its existence is inferred from galaxy
    rotation curves, gravitational lensing, and large-scale structure. -/
noncomputable def omega_dm : ℝ := 268 / 1000

/-- Baryonic (ordinary) matter fraction of the total cosmic energy density
    (Planck 2018 ΛCDM).

    Ω_b = 49/1000 ≈ 4.9 %.  Baryonic matter comprises protons, neutrons, and
    electrons — all atoms and molecules.  It is the only component that emits,
    absorbs, or scatters light, yet it constitutes less than 5 % of the
    cosmic energy budget. -/
noncomputable def omega_b : ℝ := 49 / 1000

/-- Total matter fraction (dark + baryonic) in flat ΛCDM:
    Ω_m = Ω_dm + Ω_b = 317/1000 ≈ 31.7 %. -/
noncomputable def omega_m : ℝ := omega_dm + omega_b

/-- Dimensionless expansion-rate proxy from the measured cosmic budget:
    Ω_Λ - Ω_m.

    In a Λ-dominated universe, a positive value predicts accelerated expansion. -/
noncomputable def expansion_rate_proxy : ℝ := omega_de - omega_m

/-- In the Planck-2018 budget used here, the expansion-rate proxy is 183/500. -/
theorem expansion_rate_proxy_value : expansion_rate_proxy = 183 / 500 := by
  simp [expansion_rate_proxy, omega_m, omega_de, omega_dm, omega_b]
  norm_num

/-- The expansion-rate proxy is positive in the current epoch. -/
theorem expansion_rate_proxy_pos : 0 < expansion_rate_proxy := by
  rw [expansion_rate_proxy_value]
  norm_num

/-- Normalized time model for the expansion-rate trend from origin to present.

    `t = 0` represents the origin, `t = 1` represents the present epoch. -/
noncomputable def expansion_rate_at (t : ℝ) : ℝ :=
  (2 * t - 1) * expansion_rate_proxy

/-- At the origin (`t=0`), the model gives the negative of the present proxy. -/
theorem expansion_rate_at_origin : expansion_rate_at 0 = -expansion_rate_proxy := by
  simp [expansion_rate_at]

/-- Midpoint transition (`t=1/2`) gives zero in the normalized model. -/
theorem expansion_rate_at_midpoint : expansion_rate_at ((1 : ℝ) / 2) = 0 := by
  simp [expansion_rate_at]

/-- At present (`t=1`), the model recovers the current expansion-rate proxy. -/
theorem expansion_rate_at_present : expansion_rate_at 1 = expansion_rate_proxy := by
  simp [expansion_rate_at]

/-- Quarter-time sample value in the normalized expansion-rate model. -/
theorem expansion_rate_at_quarter : expansion_rate_at ((1 : ℝ) / 4) = -(183 / 1000 : ℝ) := by
  rw [expansion_rate_at, expansion_rate_proxy_value]
  norm_num

/-- Three-quarter-time sample value in the normalized expansion-rate model. -/
theorem expansion_rate_at_three_quarters : expansion_rate_at ((3 : ℝ) / 4) = (183 / 1000 : ℝ) := by
  rw [expansion_rate_at, expansion_rate_proxy_value]
  norm_num

/-- The dark energy fraction is strictly positive. -/
theorem omega_de_pos : 0 < omega_de := by
  show (0 : ℝ) < 683 / 1000; norm_num

/-- The dark matter fraction is strictly positive. -/
theorem omega_dm_pos : 0 < omega_dm := by
  show (0 : ℝ) < 268 / 1000; norm_num

/-- The baryonic matter fraction is strictly positive. -/
theorem omega_b_pos : 0 < omega_b := by
  show (0 : ℝ) < 49 / 1000; norm_num

/-- The three energy components sum to 1: Ω_Λ + Ω_dm + Ω_b = 1.

    This is the flatness condition for the ΛCDM universe: 683 + 268 + 49 = 1000.
    A spatially flat universe has total energy density equal to the critical
    density ρ_c = 3H₀²/(8πG), consistent with CMB measurements of the acoustic
    horizon scale. -/
theorem omega_sum_one : omega_de + omega_dm + omega_b = 1 := by
  show (683 : ℝ) / 1000 + 268 / 1000 + 49 / 1000 = 1; norm_num

/-- Dark energy is strictly less than 1 (it does not constitute the entire universe). -/
theorem omega_de_lt_one : omega_de < 1 := by
  show (683 : ℝ) / 1000 < 1; norm_num

/-- Dark energy is the dominant component: Ω_dm < Ω_Λ.

    Dark energy (≈ 68.3 %) exceeds dark matter (≈ 26.8 %).  This dominance
    of Λ over matter is a relatively recent development in cosmic history:
    matter–Λ equality occurred at redshift z ≈ 0.3. -/
theorem dark_energy_dominant : omega_dm < omega_de := by
  show (268 : ℝ) / 1000 < 683 / 1000; norm_num

/-- Dark matter exceeds baryonic matter: Ω_b < Ω_dm.

    Cold dark matter (≈ 26.8 %) is more than five times more abundant than
    ordinary baryonic matter (≈ 4.9 %).  This ratio is constrained by Big Bang
    nucleosynthesis, baryon acoustic oscillations, and CMB anisotropies. -/
theorem dark_matter_gt_baryonic : omega_b < omega_dm := by
  show (49 : ℝ) / 1000 < 268 / 1000; norm_num

/-- Dark energy exceeds baryonic matter: Ω_b < Ω_Λ. -/
theorem dark_energy_gt_baryonic : omega_b < omega_de := by
  show (49 : ℝ) / 1000 < 683 / 1000; norm_num

/-- Dark energy constitutes more than half the universe: Ω_Λ > 1/2.

    The majority of the cosmic energy budget is dark energy.  This majority
    is the engine of cosmic acceleration: the universe's expansion rate has
    been increasing since z ≈ 0.7. -/
theorem dark_energy_majority : (1 : ℝ) / 2 < omega_de := by
  show (1 : ℝ) / 2 < 683 / 1000; norm_num

/-- The dark sector (dark energy + dark matter) overwhelmingly dominates ordinary matter.

    Ω_Λ + Ω_dm = 951/1000 ≈ 95.1 %, while Ω_b ≈ 4.9 %.  The universe is
    "dark" in the sense that ≈ 95 % of its energy content is inaccessible to
    electromagnetic observation. -/
theorem dark_sector_gt_baryonic : omega_b < omega_de + omega_dm := by
  show (49 : ℝ) / 1000 < 683 / 1000 + 268 / 1000; norm_num

/-- The total dark sector fraction equals 951/1000 ≈ 95.1 %. -/
theorem dark_sector_total : omega_de + omega_dm = 951 / 1000 := by
  show (683 : ℝ) / 1000 + 268 / 1000 = 951 / 1000; norm_num

/-- Strict energy ordering: baryonic matter < dark matter < dark energy.

    This total ordering Ω_b < Ω_dm < Ω_Λ captures the hierarchy of the cosmic
    energy budget: ordinary matter is the smallest component, dark matter is
    intermediate, and dark energy is dominant. -/
theorem cosmic_energy_ordering :
    omega_b < omega_dm ∧ omega_dm < omega_de := by
  exact ⟨dark_matter_gt_baryonic, dark_energy_dominant⟩

/-- Baryonic matter is the smallest of the three components:
    Ω_b < Ω_dm and Ω_b < Ω_Λ. -/
theorem baryonic_smallest :
    omega_b < omega_dm ∧ omega_b < omega_de :=
  ⟨dark_matter_gt_baryonic, dark_energy_gt_baryonic⟩

/-- Baryonic (ordinary) matter constitutes less than 10 % of the universe: Ω_b < 1/10.

    At ≈ 4.9 %, all stars, planets, gas clouds, and atoms together amount to
    less than a tenth of the cosmic energy budget.  The remaining ≥ 95 %
    consists of dark matter and dark energy. -/
theorem omega_b_lt_tenth : omega_b < 1 / 10 := by
  show (49 : ℝ) / 1000 < 1 / 10; norm_num

end
