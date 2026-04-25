/-
  Morphisms.lean — Structure-preserving maps in the Eigenverse framework.

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   Every domain in Eigenverse is held together by maps that preserve     ║
  ║   the underlying structure — coherence, symmetry, norm, linearity.      ║
  ║   This module collects these morphisms in one place, naming them as      ║
  ║   the structure-preserving maps they are.                                ║
  ║                                                                          ║
  ║   Six families of morphisms:                                             ║
  ║                                                                          ║
  ║   1.  COHERENCE EVEN MORPHISM                                            ║
  ║       C : ℝ>0 → (0, 1] is invariant under the inversion r ↦ 1/r.       ║
  ║       It descends to a well-defined map on the quotient ℝ>0 / {r~1/r}.  ║
  ║                                                                          ║
  ║   2.  PALINDROME ODD MORPHISM                                            ║
  ║       Res : ℝ>0 → ℝ is anti-invariant under r ↦ 1/r: Res(1/r) = −Res(r). ║
  ║       C and Res form a dual even/odd pair about the fixed point r = 1.  ║
  ║                                                                          ║
  ║   3.  LYAPUNOV BRIDGE MORPHISM                                           ║
  ║       exp : ℝ → ℝ>0 intertwines C and sech: C ∘ exp = sech.            ║
  ║       It maps the coherence world to the hyperbolic world exactly.       ║
  ║                                                                          ║
  ║   4.  μ-ISOMETRY MORPHISM                                                ║
  ║       Multiplication by μ is a norm-preserving map ℂ → ℂ.               ║
  ║       |μ · z| = |z| for all z; equivalently μ is a unitary operator.    ║
  ║                                                                          ║
  ║   5.  ORBIT MULTIPLICATIVE MORPHISM                                      ║
  ║       n ↦ μⁿ is a group homomorphism (ℕ, +) → (ℂˣ, ·).                ║
  ║       The 8-periodicity μⁿ⁺⁸ = μⁿ means it factors through ℤ/8ℤ.       ║
  ║                                                                          ║
  ║   6.  REALITY ADDITIVE MORPHISM                                          ║
  ║       F(s, t) = t + i·s is ℝ-bilinear: additive and homogeneous.        ║
  ║       It is a real-linear embedding ℝ² → ℂ — an ℝ-module morphism.      ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝

  The six morphisms are not independent: they are all expressions of the
  single underlying structure driven by μ = exp(I·3π/4).

    • C ∘ exp = sech  connects §1 (coherence) to §3 (Lyapunov bridge).
    • μ = exp(I·3π/4) connects §4 (μ-isometry) to §5 (orbit morphism).
    • F(η, −η) = μ    connects §6 (reality map) to §4 (μ-isometry).

  Together these six morphisms form the morphism skeleton of Eigenverse:
  they are the arrows between the mathematical objects that make the
  framework a coherent, self-referential whole.

  Sections
  ────────
  1.  Coherence even morphism  (inversion symmetry, bounded range, fixed point)
  2.  Palindrome odd morphism  (anti-symmetry under inversion, dual pair)
  3.  Lyapunov bridge morphism (C ∘ exp = sech; unitarity via sech)
  4.  μ-Isometry morphism      (|μ·z| = |z|; order-8 orbit closure)
  5.  Orbit multiplicative morphism  (n ↦ μⁿ, periodicity, fixed-point)
  6.  Reality additive morphism (additivity, homogeneity, origin, μ-embedding)

  Proof status
  ────────────
  All 20 theorems have complete machine-checked proofs.
  No `sorry` placeholders remain.
-/

import KernelAxle
import BalanceHypothesis

open Complex Real

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Coherence Even Morphism
-- C : ℝ>0 → (0, 1] is invariant under r ↦ 1/r.
-- It descends to a well-defined map on the quotient ℝ>0/{r ~ 1/r}.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Inversion invariance**: C(r) = C(1/r) for all r > 0.
    The coherence function is invariant under the inversion morphism r ↦ 1/r.
    Amplitude ratios r and 1/r represent the same physical balance. -/
theorem coherence_inversion_morphism (r : ℝ) (hr : 0 < r) : C r = C (1 / r) :=
  coherence_symm r hr

/-- **Bounded range**: C maps ℝ>0 strictly into the interval (0, 1].
    The coherence function is a morphism from scales ℝ>0 to the unit interval. -/
