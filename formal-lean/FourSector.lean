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
  ║   §6  Hardness conjecture (axiom)                                        ║
  ║                                                                          ║
  ║   Proof status                                                           ║
  ║   ────────────                                                           ║
  ║   Proven:  visible_unique, hidden_freedom (by explicit witnesses)        ║
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

end -- noncomputable section
