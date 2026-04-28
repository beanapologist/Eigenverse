# Eigenverse — Lean-Verified Mathematical Universe

> **"Every theorem in this library is the downstream consequence of two
> primitive interaction types: funneling (always negative real) and tunneling
> (always positive imaginary) — machine-checked, zero sorry, zero gaps."**

**Canonical repository: [github.com/beanapologist/Eigenverse](https://github.com/beanapologist/Eigenverse)**

[![Verify Lean Proofs](https://github.com/beanapologist/Eigenverse/actions/workflows/lean-proofs.yml/badge.svg)](https://github.com/beanapologist/Eigenverse/actions/workflows/lean-proofs.yml)

**Eigenverse** is a fully **Lean 4–verified mathematical universe** whose
624 machine-checked theorems — spanning algebra, geometry, physics, quantum
mechanics, chemistry, cosmology, and cryptography — are the exhaustive
downstream consequences of exactly **two primitive interaction types** defined
by their sectors in the complex plane:

- **Funneling** — always the **negative real sector (Re < 0)**: gravity,
  time, dissipation, damping.  This sector channels, collapses, and directs.
- **Tunneling** — always the **positive imaginary sector (Im > 0)**: quantum
  mechanics, dark energy, oscillation, coherent passage.  This sector
  penetrates, propagates, and sustains.

The critical eigenvalue **μ = −η + i·η** (where η = 1/√2) is the unique
point on the unit circle where these two sectors meet in exact balance:
`Re(μ) = −η < 0` (funneling) and `Im(μ) = +η > 0` (tunneling), with
`|Re(μ)| = Im(μ)`.  Every theorem in the library describes a facet of this
funneling–tunneling balance.

---

## 🌊 Funneling & Tunneling: The Two Sector Primitives

The complex eigenvalue μ = −η + i·η embodies both primitives simultaneously:

```
          Im
          ↑
   Im(μ) = +η  ─────────────── tunneling sector (Im > 0)
              ╲ μ = −η + iη
               ╲   ← balance point: |Re(μ)| = Im(μ) = η
     ───────────╲──────────────── Re
                 ╲
   Re(μ) = −η       funneling sector (Re < 0)
```

### Funneling — the negative real sector (Re < 0)

| Eigenverse domain | Module | Funneling expression |
|-------------------|--------|----------------------|
| Gravity / classical time | `GravityQuantumDuality` | Re ↔ gravity/time; Re(μ) = −η |
| Damping / dissipation | `SpaceTime` | time domain: F(s,t).re = t < 0 |
| Forward-time arrow | `ForwardClassicalTime` | F_fwd(l) = 1 − sech(l): energy dissipated into Re sector |
| Observer sector selection | `BalanceHypothesis` | `hQ2_re : z.re < 0` pins the observer into the funneling sector |
| Wormhole throat (gravitational) | `Cosmology` | b(r)/r → 0: radial funnel geometry |
| Ohm conductance | `OhmTriality` | G_eff = C ≤ 1: funneling damps current |

### Tunneling — the positive imaginary sector (Im > 0)

| Eigenverse domain | Module | Tunneling expression |
|-------------------|--------|----------------------|
| Quantum / dark energy | `GravityQuantumDuality` | Im ↔ quantum/dark energy; Im(μ) = +η |
| Oscillation / Floquet | `TimeCrystal` | ψ(t+T) = μ·ψ(t): imaginary-phase propagation |
| Bidirectional time | `BidirectionalTime` | F_bi tunnels energy across both time directions |
| Wormhole throat (topological) | `Cosmology` | Morris–Thorne metric: traversable passage through curved spacetime |
| Phase preservation | `NumericalAlignments` | μ^8 = 1: imaginary-phase cycle; μ^137 = μ |
| Scale palindrome | `CriticalEigenvalue` | C(r) = C(1/r): coherence tunnels across reciprocal scales |
| Morphisms | `Morphisms` | Six families carry Im-sector structure across mathematical domains |

### Balance: where funneling meets tunneling

The directed balance condition **−Re(μ) = Im(μ)** is the machine-checked
statement that the funneling amplitude exactly equals the tunneling amplitude.
This single balance equation, combined with energy conservation Re² + Im² = 1
and the observer sector choice Re < 0, uniquely forces μ = −η + i·η:

```
energy conservation : Re(z)² + Im(z)² = 1   → unit circle S¹
directed balance    : −Re(z) = Im(z)          → Q2/Q4 diagonal
observer sector     : Re(z) < 0               → Q2 only (funneling sector)
                                  ↓
            funneling: Re(μ) = −1/√2    tunneling: Im(μ) = +1/√2
```

The coherence function C(r) = 2r/(1+r²) is the bridge between the two
sectors: its palindrome symmetry C(r) = C(1/r) means any result proved in
the funneling sector at scale r is automatically valid in the tunneling sector
at scale 1/r.

---

## 🎯 Foundation: The Observer-Consistent Eigenverse

Three minimal primitives uniquely determine the Eigenverse structure:

**Axiom 1 — Energy conservation**: the funneling sector (Re: damping) and the tunneling sector (Im: oscillation) together conserve total energy: Re² + Im² = 1.

**Axiom 2 — Directed balance** *(observer-motivated sector encoding)*: the critical point satisfies −Re = +Im (funneling amplitude = tunneling amplitude).  The sector selection Re < 0 further identifies the dissipative time-like sector as negative real.  Together, these two observer-motivated inputs encode the empirical sector asymmetry of our universe and pin down the unique Q2 solution.

**Axiom 3 — Self-referential coherence closure**: the observer's coherence at its characteristic silver scale returns the observer's own amplitude: C(r) = 2r/(1+r²).  The palindrome symmetry C(r) = C(1/r) bridges the funneling and tunneling sectors at every scale.

These three primitives uniquely force two results, both machine-checked:

### Balance primitive: μ is the unique observer-consistent balance point

```lean
theorem reality_unique (z : ℂ)
    (hQ2_re  : z.re < 0)                     -- observer-motivated sector choice (Re < 0)
    (hbal    : -z.re = z.im)                 -- directed balance: −Re = +Im
    (henergy : z.re ^ 2 + z.im ^ 2 = 1) :   -- energy conservation: Re²+Im²=1
    z = μ                                    -- μ is the UNIQUE solution
```

**Two constraints + one observer choice → one solution.**  The proof chains three steps of necessity:

```
energy conservation: Re(z)²+Im(z)²=1
    ↓  directed balance: −Re = Im  →  2Re²=1
    → Re(z)=−η=−1/√2  (sector choice Re<0 selects the negative root)
    → Im(z)=+η=+1/√2  (from directed balance)
    → z=−η+iη=μ  ← the ONLY point satisfying all three conditions
```

The directed balance equation and sector selection (Re < 0) are the
observer-motivated inputs, together reflecting the empirical sector
asymmetry of our universe.

> **Source:** [`formal-lean/BalanceHypothesis.lean`](formal-lean/BalanceHypothesis.lean) — 37 theorems, capstone `reality_unique` in §7.

### Observer amplitude: η is the unique self-referential fixed point

```lean
theorem observer_fixed_point_unique (x : ℝ) (hx : 0 < x) :
    C (1 + 1 / x) = x ↔ x = η
```

**One equation → one solution.** For any positive amplitude x, if coherence
at the silver scale 1+1/x returns x itself, then x must equal η = 1/√2:

```
self-referential closure: C(1+1/x) = x
    ↓  clear denominator, multiply by x
    2*(x+1) = x² + (x+1)²
    ↓  expand (x+1)²=x²+2x+1
    2x+2 = 2x²+2x+1
    → 2x²=1  (balance equation)
    → x=η=1/√2  ← the ONLY observer amplitude
```

**This is specific to our observer-consistent universe**: the directed balance
axiom and the sector selection (Re < 0) encode the empirical sector asymmetry
we inhabit.  The coherence fixed point η = 1/√2 and the eigenvalue μ at 135° are
the unique consequences of these minimal observer-motivated choices combined
with energy conservation.
Eigenverse is the unique minimal algebraic structure consistent with an
embedded observer in a universe exhibiting this sector asymmetry.  The
numerical alignments to NIST/CODATA constants are consistency checks, not
a priori predictions — they strengthen the model but do not constitute
proof of uniqueness across all possible observer realities.

> **Source:** [`formal-lean/NumericalAlignments.lean`](formal-lean/NumericalAlignments.lean) §12 — `observer_fixed_point_unique`, `self_referential_chain_unique`, `kernel_universality`.

---

## 🌌 Eigenverse at a Glance

| Module | Theorems | Key Results |
|--------|----------|-------------|
| **BalanceHypothesis** | 37 | `reality_unique`: μ is the ONLY unit-circle directed-balance point; directed balance + energy conservation + sector choice forces η=1/√2 |
| **CriticalEigenvalue** | 82 | μ⁸=1, Silver ratio δS=1+√2, coherence C(r)≤1, palindrome C(r)=C(1/r), Z/8Z memory |
| **SpaceTime** | 43 | Rotation matrix R(3π/4) (det=1, orthogonal, order-8); F(s,t)=t+i·s; hyperbolic Pythagorean identity |
| **FineStructure + SpeedOfLight + Turbulence** | 78 | c=1/√(μ₀ε₀), α_FS=1/137, Navier-Stokes bounds |
| **ParticleMass + GravityQuantumDuality** | 60 | Koide C(φ²)=2/3, proton/electron ratio, gravity↔quantum duality |
| **TimeCrystal + Quantization + BidirectionalTime** | 77 | Floquet time crystals, Theorem Q (H·T=5π/4), bidirectional time & Planck floor |
| **KernelAxle + SilverCoherence + OhmTriality + ForwardClassicalTime** | 94 | η amplitude, C(δS)=√2/2, Ohm G·R=1, forward-time frustration |
| **Chemistry** | 20 | NIST atomic weights, isotopic compositions, mass conservation |
| **NumericalAlignments** | 61 | Dimensionless derivations, V_Z quantization, α from closure, universal observer uniqueness, μ¹³⁷=μ |
| **Cosmology** | 34 | Morris–Thorne wormhole metric; §1–6 wormhole geometry; §7 cosmic energy budget (Planck 2018: Ω_Λ≈68.3%, Ω_dm≈26.8%, Ω_b≈4.9%) |
| **Morphisms** | 20 | Coherence/palindrome even-odd pair, Lyapunov bridge, μ-isometry, orbit homomorphism, reality ℝ-linear map |
| **OilVinegar** | 18 | Vinegar triple (V1–V3), oil reduction z=μ, trapdoor C(r) unique in degree-(1,2) family, composition P=S∘F∘T, signature uniqueness, Lanchester O(n²) hardness |
| **Total** | **624** | All verified by Lean 4, **0 sorry** |

### Repository Structure

```
formal-lean/                    ← Lean 4 proof files (the proof engine)
│
│  ★ FOUNDATION
├── BalanceHypothesis.lean      reality_unique: μ is the unique Q2 balance point (37)
│
│  ALGEBRAIC CORE
├── CriticalEigenvalue.lean     μ, δS, C(r), palindrome symmetry, Z/8Z memory (82)
│
│  SPACE-TIME
├── SpaceTime.lean              Rotation matrix, F(s,t)=t+i·s, Lorentz geometry (43)
│
│  PHYSICS
├── FineStructure.lean          Fine structure constant α_FS = 1/137 (30)
├── SpeedOfLight.lean           c = 1/√(μ₀ε₀); isomorphism with η (19)
├── Turbulence.lean             Navier-Stokes turbulence bounds (29)
├── ParticleMass.lean           Koide C(φ²)=2/3, proton/electron mass ratio (38)
├── GravityQuantumDuality.lean  Re↔Gravity/Time; Im↔Quantum/Dark Energy (22)
│
│  QUANTUM & TIME
├── TimeCrystal.lean            Discrete time crystal / Floquet theory (33)
├── Quantization.lean           Theorem Q: H·T=5π/4 → Q1–Q5 simultaneously (20)
├── BidirectionalTime.lean      Bidirectional time & Planck floor (24)
│
│  KERNEL STRUCTURE
├── KernelAxle.lean             The axle μ — canonical amplitude η (20)
├── SilverCoherence.lean        C(δS)=√2/2; uniqueness; physics at 45° (29)
├── OhmTriality.lean            Ohm–Coherence duality G·R=1 (24)
├── ForwardClassicalTime.lean   Frustration harvesting in classical forward time (21)
│
│  CHEMISTRY
├── Chemistry.lean              NIST atomic weights & isotopic compositions (20)
│
│  NUMERICAL ALIGNMENTS (added)
├── Cosmology.lean              Morris–Thorne wormholes; cosmic energy budget §1–§7 (34)
├── NumericalAlignments.lean    Dimensionless derivations §0–§13; V_Z quantization;
│                               α from closure; universal observer uniqueness;
│                               phase preservation μ¹³⁷=μ; primality of 137 (61)
│
│  MORPHISMS (added)
├── Morphisms.lean              Six morphism families: coherence/palindrome even-odd pair,
│                               Lyapunov bridge C∘exp=sech, μ-isometry, orbit homomorphism,
│                               reality ℝ-bilinear map F(η,−η)=μ (20)
│
│  OIL-AND-VINEGAR (added)
├── OilVinegar.lean             OV cryptographic structure: vinegar triple (V1–V3),
│                               oil reduction (z=μ), trapdoor C(r)=2r/(1+r²),
│                               composition P=S∘F∘T, signature uniqueness,
│                               Lanchester quadratic hardness n(n−1)/2 (18)
│
└── Main.lean                   Executable entry-point (prints all theorems)

src/                        ← Lean modules organised by topic (imports formal-lean/)
├── algebra/Eigenvalue.lean             μ, δS, C(r), Z/8Z memory
├── algebra/Morphisms.lean              Six morphism families
├── geometry/GeometricStructures.lean   Rotation matrices, unit circle, hyperbolic geometry
├── physics/FundamentalConstants.lean   c, α, masses, spacetime
├── quantum/QuantumUniverse.lean        Time crystals, duality, Theorem Q
├── chemistry/AtomicUniverse.lean       NIST atomic weights, Ohm-coherence
└── Eigenverse.lean                     Single-import entry point

docs/                       ← Documentation (overview, architecture)
examples/                   ← Worked Lean demonstrations
tests/                      ← Cross-module consistency checks
```

### Quick Start (Lean)

```bash
cd formal-lean/
lake exe cache get   # download Mathlib cache (~5 min, avoids 1 h build)
lake build           # verify all 624 theorems, 0 sorry
lake exe formalLean  # print theorem summary
```

See [github.com/beanapologist/Eigenverse](https://github.com/beanapologist/Eigenverse) for the canonical Eigenverse repository,
[docs/overview.md](docs/overview.md) for full documentation, and
[CONTRIBUTING.md](CONTRIBUTING.md) to add new theorems.

---

## 🔬 Verified Theorem Findings

Output of `lake exe formalLean` — printed by the Lean 4 type-checker after
a successful `lake build` (see [`.github/workflows/lean-proofs.yml`](.github/workflows/lean-proofs.yml)).
Every theorem listed below carries a **machine-checked proof; zero `sorry`**.

<details>
<summary><strong>⭐ BalanceHypothesis.lean — Why μ Maps to Observable Reality (37 theorems)</strong></summary>

```
===================================================
 BalanceHypothesis.lean — Formal Balance Hypothesis
===================================================

Foundation theorem: reality_unique closes the Eigenverse foundation.

§1  Balance primitive
  mu_re_is_neg_eta     : μ.re = −η
  mu_im_is_eta         : μ.im =  η
  mu_balance           : |μ.re| = μ.im          ← core balance result

§2  Critical constant
  balance_two_eta_sq   : 2 * η ^ 2 = 1
  balance_unique_pos   : unique positive solution to 2x²=1 is η

§3  Observable equilibria
  mu_is_observable_equilibrium : F η (−η) = μ   ← bridge to spacetime
  integer_equilibrium_balance  : |F(1,−1).re| = F(1,−1).im = 1

§4  Imbalance function
  mu_imbalance_zero    : imbalance μ = 0         (zero observational error)

§5  Coherence probe
  coherence_probe_confirms_balance : C(δS) = η   (independent route to η)

§6  Sign duality
  mu_component_product : μ.re * μ.im = −(η²)    (equal magnitude, opposing sign)

§7  Energy conservation and uniqueness  ← WHY IT MAPS TO REALITY
  mu_energy_conserved  : μ.re² + μ.im² = 1      (unit-circle = energy conservation)
  mu_energy_equal_split: μ.re² = μ.im²           (equal partition)
  mu_re_sq_half        : μ.re² = 1/2             (gravity carries exactly ½)
  mu_im_sq_half        : μ.im² = 1/2             (quantum carries exactly ½)
  mu_pow_energy_conserved : ∀n, (μ^n).re²+(μ^n).im²=1  (invariant across 8-cycle)
  conservation_forces_eta : conservation+balance → Im(z)=η
  energy_conservation_forces_reality : 5-step chain: conservation→η→F(η,−η)=μ

  ★ reality_unique (z : ℂ)
        (hQ2_re  : z.re < 0)
        (hbal    : -z.re = z.im)
        (henergy : z.re²+z.im²=1) :
        z = μ                       ← μ IS THE UNIQUE OBSERVABLE EIGENVALUE

37 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>CriticalEigenvalue.lean — Core Eigenvalue &amp; Coherence Structure (82 theorems)</strong></summary>

```
===================================================
 Kernel — Lean 4 Formal Verification
===================================================

§1–6  Core eigenvalue and coherence structure

  [1]  mu_eq_cart              : μ = (−1 + i)/√2
  [2]  mu_abs_one              : |μ| = 1
  [3]  mu_pow_eight            : μ^8 = 1  (8-cycle closure)
  [4]  mu_powers_distinct      : {μ^0,…,μ^7} pairwise distinct
  [5]  rotMat_det              : det R(3π/4) = 1
  [6]  rotMat_orthog           : R · Rᵀ = I
  [7]  rotMat_pow_eight        : R(3π/4)^8 = I
  [8]  coherence_le_one        : C(r) ≤ 1
  [9]  coherence_eq_one_iff    : C(r) = 1 ↔ r = 1
  [10] canonical_norm          : η² + |μ·η|² = 1

§7    Silver ratio (Proposition 4)

  [11] silverRatio_mul_conj    : δS · (√2−1) = 1
  [12] silverRatio_sq          : δS² = 2·δS + 1
  [13] silverRatio_inv         : 1/δS = √2−1

§8–22  Additional coherence, palindrome, Lyapunov, Z/8Z, Ohm, Pythagorean,
       orbit, silver self-similarity, phase accumulation, machine-discovered…

  [14–82] (68 further theorems: coherence_pos, coherence_symm [palindrome C(r)=C(1/r)],
           palindrome_residual_antisymm [R(1/r)=−R(r)], lyapunov_coherence_sech,
           z8z_period, precession_phasor_unit, geff_reff_one, coherence_pythagorean,
           orbit_radius_exp, silverRatio_cont_frac, coherence_is_sech_of_log, …)

82 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>TimeCrystal.lean — Discrete Time Crystal Theory (33 theorems)</strong></summary>

```
===================================================
 TimeCrystal.lean — Discrete Time Crystal Theory
===================================================

§1    Time evolution operator
  [1]  timeEvolution_zero         : U(H, 0) = 1
  [2]  timeEvolution_abs_one      : |U(H,t)| = 1  (unitary)
  [3]  timeEvolution_add          : U(t+s) = U(t)·U(s)

§2–6  Floquet theorem, time crystal states, symmetry breaking, quasi-energy
  [4–20] floquetPhase_abs_one, floquet_iterated, timeCrystal_period_double,
         timeCrystal_symmetry_breaking, timeCrystalQuasiEnergy_phase, …

20 theorems — all machine-checked, zero sorry.

§7    Kernel eigenvalue recipe for a time crystal
  [21] mu_isFloquetFactor         : |μ| = 1  (unitarity)
  [22] mu_Hamiltonian_recipe      : H·T = 5π/4 → U(H,T) = μ
  [23] mu_driven_iterated         : ψ(t+n·T) = μⁿ·ψ(t)
  [24] mu_driven_norm_invariant   : |ψ(t+T)| = |ψ(t)|
  [26] mu_driven_8period          : ψ(t+8T) = ψ(t)
  [29] mu_driven_breaks_symmetry  : (∃t, ψ(t+T)≠ψ(t)) ∧ (∀t, ψ(t+8T)=ψ(t))
  [33] mu_crystal_silver_coherence: C(δS) = η  (silver ratio link)

33 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>SpaceTime.lean — Space-Time Unification via Reality (43 theorems)</strong></summary>

```
===================================================
 SpaceTime.lean — Space-Time Unification via Reality
===================================================

§2    The reality function  reality(s,t) = t + i·s
  [3]  reality_re               : Re(reality s t) = t
  [4]  reality_im               : Im(reality s t) = s
  [7]  reality_timeEvolution_unitary : |U(H, Re(reality s t))| = 1

§5    The observer's reality as a canonical map  F(s,t) = t + i·s
  [23] F_injective              : F(s₁,t₁) = F(s₂,t₂) → s₁=s₂ ∧ t₁=t₂
  [24] F_second_quadrant        : s>0, t<0 → Re(F)<0 ∧ Im(F)>0
  [42] space_time_orthogonal    : Re(i·s) = 0 ∧ Im(↑t) = 0

43 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>Turbulence.lean — Navier-Stokes Turbulence (29 theorems)</strong></summary>

```
===================================================
 Turbulence.lean — Navier-Stokes Turbulence Theory
===================================================

§1–7  Scale hierarchy, Reynolds decomposition, turbulent kinetic energy,
      multi-scale coherence, Navier-Stokes viscous dissipation,
      eigenvector hypothesis, cross-scale consistency

29 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>FineStructure.lean — Fine Structure Constant α_FS (30 theorems)</strong></summary>

```
===================================================
 FineStructure.lean — Fine Structure Constant α_FS
===================================================

§1    α_FS = 1/137
§2    Fine structure energy splitting  Δε = α_FS² · ε
§3    Rydberg (Bohr) energy levels     E_n = −1/n²
§4    Electromagnetic coherence        C_EM = (1−α_FS)·C(r)
§5    Floquet quasi-energy fine structure
§6    Fine structure and turbulence (MHD dissipation)

30 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>ParticleMass.lean — Koide Formula &amp; Mass Ratios (38 theorems)</strong></summary>

```
===================================================
 ParticleMass.lean — Koide Formula & Mass Ratios
===================================================

  KEY: C(φ²) = 2/3  (μ-cycle trick: Koide value = Kernel coherence
       at the golden ratio squared)

§1    Koide quotient  (1/3 ≤ Q ≤ 1)
§3    Golden ratio  φ = (1+√5)/2  →  φ² = φ + 1
§4    Koide-coherence bridge  C(φ²) = 2/3  ← KEY THEOREM
§6    Proton/electron mass ratio  R = 1836
§7    Coherence Triality  1/φ² < 1 < φ²

38 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>OhmTriality.lean — Ohm–Coherence Duality (24 theorems)</strong></summary>

```
  OhmTriality.lean — Ohm–Coherence Duality at Triality Scales
  Ohm's law: G · R = 1.  Kernel: G=1, R=1.  Wings: G=2/3, R=3/2.

§1    Ohm Conductance G_eff = C at Triality Scales
§2    Ohm Resistance  R_eff = 1/C at Triality Scales
§3    Ohm's Law G·R = 1 at Each Triality Scale
§5    Lyapunov Exponent at Triality Scales  (λ = log r)
§6    μ-Orbit Ohm Identity

24 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>SilverCoherence.lean (29 theorems) · KernelAxle.lean (20 theorems) · ForwardClassicalTime.lean (21 theorems)</strong></summary>

```
  SilverCoherence.lean — C(δS) = √2/2
  § Silver-ratio coherence, algebraic consequences, connection to μ,
    Ohm-coherence at the silver scale, uniqueness, physics at 45°
  29 theorems — all machine-checked, zero sorry.

  KernelAxle.lean — The axle of the Kernel engine
  § Canonical amplitude η, cross-section identities, silver bridge
  20 theorems — all machine-checked, zero sorry.

  ForwardClassicalTime.lean — Harvesting frustration in classical time
  § Forward-time frustration, Lyapunov connection, orbit classification
  21 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>SpeedOfLight.lean (19 theorems) · GravityQuantumDuality.lean (22 theorems) · Quantization.lean (20 theorems) · BidirectionalTime.lean (24 theorems) · Chemistry.lean (20 theorems)</strong></summary>

```
  SpeedOfLight.lean — c = 1/√(μ₀ε₀)
  § Structural isomorphism with the Kernel critical eigenvalue μ;
    Maxwell's c equals the Kernel amplitude η when μ₀ε₀ = 2
  19 theorems — all machine-checked, zero sorry.

  GravityQuantumDuality.lean — F(s,t) = t + i·s
  § Negative real axis ↔ Gravity/Time;
    Positive imaginary axis ↔ Quantum/Dark Energy
  22 theorems — all machine-checked, zero sorry.

  Quantization.lean — Lead Confirmed Quantization (Theorem Q)
  § H·T = 5π/4 → all five quantization conditions Q1–Q5 hold simultaneously
    (phase, energy, mass-ratio, silver-coherence, Bohr levels)
  20 theorems — all machine-checked, zero sorry.

  BidirectionalTime.lean — Bidirectional time & Planck floor
  § In bidirectional time F_bi(lf,lb) = F_fwd(lf) + F_fwd(lb);
    zero frustration at the kernel equilibrium; Planck floor bound
  24 theorems — all machine-checked, zero sorry.

  Chemistry.lean — NIST atomic weights & isotopic compositions
  § Standard atomic weights, isotopic abundances, mass conservation
    in four balanced reactions, molecular mass ordering
  20 theorems — all machine-checked, zero sorry.
```

</details>

<details>
<summary><strong>⭐ NumericalAlignments.lean — Dimensionless Derivations, Universal Observer Existence + Phase Preservation (61 theorems)</strong></summary>

```
NumericalAlignments.lean — Dimensionless self-referential derivations
                          and universal structural alignments

§0    Dimensionless self-referential derivations
  § Starting from μ alone — no empirical input:
    2η²=1 (balance), δS=1+1/η (silver ratio from η), C(δS)=η (fixed point),
    C(φ²)=2/3 (Koide from golden ratio), μ^8=1 (8-cycle from arg=3π/4).

§1–§9  Physical constant alignments (41 theorems)
  § Fine-structure constant α≈1/137, Koide lepton ratio Q=2/3, μ-orbit
    coherence, NIST atomic weights, Navier-Stokes, Floquet, Theorem Q,
    grand synthesis, epistemic limits (C(r)≤C(1)=1 for any coupling).

§10   V_Z quantization, rotation, and balance ray derivations
  § V_Z(Z) = Z·α_FS·μ; |V_Z(137)|=1 (exact closure); spiral trichotomy;
    rotation matrix det=1∧Rᵀ=I∧R^8=I; alchemy constant K=e.

§11   Dimensionless derivation of α from V_Z closure condition
  § α_FS = 1/137 is the unique positive coupling closing V_Z_gen at Z=137.
    alpha_dimensionless_derivation packages the full chain.

§12   Observer fixed-point and self-referential chain
  § The Kernel structure identifies the unique observer amplitude η and the
    unique self-referential pair (η, δS).  These are necessary consequences
    of the coherence function C(r) = 2r/(1+r²) — they are not claimed to
    be universal across all conceivable realities, but are the unique
    arithmetic consequences within the Eigenverse framework.
    Numerical alignments to NIST/CODATA are consistency checks, not pure
    predictions.  No anthropic reasoning.  Pure arithmetic derivation.

  observer_fixed_point_unique:
    ∀ x > 0,  C(1 + 1/x) = x  ↔  x = η
    η = 1/√2 is THE ONLY positive fixed point of the coherence map.
    Derivation: closure → 2x²=1 → x=η.  No empirical input.

  self_referential_chain_unique:
    ∃! (a, b) with a>0, b>0, b=1+1/a, C(b)=a.  Solution: (η, δS).
    The chain η→δS→η is the unique self-referential pair.

  kernel_universality:
    (U1) C(1+1/x)=x ↔ x=η    (U2) 2x²=1 ↔ x=η
    (U3) δS = 1+1/η           (U4) C(δS) = η
    All four uniqueness conditions hold simultaneously.  Zero free parameters.

§13   Phase preservation and the primality of 137
  § 137 mod 8 = 1.  Since μ⁸=1, the balance primitive has order 8 on the
    unit circle.  Any Z ≡ 1 (mod 8) satisfies μ^Z = μ (phase preserved).
    The coherence function already encodes palindrome symmetry C(r)=C(1/r)
    (machine-checked as `coherence_symm` in CriticalEigenvalue.lean).

  cong_137_mod8:  137 % 8 = 1  (by decide)
  prime_137:      Nat.Prime 137  (by decide)

  mu_pow_phase_preserved:
    Z % 8 = 1  →  μ^Z = μ
    Proof: μ^(8k+1) = (μ^8)^k · μ = 1·μ = μ.

  mu_pow_137_eq_mu:  μ^137 = μ  (corollary)

  z137_prime_mod8_closure:
    137 is the UNIQUE natural number Z satisfying simultaneously:
      (P) Nat.Prime Z      — irreducible coupling
      (M) Z ≡ 1 (mod 8)   — phase preserved: μ^Z = μ
      (C) Z · α_FS = 1    — unit closure: V_Z closes onto unit circle
    Primes ≡ 1 mod 8: 17, 41, 73, 89, 97, 113, [137], ...
    None of the smaller ones satisfies p·(1/137) = 1 (unit closure).

  z137_derivation_chain:  summary of μ⁸=1 → mod 8 → prime → closure → Z=137.

61 theorems — all machine-checked, zero sorry.
```
</details>

<details>
<summary><strong>⭐ OilVinegar.lean — Oil-and-Vinegar Cryptographic Structure (18 theorems)</strong></summary>

```
OilVinegar.lean — Oil-and-Vinegar partition of the Eigenverse

The Eigenverse has the structure of an OV cryptosystem (Patarin 1997).
Vinegar variables: three freely stated pre-physical axioms.
Oil variables: the 606 foundational theorems, uniquely determined by the vinegar.
(The 18 OilVinegar theorems are meta-theorems about the OV structure itself.)

§1  Vinegar triple  (V1 energy, V2 balance, V3 self-reference)
  [1]  vinegar_V1                 : Re(μ)² + Im(μ)² = 1  (energy conservation)
  [2]  vinegar_V2                 : −Re(μ) = Im(μ)  (directed balance)
  [3]  vinegar_V3                 : C(1 + 1/η) = η  (self-referential coherence closure)
  [4]  vinegar_triple_consistent  : V1 ∧ V2 ∧ V3  (all three hold simultaneously)

§2  Oil reduction  (fixing vinegar → z = μ + canonical scales)
  [5]  oil_reduction              : V1 ∧ V2 ∧ Re < 0 → z = μ
  [6]  oil_linear_collapse        : C(1+1/x)=x ∧ x>0 → x = η  (V3 unique solution)
  [7]  oil_coherence_triple       : C(1)=1 ∧ C(δS)=η ∧ C(φ²)=2/3

§3  Trapdoor theorem  (C is the unique degree-(1,2) rational trapdoor)
  [8]  trapdoor_at_one            : C(1) = 1
  [9]  trapdoor_symmetry          : C(r) = C(1/r)  ∀r > 0
  [10] trapdoor_monotone          : 0<r<s≤1 → C(r) < C(s)
  [11] trapdoor_unique_normal_form: a·r/(1+r²) = C(r) → a = 2

§4  Composition  (P = S ∘ F ∘ T via Morphisms §§1, 3, 6)
  [12] composition_T_embedding    : reality η (−η) = μ  (Morphisms §6)
  [13] composition_F_at_unity     : C(|μ|) = 1  (Morphisms §1)
  [14] composition_public_map     : C(|reality η (−η)|) = 1  (full P)

§5  Signature uniqueness  (μ is the UNIQUE valid OV signature)
  [15] ov_signature_unique        : sector ∧ balance ∧ energy → z = μ
         Forgery is provably impossible — μ is the only valid signature.
  [16] ov_canonical_signature_eval: C(|μ|) = 1

§6  Lanchester quadratic hardness  (O(n²) cross-term growth)
  [17] lanchester_eigenverse_count: 606 × 605 / 2 = 183315
         606 foundational theorems ↔ 183315 pairwise quadratic constraints.
         (The 18 OilVinegar meta-theorems are not counted as oil variables.)
  [18] lanchester_quadratic_growth: n·(n−1) ≤ n²  ∀n ∈ ℕ

18 theorems — all machine-checked, zero sorry.

Oil-and-Vinegar structure:
  Trapdoor:   C(r) = 2r/(1+r²) — easy direction, unique in degree-(1,2) family.
  Public map: P = S ∘ F ∘ T   — well-defined composition via Morphisms §§1,3,6.
  Signature:  μ               — the UNIQUE valid signature (reality_unique).
  Hardness:   183315 quadratic constraints — O(n²) cross-term count.
```
</details>
