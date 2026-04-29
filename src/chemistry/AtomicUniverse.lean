/-
  src/chemistry/AtomicUniverse.lean — NIST-validated chemistry formalizations.

  This module collects the Lean proofs for chemical and coherence-dynamics
  results that anchor Eigenverse to empirical measurement:

    • Atomic structure   NIST 2016 standard atomic weights for H, He, C, N, O;
                         isotopic abundances; weighted-average mass formula.
    • Ohm–coherence      G · R = 1 duality; parallel/series coherence laws;
                         sech coherence at triality scales; OhmTriality 24 thms.
    • Organic chemistry  Complete bond dissociation hierarchy for 8 common covalent
                         bond types (C-N < C-C < C-O < C-H < O-H < C=C < C=O < C≡C);
                         OrganicDissociation 22 theorems.
    • Molecular geometry Bond length ordering (C≡C < C=C < C-C); VSEPR bond angle
                         ordering; explicit 3D bond vectors for CH₄ (tetrahedral,
                         cos θ = −1/3), HC≡CH (linear, cos θ = −1), and sp²
                         trigonal planar geometry; MolecularGeometry 26 theorems.

  Sources (all proofs in formal-lean/, 0 sorry each)
  ────────────────────────────────────────────────────
  formal-lean/Chemistry.lean           (20 theorems)
  formal-lean/OhmTriality.lean         (24 theorems)
  formal-lean/OrganicDissociation.lean (22 theorems)
  formal-lean/MolecularGeometry.lean   (26 theorems)

  Usage
  ─────
      import Eigenverse.Chemistry.AtomicUniverse
-/

import FormalLean.Chemistry
import FormalLean.OhmTriality
import FormalLean.OrganicDissociation
import FormalLean.MolecularGeometry
