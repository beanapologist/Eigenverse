# Particles — Elementary Particle Properties

> Lean 4–verified formalization of electrons, protons, and quarks.
> **20 theorems, zero `sorry`, zero gaps.**

This module formalizes the fundamental properties of the three families of
elementary particles that make up ordinary matter: **electrons**, **protons**,
and **quarks**.  All results are machine-checked by the Lean 4 type-checker.

---

## Overview

The module is organized across two files:

| File | Purpose |
|---|---|
| [`formal-lean/Particles.lean`](../../formal-lean/Particles.lean) | Core Lean 4 proofs (structures + 20 theorems) |
| [`src/particles/ElementaryParticles.lean`](ElementaryParticles.lean) | Re-export module for downstream consumers |

---

## Particle Structures

Three Lean 4 record types are defined to bundle the observable properties of
each particle family.

### `Electron`

```lean
structure Electron where
  mass   : ℝ   -- rest mass in MeV/c²  (CODATA 2018: 51099895/100000000 ≈ 0.511 MeV/c²)
  charge : ℝ   -- electric charge in units of e  (value: −1)
  spin   : ℝ   -- spin quantum number in units of ℏ/2  (value: 1 = spin-½)
```

### `Proton`

```lean
structure Proton where
  mass   : ℝ   -- rest mass in MeV/c²  (CODATA 2018: 938.272)
  charge : ℝ   -- electric charge in units of e  (value: +1)
  spin   : ℝ   -- spin quantum number in units of ℏ/2  (value: 1 = spin-½)
```

### `Quark`

```lean
structure Quark where
  mass        : ℝ      -- rest mass in MeV/c²  (PDG 2020 current quark masses)
  charge      : ℝ      -- electric charge in units of e  (+2/3 or −1/3)
  colorCharge : Fin 3  -- QCD color: 0 = red, 1 = green, 2 = blue
```

---

## Verified Theorems

### §2 — Electron Properties (4 theorems)

| Theorem | Statement |
|---|---|
| `electron_mass_pos` | `0 < m_electron` |
| `electron_charge_neg` | `q_electron < 0` |
| `electron_spin_one` | `spin_electron = 1` (spin-½ in units of ℏ/2) |
| `electron_spin_pos` | `0 < spin_electron` |

### §3 — Proton Properties (4 theorems)

| Theorem | Statement |
|---|---|
| `proton_mass_pos` | `0 < m_proton` |
| `proton_charge_pos` | `0 < q_proton` |
| `proton_heavier_than_electron` | `m_electron < m_proton` (ratio ≈ 1836) |
| `electron_proton_charge_cancel` | `q_electron + q_proton = 0` |

### §4 — Quark Flavors (5 theorems)

| Theorem | Statement |
|---|---|
| `quark_up_charge_pos` | `0 < q_up` (+2/3) |
| `quark_down_charge_neg` | `q_down < 0` (−1/3) |
| `quark_up_charge_gt_down` | `q_down < q_up` (−1/3 < +2/3) |
| `quark_masses_pos` | all six quark masses are positive |
| `quark_mass_hierarchy` | `m_u < m_d < m_s < m_c < m_b < m_t` |

Quark masses in MeV/c² (PDG 2020):

| Flavor | Symbol | Mass (MeV/c²) | Charge |
|---|---|---|---|
| up      | u | 2.16    | +2/3 |
| down    | d | 4.67    | −1/3 |
| strange | s | 93.4    | −1/3 |
| charm   | c | 1270    | +2/3 |
| bottom  | b | 4180    | −1/3 |
| top     | t | 172760  | +2/3 |

### §5 — Baryon Composition (3 theorems)

| Theorem | Statement |
|---|---|
| `proton_charge_from_quarks` | `2·q_up + q_down = q_proton` (proton = uud) |
| `neutron_charge_neutral` | `q_up + 2·q_down = 0` (neutron = udd) |
| `proton_decay_charge_conserved` | `q_proton = 0 + (−q_electron) + 0` (β⁺ decay) |

