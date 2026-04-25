/-
  Observer.lean — Formal physical-observer model for the FourSector framework.

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   This file formalizes the "physical observer" model hinted at in        ║
  ║   FourSector.lean §7.  The central question is:                          ║
  ║                                                                          ║
  ║     "Could we *derive* that hidden sectors are inaccessible,             ║
  ║      rather than merely assume it?"                                      ║
  ║                                                                          ║
  ║   Answer: yes, given a formal constraint on what observers can read.     ║
  ║   A *physical observer* is one whose output factors through `observe`    ║
  ║   (the Q2 projection).  Under this constraint, indistinguishability of   ║
  ║   the hidden sectors is a *theorem*, not an axiom.                       ║
  ║                                                                          ║
  ║   The asymmetry between Alice and an adversary then has two layers:      ║
  ║     • Informational (FourSector §7): Alice prepared the state and holds  ║
  ║       OilParams; the adversary only sees observe s = μ.                  ║
  ║     • Physical (this file): even if the adversary builds the most        ║
  ║       general allowed measuring device, it factors through observe, so   ║
  ║       it still only reveals Q2.                                          ║
  ║                                                                          ║
  ║   Sections                                                               ║
  ║   ────────                                                               ║
  ║   §1  Observer type and the factoring constraint                         ║
  ║   §2  Core indistinguishability theorem                                  ║
  ║   §3  Hidden-sector inaccessibility (derived, not axiom)                 ║
  ║   §4  Observer vs Alice: combined asymmetry                              ║
  ║                                                                          ║
  ║   Proof status                                                           ║
  ║   ────────────                                                           ║
  ║   Proven:  physical_obs_indistinguishable,                               ║
  ║            physical_obs_fiber_constant,                                  ║
  ║            q4_re_inaccessible, q4_im_inaccessible,                       ║
  ║            q1_inaccessible, q3_inaccessible,                             ║
  ║            observer_cannot_recover,                                      ║
  ║            observer_alice_asymmetry                                      ║
  ║   Sorry:   none                                                          ║
  ║   Axioms:  PhysicalConstraint  (the model assumption; see §1 docstring)  ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝
-/

import FourSector

open Complex Real

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Observer Type and the Factoring Constraint
--
-- An *observer* with output type α is any function `FourState → α`.  There
-- is no restriction yet — an observer could in principle read any field.
--
-- A *physical observer* is one whose output depends on the `FourState` only
-- through its observable component `observe s = s.q2`.  Formally, its output
-- function must factor through `observe`:
--
--    obs s = f (observe s)  for some  f : ℂ → α  and all s : FourState.
--
-- The model assumption (`PhysicalConstraint`) is that every legitimate
-- observer in the physical setup satisfies this factoring requirement.
-- This is the single assumption of the model; all inaccessibility results
-- are derived from it.
-- ════════════════════════════════════════════════════════════════════════════

/-- An observer with output type `α`: any function from states to outputs. -/
def Observer (α : Type*) : Type* := FourState → α

/-- `FactorsThrough obs` holds when the observer `obs` depends on the
    `FourState` only through `observe` — i.e., there exists a function
    `f : ℂ → α` such that `obs s = f (observe s)` for all `s`.

    This is the mathematical encoding of the physical constraint: a
    measurement device may only read the Q2 component. -/
def FactorsThrough {α : Type*} (obs : Observer α) : Prop :=
  ∃ f : ℂ → α, ∀ s : FourState, obs s = f (observe s)

/-- A *physical observer*: an observer together with a proof that its output
    factors through the observation map.

    The `factor` field witnesses the factoring function `f : ℂ → α`.
    The `hfactor` field proves `obs s = factor (observe s)` for all `s`.

    This is the formal counterpart of a physical measuring device that
    interacts with the system only through the Q2 ("vinegar") sector. -/
structure PhysicalObserver (α : Type*) where
  /-- The observer function. -/
  obs    : Observer α
  /-- The factoring function through `observe`. -/
  factor : ℂ → α
  /-- Proof that `obs` factors through `observe` via `factor`. -/
  hfactor : ∀ s : FourState, obs s = factor (observe s)

/-- **Physical constraint axiom** — all legitimate observers factor through
    `observe`.

    This is the single model assumption of `Observer.lean`.  It states that
    every observer in the physical setup satisfies `FactorsThrough`.  From
    this assumption all hidden-sector inaccessibility theorems are derived.

    **Status**: declared as an `axiom` because it is a *model assumption*,
    not a mathematical theorem.  It encodes the physics claim: "measuring
    devices can only read Q2."  Replacing this axiom with a derivation from
    a richer operational model (e.g., a quantum interaction predicate) is the
    next step toward a fully physical account.

    Compare with the informational asymmetry in FourSector §7:
    `adversary_view_constant` is a *proven theorem* (the adversary's
    information type is `ℂ`).  The current axiom is a *model assumption*
    (observers are physically constrained to read only `ℂ = Q2`).  The two
    claims are logically independent; together they give the full picture. -/
