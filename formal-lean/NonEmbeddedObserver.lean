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

/-- A trajectory is temporally coherent when every time-slice is coherent. -/
def temporallyCoherent {World : Type u} (O : NonEmbeddedObserver World) (trajectory : ℝ → World) : Prop :=
  ∀ t : ℝ, observerCoherent O (trajectory t)

/-- Optional exploratory notion: "breaking time" means distinct times map to the
same world state. -/
def breaksTime {World : Type u} (trajectory : ℝ → World) : Prop :=
  ∃ t₁ t₂ : ℝ, t₁ < t₂ ∧ trajectory t₁ = trajectory t₂

/-- Alias for `breaksTime` emphasizing the state-repetition interpretation. -/
def hasRepeatingStates {World : Type u} (trajectory : ℝ → World) : Prop :=
  breaksTime trajectory

theorem constantTrajectory_breaksTime {World : Type u} (w : World) :
    breaksTime (fun _ : ℝ => w) := by
  refine ⟨0, 1, by norm_num, rfl⟩

theorem constantTrajectory_temporallyCoherent
    {World : Type u} (O : NonEmbeddedObserver World) (w : World)
    (hw : observerCoherent O w) :
    temporallyCoherent O (fun _ : ℝ => w) := by
  intro t
  simpa using hw

/-- Focused checks for the positive-real / negative-imaginary coherence gate. -/
example : coherentPRNI (point 1 (-1)) := by
  norm_num [point_coherent_iff]

example : coherenceFromParts 1 (-1) = true := by
  simp [coherenceFromParts_true_iff]

example : coherenceFromParts (-1) 1 = false := by
  simp [coherenceFromParts, coherenceTest, point, coherentPRNI]
