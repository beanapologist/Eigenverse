/-
  FourSector.lean — Four-quadrant formalization of the Oil-and-Vinegar analogy.

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   The Oil-and-Vinegar analogy made structurally honest:                  ║
  ║                                                                          ║
  ║   The complex plane is divided into four open quadrants Q1–Q4.           ║
  ║   A FourState assigns one complex number to each quadrant.               ║
  ║   The observation map projects to the Q2 ("vinegar") component.          ║
  ║                                                                          ║
  ║   Key results:                                                           ║
  ║     • Visible uniqueness: sector constraint + V2 + unit energy → μ.     ║
  ║     • Hidden-sector freedom: two distinct Coherent FourStates share      ║
  ║       the same observe value — the oil subspace is non-trivial.          ║
  ║                                                                          ║
  ║   Cryptographic structure:                                               ║
  ║     • The visible sector Q2 is uniquely observable (vinegar).            ║
  ║     • The hidden sectors Q1 ∪ Q3 ∪ Q4 are underdetermined (oil).        ║
  ║     • Recovering the full FourState from observe is conjectured hard.    ║
  ║                                                                          ║
  ║   Sections                                                               ║
  ║   ────────                                                               ║
  ║   §1  Sector type and quadrant membership                                ║
  ║   §2  FourState structure with quadrant constraints                      ║
  ║   §3  Observation map and energy predicate                               ║
  ║   §4  Visible uniqueness theorem                                         ║
  ║   §5  Hidden-sector freedom theorem                                      ║
  ║   §5b Five-dimensional oil fiber                                         ║
  ║   §6  Hardness conjecture (axiom)                                        ║
  ║   §7  Measurement asymmetry                                              ║
  ║                                                                          ║
  ║   Proof status                                                           ║
  ║   ────────────                                                           ║
  ║   Proven:  visible_unique, hidden_freedom, oil_subspace_parametric,      ║
  ║            oil_fiber_map_mem, oil_fiber_five_dimensional,                ║
  ║            alice_key_determines_state, adversary_view_constant,          ║
  ║            adversary_indistinguishable, measurement_asymmetry,           ║
  ║            adversary_cannot_recover                                      ║
  ║   Sorry:   none                                                          ║
  ║   Axioms:  hidden_recovery_hard  (cryptographic assumption)              ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝
-/

import BalanceHypothesis

open Complex Real

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Sector Type and Quadrant Membership
-- The complex plane is partitioned into four open quadrants by the sign of
-- the real and imaginary parts.
-- ════════════════════════════════════════════════════════════════════════════

/-- The four open quadrants of the complex plane.

    - `Q1`: Re > 0 and Im > 0  (upper right)
    - `Q2`: Re < 0 and Im > 0  (upper left  — the "vinegar" sector)
    - `Q3`: Re < 0 and Im < 0  (lower left)
    - `Q4`: Re > 0 and Im < 0  (lower right)

    The quadrants are open (strict inequalities); points on the axes
    belong to none of them. -/
inductive Sector : Type
  | Q1 : Sector
  | Q2 : Sector
  | Q3 : Sector
  | Q4 : Sector

/-- Quadrant membership predicate.

    `Sector.contains s z` holds when the complex number `z` lies in the
    open quadrant described by `s`. -/
def Sector.contains : Sector → ℂ → Prop
  | Sector.Q1, z => 0 < z.re ∧ 0 < z.im
  | Sector.Q2, z => z.re < 0 ∧ 0 < z.im
  | Sector.Q3, z => z.re < 0 ∧ z.im < 0
  | Sector.Q4, z => 0 < z.re ∧ z.im < 0

-- ════════════════════════════════════════════════════════════════════════════
-- §2  FourState Structure
-- A FourState bundles four complex numbers, one per quadrant, each
-- constrained to lie in its labeled open quadrant.
-- ════════════════════════════════════════════════════════════════════════════

/-- A four-sector state: one complex number per quadrant.

    Each field `qᵢ` is required to lie in the corresponding open quadrant
    Qᵢ via the constraint `hqᵢ : Sector.Qᵢ.contains qᵢ`. -/
structure FourState where
  /-- The Q1 component (Re > 0, Im > 0). -/
  q1 : ℂ
  /-- The Q2 component (Re < 0, Im > 0) — the visible "vinegar" sector. -/
  q2 : ℂ
  /-- The Q3 component (Re < 0, Im < 0) — a hidden "oil" sector. -/
  q3 : ℂ
  /-- The Q4 component (Re > 0, Im < 0) — a hidden "oil" sector. -/
  q4 : ℂ
  /-- Q1 membership constraint. -/
  hq1 : Sector.Q1.contains q1
  /-- Q2 membership constraint. -/
  hq2 : Sector.Q2.contains q2
  /-- Q3 membership constraint. -/
  hq3 : Sector.Q3.contains q3
  /-- Q4 membership constraint. -/
  hq4 : Sector.Q4.contains q4

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Observation Map and Energy Predicate
-- ════════════════════════════════════════════════════════════════════════════

