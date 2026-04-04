/-
  src/particles/ElementaryParticles.lean — Consumer-layer module for elementary particles.

  Canonical repository: https://github.com/beanapologist/Eigenverse

  This module re-exports the Lean 4–verified elementary particle theorems from
  `formal-lean/Particles.lean` for downstream consumers organised by topic.

  Import this file to bring the complete set of particle physics results into scope.

  Key results available after import
  ────────────────────────────────────
  Structures:
  • `Electron`  — record { mass, charge, spin } with CODATA 2018 values
  • `Proton`    — record { mass, charge, spin } with CODATA 2018 values
  • `Quark`     — record { mass, charge, colorCharge } with PDG 2020 masses

  Electron theorems:
  • `electron_mass_pos`    — m_e > 0:   electron has positive rest mass
  • `electron_charge_neg`  — Q_e < 0:   electron is negatively charged
  • `electron_spin_one`    — spin_e = 1: spin-½ in units of ℏ/2
  • `electron_spin_pos`    — spin_e > 0: spin is positive

  Proton theorems:
  • `proton_mass_pos`              — m_p > 0:   proton has positive rest mass
  • `proton_charge_pos`            — Q_p > 0:   proton is positively charged
  • `proton_heavier_than_electron` — m_e < m_p: proton ≈ 1836× heavier
  • `electron_proton_charge_cancel`— Q_e + Q_p = 0: equal and opposite charges

  Quark flavor theorems:
  • `quark_up_charge_pos`    — Q_u > 0:     up-type quarks positive (+2/3)
  • `quark_down_charge_neg`  — Q_d < 0:     down-type quarks negative (−1/3)
  • `quark_up_charge_gt_down`— Q_d < Q_u:   asymmetry drives baryon charge
  • `quark_masses_pos`       — all six masses > 0: Higgs-generated masses
  • `quark_mass_hierarchy`   — m_u < m_d < m_s < m_c < m_b < m_t

  Baryon composition theorems:
  • `proton_charge_from_quarks`    — 2·Q_u + Q_d = Q_p = 1 (uud)
  • `neutron_charge_neutral`       — Q_u + 2·Q_d = 0       (udd)
  • `proton_decay_charge_conserved`— Q_p = 0 + (−Q_e) + 0  (β⁺ decay)

  Hydrogen atom theorems:
  • `hydrogen_atom_neutral`        — Q_e + Q_p = 0    (electrically neutral)
  • `hydrogen_mass_pos`            — m_e + m_p > 0    (positive rest mass)
  • `electron_lt_half_proton_mass` — m_e < m_p/2     (proton dominates)
  • `hydrogen_heavier_than_proton` — m_p < m_e + m_p  (electron adds mass)

  Background
  ──────────
  Electrons, protons, and quarks are the fundamental charged constituents of
  ordinary matter.  Electrons are point-like leptons governed by quantum
  electrodynamics (QED).  Protons and neutrons are composite baryons built
  from three quarks each, bound by the strong force (QCD).

  Quark flavors and their charges (in units of e):
    Generation I:   up   (+2/3)   down    (−1/3)
    Generation II:  charm(+2/3)   strange (−1/3)
    Generation III: top  (+2/3)   bottom  (−1/3)

  Proton composition (uud): 2·(+2/3) + (−1/3) = +1
  Neutron composition (udd): (+2/3) + 2·(−1/3) =  0

  References:
  • CODATA 2018 internationally recommended values of fundamental constants.
    NIST, https://physics.nist.gov/cuu/Constants/
  • Particle Data Group (PDG 2020). Review of Particle Physics.
    Prog. Theor. Exp. Phys. 2020, 083C01.
-/

import FormalLean.Particles
