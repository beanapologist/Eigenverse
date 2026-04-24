/-
  src/thermodynamics/EntropyModule.lean — Entropy formalisations.

  This module organises all entropy-theoretic theorems verified in Eigenverse:

    • Kernel entropy     S(r) = −log(C(r))  — coherence-based entropy
    • Lyapunov entropy   H(l) = log(cosh l)  — Lyapunov-exponent entropy
    • Entropy-coherence duality  S(r)=0 ↔ C(r)=1
    • Frustration-entropy identity  F_fwd(l) = 1 − exp(−H(l))
    • Special values: S(δS) = H(log δS) = log(2)/2

  Sources (all proofs in formal-lean/, 0 sorry each)
  ────────────────────────────────────────────────────
  formal-lean/Entropy.lean              (20 theorems)

  Usage
  ─────
      import Eigenverse.Thermodynamics.EntropyModule
-/

import FormalLean.Entropy