/-- The observation map: project to the visible Q2 component.

    In the Oil-and-Vinegar analogy `q2` is the "vinegar" variable —
    it is directly observable.  The remaining components `q1`, `q3`, `q4`
    are the "oil" variables: hidden and underdetermined by the observation. -/
def observe (s : FourState) : ℂ := s.q2

/-- The Coherent energy predicate: the sum of squared norms equals 4.

    One unit of spectral energy is allocated to each of the four sectors.
    This is the four-sector analogue of the unit-circle constraint
    `|z|² = 1` used in `BalanceHypothesis`. -/
def Coherent (s : FourState) : Prop :=
  Complex.normSq s.q1 + Complex.normSq s.q2 +
  Complex.normSq s.q3 + Complex.normSq s.q4 = 4

-- ════════════════════════════════════════════════════════════════════════════
-- §4  Visible Uniqueness Theorem
-- If a FourState's Q2 component satisfies the sector constraint (Re < 0),
-- V2 (directed balance), and unit energy, then the observation is uniquely μ.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Visible uniqueness** — sector constraint + V2 + unit energy forces observe s = μ.

    If a FourState `s` satisfies:
      - the Q2 sector constraint (Re(q2) < 0, encoded in `s.hq2`),
      - the directed balance V2 (−Re(q2) = Im(q2)), and
      - unit energy on the visible sector (Re(q2)² + Im(q2)² = 1),
    then `observe s = μ`.

    The `Coherent` predicate constrains the total energy across all four
    sectors; the `hener` hypothesis additionally fixes the visible sector's
    energy to 1.  These three conditions precisely match the hypotheses of
    `reality_unique` from `BalanceHypothesis`.

    Proof: the Q2 membership gives Re < 0; with V2 and unit energy, apply
    `reality_unique` directly. -/
theorem visible_unique (s : FourState)
    (hcoh  : Coherent s)
    (hV2   : -s.q2.re = s.q2.im)
    (hener : s.q2.re ^ 2 + s.q2.im ^ 2 = 1) :
    observe s = μ := by
  -- The Q2 sector constraint gives Re(q2) < 0.
  have hre_neg : s.q2.re < 0 := s.hq2.1
  -- Apply reality_unique from BalanceHypothesis (observe s = s.q2 by rfl).
  exact reality_unique s.q2 hre_neg hV2 hener

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Hidden-Sector Freedom Theorem
-- There exist two distinct Coherent FourStates with the same observe value.
-- This witnesses the oil subspace: many hidden configurations are consistent
-- with a single visible observation.
-- ════════════════════════════════════════════════════════════════════════════

-- Helper: normSq μ = 1.
private lemma normSq_mu : Complex.normSq μ = 1 := by
  rw [Complex.normSq_eq_abs, mu_abs_one]; norm_num

/-- **Hidden-sector freedom** — two distinct Coherent FourStates share the same observation.

    We exhibit two explicit witnesses `s₁` and `s₂` that agree on
    `q1 = η + iη`, `q2 = μ`, `q3 = −η − iη` but differ in the hidden Q4
    component.  Both satisfy the `Coherent` energy predicate (total normSq = 4).

    This is the oil-subspace existence result: the map `observe` is not
    injective on `Coherent` FourStates.  Recovering the full state from
    a single observation is generically impossible.

    **Witnesses** (shared: q1 = η + iη, q2 = μ, q3 = −η − iη):
    - `s₁`: q4 = η − iη      (normSq = η² + η² = 1)
    - `s₂`: q4 = 3/5 − 4i/5  (normSq = 9/25 + 16/25 = 1)

    Both have total normSq = 1 + 1 + 1 + 1 = 4, confirming `Coherent`.
    They differ since η = 1/√2 ≠ 3/5 (from 2η² = 1 vs. 2·(3/5)² = 18/25 ≠ 1). -/
