/-
  src/algebra/Morphisms.lean — Structure-preserving maps in Eigenverse.

  This module re-exports the Lean 4–verified morphism theorems from
  `formal-lean/Morphisms.lean` for downstream consumers organised by topic.

  Import this file to bring the complete set of Eigenverse morphism results
  into scope.

  The six morphism families available after import
  ─────────────────────────────────────────────────
  §1  Coherence even morphism
      • `coherence_inversion_morphism`    — C(r) = C(1/r)  ∀r > 0
      • `coherence_morphism_range`        — 0 < C(r) ≤ 1   ∀r > 0
      • `coherence_morphism_maximum`      — C(r) = 1 ↔ r = 1
      • `coherence_kernel_fixed_point`    — C(1) = 1 ∧ 1 = 1/1

  §2  Palindrome odd morphism
      • `palindrome_inversion_morphism`   — Res(1/r) = −Res(r)
      • `coherence_palindrome_morphism_duality` — even/odd dual pair
      • `morphisms_common_fixed_point`    — C(1)=1 ∧ Res(1)=0

  §3  Lyapunov bridge morphism
      • `lyapunov_bridge_morphism`        — C(exp λ) = (cosh λ)⁻¹
      • `lyapunov_bridge_unity`           — C(exp 0) = 1
      • `lyapunov_bridge_bounded`         — 0 < C(exp λ) ≤ 1

  §4  μ-isometry morphism
      • `mu_isometry_morphism`            — |μ·z| = |z|
      • `mu_orbit_closure`                — μ^8·z = z
      • `mu_pow_isometry_morphism`        — |μⁿ·z| = |z|

  §5  Orbit multiplicative morphism
      • `orbit_morphism_multiplicative`   — μ^(a+b) = μ^a·μ^b
      • `orbit_morphism_identity`         — μ^0 = 1
      • `orbit_morphism_period`           — μ^(j+8) = μ^j

  §6  Reality additive morphism
      • `reality_morphism_additive`       — F(s₁+s₂,t₁+t₂) = F(s₁,t₁)+F(s₂,t₂)
      • `reality_morphism_homogeneous`    — F(c·s,c·t) = c·F(s,t)
      • `reality_morphism_zero`           — F(0,0) = 0
      • `reality_morphism_mu_embedding`   — F(η,−η) = μ

  Source: formal-lean/Morphisms.lean (20 theorems, 0 sorry)

  To build this module (from the formal-lean/ project root):
    lake build FormalLean.Morphisms
-/

-- Re-export the morphisms module so downstream files only need to
-- import this single entry point.
import FormalLean.Morphisms