theorem coherence_morphism_range (r : ℝ) (hr : 0 < r) : 0 < C r ∧ C r ≤ 1 :=
  ⟨coherence_pos r hr, coherence_le_one r (le_of_lt hr)⟩

/-- **Unique maximum**: C(r) = 1 if and only if r = 1 (for r ≥ 0).
    The kernel fixed point r = 1 is the unique maximum of the coherence morphism. -/
theorem coherence_morphism_maximum (r : ℝ) (hr : 0 ≤ r) : C r = 1 ↔ r = 1 :=
  coherence_eq_one_iff r hr

/-- **Morphism pair composition**: the fixed point r = 1 is preserved by
    both the inversion r ↦ 1/r and the coherence maximum.
    C(1) = 1 and 1 = 1/1: the kernel is a fixed point of both structures. -/
theorem coherence_kernel_fixed_point : C 1 = 1 ∧ (1 : ℝ) = 1 / 1 :=
  ⟨(coherence_eq_one_iff 1 zero_le_one).mpr rfl, by norm_num⟩

-- ════════════════════════════════════════════════════════════════════════════
-- §2  Palindrome Odd Morphism
-- Res : ℝ>0 → ℝ is anti-invariant under r ↦ 1/r: Res(1/r) = −Res(r).
-- C and Res form a complementary even/odd pair about the fixed point r = 1.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Anti-invariance**: Res(1/r) = −Res(r) for all r > 0.
    The palindrome residual is an odd morphism under inversion:
    it changes sign while C is unchanged — they are dual partners. -/
theorem palindrome_inversion_morphism (r : ℝ) (hr : 0 < r) : Res (1 / r) = -Res r :=
  palindrome_residual_antisymm r hr

/-- **Dual morphism pair**: C is even and Res is odd under r ↦ 1/r.
    The two invariants of the coherence framework are in exact duality:
    one is preserved, the other is negated, by the same symmetry. -/
theorem coherence_palindrome_morphism_duality (r : ℝ) (hr : 0 < r) :
    C r = C (1 / r) ∧ Res (1 / r) = -Res r :=
  coherence_palindrome_duality r hr

/-- **Common fixed point**: both morphisms reduce to their neutral elements
    at r = 1: C(1) = 1 (maximum) and Res(1) = 0 (zero crossing).
    The kernel r = 1 is the simultaneous fixed point of the dual pair. -/
theorem morphisms_common_fixed_point : C 1 = 1 ∧ Res 1 = 0 :=
  ⟨(coherence_eq_one_iff 1 zero_le_one).mpr rfl,
   (palindrome_residual_zero_iff 1 one_pos).mpr rfl⟩

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Lyapunov Bridge Morphism
-- exp : ℝ → ℝ>0 intertwines C and sech: C(exp λ) = sech λ.
-- This is the bridge between the coherence world and hyperbolic geometry.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Lyapunov bridge**: C(exp λ) = (cosh λ)⁻¹ = sech λ for all λ ∈ ℝ.
    The exponential map sends the Lyapunov exponent λ to a scale exp(λ) at
    which coherence equals the hyperbolic secant.  This is the bridge between
    the coherence function and hyperbolic geometry. -/
theorem lyapunov_bridge_morphism (l : ℝ) : C (Real.exp l) = (Real.cosh l)⁻¹ :=
  lyapunov_coherence_sech l

/-- **Bridge unity**: the bridge morphism preserves the neutral element.
    At λ = 0: exp(0) = 1, and C(1) = sech(0) = 1 — all three agree. -/
theorem lyapunov_bridge_unity : C (Real.exp 0) = 1 := by
  rw [Real.exp_zero]
  exact (coherence_eq_one_iff 1 zero_le_one).mpr rfl

/-- **Bridge boundedness**: the bridge morphism maps into (0, 1].
    sech λ = (cosh λ)⁻¹ > 0 and ≤ 1, mirroring the coherence range. -/
theorem lyapunov_bridge_bounded (l : ℝ) : 0 < C (Real.exp l) ∧ C (Real.exp l) ≤ 1 :=
  ⟨coherence_pos (Real.exp l) (Real.exp_pos l),
   coherence_le_one (Real.exp l) (le_of_lt (Real.exp_pos l))⟩

-- ════════════════════════════════════════════════════════════════════════════
-- §4  μ-Isometry Morphism
-- Multiplication by μ is a norm-preserving map ℂ → ℂ.
-- |μ · z| = |z| for all z ∈ ℂ — μ is a unitary endomorphism.
-- ════════════════════════════════════════════════════════════════════════════

