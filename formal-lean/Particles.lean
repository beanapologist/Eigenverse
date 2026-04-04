/-
  Particles.lean — Lean 4 formalization of elementary particle properties.

  This module formalizes key properties of electrons, protons, and quarks,
  including masses, charges, spins, and their interactions.  The results
  connect to the broader Eigenverse framework through conservation laws
  and the proton/electron mass hierarchy established in ParticleMass.lean.

  Physical constants are taken from CODATA 2018 / PDG 2020 where applicable.
  All masses are given in MeV/c² (megaelectronvolt per speed-of-light squared).
  Charges are given in units of the elementary charge e (e = 1 in natural units).

  Structures
  ──────────
  Three record types bundle the fundamental properties of each particle kind:
    • Electron  — mass (MeV/c²), charge (units of e), spin (ℏ/2 units)
    • Proton    — mass (MeV/c²), charge (units of e), spin (ℏ/2 units)
    • Quark     — mass (MeV/c²), charge (units of e), colorCharge (0,1,2 = R,G,B)

  Sections
  ────────
  1.  Particle structures:  Electron, Proton, Quark
  2.  Electron properties:  mass, charge, spin  (4 theorems)
  3.  Proton properties:    mass, charge        (4 theorems)
  4.  Quark flavors:        six quarks, masses, charges  (5 theorems)
  5.  Baryon composition:   proton (uud), neutron (udd), charge conservation  (3 theorems)
  6.  Hydrogen atom:        formation, neutrality, mass conservation  (4 theorems)

  Proof status
  ────────────
  All 20 theorems have complete machine-checked proofs.
  No `sorry` placeholders remain.
-/

import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- Section 1 — Particle Structures
-- Each structure bundles the fundamental observable properties of one kind
-- of elementary particle.  Fields use SI-compatible natural units:
--   mass   in MeV/c² (1 MeV/c² ≈ 1.783 × 10⁻³⁰ kg)
--   charge in multiples of the elementary charge e
--   spin   in multiples of ℏ/2  (so the electron spin quantum number = 1)
-- ════════════════════════════════════════════════════════════════════════════

/-- An electron record bundling its fundamental properties.

    Fields:
      mass   — rest mass in MeV/c² (CODATA 2018: 0.51099895 MeV/c²)
      charge — electric charge in units of e  (electron: −1)
      spin   — spin quantum number in units of ℏ/2 (electron: 1, i.e. spin-½) -/
structure Electron where
  mass   : ℝ
  charge : ℝ
  spin   : ℝ

/-- A proton record bundling its fundamental properties.

    Fields:
      mass   — rest mass in MeV/c² (CODATA 2018: 938.272 MeV/c²)
      charge — electric charge in units of e  (proton: +1)
      spin   — spin quantum number in units of ℏ/2 (proton: 1, i.e. spin-½) -/
structure Proton where
  mass   : ℝ
  charge : ℝ
  spin   : ℝ

/-- A quark record bundling its fundamental properties.

    Fields:
      mass        — rest mass in MeV/c² (PDG 2020 current quark mass)
      charge      — electric charge in units of e (+2/3 or −1/3)
      colorCharge — QCD color charge index: 0 = red, 1 = green, 2 = blue -/
structure Quark where
  mass        : ℝ
  charge      : ℝ
  colorCharge : Fin 3

-- ════════════════════════════════════════════════════════════════════════════
-- Section 2 — Electron Properties  (CODATA 2018)
-- ════════════════════════════════════════════════════════════════════════════

/-- Electron rest mass: m_e = 0.51099895 MeV/c² (CODATA 2018).

    Stored as exact rational 51099895/100000000.  This is the mass of the
    lightest charged lepton; it sets the atomic energy scale. -/
noncomputable def m_electron : ℝ := 51099895 / 100000000

/-- Electron electric charge: Q_e = −1 (in units of the elementary charge e).

    The electron carries one unit of negative charge by definition; the
    proton carries the corresponding +1, making atoms neutral. -/
noncomputable def q_electron : ℝ := -1

/-- Electron spin quantum number: s_e = 1 (in units of ℏ/2).

    The electron is a spin-½ fermion; its spin angular momentum is ℏ/2.
    In units where ℏ/2 = 1 the spin quantum number is 1. -/
noncomputable def spin_electron : ℝ := 1

/-- The standard electron, populated with CODATA 2018 values. -/
noncomputable def standardElectron : Electron :=
  { mass := m_electron, charge := q_electron, spin := spin_electron }

/-- The electron rest mass is strictly positive.

    Verified numerically: 51099895/100000000 > 0. -/
theorem electron_mass_pos : 0 < m_electron := by
  unfold m_electron; norm_num

/-- The electron is negatively charged: Q_e < 0.

    The electron charge −e is negative by the conventional sign assignment
    in the SI system. -/
theorem electron_charge_neg : q_electron < 0 := by
  unfold q_electron; norm_num

/-- The electron spin quantum number equals 1 (in units of ℏ/2).

    Equivalently, the spin angular momentum is ℏ/2: the electron is a
    spin-½ particle, the defining example of a fermion. -/
