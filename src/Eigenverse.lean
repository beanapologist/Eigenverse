/-
  src/Eigenverse.lean — Top-level entry point for Eigenverse.

  Canonical repository: https://github.com/beanapologist/Eigenverse

  Import this single file to bring the entire Lean-verified Eigenverse into
  scope.  Eigenverse currently contains **624 theorems** across six domains,
  all verified by the Lean 4 type-checker with zero `sorry` placeholders.

  ─────────────────────────────────────────────────────────────────────────
  FUNDAMENTAL PRINCIPLE: Every theorem in this library is the downstream
  consequence of two primitive interaction types defined by their sectors
  in the complex plane.

  FUNNELING — always the NEGATIVE REAL sector (Re < 0):
    gravity, classical time, dissipation, damping.
    The critical eigenvalue μ = exp(i·3π/4) = −1/√2 + i·1/√2.
    Re(μ) = −1/√2 is the funneling component of the critical eigenvalue.
    Modules: SpaceTime (time on real axis), GravityQuantumDuality (Re↔gravity),
             ForwardClassicalTime (F_fwd dissipates into Re), Turbulence (NS
             dissipation), Cosmology §1–6 (wormhole radial/throat geometry).

  TUNNELING — always the POSITIVE IMAGINARY sector (Im > 0):
    quantum mechanics, dark energy, oscillation, coherent passage.
    Im(μ) = +1/√2 is the tunneling component of the critical eigenvalue.
    Modules: TimeCrystal (Floquet Im-phase), BidirectionalTime (passage
             across time), Quantization (Theorem Q), NumericalAlignments
             (μ¹³⁷=μ Im-phase), Cosmology §7 (traversable wormhole),
             Morphisms (six families propagate Im-sector structure).

  BALANCE — where funneling meets tunneling:
    The directed balance axiom −Re(μ) = Im(μ) asserts that funneling
    and tunneling amplitudes are exactly equal at the fixed point
    μ = −η + i·η (η = 1/√2).  All balance/coherence theorems live here.
    Modules: BalanceHypothesis (reality_unique), CriticalEigenvalue
             (palindrome C(r)=C(1/r)), SilverCoherence, KernelAxle,
             OhmTriality, GravityQuantumDuality (duality gap).
  ─────────────────────────────────────────────────────────────────────────

  The name "Eigenverse" reflects the central object: the critical eigenvalue
  μ = exp(i·3π/4) — the unique unit-circle point where funneling (Re < 0)
  and tunneling (Im > 0) are in exact balance.

  ┌──────────────────────────────────────────────────────────────────┐
  │  Domain         Modules                         Sector           │
  ├──────────────────────────────────────────────────────────────────┤
  │  Foundation     BalanceHypothesis                                │
  │                 → balance: funneling = tunneling → reality_unique │
  │  Algebra        CriticalEigenvalue, SilverCoherence, KernelAxle  │
  │                 → balance: palindrome bridges Re ↔ Im sectors    │
  │  Geometry       SpaceTime, KernelAxle                            │
  │                 → funneling: time on real axis; rotation R(3π/4) │
  │  Physics        SpeedOfLight, FineStructure, ParticleMass,       │
  │                 Turbulence                                        │
  │                 → funneling/balance: c, α_FS, Koide, NS bounds   │
  │  Quantum        TimeCrystal, GravityQuantumDuality,              │
  │                 Quantization, ForwardClassicalTime,              │
  │                 BidirectionalTime                                │
  │                 → tunneling: Floquet, dark energy, Theorem Q,   │
  │                   time passage, Planck floor                    │
  │                 → funneling: F_fwd, gravity                     │
  │  Chemistry      Chemistry, OhmTriality                           │
  │                 → balance: NIST weights, G·R=1 duality           │
  │  Cosmology      Cosmology                                        │
  │                 → funneling §1–6: wormhole radial geometry       │
  │                 → tunneling §7: traversable passage + budget     │
  │  Morphisms      Morphisms                                        │
  │                 → tunneling: six families propagate Im-sector    │
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