theorem hidden_freedom :
    ∃ s₁ s₂ : FourState,
      Coherent s₁ ∧ Coherent s₂ ∧
      observe s₁ = μ ∧ observe s₂ = μ ∧
      s₁ ≠ s₂ := by
  have hη_pos : (0 : ℝ) < η := eta_pos
  have hη_neg : -(η : ℝ) < 0 := by linarith
  -- ── Shared quadrant membership proofs ───────────────────────────────────
  -- Q1 component: (η, η)
  have hq1_mem : Sector.Q1.contains (⟨η, η⟩ : ℂ) := ⟨hη_pos, hη_pos⟩
  -- Q2 component: μ = (−η, η)
  have hq2_mem : Sector.Q2.contains μ := ⟨mu_re_neg, mu_im_pos⟩
  -- Q3 component: (−η, −η)
  have hq3_mem : Sector.Q3.contains (⟨-η, -η⟩ : ℂ) := ⟨hη_neg, hη_neg⟩
  -- Q4 component for s₁: (η, −η)
  have hq4₁_mem : Sector.Q4.contains (⟨η, -η⟩ : ℂ) := ⟨hη_pos, hη_neg⟩
  -- Q4 component for s₂: (3/5, −4/5)
  have hq4₂_mem : Sector.Q4.contains (⟨3/5, -4/5⟩ : ℂ) := ⟨by norm_num, by norm_num⟩
  -- ── Construct the two witnesses ─────────────────────────────────────────
  let s₁ : FourState :=
    { q1 := ⟨η, η⟩,   q2 := μ, q3 := ⟨-η, -η⟩, q4 := ⟨η, -η⟩,
      hq1 := hq1_mem,  hq2 := hq2_mem, hq3 := hq3_mem, hq4 := hq4₁_mem }
  let s₂ : FourState :=
    { q1 := ⟨η, η⟩,   q2 := μ, q3 := ⟨-η, -η⟩, q4 := ⟨3/5, -4/5⟩,
      hq1 := hq1_mem,  hq2 := hq2_mem, hq3 := hq3_mem, hq4 := hq4₂_mem }
  -- ── normSq computations ─────────────────────────────────────────────────
  -- normSq(η, η) = η² + η² = 1
  have hnSq_q1 : Complex.normSq (⟨η, η⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; exact balance_from_unit_circle
  -- normSq μ = 1
  have hnSq_q2 : Complex.normSq μ = 1 := normSq_mu
  -- normSq(−η, −η) = (−η)² + (−η)² = η² + η² = 1
  have hnSq_q3 : Complex.normSq (⟨-η, -η⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; simp only [neg_sq]; exact balance_from_unit_circle
  -- normSq(η, −η) = η² + (−η)² = η² + η² = 1
  have hnSq_q4₁ : Complex.normSq (⟨η, -η⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; simp only [neg_sq]; exact balance_from_unit_circle
  -- normSq(3/5, −4/5) = (3/5)² + (−4/5)² = 9/25 + 16/25 = 1
  have hnSq_q4₂ : Complex.normSq (⟨3/5, -4/5⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; norm_num
  -- ── Coherent proofs ─────────────────────────────────────────────────────
  have hcoh₁ : Coherent s₁ := by
    show Complex.normSq (⟨η, η⟩ : ℂ) + Complex.normSq μ +
         Complex.normSq (⟨-η, -η⟩ : ℂ) + Complex.normSq (⟨η, -η⟩ : ℂ) = 4
    linarith [hnSq_q1, hnSq_q2, hnSq_q3, hnSq_q4₁]
  have hcoh₂ : Coherent s₂ := by
    show Complex.normSq (⟨η, η⟩ : ℂ) + Complex.normSq μ +
         Complex.normSq (⟨-η, -η⟩ : ℂ) + Complex.normSq (⟨3/5, -4/5⟩ : ℂ) = 4
    linarith [hnSq_q1, hnSq_q2, hnSq_q3, hnSq_q4₂]
  -- ── Observation values ──────────────────────────────────────────────────
  have hobs₁ : observe s₁ = μ := rfl
  have hobs₂ : observe s₂ = μ := rfl
  -- ── s₁ ≠ s₂: the Q4 real parts differ (η ≠ 3/5) ───────────────────────
  have hne : s₁ ≠ s₂ := by
    intro heq
    -- The Q4 fields must be equal
    have hq4 : s₁.q4 = s₂.q4 := congrArg FourState.q4 heq
    -- Extract real-part equality: η = 3/5
    have hre : η = 3 / 5 := congrArg Complex.re hq4
    -- Contradiction: 2η² = 1 but 2·(3/5)² = 18/25 ≠ 1
    have h2η := balance_two_eta_sq
    rw [hre] at h2η
    norm_num at h2η
  exact ⟨s₁, s₂, hcoh₁, hcoh₂, hobs₁, hobs₂, hne⟩

/-- **Oil subspace parametrization** — the oil subspace is uncountably infinite.

    For every `a ∈ (0, 1)`, there exists a Coherent FourState `s` satisfying
    `observe s = μ` and `s.q4.re = a`.  Because distinct values of `a`
    produce states with distinct `q4.re`, the assignment `a ↦ s` is injective
    and the oil subspace contains an uncountable continuous family.

    Construction: fix `q1 = η + iη`, `q2 = μ`, `q3 = −η − iη` (each with
    normSq = 1), and let `q4 = (a, −√(1−a²))`.  Since `0 < a < 1` we have
    `1 − a² ∈ (0, 1)`, so `√(1−a²) > 0` and `q4 ∈ Q4`.  Moreover
    `normSq q4 = a² + (1−a²) = 1`, so the total normSq is `1+1+1+1 = 4`.

    In summary: the oil subspace `{s : FourState | Coherent s ∧ observe s = μ}`
    contains an uncountable family, parametrized by the open arc of the
    unit circle in Q4 (Re ∈ (0, 1)).  The answer to "how big?" is:
    **uncountably infinite** — a continuous 5-real-parameter family subject to
    one normSq constraint, or concretely at least as large as (0, 1) ⊂ ℝ. -/
theorem oil_subspace_parametric (a : ℝ) (ha_pos : 0 < a) (ha_lt : a < 1) :
    ∃ s : FourState, Coherent s ∧ observe s = μ ∧ s.q4.re = a := by
  -- b = √(1 − a²) is the (positive) imaginary magnitude of the Q4 component
  set b := Real.sqrt (1 - a ^ 2) with hb_def
  have hb_arg : 0 < 1 - a ^ 2 := by nlinarith
  have hb_pos : 0 < b := sqrt_pos.mpr hb_arg
  have hb_sq  : b ^ 2 = 1 - a ^ 2 := by
    rw [hb_def]; exact Real.sq_sqrt (le_of_lt hb_arg)
  -- Quadrant membership
  have hη_neg : -(η : ℝ) < 0 := by linarith [eta_pos]
  have hq1_mem : Sector.Q1.contains (⟨η, η⟩ : ℂ)  := ⟨eta_pos, eta_pos⟩
  have hq2_mem : Sector.Q2.contains μ               := ⟨mu_re_neg, mu_im_pos⟩
  have hq3_mem : Sector.Q3.contains (⟨-η, -η⟩ : ℂ) := ⟨hη_neg, hη_neg⟩
  have hq4_mem : Sector.Q4.contains (⟨a, -b⟩ : ℂ)  := ⟨ha_pos, by linarith⟩
  -- Construct the witness
  let s : FourState :=
    { q1 := ⟨η, η⟩,  q2 := μ,  q3 := ⟨-η, -η⟩,  q4 := ⟨a, -b⟩,
      hq1 := hq1_mem, hq2 := hq2_mem, hq3 := hq3_mem, hq4 := hq4_mem }
  -- normSq computations
  have hnSq_q1 : Complex.normSq (⟨η, η⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; exact balance_from_unit_circle
  have hnSq_q2 : Complex.normSq μ = 1 := normSq_mu
  have hnSq_q3 : Complex.normSq (⟨-η, -η⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; simp only [neg_sq]; exact balance_from_unit_circle
  have hnSq_q4 : Complex.normSq (⟨a, -b⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; simp only [neg_sq]; linarith [hb_sq]
  -- Coherent: total normSq = 4
  have hcoh : Coherent s := by
    show Complex.normSq (⟨η, η⟩ : ℂ) + Complex.normSq μ +
         Complex.normSq (⟨-η, -η⟩ : ℂ) + Complex.normSq (⟨a, -b⟩ : ℂ) = 4
    linarith [hnSq_q1, hnSq_q2, hnSq_q3, hnSq_q4]
  exact ⟨s, hcoh, rfl, rfl⟩

-- ════════════════════════════════════════════════════════════════════════════
-- §5b  Five-Dimensional Oil Fiber
-- The oil fiber {s : FourState | Coherent s ∧ observe s = μ} admits an
-- explicit injective parametrization by five real numbers, establishing
-- that the fiber is at least 5-dimensional.
--
-- Parametrization: (x₁, y₁, x₃, y₃, t) ↦ FourState with
--   q1 = x₁ + i·y₁,   q2 = μ,   q3 = x₃ + i·y₃,
--   q4 = r₄·t + i·(−r₄·√(1−t²)),   r₄ = √(3 − x₁²−y₁²−x₃²−y₃²)
--
-- Injectivity: q1 recovers (x₁, y₁); q3 recovers (x₃, y₃); the radius
-- r₄ is then determined, and Re(q4) = r₄·t with r₄ > 0 recovers t.
-- ════════════════════════════════════════════════════════════════════════════

/-- Five real parameters for the oil fiber parametrization.
    No bundled proof fields; validity is captured by `OilValid`. -/
@[ext]
structure OilParams where
  /-- Re(q1), must be positive (Q1 sector).        -/ x₁ : ℝ
  /-- Im(q1), must be positive (Q1 sector).        -/ y₁ : ℝ
  /-- Re(q3), must be negative (Q3 sector).        -/ x₃ : ℝ
  /-- Im(q3), must be negative (Q3 sector).        -/ y₃ : ℝ
  /-- Normalized Re(q4)/r₄, must lie in (0, 1).   -/ t  : ℝ

/-- Validity of `OilParams`: all five parameters in their required open
    ranges, with sufficient energy remaining for a nonzero Q4 component. -/
def OilValid (p : OilParams) : Prop :=
  0 < p.x₁ ∧ 0 < p.y₁ ∧ p.x₃ < 0 ∧ p.y₃ < 0 ∧
  0 < p.t  ∧ p.t < 1 ∧ p.x₁ ^ 2 + p.y₁ ^ 2 + p.x₃ ^ 2 + p.y₃ ^ 2 < 3

-- The squared radius of the Q4 circle (energy left after q1, q2, q3).
private def q4RadSq (p : OilParams) : ℝ :=
  3 - p.x₁ ^ 2 - p.y₁ ^ 2 - p.x₃ ^ 2 - p.y₃ ^ 2

private lemma q4RadSq_pos {p : OilParams} (hv : OilValid p) : 0 < q4RadSq p := by
  obtain ⟨_, _, _, _, _, _, hfib⟩ := hv
  simp only [q4RadSq]; linarith

-- The Q4 radius.
private noncomputable def q4Rad (p : OilParams) : ℝ := Real.sqrt (q4RadSq p)

private lemma q4Rad_pos {p : OilParams} (hv : OilValid p) : 0 < q4Rad p :=
  sqrt_pos.mpr (q4RadSq_pos hv)

-- (√(q4RadSq p))² = q4RadSq p
private lemma q4Rad_sq_eq {p : OilParams} (hv : OilValid p) :
    q4Rad p ^ 2 = q4RadSq p := by
  rw [q4Rad]; exact Real.sq_sqrt (le_of_lt (q4RadSq_pos hv))

/-- **Oil fiber map** — constructs a Coherent FourState with `observe = μ`
    from five real parameters `(x₁, y₁, x₃, y₃, t)`.

    The Q4 component `r₄·t + i·(−r₄·√(1−t²))` lies on a circle of
    radius `r₄ = √(3 − ‖q1‖² − ‖q3‖²)` inside Q4, so the Coherent
    energy constraint `normSq q1 + 1 + normSq q3 + r₄² = 4` holds. -/
noncomputable def oil_fiber_map (p : OilParams) (hv : OilValid p) : FourState := by
  obtain ⟨hx₁, hy₁, hx₃, hy₃, ht_pos, ht_lt, _⟩ := hv
  have hr_pos : 0 < q4Rad p := q4Rad_pos hv
  have ht2_pos : 0 < 1 - p.t ^ 2 := by nlinarith
  exact
    { q1 := ⟨p.x₁, p.y₁⟩
      q2 := μ
      q3 := ⟨p.x₃, p.y₃⟩
      q4 := ⟨q4Rad p * p.t, -(q4Rad p * Real.sqrt (1 - p.t ^ 2))⟩
      hq1 := ⟨hx₁, hy₁⟩
      hq2 := ⟨mu_re_neg, mu_im_pos⟩
      hq3 := ⟨hx₃, hy₃⟩
      hq4 := ⟨mul_pos hr_pos ht_pos,
               neg_of_pos (mul_pos hr_pos (sqrt_pos.mpr ht2_pos))⟩ }

-- Projection simp lemmas (follow from the definition by rfl).
@[simp] private lemma ofm_q1 (p : OilParams) (hv : OilValid p) :
    (oil_fiber_map p hv).q1 = ⟨p.x₁, p.y₁⟩ := rfl
@[simp] private lemma ofm_q2 (p : OilParams) (hv : OilValid p) :
    (oil_fiber_map p hv).q2 = μ := rfl
@[simp] private lemma ofm_q3 (p : OilParams) (hv : OilValid p) :
    (oil_fiber_map p hv).q3 = ⟨p.x₃, p.y₃⟩ := rfl
@[simp] private lemma ofm_q4 (p : OilParams) (hv : OilValid p) :
    (oil_fiber_map p hv).q4 =
      ⟨q4Rad p * p.t, -(q4Rad p * Real.sqrt (1 - p.t ^ 2))⟩ := rfl

-- normSq q4 = q4RadSq p (unit-arc identity).
private lemma normSq_q4_eq (p : OilParams) (hv : OilValid p) :
    Complex.normSq (⟨q4Rad p * p.t, -(q4Rad p * Real.sqrt (1 - p.t ^ 2))⟩ : ℂ) =
    q4RadSq p := by
  have ht2_nn : 0 ≤ 1 - p.t ^ 2 := by
    obtain ⟨_, _, _, _, ht_pos, ht_lt, _⟩ := hv; nlinarith
  rw [Complex.normSq_apply]
  simp only [Complex.re, Complex.im, neg_sq]
  -- Factor out r₄², then use (r₄)²=q4RadSq p and (√(1-t²))²=1-t².
  have hfactor :
      q4Rad p * p.t * (q4Rad p * p.t) +
      q4Rad p * Real.sqrt (1 - p.t ^ 2) * (q4Rad p * Real.sqrt (1 - p.t ^ 2)) =
      q4Rad p ^ 2 * p.t ^ 2 + q4Rad p ^ 2 * Real.sqrt (1 - p.t ^ 2) ^ 2 := by ring
  rw [hfactor, q4Rad_sq_eq hv, Real.sq_sqrt ht2_nn]
  ring

/-- Every `oil_fiber_map p hv` is Coherent and satisfies `observe = μ`. -/
lemma oil_fiber_map_mem (p : OilParams) (hv : OilValid p) :
    Coherent (oil_fiber_map p hv) ∧ observe (oil_fiber_map p hv) = μ :=
  ⟨by
    unfold Coherent
    simp only [ofm_q1, ofm_q2, ofm_q3, ofm_q4]
    rw [normSq_mu, normSq_q4_eq p hv, q4RadSq]
    simp only [Complex.normSq_apply, Complex.re, Complex.im]
    ring,
   rfl⟩

/-- **Five-dimensional oil fiber** — the oil fiber parametrization is injective.

    The map `OilParams → FourState` (restricted to valid inputs) is injective,
    so the oil fiber `{s | Coherent s ∧ observe s = μ}` contains an embedding
    of a 5-real-dimensional open set.  This makes precise the claim that the
    oil subspace is **5-dimensional**:

    | Parameter | Range       | Encodes                     |
    |-----------|-------------|-----------------------------|
    | `x₁`      | `(0, ∞)`    | Re(q1)                      |
    | `y₁`      | `(0, ∞)`    | Im(q1)                      |
    | `x₃`      | `(-∞, 0)`   | Re(q3)                      |
    | `y₃`      | `(-∞, 0)`   | Im(q3)                      |
    | `t`       | `(0, 1)`    | Re(q4)/r₄  (angle in Q4)    |

    **Proof sketch**: q1 equality gives `x₁`, `y₁`; q3 equality gives `x₃`,
    `y₃`; those four determine `r₄ = √(3−x₁²−y₁²−x₃²−y₃²) > 0`; and
    `Re(q4) = r₄·t` with `r₄ > 0` then recovers `t` by cancellation. -/
theorem oil_fiber_five_dimensional :
    Function.Injective
      (fun p : {p : OilParams // OilValid p} => oil_fiber_map p.1 p.2) := by
  intro ⟨p, hv_p⟩ ⟨q, hv_q⟩ heq
  apply Subtype.ext
  -- Extract the four FourState field equalities.
  have hq1_eq : (oil_fiber_map p hv_p).q1 = (oil_fiber_map q hv_q).q1 :=
    congr_arg FourState.q1 heq
  have hq3_eq : (oil_fiber_map p hv_p).q3 = (oil_fiber_map q hv_q).q3 :=
    congr_arg FourState.q3 heq
  have hq4_eq : (oil_fiber_map p hv_p).q4 = (oil_fiber_map q hv_q).q4 :=
    congr_arg FourState.q4 heq
  simp only [ofm_q1, ofm_q3, ofm_q4] at hq1_eq hq3_eq hq4_eq
  -- Recover the five parameters one by one.
  have hx₁ : p.x₁ = q.x₁ := congr_arg Complex.re hq1_eq
  have hy₁ : p.y₁ = q.y₁ := congr_arg Complex.im hq1_eq
  have hx₃ : p.x₃ = q.x₃ := congr_arg Complex.re hq3_eq
  have hy₃ : p.y₃ = q.y₃ := congr_arg Complex.im hq3_eq
  -- The Q4 radii are equal once (x₁, y₁, x₃, y₃) agree.
  have hrad : q4Rad p = q4Rad q := by
    unfold q4Rad q4RadSq; rw [hx₁, hy₁, hx₃, hy₃]
  -- Re(q4): r₄·p.t = r₄·q.t; cancel r₄ > 0.
  have hre4 : q4Rad p * p.t = q4Rad q * q.t := congr_arg Complex.re hq4_eq
  rw [hrad] at hre4
  have ht : p.t = q.t := mul_left_cancel₀ (q4Rad_pos hv_q).ne' hre4
  -- All five fields match → OilParams are equal.
  exact OilParams.ext hx₁ hy₁ hx₃ hy₃ ht

-- ════════════════════════════════════════════════════════════════════════════
-- §6  Hardness Conjecture
-- Recovering the full FourState from its observe value is conjectured to be
-- computationally hard, analogous to the MQ assumption in UOV cryptography.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Hardness conjecture** — hidden-sector recovery is computationally hard.

    Given only `observe s = v` for some `v : ℂ`, it is conjectured that
    no polynomial-time algorithm can reconstruct a full `FourState` `s`
    with `Coherent s` and `observe s = v`.

    **Formal statement note**: the statement below — that no total function
    `A : ℂ → FourState` recovers every FourState from its observation — is
    actually a *theorem* provable from `hidden_freedom`: since two distinct
    Coherent states share the same observation, any deterministic `A` must
    fail on at least one of them.  The formal statement is therefore not the
    hard part; it is included here to fix the interface for future work.

    **True cryptographic claim (unproven)**: no *polynomial-time* algorithm
    can, given `observe s`, reconstruct a Coherent `FourState` consistent
    with that observation.  This is the actual cryptographic assumption,
    analogous to the MQ (Multivariate Quadratic) hardness assumption
    underlying Unbalanced Oil-and-Vinegar (UOV).  A formal reduction from
    a standard hardness assumption is left for future work.

    **Status**: declared as an `axiom` to flag the computational hardness
    claim as unproven and requiring external justification.  Do not use
    in security proofs without replacing this with a proved reduction. -/
axiom hidden_recovery_hard :
    -- For all total adversaries A (no time bound), there exists a FourState s
    -- such that A fails to recover s from observe s.
    -- NOTE: this is provable from hidden_freedom; the true unproven claim is
    -- that no *polynomial-time* A succeeds.  See docstring above.
    ∀ (A : ℂ → FourState), ∃ s : FourState, A (observe s) ≠ s

-- ════════════════════════════════════════════════════════════════════════════
-- §7  Measurement Asymmetry
-- Formalizes the information gap between Alice (the state-preparer, who holds
-- OilParams as a private secret) and an adversary (who sees only the Q2
-- observation, a single ℂ value equal to μ for every valid preparation).
--
-- Alice's asymmetry comes from state preparation: she chose OilParams before
-- any adversary interaction.  The adversary's view is a constant function of
-- Alice's key, while Alice's preparation function is injective.
--
-- Definitions:
--   AliceKey           — valid OilParams (Alice's private secret)
--   AdversaryView      — type alias ℂ (the adversary's information)
--   alice_prepares     — Alice's injective state-preparation function
--   adversary_observes — the adversary's constant observation function
--
-- Theorems:
--   alice_key_determines_state  — alice_prepares is injective
--   adversary_view_constant     — adversary_observes is constant at μ
--   adversary_indistinguishable — adversary cannot distinguish any two keys
--   measurement_asymmetry       — combined statement of the information gap
--   adversary_cannot_recover    — no total function recovers Alice's full state
-- ════════════════════════════════════════════════════════════════════════════

/-- Alice's private key: a valid set of five real parameters determining the
    full hidden-sector state.

    Alice's asymmetric advantage comes from state preparation: she holds
    `params : OilParams` (encoding all four quadrant components) before any
    adversary interaction begins.  The adversary never obtains this value —
    they only see `observe s = μ`, which is identical for every key. -/
abbrev AliceKey : Type := {p : OilParams // OilValid p}

/-- The adversary's information type: only the visible Q2 observation.

    An adversary who interacts with Alice's scheme can extract at most
    `observe s : ℂ` — a single complex number equal to μ for every state
    Alice prepares.  This type alias makes the information restriction
    syntactically explicit. -/
abbrev AdversaryView : Type := ℂ

/-- Alice constructs a `Coherent` `FourState` from her private key. -/
def alice_prepares (k : AliceKey) : FourState := oil_fiber_map k.1 k.2

/-- The adversary's information extraction: they see only `observe s`. -/
def adversary_observes (k : AliceKey) : AdversaryView := observe (alice_prepares k)

/-- **Alice's key uniquely determines her state** — `alice_prepares` is injective.

    Alice holds a one-to-one map from her private key to the prepared state:
    distinct keys produce distinct states.  Knowing the state is equivalent
    to knowing the key.  This is the positive side of the asymmetry: Alice
    has complete information about her preparation.

    Proof: direct consequence of `oil_fiber_five_dimensional`. -/
theorem alice_key_determines_state : Function.Injective alice_prepares :=
  oil_fiber_five_dimensional

/-- **Adversary view is constant** — the adversary always sees μ, regardless
    of which key Alice holds.

    Alice's state-preparation map sends every valid `AliceKey` to a state in
    the oil fiber, and every oil-fiber element satisfies `observe s = μ`
    (proved by `oil_fiber_map_mem`).  The adversary's information function is
    therefore a constant — they cannot distinguish Alice's keys by observation. -/
theorem adversary_view_constant (k : AliceKey) : adversary_observes k = μ :=
  (oil_fiber_map_mem k.1 k.2).2

/-- Any two of Alice's keys are mutually indistinguishable from the adversary's
    perspective: they produce the same observation. -/
theorem adversary_indistinguishable (k₁ k₂ : AliceKey) :
    adversary_observes k₁ = adversary_observes k₂ := by
  rw [adversary_view_constant, adversary_view_constant]

/-- **Measurement asymmetry** — the formal statement of the information gap.

    Alice's map `AliceKey → FourState` is injective: she has complete
    information about her preparation.  The adversary's map `AliceKey → ℂ`
    is constant at μ: they have zero distinguishing information.

    These two properties together make the asymmetry structurally explicit:
    Alice and the adversary occupy incompatible epistemic positions — not by
    definition, but as provable consequences of the oil-fiber geometry. -/
theorem measurement_asymmetry :
    Function.Injective alice_prepares ∧
    ∀ k : AliceKey, adversary_observes k = μ :=
  ⟨alice_key_determines_state, adversary_view_constant⟩

/-- **Adversary cannot recover** — no total function from observations to states
    correctly identifies every state Alice might prepare.

    Proof: exhibit two distinct keys `k₁` (t = 1/2) and `k₂` (t = 3/4) with
    the same adversary view (μ by `adversary_view_constant`).  Any deterministic
    `A : AdversaryView → FourState` produces the same output for both; but the
    states differ (by `alice_key_determines_state`), so `A` fails on at least one.

    This theorem is provable (not an axiom) because it follows purely from the
    information-theoretic fiber structure.  The computational hardness claim in
    `hidden_recovery_hard` is the genuine unproven assumption. -/
theorem adversary_cannot_recover :
    ∀ (A : AdversaryView → FourState),
      ∃ k : AliceKey, A (adversary_observes k) ≠ alice_prepares k := by
  intro A
  -- Two explicit valid keys differing only in t (1/2 vs 3/4)
  have hv₁ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  have hv₂ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 3/4⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  let k₁ : AliceKey := ⟨⟨1/2, 1/2, -1/2, -1/2, 1/2⟩, hv₁⟩
  let k₂ : AliceKey := ⟨⟨1/2, 1/2, -1/2, -1/2, 3/4⟩, hv₂⟩
  -- The keys are distinct: their t fields differ (1/2 ≠ 3/4)
  have hne_keys : k₁ ≠ k₂ := by
    intro heq
    have hval := congr_arg Subtype.val heq
    have ht   := congr_arg OilParams.t hval
    norm_num at ht
  -- By injectivity of alice_prepares, the prepared states are distinct
  have hne_states : alice_prepares k₁ ≠ alice_prepares k₂ :=
    fun heq => hne_keys (alice_key_determines_state heq)
  -- Both keys share the same adversary view, so A gives the same output for both
  have hA_eq : A (adversary_observes k₁) = A (adversary_observes k₂) :=
    congrArg A (adversary_indistinguishable k₁ k₂)
  -- If A succeeds on k₁ it must fail on k₂; otherwise it already fails on k₁
  by_cases h₁ : A (adversary_observes k₁) = alice_prepares k₁
  · refine ⟨k₂, fun h₂ => hne_states ?_⟩
    calc alice_prepares k₁
        = A (adversary_observes k₁) := h₁.symm
      _ = A (adversary_observes k₂) := hA_eq
      _ = alice_prepares k₂         := h₂
  · exact ⟨k₁, h₁⟩

end -- noncomputable section