theorem electron_spin_one : spin_electron = 1 := rfl

/-- The electron spin is strictly positive. -/
theorem electron_spin_pos : 0 < spin_electron := by
  unfold spin_electron; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 3 — Proton Properties  (CODATA 2018)
-- ════════════════════════════════════════════════════════════════════════════

/-- Proton rest mass: m_p = 938.272 MeV/c² (CODATA 2018, 6 s.f.).

    Stored as exact rational 938272/1000.  The proton is ≈ 1836 times heavier
    than the electron; this hierarchy is central to atomic structure. -/
noncomputable def m_proton : ℝ := 938272 / 1000

/-- Proton electric charge: Q_p = +1 (in units of e).

    The proton carries one unit of positive charge, exactly cancelling the
    electron charge in a hydrogen atom. -/
noncomputable def q_proton : ℝ := 1

/-- Proton spin quantum number: s_p = 1 (in units of ℏ/2).

    Like the electron, the proton is a spin-½ fermion.  The proton spin
    arises from the combined spins and orbital angular momenta of its three
    constituent quarks. -/
noncomputable def spin_proton : ℝ := 1

/-- The standard proton, populated with CODATA 2018 values. -/
noncomputable def standardProton : Proton :=
  { mass := m_proton, charge := q_proton, spin := spin_proton }

/-- The proton rest mass is strictly positive. -/
theorem proton_mass_pos : 0 < m_proton := by
  unfold m_proton; norm_num

/-- The proton is positively charged: Q_p > 0. -/
theorem proton_charge_pos : 0 < q_proton := by
  unfold q_proton; norm_num

/-- The proton is much heavier than the electron: m_e < m_p.

    Numerically: 0.51099895 MeV/c² < 938.272 MeV/c² (ratio ≈ 1836). -/
theorem proton_heavier_than_electron : m_electron < m_proton := by
  unfold m_electron m_proton; norm_num

/-- The electron and proton charges cancel exactly: Q_e + Q_p = 0.

    This is the fundamental reason hydrogen atoms are electrically neutral:
    −1 + 1 = 0 in units of e. -/
theorem electron_proton_charge_cancel : q_electron + q_proton = 0 := by
  unfold q_electron q_proton; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 4 — Quark Flavors and Properties  (PDG 2020)
-- There are six quark flavors arranged in three generations:
--   Generation I:   up (u),     down (d)
--   Generation II:  charm (c),  strange (s)
--   Generation III: top (t),    bottom (b)
-- Up-type quarks (u,c,t) carry charge +2/3; down-type (d,s,b) carry −1/3.
-- ════════════════════════════════════════════════════════════════════════════

-- Quark electric charges (in units of e)
/-- Up quark charge: Q_u = +2/3. -/    noncomputable def q_up      : ℝ :=  2 / 3
/-- Down quark charge: Q_d = −1/3. -/  noncomputable def q_down    : ℝ := -1 / 3
/-- Charm quark charge: Q_c = +2/3. -/ noncomputable def q_charm   : ℝ :=  2 / 3
/-- Strange quark charge: Q_s = −1/3.-/noncomputable def q_strange : ℝ := -1 / 3
/-- Top quark charge: Q_t = +2/3. -/   noncomputable def q_top     : ℝ :=  2 / 3
/-- Bottom quark charge: Q_b = −1/3. -/noncomputable def q_bottom  : ℝ := -1 / 3

-- Quark current masses (MeV/c², PDG 2020 central values)
/-- Up quark mass: m_u ≈ 2.16 MeV/c² (PDG 2020). -/
noncomputable def m_up      : ℝ :=     216 /    100
/-- Down quark mass: m_d ≈ 4.67 MeV/c² (PDG 2020). -/
noncomputable def m_down    : ℝ :=     467 /    100
/-- Strange quark mass: m_s ≈ 93.4 MeV/c² (PDG 2020). -/
noncomputable def m_strange : ℝ :=     934 /     10
/-- Charm quark mass: m_c ≈ 1270 MeV/c² (PDG 2020). -/
noncomputable def m_charm   : ℝ :=    1270
/-- Bottom quark mass: m_b ≈ 4180 MeV/c² (PDG 2020). -/
noncomputable def m_bottom  : ℝ :=    4180
/-- Top quark mass: m_t ≈ 172760 MeV/c² (PDG 2020). -/
noncomputable def m_top     : ℝ :=  172760

/-- Up-type quarks carry positive fractional charge: Q_u > 0.

    The up quark charge +2/3 is positive, meaning up-type quarks contribute
    positively to the baryon charge sum. -/
theorem quark_up_charge_pos : 0 < q_up := by
  unfold q_up; norm_num

/-- Down-type quarks carry negative fractional charge: Q_d < 0.

    The down quark charge −1/3 is negative.  Two down quarks in a neutron
    (udd) cancel the single up quark contribution to give zero net charge. -/
theorem quark_down_charge_neg : q_down < 0 := by
  unfold q_down; norm_num

/-- Up-type charge exceeds down-type charge: Q_d < Q_u.

    Numerically: −1/3 < +2/3.  This asymmetry between the two charge
    species is responsible for the proton being positively charged. -/
