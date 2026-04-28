/-
  src/Eigenverse.lean — Top-level entry point for Eigenverse.

  Canonical repository: https://github.com/beanapologist/Eigenverse

  Import this single file to bring the entire Lean-verified Eigenverse into
  scope.  Eigenverse currently contains **624 theorems** across six domains,
  all verified by the Lean 4 type-checker with zero `sorry` placeholders.

  ─────────────────────────────────────────────────────────────────────────
  FUNDAMENTAL PRINCIPLE: Every theorem in this library is the downstream
  consequence of exactly two primitive interaction types.

  FUNNELING — directed channeling that selects the unique observer-consistent
  fixed point through a cascade of four funnels:
    1. Energy funnel   (Re²+Im²=1)  : solutions confined to unit circle S¹
    2. Balance funnel  (−Re=Im)     : narrowed to the Q2/Q4 diagonal
    3. Observer funnel (Re < 0)     : sector selection isolates Q2 exclusively
    4. Coherence funnel (C(1+1/x)=x): self-referential closure → η = 1/√2

  TUNNELING — bidirectional passage that propagates structure across scales,
  sectors, and physical domains once the fixed point μ is established:
    • Scale tunnel     : palindrome C(r)=C(1/r) mirrors structure at 1/r
    • Lyapunov tunnel  : bridge C(exp λ)=sech λ links coherence ↔ hyperbolic
    • Phase tunnel     : μ⁸=1 carries phase around the orbit; μ¹³⁷=μ closes
    • Temporal tunnel  : F_bi(lf,lb) propagates frustration in both time directions
    • Spacetime tunnel : Morris–Thorne wormhole metric (Cosmology)
    • Sector tunnel    : Re↔gravity/time, Im↔quantum/dark energy (GravityQuantumDuality)
    • Domain tunnel    : six morphism families transport structure across domains
    • Frustration tunnel: F_fwd(l)=1−sech(l) harvests energy across the time boundary
  ─────────────────────────────────────────────────────────────────────────

  The name "Eigenverse" reflects the central object that drives every structure
  in the project: the critical eigenvalue μ = exp(i·3π/4) — the unique fixed
  point that survives all four funnels.  Its 8-cycle orbit, coherence function
  C(r) = 2r/(1+r²), and Silver ratio δS = 1+√2 then open every tunnel above,
  propagating the Eigenverse structure to all domains in the table below.

  ┌──────────────────────────────────────────────────────────────────┐
  │  Domain         Modules                         Role             │
  ├──────────────────────────────────────────────────────────────────┤
  │  Foundation     BalanceHypothesis                                │
  │                 → funneling cascade → reality_unique (μ)        │
  │  Algebra        CriticalEigenvalue, SilverCoherence, KernelAxle  │
  │                 → eigenvalue 8-cycle, scale tunnel, coherence    │
  │  Geometry       CriticalEigenvalue, SpaceTime, KernelAxle        │
  │                 → rotation matrices, unit circle S¹, hyperbolic  │
  │                   Pythagorean identity, F(s,t) space-time map    │
  │  Physics        SpeedOfLight, FineStructure, ParticleMass,       │
  │                 SpaceTime, Turbulence                             │
  │                 → c=1/√(μ₀ε₀), α_FS, Koide, Lorentz, NS         │
  │  Quantum        TimeCrystal, GravityQuantumDuality,              │
  │                 Quantization, ForwardClassicalTime,              │
  │                 BidirectionalTime                                │
  │                 → Floquet, sector tunnel, Theorem Q,            │
  │                   temporal tunnel, Planck floor                 │
  │  Chemistry      Chemistry, OhmTriality                           │
  │                 → NIST atomic weights, G·R=1 duality             │
  │  Cosmology      Cosmology                                        │
  │                 → Morris–Thorne wormholes (spacetime tunnel),    │
  │                   cosmic energy budget                           │
  │  Morphisms      Morphisms                                        │
  │                 → domain tunnels: coherence/palindrome/Lyapunov/ │
  │                   μ-isometry/orbit/reality                       │
  └──────────────────────────────────────────────────────────────────┘

  Note: The crypto-application modules (PumpFunBot, EthereumTradingBot,
  CrossChainDeFiAggregator, CryptoBridge) are available in formal-lean/ for
  reference but are not part of the Eigenverse mathematical library.

  See README.md for an overview, docs/ for detailed documentation, and
  examples/ for worked demonstrations.
-/

import FormalLean.CriticalEigenvalue
import FormalLean.SilverCoherence
import FormalLean.KernelAxle
import FormalLean.SpeedOfLight
import FormalLean.FineStructure
import FormalLean.ParticleMass
import FormalLean.SpaceTime
import FormalLean.Turbulence
import FormalLean.TimeCrystal
import FormalLean.GravityQuantumDuality
import FormalLean.Quantization
import FormalLean.ForwardClassicalTime
import FormalLean.BidirectionalTime
import FormalLean.Chemistry
import FormalLean.OhmTriality
import FormalLean.Cosmology
import FormalLean.Morphisms