The key charge identities:

```
Proton  p = uud:  2 × (+2/3) + (−1/3) = 4/3 − 1/3 = +1  ✓
Neutron n = udd:     (+2/3) + 2×(−1/3) = 2/3 − 2/3 =  0  ✓
```

### §6 — Hydrogen Atom (4 theorems)

| Theorem | Statement |
|---|---|
| `hydrogen_atom_neutral` | `q_electron + q_proton = 0` (neutral atom) |
| `hydrogen_mass_pos` | `0 < m_electron + m_proton` |
| `electron_lt_half_proton_mass` | `m_electron < m_proton / 2` (proton dominates) |
| `hydrogen_heavier_than_proton` | `m_proton < m_electron + m_proton` |

---

## Usage

Import the consumer module to bring all particle theorems into scope:

```lean
import Eigenverse.Particles.ElementaryParticles
```

Or import the core formalization directly:

```lean
import FormalLean.Particles
```

### Example: checking the proton charge from quarks

```lean
#check proton_charge_from_quarks
-- proton_charge_from_quarks : 2 * q_up + q_down = q_proton

example : 2 * q_up + q_down = 1 := by
  have h := proton_charge_from_quarks
  unfold q_proton at h
  linarith
```

### Example: verifying neutron neutrality

```lean
#check neutron_charge_neutral
-- neutron_charge_neutral : q_up + 2 * q_down = 0
```

---

## Building and Verifying

The proofs are verified as part of the Eigenverse Lean 4 project.

```bash
cd formal-lean/
lake exe cache get   # download pre-built Mathlib cache (recommended)
lake build           # build and verify all proofs
```

The CI workflow (`.github/workflows/lean-proofs.yml`) automatically verifies
all proofs on every push to the repository.

---

## Physical Constants

All constants follow CODATA 2018 and PDG 2020 recommendations.

**Quark mass scheme**: quark current masses are given in the
[MS-bar renormalization scheme](https://pdg.lbl.gov/2020/tables/rpp2020-sum-quarks.pdf):
- Light quarks (u, d, s): evaluated at μ = 2 GeV.
- Heavy quarks (c, b, t): evaluated at the quark mass scale μ = m_q.

All values are PDG 2020 central values; see PDG Table 1.1 for full uncertainties.

| Constant | Symbol | Value | Unit | Source / Scheme |
|---|---|---|---|---|
| Electron mass | m_e | 51099895/100000000 ≈ 0.511 | MeV/c² | CODATA 2018 |
| Proton mass | m_p | 938272/1000 = 938.272 | MeV/c² | CODATA 2018 |
| Elementary charge | e | 1 (natural units) | — | convention |
| Up quark mass | m_u | 2.16 | MeV/c² | PDG 2020, MS-bar at 2 GeV |
| Down quark mass | m_d | 4.67 | MeV/c² | PDG 2020, MS-bar at 2 GeV |
| Strange quark mass | m_s | 93.4 | MeV/c² | PDG 2020, MS-bar at 2 GeV |
| Charm quark mass | m_c | 1270 | MeV/c² | PDG 2020, MS-bar at m_c |
| Bottom quark mass | m_b | 4180 | MeV/c² | PDG 2020, MS-bar at m_b |
| Top quark mass | m_t | 172760 | MeV/c² | PDG 2020, MS-bar at m_t |

---

## References

- **CODATA 2018**: NIST Internationally Recommended 2018 Values of the
  Fundamental Physical Constants.
  <https://physics.nist.gov/cuu/Constants/>

- **PDG 2020**: Particle Data Group, "Review of Particle Physics",
  *Prog. Theor. Exp. Phys.* **2020**, 083C01.
  <https://pdg.lbl.gov>

- **Koide formula** (related): Y. Koide (1982), *Phys. Lett. B* **120**, 161–165.
  See also `formal-lean/ParticleMass.lean` for the Koide lepton mass relation.