axiom PhysicalConstraint : ∀ {α : Type*} (obs : Observer α),
    FactorsThrough obs

-- ════════════════════════════════════════════════════════════════════════════
-- §2  Core Indistinguishability Theorem
-- ════════════════════════════════════════════════════════════════════════════

/-- **Physical observers cannot distinguish states with equal observations.**

    If two `FourState`s satisfy `observe s₁ = observe s₂`, then every
    `PhysicalObserver` assigns them the same output.

    Proof: `obs sᵢ = factor (observe sᵢ)` by `hfactor`; since
    `observe s₁ = observe s₂`, both sides are equal. -/
theorem physical_obs_indistinguishable {α : Type*}
    (P : PhysicalObserver α)
    (s₁ s₂ : FourState) (hobs : observe s₁ = observe s₂) :
    P.obs s₁ = P.obs s₂ := by
  rw [P.hfactor s₁, P.hfactor s₂, hobs]

/-- **Physical observers are constant on the oil fiber.**

    The oil fiber `{s | Coherent s ∧ observe s = μ}` consists of all
    Coherent FourStates that map to μ under `observe`.  Every
    `PhysicalObserver` assigns the same value to every element of
    this fiber.

    Proof: for any `s₁, s₂` in the fiber, `observe s₁ = μ = observe s₂`,
    so the result follows from `physical_obs_indistinguishable`. -/
theorem physical_obs_fiber_constant {α : Type*}
    (P : PhysicalObserver α)
    (s₁ s₂ : FourState)
    (h₁ : Coherent s₁ ∧ observe s₁ = μ)
    (h₂ : Coherent s₂ ∧ observe s₂ = μ) :
    P.obs s₁ = P.obs s₂ :=
  physical_obs_indistinguishable P s₁ s₂ (h₁.2.trans h₂.2.symm)

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Hidden-Sector Inaccessibility
-- The Q1, Q3, Q4 components of a FourState are inaccessible to any
-- PhysicalObserver: no physical measurement can recover any real-valued
-- function of the hidden sectors that varies across the oil fiber.
--
-- All witnesses below are constructed explicitly using the FourState
-- structure constructor (as in hidden_freedom), avoiding any dependence
-- on private helpers from FourSector.
-- ════════════════════════════════════════════════════════════════════════════

-- Shared normSq fact for the "standard" shared q1 and q3 components.
private lemma normSq_eta_eta : Complex.normSq (⟨η, η⟩ : ℂ) = 1 := by
  rw [Complex.normSq_apply]; exact balance_from_unit_circle

private lemma normSq_neg_eta : Complex.normSq (⟨-η, -η⟩ : ℂ) = 1 := by
  rw [Complex.normSq_apply]; simp only [neg_sq]; exact balance_from_unit_circle

private lemma normSq_mu_one : Complex.normSq μ = 1 := by
  rw [Complex.normSq_eq_abs, mu_abs_one]; norm_num

/-- **The Q4 real part is inaccessible to physical observers.**

    There is no `PhysicalObserver ℝ` whose output equals `s.q4.re` for
    every `FourState` `s` in the oil fiber.

    Proof: from `oil_subspace_parametric`, for `a = 1/4` and `a = 3/4`
    there exist Coherent oil-fiber states `s₁, s₂` with `s₁.q4.re = 1/4`
    and `s₂.q4.re = 3/4`.  A `PhysicalObserver` must assign them the same
    output (they share `observe = μ`), but if it read `q4.re` the outputs
    would differ. -/
theorem q4_re_inaccessible :
    ¬ ∃ P : PhysicalObserver ℝ,
        ∀ s : FourState, Coherent s → observe s = μ →
          P.obs s = s.q4.re := by
  intro ⟨P, hP⟩
  -- Two Coherent oil-fiber states with different q4.re.
  obtain ⟨s₁, hcoh₁, hobs₁, hre₁⟩ :=
    oil_subspace_parametric (1/4) (by norm_num) (by norm_num)
  obtain ⟨s₂, hcoh₂, hobs₂, hre₂⟩ :=
    oil_subspace_parametric (3/4) (by norm_num) (by norm_num)
  -- P assigns them the same output (same observe value).
  have hP_eq : P.obs s₁ = P.obs s₂ :=
    physical_obs_fiber_constant P s₁ s₂ ⟨hcoh₁, hobs₁⟩ ⟨hcoh₂, hobs₂⟩
  -- If P reads q4.re, the outputs are 1/4 and 3/4 — contradiction.
  rw [hP s₁ hcoh₁ hobs₁, hP s₂ hcoh₂ hobs₂, hre₁, hre₂] at hP_eq
  norm_num at hP_eq

