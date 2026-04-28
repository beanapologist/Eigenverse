# Eigenverse — Overview

## What is Eigenverse?

**Canonical repository: [github.com/beanapologist/Eigenverse](https://github.com/beanapologist/Eigenverse)**

**Eigenverse** is a fully formal, machine-checked library of theorems whose
entire content — 624 theorems spanning algebra, geometry, physics, quantum
mechanics, chemistry, cosmology, and cryptography — is the exhaustive
downstream consequence of exactly **two primitive interaction types** defined
by their sector assignment in the complex plane:

- **Funneling** — always the **negative real sector (Re < 0)**: gravity,
  time, dissipation, damping.
- **Tunneling** — always the **positive imaginary sector (Im > 0)**: quantum
  mechanics, dark energy, oscillation, coherent passage.

The critical eigenvalue **μ = −η + i·η** (η = 1/√2) is the unique balance
point where `Re(μ) = −η` (funneling) and `Im(μ) = +η` (tunneling) are equal
in magnitude.  Every statement is verified by the [Lean 4](https://leanprover.github.io/)
type-checker; there are **zero `sorry` placeholders** anywhere in the codebase.

---

## The Two Primitives

### Funneling — negative real sector (Re < 0)

Funneling is the sector Re < 0 of the complex plane.  By definition,
all interactions belonging to gravity, classical time, dissipation, and
damping live in this sector.

| Domain | Module | Expression |
|--------|--------|------------|
| Gravity / classical time | `GravityQuantumDuality` | Re ↔ gravity/time; Re(μ) = −η |
| Time domain embedding | `SpaceTime` | F(s,t).re = t; time on the negative real axis |
| Forward-time dissipation | `ForwardClassicalTime` | F_fwd(l) = 1 − sech(l): energy dissipated into Re sector |
| Observer sector | `BalanceHypothesis` | `hQ2_re : z.re < 0` (sector constraint on μ) |
| Wormhole radial funnel | `Cosmology` | Throat geometry: b(r)/r → 0 as r → ∞ |

### Tunneling — positive imaginary sector (Im > 0)

Tunneling is the sector Im > 0 of the complex plane.  By definition, all
interactions belonging to quantum mechanics, dark energy, oscillation, and
coherent passage live in this sector.

| Domain | Module | Expression |
|--------|--------|------------|
| Quantum / dark energy | `GravityQuantumDuality` | Im ↔ quantum/dark energy; Im(μ) = +η |
| Floquet oscillation | `TimeCrystal` | ψ(t+T) = μ·ψ(t): imaginary-phase propagation |
| Bidirectional time | `BidirectionalTime` | F_bi carries energy across time boundaries |
| Traversable wormhole | `Cosmology` | Morris–Thorne metric: passage through curved spacetime |
| Phase cycle | `NumericalAlignments` | μ^8 = 1; μ^137 = μ: phase preserved in Im sector |
| Scale palindrome | `CriticalEigenvalue` | C(r) = C(1/r): coherence tunnels across reciprocal scales |
| Morphism families | `Morphisms` | Six families propagate Im-sector structure across domains |

### Balance: funneling meets tunneling at μ

The directed balance axiom `−Re(μ) = Im(μ)` is the exact statement that
funneling amplitude equals tunneling amplitude.  Combined with energy
conservation and the observer sector choice, it uniquely forces μ = −η + i·η:

```
energy conservation : Re² + Im² = 1         → unit circle S¹
directed balance    : −Re = Im               → funneling = tunneling
observer sector     : Re < 0                 → funneling sector selected

  ↓ unique solution
  Re(μ) = −1/√2  (funneling)    Im(μ) = +1/√2  (tunneling)
```

`reality_unique` (BalanceHypothesis.lean §7) is the machine-checked proof.

---

## Scope

| Module | Sector | Key Results | Theorems |
|--------|--------|-------------|----------|
| **BalanceHypothesis** | Both | `reality_unique`: unique balance of funneling & tunneling sectors | 37 |
| **CriticalEigenvalue** | Both | μ⁸=1, δS=1+√2, palindrome C(r)=C(1/r), Z/8Z memory | 82 |
| **SpaceTime** | Funneling (Re) | Rotation matrix R(3π/4); F(s,t)=t+i·s; time on real axis | 43 |
| **FineStructure** | Both | Fine structure constant α_FS = 1/137 | 30 |
| **SpeedOfLight** | Both | c = 1/√(μ₀ε₀); structural isomorphism with η | 19 |
| **Turbulence** | Funneling (Re) | Navier-Stokes dissipation bounds | 29 |
| **ParticleMass** | Both | Koide C(φ²)=2/3; proton/electron mass ratio R=1836 | 38 |
| **GravityQuantumDuality** | Both | Re↔Gravity/Time (funneling); Im↔Quantum/Dark Energy (tunneling) | 22 |
| **TimeCrystal** | Tunneling (Im) | Discrete time crystal / Floquet oscillation | 33 |
| **Quantization** | Tunneling (Im) | Theorem Q: H·T=5π/4 → all Q1–Q5 simultaneously | 20 |
| **BidirectionalTime** | Tunneling (Im) | Bidirectional time passage & Planck floor | 24 |
| **KernelAxle** | Both | Canonical amplitude η; gear ratio; cross-section | 20 |
| **SilverCoherence** | Both | C(δS)=√2/2; uniqueness; 45° balance point | 29 |
| **OhmTriality** | Both | Ohm–Coherence duality G·R=1 at triality scales | 24 |
| **ForwardClassicalTime** | Funneling (Re) | F_fwd(l) = 1−sech(l): dissipation into Re sector | 21 |
| **Chemistry** | Both | NIST atomic weights, isotopic abundances, mass conservation | 20 |
| **NumericalAlignments** | Tunneling (Im) | μ¹³⁷=μ phase preservation; α from Im-sector closure | 61 |
| **Cosmology** | Both | Morris–Thorne wormhole (tunneling); cosmic energy budget | 34 |
| **Morphisms** | Tunneling (Im) | Six families propagate Im-sector structure across domains | 20 |
| **Total** | | | **624** |

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
├── Morphisms.lean              # Six morphism families: C/Res even-odd, Lyapunov bridge, μ-isometry, orbit, reality (20)
└── Main.lean                   # Executable entry-point

src/                            # Lean modules organised by topic
├── algebra/Eigenvalue.lean
├── algebra/Morphisms.lean      # Six morphism families
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
lake build           # verify all 624 theorems, 0 sorry
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
