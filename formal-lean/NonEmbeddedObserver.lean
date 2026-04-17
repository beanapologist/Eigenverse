/-
  NonEmbeddedObserver.lean — Lean 4 formalization of a non-embedded observer
  together with a coherence test in the positive-real / negative-imaginary
  sector of the complex plane.

  This module provides:
    1. An abstract non-embedded observer model (world-internal evaluation)
    2. A coherence predicate: Re(z) > 0 and Im(z) < 0
    3. A Bool-valued test with specification theorems
    4. A small optional temporal-coherence layer ("break time")
-/

import Mathlib.Data.Complex.Basic

open Complex

noncomputable section

universe u v

/-- A non-embedded observer over a world `World`.

The observer only evaluates entities of its own world. -/
structure NonEmbeddedObserver (World : Type u) where
  evaluate : World → ℂ

/-- Coherence in the target sector: positive real part, negative imaginary part.
`PRNI` abbreviates **Positive Real / Negative Imaginary**. -/
def coherentPRNI (z : ℂ) : Prop := 0 < z.re ∧ z.im < 0

/-- Observer coherence for a specific world entity. -/
def observerCoherent {World : Type u} (O : NonEmbeddedObserver World) (w : World) : Prop :=
  coherentPRNI (O.evaluate w)

/-- A canonical constructor from real and imaginary coordinates. -/
def point (r i : ℝ) : ℂ := (r : ℂ) + Complex.I * (i : ℂ)

/-- Bool-valued coherence test for complex inputs. -/
noncomputable def coherenceTest (z : ℂ) : Bool := decide (coherentPRNI z)

/-- Bool-valued coherence test from real/imaginary coordinates. -/
noncomputable def coherenceFromParts (r i : ℝ) : Bool :=
  coherenceTest (point r i)

theorem coherenceTest_true_iff (z : ℂ) :
    coherenceTest z = true ↔ coherentPRNI z := by
  simp [coherenceTest, coherentPRNI]

theorem coherenceTest_false_iff (z : ℂ) :
    coherenceTest z = false ↔ ¬ coherentPRNI z := by
  simp [coherenceTest, coherentPRNI]

theorem point_re (r i : ℝ) : (point r i).re = r := by
  simp [point]

theorem point_im (r i : ℝ) : (point r i).im = i := by
  simp [point]

theorem point_coherent_iff (r i : ℝ) :
    coherentPRNI (point r i) ↔ 0 < r ∧ i < 0 := by
  simp [coherentPRNI, point]

theorem coherenceFromParts_true_iff (r i : ℝ) :
    coherenceFromParts r i = true ↔ 0 < r ∧ i < 0 := by
  simp [coherenceFromParts, coherenceTest, point, coherentPRNI]

/-- The observer evaluation is independent of external representation:
if two external values `e₁ e₂ : Env` embed to the same world entity, the
observer coherence judgment is identical. -/
theorem observer_independent_of_external
    {World : Type u} (O : NonEmbeddedObserver World)
    {Env : Type v} (embed : Env → World) (e₁ e₂ : Env)
    (h : embed e₁ = embed e₂) :
    observerCoherent O (embed e₁) ↔ observerCoherent O (embed e₂) := by
  simpa [observerCoherent, h]

/-- A trajectory is temporally coherent when every time-slice is coherent.
`Time` is intentionally polymorphic: this notion only needs an index set, not
an order or metric. This checks pointwise coherence only; see
`breaksTimeOrdered` for an order-sensitive repetition witness. -/
def temporallyCoherent {Time : Type v} {World : Type u}
    (O : NonEmbeddedObserver World) (trajectory : Time → World) : Prop :=
  ∀ t : Time, observerCoherent O (trajectory t)

/-- Optional exploratory notion: "breaking time" means distinct times map to the
same world state.

This is the symmetry-based (order-free) variant: it captures repeated states
at two different labels even when no temporal order is assumed. -/
def breaksTime {Time : Type v} {World : Type u} (trajectory : Time → World) : Prop :=
  ∃ t₁ t₂ : Time, t₁ ≠ t₂ ∧ trajectory t₁ = trajectory t₂