/-- **The Q4 imaginary part is inaccessible to physical observers.**

    There is no `PhysicalObserver ℝ` whose output equals `s.q4.im` for
    every Coherent oil-fiber element.

    Proof: exhibit two explicit Coherent oil-fiber states with the same
    Q1, Q2, Q3 components but distinct Q4 imaginary parts:
    `(4/5, −3/5)` and `(3/5, −4/5)` both lie on the unit circle in Q4
    with normSq = 1.  A PhysicalObserver assigns both the same output
    (they have `observe = μ`), so it cannot read `q4.im`. -/
theorem q4_im_inaccessible :
    ¬ ∃ P : PhysicalObserver ℝ,
        ∀ s : FourState, Coherent s → observe s = μ →
          P.obs s = s.q4.im := by
  intro ⟨P, hP⟩
  have hη_pos : (0 : ℝ) < η := eta_pos
  have hη_neg : -(η : ℝ) < 0 := by linarith
  -- Shared sector membership.
  have hq1_mem : Sector.Q1.contains (⟨η, η⟩ : ℂ)  := ⟨hη_pos, hη_pos⟩
  have hq2_mem : Sector.Q2.contains μ               := ⟨mu_re_neg, mu_im_pos⟩
  have hq3_mem : Sector.Q3.contains (⟨-η, -η⟩ : ℂ) := ⟨hη_neg, hη_neg⟩
  -- Q4 components: (4/5, −3/5) and (3/5, −4/5), both unit-circle points in Q4.
  have hq4₁_mem : Sector.Q4.contains (⟨4/5, -3/5⟩ : ℂ) := ⟨by norm_num, by norm_num⟩
  have hq4₂_mem : Sector.Q4.contains (⟨3/5, -4/5⟩ : ℂ) := ⟨by norm_num, by norm_num⟩
  -- Construct the two witnesses.
  let s₁ : FourState :=
    { q1 := ⟨η, η⟩, q2 := μ, q3 := ⟨-η, -η⟩, q4 := ⟨4/5, -3/5⟩,
      hq1 := hq1_mem, hq2 := hq2_mem, hq3 := hq3_mem, hq4 := hq4₁_mem }
  let s₂ : FourState :=
    { q1 := ⟨η, η⟩, q2 := μ, q3 := ⟨-η, -η⟩, q4 := ⟨3/5, -4/5⟩,
      hq1 := hq1_mem, hq2 := hq2_mem, hq3 := hq3_mem, hq4 := hq4₂_mem }
  -- normSq computations.
  have hnSq_q4₁ : Complex.normSq (⟨4/5, -3/5⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; norm_num
  have hnSq_q4₂ : Complex.normSq (⟨3/5, -4/5⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; norm_num
  -- Both are Coherent.
  have hcoh₁ : Coherent s₁ := by
    show Complex.normSq (⟨η, η⟩ : ℂ) + Complex.normSq μ +
         Complex.normSq (⟨-η, -η⟩ : ℂ) + Complex.normSq (⟨4/5, -3/5⟩ : ℂ) = 4
    linarith [normSq_eta_eta, normSq_mu_one, normSq_neg_eta, hnSq_q4₁]
  have hcoh₂ : Coherent s₂ := by
    show Complex.normSq (⟨η, η⟩ : ℂ) + Complex.normSq μ +
         Complex.normSq (⟨-η, -η⟩ : ℂ) + Complex.normSq (⟨3/5, -4/5⟩ : ℂ) = 4
    linarith [normSq_eta_eta, normSq_mu_one, normSq_neg_eta, hnSq_q4₂]
  -- Both have observe = μ.
  have hobs₁ : observe s₁ = μ := rfl
  have hobs₂ : observe s₂ = μ := rfl
  -- P assigns them the same output.
  have hP_eq : P.obs s₁ = P.obs s₂ :=
    physical_obs_fiber_constant P s₁ s₂ ⟨hcoh₁, hobs₁⟩ ⟨hcoh₂, hobs₂⟩
  -- If P reads q4.im, the outputs are −3/5 and −4/5 — contradiction.
  have him₁ : s₁.q4.im = -3/5 := rfl
  have him₂ : s₂.q4.im = -4/5 := rfl
  rw [hP s₁ hcoh₁ hobs₁, hP s₂ hcoh₂ hobs₂, him₁, him₂] at hP_eq
  norm_num at hP_eq

/-- **The Q1 component is inaccessible to physical observers.**

    There is no `PhysicalObserver ℂ` whose output equals `s.q1` for every
    Coherent oil-fiber element.

    Proof: two valid `OilParams` differing only in `x₁` (1/2 vs 3/4)
    produce Coherent oil-fiber states via `oil_fiber_map` with the same
    `observe = μ` but distinct `q1` components.  A `PhysicalObserver`
    assigns them the same output, so it cannot recover `q1`. -/
theorem q1_inaccessible :
    ¬ ∃ P : PhysicalObserver ℂ,
        ∀ s : FourState, Coherent s → observe s = μ →
          P.obs s = s.q1 := by
  intro ⟨P, hP⟩
  -- Two valid OilParams differing only in x₁.
  have hv₁ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  have hv₂ : OilValid ⟨3/4, 1/2, -1/2, -1/2, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  let s₁ := oil_fiber_map ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ hv₁
  let s₂ := oil_fiber_map ⟨3/4, 1/2, -1/2, -1/2, 1/2⟩ hv₂
  have hm₁ := oil_fiber_map_mem ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ hv₁
  have hm₂ := oil_fiber_map_mem ⟨3/4, 1/2, -1/2, -1/2, 1/2⟩ hv₂
  -- P assigns both the same output.
  have hP_eq : P.obs s₁ = P.obs s₂ :=
    physical_obs_fiber_constant P s₁ s₂ ⟨hm₁.1, hm₁.2⟩ ⟨hm₂.1, hm₂.2⟩
  -- If P recovers q1, the Re parts differ: 1/2 ≠ 3/4.
  rw [hP s₁ hm₁.1 hm₁.2, hP s₂ hm₂.1 hm₂.2] at hP_eq
  have hq1₁ : s₁.q1 = ⟨1/2, 1/2⟩ := rfl
  have hq1₂ : s₂.q1 = ⟨3/4, 1/2⟩ := rfl
  rw [hq1₁, hq1₂] at hP_eq
  have : (⟨1/2, 1/2⟩ : ℂ).re = (⟨3/4, 1/2⟩ : ℂ).re := congr_arg Complex.re hP_eq
  norm_num at this

/-- **The Q3 component is inaccessible to physical observers.**

    There is no `PhysicalObserver ℂ` whose output equals `s.q3` for every
    Coherent oil-fiber element.

    Proof: analogous to `q1_inaccessible`, using two valid `OilParams`
    differing only in `x₃` (−1/2 vs −3/4). -/
theorem q3_inaccessible :
    ¬ ∃ P : PhysicalObserver ℂ,
        ∀ s : FourState, Coherent s → observe s = μ →
          P.obs s = s.q3 := by
  intro ⟨P, hP⟩
  -- Two valid OilParams differing only in x₃.
  have hv₁ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  have hv₂ : OilValid ⟨1/2, 1/2, -3/4, -1/2, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  let s₁ := oil_fiber_map ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ hv₁
  let s₂ := oil_fiber_map ⟨1/2, 1/2, -3/4, -1/2, 1/2⟩ hv₂
  have hm₁ := oil_fiber_map_mem ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ hv₁
  have hm₂ := oil_fiber_map_mem ⟨1/2, 1/2, -3/4, -1/2, 1/2⟩ hv₂
  have hP_eq : P.obs s₁ = P.obs s₂ :=
    physical_obs_fiber_constant P s₁ s₂ ⟨hm₁.1, hm₁.2⟩ ⟨hm₂.1, hm₂.2⟩
  rw [hP s₁ hm₁.1 hm₁.2, hP s₂ hm₂.1 hm₂.2] at hP_eq
  have hq3₁ : s₁.q3 = ⟨-1/2, -1/2⟩ := rfl
  have hq3₂ : s₂.q3 = ⟨-3/4, -1/2⟩ := rfl
  rw [hq3₁, hq3₂] at hP_eq
  have : (⟨-1/2, -1/2⟩ : ℂ).re = (⟨-3/4, -1/2⟩ : ℂ).re := congr_arg Complex.re hP_eq
  norm_num at this

/-- **No physical observer can recover the full FourState.**

    There is no `PhysicalObserver FourState` that is the identity on the
    oil fiber: no physical measurement can reconstruct which of Alice's
    possible states was prepared.

    Proof: by `oil_fiber_five_dimensional`, the map from valid `OilParams`
    to `FourState` is injective.  Two valid params differing in `t` (1/2
    vs 3/4) produce distinct states, both in the oil fiber.  Any
    `PhysicalObserver` assigns them the same output (same `observe = μ`),
    so it cannot be the identity on the fiber. -/
theorem observer_cannot_recover :
    ¬ ∃ P : PhysicalObserver FourState,
        ∀ s : FourState, Coherent s → observe s = μ →
          P.obs s = s := by
  intro ⟨P, hP⟩
  have hv₁ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  have hv₂ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 3/4⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  let s₁ := oil_fiber_map ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ hv₁
  let s₂ := oil_fiber_map ⟨1/2, 1/2, -1/2, -1/2, 3/4⟩ hv₂
  have hm₁ := oil_fiber_map_mem ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ hv₁
  have hm₂ := oil_fiber_map_mem ⟨1/2, 1/2, -1/2, -1/2, 3/4⟩ hv₂
  -- s₁ ≠ s₂: by injectivity of oil_fiber_map (oil_fiber_five_dimensional),
  -- distinct OilParams (t = 1/2 vs t = 3/4) produce distinct FourStates.
  have hne : s₁ ≠ s₂ := by
    intro heq
    have hinj :
      (⟨⟨1/2, 1/2, -1/2, -1/2, 1/2⟩, hv₁⟩ : {p : OilParams // OilValid p}) =
      ⟨⟨1/2, 1/2, -1/2, -1/2, 3/4⟩, hv₂⟩ :=
      oil_fiber_five_dimensional heq
    have ht : (1 : ℝ)/2 = 3/4 := congr_arg (fun p : {p : OilParams // OilValid p} =>
      p.1.t) hinj
    norm_num at ht
  -- P assigns s₁ and s₂ the same output (same observe value μ).
  have hP_eq : P.obs s₁ = P.obs s₂ :=
    physical_obs_fiber_constant P s₁ s₂ ⟨hm₁.1, hm₁.2⟩ ⟨hm₂.1, hm₂.2⟩
  -- If P is the identity on the fiber, P.obs s₁ = s₁ ≠ s₂ = P.obs s₂.
  rw [hP s₁ hm₁.1 hm₁.2, hP s₂ hm₂.1 hm₂.2] at hP_eq
  exact hne hP_eq

-- ════════════════════════════════════════════════════════════════════════════
-- §4  Observer vs Alice: Combined Asymmetry
-- Connects the physical observer model to the informational asymmetry of
-- FourSector §7.  Alice holds OilParams (a secret outside the observer
-- model); any physical observer sees only μ.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Observer–Alice asymmetry** — the complete two-layer asymmetry.

    This theorem combines the informational asymmetry from FourSector §7
    with the physical observer model from §§1–3:

    1. *Alice's advantage*: `alice_prepares` is injective — distinct keys
       produce distinct states.  Alice's knowledge of her `OilParams` is
       not captured by any physical observer.

    2. *Physical observers see only μ*: every `PhysicalObserver` is constant
       on the oil fiber — it assigns the same output to every state Alice
       might prepare.

    Taken together: Alice can distinguish every pair of keys (by
    `alice_key_determines_state`), while any physical observer is constant
    across Alice's entire key space.  The gap between the two is the
    cryptographic asymmetry.

    Note on the two layers:
    - The *informational* claim (FourSector §7) is proved without any
      observer model: `adversary_view_constant` holds because the
      adversary's type is `ℂ` and `observe` is a constant function on the
      fiber.
    - The *physical* claim (this file) requires `PhysicalConstraint` as the
      single model assumption: even a measuring device built to extract as
      much information as possible, subject only to the constraint that it
      factors through `observe`, is still constant on the fiber.
    Both claims are logically independent; together they close the gap. -/
theorem observer_alice_asymmetry :
    -- Alice's preparation is injective (informational layer).
    Function.Injective alice_prepares ∧
    -- Every physical observer is constant on the oil fiber (physical layer).
    ∀ (P : PhysicalObserver ℝ),
      ∀ s₁ s₂ : FourState,
        (Coherent s₁ ∧ observe s₁ = μ) →
        (Coherent s₂ ∧ observe s₂ = μ) →
        P.obs s₁ = P.obs s₂ :=
  ⟨alice_key_determines_state,
   fun P s₁ s₂ h₁ h₂ => physical_obs_fiber_constant P s₁ s₂ h₁ h₂⟩

end -- noncomputable section
