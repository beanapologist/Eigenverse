/-
  examples/BasicProofs.lean — Introductory examples from Eigenverse.

  This file demonstrates how to use the verified theorems from Eigenverse
  in downstream proofs.  The examples are designed to be run with:

      cd formal-lean/
      lake build
      lake exe formalLean

  ── Example 1: 8-cycle closure ──────────────────────────────────────────────
  The critical eigenvalue μ = exp(I · 3π/4) satisfies μ^8 = 1.
  Proof: CriticalEigenvalue.mu_pow_eight

  ── Example 2: Coherence upper bound ────────────────────────────────────────
  For all r > 0, C(r) = 2r/(1+r²) ≤ 1 with equality iff r = 1.
  Proof: CriticalEigenvalue.coherence_le_one

  ── Example 3: Speed of light identity ──────────────────────────────────────
  c² · μ₀ · ε₀ = 1, i.e. c = 1/√(μ₀ε₀).
  Proof: SpeedOfLight.c_sq_mu0_eps0

  ── Example 4: Floquet period-doubling ──────────────────────────────────────
  A Floquet state with phase φ = π satisfies ψ(t + 2T) = ψ(t).
  Proof: TimeCrystal.time_crystal_period_doubling

  ── Example 5: Silver ratio uniqueness ──────────────────────────────────────
  δS = 1 + √2 is the unique positive root of x² - 2x - 1 = 0.
  Proof: SilverCoherence.silver_ratio_unique

  ── Example 6: μ-isometry morphism ──────────────────────────────────────────
  Multiplication by μ is norm-preserving: |μ · z| = |z| for all z ∈ ℂ.
  Proof: Morphisms.mu_isometry_morphism

  ── Example 7: Lyapunov bridge morphism ─────────────────────────────────────
  The exponential intertwines coherence and sech: C(exp λ) = (cosh λ)⁻¹.
  Proof: Morphisms.lyapunov_bridge_morphism

  ── Example 8: Reality map as ℝ-linear morphism ─────────────────────────────
  F(η, −η) = μ: the balance point in spacetime maps exactly to the critical
  eigenvalue under the reality morphism.
  Proof: Morphisms.reality_morphism_mu_embedding

  See formal-lean/*.lean for full proof terms.
-/

-- Import the top-level entry point.
-- (Uncomment after running `lake build` from formal-lean/)
-- import FormalLean.CriticalEigenvalue
-- import FormalLean.TimeCrystal
-- import FormalLean.SpeedOfLight
-- import FormalLean.SilverCoherence
-- import FormalLean.Morphisms

/-
  Example usage in a downstream theorem:

  theorem my_result : ∀ r : ℝ, 0 < r → coherence r ≤ 1 :=
    CriticalEigenvalue.coherence_le_one

  theorem energy_cycle (n : ℕ) : μ ^ (n + 8) = μ ^ n :=
    CriticalEigenvalue.mu_z8z_period n

  theorem mu_is_isometry (z : ℂ) : Complex.abs (μ * z) = Complex.abs z :=
    Morphisms.mu_isometry_morphism z

  theorem coherence_symmetric (r : ℝ) (hr : 0 < r) : C r = C (1 / r) :=
    Morphisms.coherence_inversion_morphism r hr

  theorem lyapunov_bridge (λ : ℝ) : C (Real.exp λ) = (Real.cosh λ)⁻¹ :=
    Morphisms.lyapunov_bridge_morphism λ
-/

#check @id  -- placeholder to keep the file valid before build