/-- Ordered variant of temporal break when `Time` is ordered: the witness
exhibits `t₁ < t₂` with equal trajectory values. -/
def breaksTimeOrdered {Time : Type v} [Preorder Time] {World : Type u}
    (trajectory : Time → World) : Prop :=
  ∃ t₁ t₂ : Time, t₁ < t₂ ∧ trajectory t₁ = trajectory t₂

/-- Any ordered temporal break implies the symmetric `breaksTime` witness. -/
theorem breaksTimeOrdered_implies_breaksTime
    {Time : Type v} [Preorder Time] {World : Type u} (trajectory : Time → World) :
    breaksTimeOrdered trajectory → breaksTime trajectory := by
  intro h
  rcases h with ⟨t₁, t₂, hlt, heq⟩
  exact ⟨t₁, t₂, ne_of_lt hlt, heq⟩

/-- Alias for `breaksTime` emphasizing the state-repetition interpretation. -/
def hasRepeatingStates {Time : Type v} {World : Type u} (trajectory : Time → World) : Prop :=
  breaksTime trajectory

theorem constantTrajectory_breaksTime {Time : Type v} {World : Type u}
    [Nontrivial Time] (w : World) :
    breaksTime (fun _ : Time => w) := by
  rcases exists_pair_ne Time with ⟨t₁, t₂, hne⟩
  exact ⟨t₁, t₂, hne, rfl⟩

theorem constantTrajectory_temporallyCoherent
    {Time : Type v} {World : Type u}
    (O : NonEmbeddedObserver World) (w : World)
    (hw : observerCoherent O w) :
    temporallyCoherent O (fun _ : Time => w) := by
  intro t
  simpa using hw

/-- An abstract Grover trajectory over a state space:
iterated application of `G` exactly `n` times from initial state `s₀`. -/
def GroverTrajectory {State : Type u} (G : State → State) (s₀ : State) : ℕ → State :=
  fun n => Function.iterate G n s₀

/-- If two distinct Grover iteration counts produce the same state, the
trajectory satisfies `breaksTime`. -/
theorem grover_breaks_time {State : Type u} (G : State → State) (s₀ : State)
    (h_repeat : ∃ t₁ t₂ : ℕ, t₁ ≠ t₂ ∧
      Function.iterate G t₁ s₀ = Function.iterate G t₂ s₀) :
    breaksTime (GroverTrajectory G s₀) := by
  simpa [GroverTrajectory] using h_repeat

/-- Under a break witness and an observer-guided predecessor choice principle,
the observer can define an inverse-step selector that lands in coherent states.

Outside the coherent domain, the selector is intentionally the identity map:
the theorem's specification only constrains coherent inputs. The break witness
is kept as an explicit precondition indicating the branch-selection regime where
this inversion principle is intended to apply. -/
theorem non_embedded_observer_inverts_grover
    {State : Type u}
    (obs : NonEmbeddedObserver State)
    (G : State → State)
    (s₀ : State)
    (h_break : breaksTime (GroverTrajectory G s₀))
    (h_choose :
      breaksTime (GroverTrajectory G s₀) →
      ∀ s : State, observerCoherent obs s →
        ∃ s_prev : State, G s_prev = s ∧ observerCoherent obs s_prev) :
    ∃ Ginv : State → State,
      ∀ s : State, observerCoherent obs s →
        G (Ginv s) = s ∧ observerCoherent obs (Ginv s) := by
  classical
  let Ginv : State → State := fun s =>
    -- Outside the coherent domain we return the identity mapping (`s ↦ s`).
    -- This keeps the function total without introducing arbitrary default data.
    if hs : observerCoherent obs s then Classical.choose (h_choose h_break s hs)
    else s  -- identity fallback outside the coherent domain
  refine ⟨Ginv, ?_⟩
  intro s hs
  have hdef : Ginv s = Classical.choose (h_choose h_break s hs) := by
    simp [Ginv, hs]
  have hspec := Classical.choose_spec (h_choose h_break s hs)
  constructor
  · simpa [hdef] using hspec.1
  · simpa [hdef] using hspec.2

/-- Focused checks for the positive-real / negative-imaginary coherence gate. -/
example : coherentPRNI (point 1 (-1)) := by
  norm_num [point_coherent_iff]

example : coherenceFromParts 1 (-1) = true := by
  simp [coherenceFromParts_true_iff]

example : coherenceFromParts (-1) 1 = false := by
  simp [coherenceFromParts, coherenceTest, point, coherentPRNI]
