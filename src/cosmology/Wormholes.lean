/-
  src/cosmology/Wormholes.lean — Consumer-layer module for wormhole geometry.

  Canonical repository: https://github.com/beanapologist/Eigenverse

  This module re-exports the Lean 4–verified wormhole geometry theorems from
  `formal-lean/Cosmology.lean` for downstream consumers organised by topic.

  Import this file to bring the complete set of Morris–Thorne wormhole
  results into scope.

  Key results available after import
  ────────────────────────────────────
  • `mt_temporal_pos`           — e^{2Φ} > 0: no temporal event horizon
  • `mt_zero_redshift_temporal` — e^{2·0} = 1: flat-time tidal-force-free model
  • `mt_temporal_ge_one`        — Φ ≥ 0 → e^{2Φ} ≥ 1: redshifting wormholes
  • `mt_throat_denom_zero`      — b(r₀)=r₀ → coordinate singularity at throat
  • `mt_radial_denom_pos`       — r>r₀ → radial denominator > 0 (no horizon)
  • `mt_grr_pos`                — g_rr > 0 away from throat (positive-definite)
  • `mt_radial_denom_flat_space`— b=0 gives flat Minkowski (correct limit)
  • `mt_constant_shape_hasDerivAt` — constant b has zero derivative (HasDerivAt)
  • `mt_constant_shape_deriv`   — constant b has zero Fréchet derivative
  • `mt_constant_flare_out`     — b'(r₀)=0<1: flare-out condition satisfied
  • `mt_asymptotic_flat`        — b(r)/r → 0: asymptotic flatness
  • `mt_grr_denom_approaches_one` — g_rr→1 at large r: flat space limit
  • `mt_shape_ratio_decreasing` — b/r is decreasing in r
  • `toy_angular_pos`           — b₀²+r²>0: non-degenerate angular metric
  • `toy_angular_lower_bound`   — b₀²+r²≥b₀²: throat sets minimum circumference
  • `toy_angular_symmetric`     — Z₂ symmetry of toy wormhole about the throat
  • `toy_angular_monotone`      — angular coeff increases away from throat
  • `schwarzschild_throat_condition`  — Schwarzschild b(2M)=2M throat condition
  • `schwarzschild_throat_denom_zero` — Schwarzschild horizon as wormhole throat
  • `einstein_rosen_throat_pos`       — M>0 → 2M>0: positive throat radius

  Background
  ──────────
  Wormholes are solutions to Einstein's field equations G_{μν} = 8π T_{μν}
  (units G = c = 1) that connect distant regions of spacetime.  The Morris–Thorne
  metric (1988) describes a static, spherically symmetric, traversable wormhole
  supported by exotic matter (negative energy density near the throat).

  The original Einstein–Rosen bridge (1935) arises from the maximally extended
  Schwarzschild solution and is non-traversable.  Traversable wormholes require
  exotic matter violating the null energy condition (NEC).

  The cosmic energy budget section (§7) formalises the Planck 2018 ΛCDM composition:
    • omega_de  = 683/1000 ≈ 68.3 %  (dark energy / cosmological constant Λ)
    • omega_dm  = 268/1000 ≈ 26.8 %  (cold dark matter)
    • omega_b   =  49/1000 ≈  4.9 %  (baryonic / ordinary matter)
  Key results: Ω_Λ + Ω_dm + Ω_b = 1 (flatness); Ω_Λ > 1/2 (dark energy majority);
  dark sector = 95.1 %; ordering Ω_b < Ω_dm < Ω_Λ.

  References:
  • Morris, M. S. & Thorne, K. S. (1988). Wormholes in spacetime and
    their use for interstellar travel. *Am. J. Phys.* **56**, 395–412.
  • Planck Collaboration (2020). Planck 2018 Results VI.
    *A&A* **641**, A6. (Table 2, ΛCDM best fit)
-/

import FormalLean.Cosmology