/-- **μ-isometry**: multiplication by μ preserves the complex norm.
    |μ · z| = |z| for all z ∈ ℂ.  μ is a unitary operator: it rotates
    without stretching or contracting. -/
theorem mu_isometry_morphism (z : ℂ) : Complex.abs (μ * z) = Complex.abs z := by
  rw [map_mul, mu_abs_one, one_mul]

/-- **Order-8 closure**: the μ-endomorphism has order 8 on ℂ.
    Applying μ-multiplication 8 times returns to the identity: μ^8 · z = z. -/
theorem mu_orbit_closure (z : ℂ) : μ ^ 8 * z = z := by
  rw [mu_pow_eight, one_mul]

/-- **n-th power isometry**: every power of μ is also norm-preserving.
    |μⁿ · z| = |z| for all n ∈ ℕ and z ∈ ℂ.  The entire μ-orbit consists
    of isometries. -/
theorem mu_pow_isometry_morphism (n : ℕ) (z : ℂ) :
    Complex.abs (μ ^ n * z) = Complex.abs z := by
  rw [map_mul, mu_pow_abs, one_mul]

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Orbit Multiplicative Morphism
-- n ↦ μⁿ is a monoid homomorphism (ℕ, +, 0) → (ℂˣ, ·, 1).
-- The 8-periodicity μⁿ⁺⁸ = μⁿ means it factors through ℤ/8ℤ.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Multiplicativity**: the orbit map is a monoid homomorphism.
    μ^(a + b) = μ^a · μ^b for all a, b ∈ ℕ.
    Exponentiation is the bridge between additive and multiplicative structure. -/
theorem orbit_morphism_multiplicative (a b : ℕ) : μ ^ (a + b) = μ ^ a * μ ^ b :=
  pow_add μ a b

/-- **Identity preservation**: the orbit map sends 0 to the multiplicative identity.
    μ^0 = 1 — the trivial orbit step is the identity morphism. -/
theorem orbit_morphism_identity : μ ^ 0 = 1 := pow_zero μ

/-- **8-Periodicity**: the orbit morphism factors through ℤ/8ℤ.
    μ^(j + 8) = μ^j for all j ∈ ℕ — the map is periodic with period 8,
    so it descends to a well-defined morphism on the cyclic group ℤ/8ℤ. -/
theorem orbit_morphism_period (j : ℕ) : μ ^ (j + 8) = μ ^ j :=
  mu_z8z_period j

-- ════════════════════════════════════════════════════════════════════════════
-- §6  Reality Additive Morphism
-- F(s, t) = t + i·s is a real-linear map ℝ² → ℂ — an ℝ-module morphism.
-- It embeds spacetime coordinates into the complex plane.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Additivity**: the reality map is additive in both arguments.
    F(s₁+s₂, t₁+t₂) = F(s₁,t₁) + F(s₂,t₂) — it is a group homomorphism
    from (ℝ², +) to (ℂ, +). -/
theorem reality_morphism_additive (s₁ s₂ t₁ t₂ : ℝ) :
    reality (s₁ + s₂) (t₁ + t₂) = reality s₁ t₁ + reality s₂ t₂ := by
  unfold reality
  push_cast
  ring

/-- **Homogeneity**: the reality map is homogeneous over ℝ.
    F(c·s, c·t) = c·F(s,t) for all c ∈ ℝ — it scales linearly with the
    scalar c.  Together with additivity, this makes F an ℝ-module morphism. -/
theorem reality_morphism_homogeneous (c s t : ℝ) :
    reality (c * s) (c * t) = ↑c * reality s t := by
  unfold reality
  push_cast
  ring

/-- **Origin**: the reality morphism maps the origin to the origin.
    F(0, 0) = 0 — the zero element of ℝ² maps to the zero element of ℂ. -/
theorem reality_morphism_zero : reality 0 0 = 0 := by
  unfold reality
  simp

/-- **μ-embedding**: the critical eigenvalue is the image of the balance point.
    F(η, −η) = μ — the observer's natural spacetime balance (η space, −η time)
    maps precisely to the critical eigenvalue.  The reality map embeds the
    balance primitive μ as the image of the fundamental observer coordinates. -/
theorem reality_morphism_mu_embedding :
    reality η (-η) = μ := by
  -- SpaceTime defines F s t := reality s t, so F and reality are definitionally equal
  exact mu_is_observable_equilibrium

end
