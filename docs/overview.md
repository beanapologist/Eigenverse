# Eigenverse — Overview

## What is Eigenverse?

**Canonical repository: [github.com/beanapologist/Eigenverse](https://github.com/beanapologist/Eigenverse)**

**Eigenverse** is a fully formal, machine-checked library of theorems built
around a single central object: the critical eigenvalue
**μ = exp(i·3π/4)** — a point on the complex unit circle whose 8-cycle orbit,
coherence function C(r) = 2r/(1+r²), and Silver ratio δS = 1+√2 generate a
complete, self-consistent structure that is the **unique** recipe for any
conceivable reality with an observer.

Every statement is verified by the [Lean 4](https://leanprover.github.io/)
type-checker; there are **zero `sorry` placeholders** anywhere in the codebase.

This means that if Lean accepts a proof, the theorem is *logically guaranteed*
to follow from the stated axioms — no hand-waving, no gaps.

---

## Scope

| Module | Key Results | Theorems |
|--------|-------------|----------|
| **BalanceHypothesis** | `reality_unique`: μ is the ONLY Q2 unit-circle balance point | 37 |
| **CriticalEigenvalue** | μ⁸=1, δS=1+√2, C(r)≤1, palindrome C(r)=C(1/r), Z/8Z memory | 82 |
| **SpaceTime** | Rotation matrix R(3π/4) det=1/orthogonal/order-8; F(s,t)=t+i·s | 43 |
| **FineStructure** | Fine structure constant α_FS = 1/137 | 30 |
| **SpeedOfLight** | c = 1/√(μ₀ε₀); structural isomorphism with η | 19 |
| **Turbulence** | Navier-Stokes turbulence bounds | 29 |
| **ParticleMass** | Koide C(φ²)=2/3; proton/electron mass ratio R=1836 | 38 |
| **GravityQuantumDuality** | Re↔Gravity/Time; Im↔Quantum/Dark Energy | 22 |
| **TimeCrystal** | Discrete time crystal / Floquet theory | 33 |
| **Quantization** | Theorem Q: H·T=5π/4 → all Q1–Q5 simultaneously | 20 |
| **BidirectionalTime** | Bidirectional time & Planck floor | 24 |
| **KernelAxle** | Canonical amplitude η; gear ratio; cross-section | 20 |
| **SilverCoherence** | C(δS)=√2/2; uniqueness; physics at 45° | 29 |
| **OhmTriality** | Ohm–Coherence duality G·R=1 at triality scales | 24 |
| **ForwardClassicalTime** | Forward-time frustration harvesting | 21 |
| **Chemistry** | NIST atomic weights, isotopic abundances, mass conservation | 20 |
| **NumericalAlignments** | Dimensionless derivations §0–§13; V_Z quantization; α from closure; universal observer uniqueness; μ¹³⁷=μ | 61 |
| **Cosmology** | Morris–Thorne wormhole metric; §1–6 wormhole geometry; §7 cosmic energy budget (Planck 2018: Ω_Λ=68.3%, Ω_dm=26.8%, Ω_b=4.9%) | 34 |
| **Total** | | **586** |

Additionally, `formal-lean/NonEmbeddedObserver.lean` provides a compact
observer abstraction and a formally specified coherence gate for
**positive real / negative imaginary** complex states, with an optional
temporal-coherence (`breaksTime`) exploration.

---

## Repository Layout

```
formal-lean/                    # Lean 4 source files (the proof engine)
├── BalanceHypothesis.lean      # ★ FOUNDATION: reality_unique (37)
├── CriticalEigenvalue.lean     # Algebraic core: μ, δS, C(r), palindrome (82)
├── SpaceTime.lean              # Geometry: F(s,t), rotation matrix (43)
├── FineStructure.lean          # α_FS = 1/137 (30)
├── SpeedOfLight.lean           # c = 1/√(μ₀ε₀) (19)
├── Turbulence.lean             # Navier-Stokes bounds (29)
├── ParticleMass.lean           # Koide formula, mass ratios (38)
├── GravityQuantumDuality.lean  # Re↔Gravity, Im↔Quantum (22)
├── TimeCrystal.lean            # Floquet time crystals (33)
├── Quantization.lean           # Theorem Q (20)
├── BidirectionalTime.lean      # Bidirectional time (24)
├── KernelAxle.lean             # Kernel amplitude η (20)
├── SilverCoherence.lean        # C(δS)=√2/2 (29)
├── OhmTriality.lean            # Ohm G·R=1 (24)
├── ForwardClassicalTime.lean   # Forward frustration (21)
├── Chemistry.lean              # NIST atomic weights (20)
├── NumericalAlignments.lean    # Dimensionless derivations §0–§13 (61)
├── Cosmology.lean              # Morris–Thorne wormholes + cosmic energy budget (34)
└── Main.lean                   # Executable entry-point

src/                            # Lean modules organised by topic
├── algebra/Eigenvalue.lean
├── geometry/GeometricStructures.lean
├── physics/FundamentalConstants.lean
├── quantum/QuantumUniverse.lean
├── chemistry/AtomicUniverse.lean
├── cosmology/Wormholes.lean    # Wormhole geometry
└── Eigenverse.lean             # Single-import entry point

docs/                           # Documentation
examples/                       # Worked demonstrations
tests/                          # Cross-module consistency checks
```

---

## Design Principles

1. **Zero sorry** — every proof compiles without axiom bypasses.
2. **Mathlib grounded** — all arithmetic, linear algebra, and analysis
   reasoning is delegated to [Mathlib4](https://github.com/leanprover-community/mathlib4).
3. **Modular** — each domain is an independent `formal-lean/*.lean` file;
   `src/` organises them by topic for downstream consumers.
4. **NIST-anchored** — numerical constants (atomic weights, isotopic
   compositions, fundamental constants) are taken directly from official
   NIST publications.
5. **Extensible** — adding a new theorem requires only a new `.lean` file
   and a line in `lakefile.lean`; see [CONTRIBUTING.md](../CONTRIBUTING.md).

---

## Quick Start

```bash
cd formal-lean/
lake exe cache get   # download pre-built Mathlib cache (~5 min)
lake build           # verify all 552 theorems, 0 sorry
lake exe formalLean  # print summary of verified theorems
```

---

## References

- **Eigenverse**: <https://github.com/beanapologist/Eigenverse>
- Lean 4: <https://leanprover.github.io/>
- Mathlib4: <https://leanprover-community.github.io/mathlib4_docs/>
- NIST Atomic Weights 2016: <https://www.nist.gov/pml/atomic-weights-and-isotopic-compositions-relative-atomic-masses>
- Wilczek, F. (2012). Quantum Time Crystals. *Phys. Rev. Lett.* **109**, 160401.
- Sacha & Zakrzewski (2018). Time crystals: a review. *Rep. Prog. Phys.*