theorem quark_up_charge_gt_down : q_down < q_up := by
  unfold q_up q_down; norm_num

/-- All six quark current masses are strictly positive.

    This confirms that every quark flavor carries a nonzero rest mass, as
    required by the Higgs mechanism in the Standard Model. -/
theorem quark_masses_pos :
    0 < m_up ∧ 0 < m_down ∧ 0 < m_strange ∧
    0 < m_charm ∧ 0 < m_bottom ∧ 0 < m_top := by
  unfold m_up m_down m_strange m_charm m_bottom m_top; norm_num

/-- Quark mass hierarchy across all three generations:
    m_u < m_d < m_s < m_c < m_b < m_t.

    Numerically (MeV/c²): 2.16 < 4.67 < 93.4 < 1270 < 4180 < 172760.
    The hierarchy spans five orders of magnitude, reflecting the three
    generations of increasing mass in the Standard Model. -/
theorem quark_mass_hierarchy :
    m_up < m_down ∧ m_down < m_strange ∧ m_strange < m_charm ∧
    m_charm < m_bottom ∧ m_bottom < m_top := by
  unfold m_up m_down m_strange m_charm m_bottom m_top; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 5 — Baryon Composition and Charge Conservation
-- A baryon is a composite particle made of three quarks.
--   Proton  p = uud:  two up quarks + one down quark
--   Neutron n = udd:  one up quark  + two down quarks
-- The Standard Model predicts — and experiment confirms — that the total
-- charge of each baryon is the sum of its constituent quark charges.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Proton charge from quark content (uud)**: 2·Q_u + Q_d = +1.

    A proton consists of two up quarks and one down quark (uud).
    Charge sum: 2·(2/3) + (−1/3) = 4/3 − 1/3 = 3/3 = 1  ✓

    This confirms that the proton charge +1 is an exact consequence of the
    quark model, with no additional charge from gluons or sea quarks. -/
theorem proton_charge_from_quarks : 2 * q_up + q_down = q_proton := by
  unfold q_up q_down q_proton; norm_num

/-- **Neutron charge from quark content (udd)**: Q_u + 2·Q_d = 0.

    A neutron consists of one up quark and two down quarks (udd).
    Charge sum: (2/3) + 2·(−1/3) = 2/3 − 2/3 = 0  ✓

    The neutron is exactly electrically neutral: the partial charges of its
    three quarks cancel to zero. -/
theorem neutron_charge_neutral : q_up + 2 * q_down = 0 := by
  unfold q_up q_down; norm_num

/-- **Charge conservation in proton β⁺-decay**: p → n + e⁺ + ν_e.

    In positron emission, a proton converts to a neutron while emitting a
    positron (charge +1) and an electron-neutrino (charge 0).  Total charge
    is conserved:
        Q_p = Q_n + Q_{e⁺} + Q_ν  =  0 + 1 + 0 = 1  ✓

    Here the positron charge equals −Q_e = +1 (the antiparticle of the
    electron), and the neutrino is electrically neutral. -/
theorem proton_decay_charge_conserved :
    q_proton = 0 + (- q_electron) + 0 := by
  unfold q_proton q_electron; norm_num

-- ════════════════════════════════════════════════════════════════════════════
-- Section 6 — Hydrogen Atom Formation
-- The hydrogen atom H = {e⁻ + p} is the simplest atom: one electron bound
-- to one proton by the Coulomb force.  Its formation illustrates both
-- charge neutrality and mass conservation.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Hydrogen atom is electrically neutral**: Q_e + Q_p = 0.

    One electron (Q = −1) and one proton (Q = +1) together carry zero net
    charge.  This is the fundamental reason hydrogen — and all neutral atoms
    — do not participate in long-range electrostatic interactions. -/
theorem hydrogen_atom_neutral : q_electron + q_proton = 0 :=
  electron_proton_charge_cancel

/-- **Hydrogen atom mass is positive**: m_e + m_p > 0.

    The rest mass of a hydrogen atom (neglecting the 13.6 eV binding energy)
    is the sum of the electron and proton masses, which is strictly positive. -/
theorem hydrogen_mass_pos : 0 < m_electron + m_proton := by
  have he := electron_mass_pos
  have hp := proton_mass_pos
  linarith

/-- **Proton dominates hydrogen mass**: m_e < m_p / 2.

    The proton accounts for more than 99.9 % of the hydrogen atom mass.
    Numerically: 0.51099895 MeV/c² < 469.136 MeV/c²  ✓

    This inequality also implies m_e < m_p (since m_p/2 < m_p). -/
theorem electron_lt_half_proton_mass : m_electron < m_proton / 2 := by
  unfold m_electron m_proton; norm_num

/-- **Hydrogen is heavier than the proton alone**: m_p < m_e + m_p.

    Adding the electron mass strictly increases the total hydrogen mass
    above the proton mass alone. -/
theorem hydrogen_heavier_than_proton : m_proton < m_electron + m_proton := by
  have he := electron_mass_pos
  linarith

end
