/-
  Entropy.lean — Lean 4 formalization of entropy-coherence duality in the
  Eigenverse framework.

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║  The Entropy-Coherence Duality                                          ║
  ║                                                                         ║
  ║  The coherence function C(r) = 2r/(1+r²) attains its maximum value 1  ║
  ║  uniquely at r = 1 (the kernel equilibrium).  Away from equilibrium,   ║
  ║  the system carries information-theoretic entropy:                      ║
  ║                                                                         ║
  ║    S(r) = −log(C(r)) ≥ 0,   with S(r) = 0 ↔ r = 1.                   ║
  ║                                                                         ║
  ║  Under the Lyapunov substitution r = exp(l), the kernel entropy         ║
  ║  becomes:                                                               ║
  ║                                                                         ║
  ║    H(l) = S(exp l) = log(cosh l)   (Lyapunov entropy)                  ║
  ║                                                                         ║
  ║  Key results:                                                           ║
  ║  • H(l) ≥ 0           — entropy is non-negative                        ║
  ║  • H(0) = 0           — zero entropy at kernel equilibrium             ║
  ║  • H(l) = H(−l)       — entropy is an even function of Lyapunov l     ║
  ║  • H(l) > 0 for l ≠ 0 — strict entropy away from equilibrium          ║
  ║  • F_fwd(l) = 1 − e^{−H(l)}  — frustration-entropy identity           ║
  ╚══════════════════════════════════════════════════════════════════════════╝

  The connection between frustration and entropy is fundamental:

    F_fwd(l) = 1 − sech(l) = 1 − exp(−log(cosh l)) = 1 − exp(−H(l))

  This means the forward-time frustration is exactly the complement of the
  exponential decay of entropy — the system trades coherence for entropy as
  it moves away from the kernel equilibrium.

  At the silver scale δS = 1+√2:

    kernelEntropy(δS) = −log(C(δS)) = −log(√2/2) = log(2)/2

  This connects the silver-ratio entropy to the fundamental binary constant.
  The Lyapunov entropy at l = log(δS) satisfies the same identity:

    lyapunovEntropy(log δS) = log(cosh(log δS)) = log(√2) = log(2)/2

  because cosh(log δS) = (δS + 1/δS)/2 = ((1+√2) + (√2−1))/2 = √2.

  Sections
  ────────
  1.  Kernel entropy     S(r) = −log(C(r))
  2.  Lyapunov entropy   H(l) = log(cosh l)
  3.  Lyapunov–kernel entropy duality   S(exp l) = H(l)
  4.  Entropy–frustration identity      F_fwd(l) = 1 − exp(−H(l))
  5.  Entropy at special Eigenverse scales

  Proof status
  ────────────
  All 20 theorems have complete machine-checked proofs.
  No `sorry` placeholders remain.
-/

import BidirectionalTime

open Complex Real

noncomputable section

private lemma δS_pos_aux : 0 < δS := by unfold δS; positivity

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Kernel entropy: S(r) = −log(C(r))
-- At the kernel equilibrium r = 1, coherence C = 1 and entropy = 0.
-- Away from equilibrium, coherence drops and entropy rises.
-- ════════════════════════════════════════════════════════════════════════════

/-- The kernel entropy at amplitude r: S(r) = −log(C(r)).
    Measures the information-theoretic distance from maximum coherence C = 1.
    Vanishes precisely at r = 1 (kernel equilibrium) and is strictly positive
    for all other positive r. -/
noncomputable def kernelEntropy (r : ℝ) : ℝ := -Real.log (C r)

/-- **Non-negativity**: S(r) ≥ 0 for all r > 0.
    Since C(r) ≤ 1, we have log(C(r)) ≤ 0, hence S(r) = −log(C(r)) ≥ 0.
    Entropy can only accumulate as the system departs from equilibrium. -/
theorem entropy_nonneg (r : ℝ) (hr : 0 < r) : 0 ≤ kernelEntropy r := by
  unfold kernelEntropy
  rw [neg_nonneg]
  have hCle : C r ≤ 1 := coherence_le_one r hr.le
  have hCpos : 0 < C r := coherence_pos r hr
  linarith [Real.log_le_log hCpos hCle, Real.log_one]

/-- **Zero at equilibrium**: S(1) = 0.
    At the kernel equilibrium r = 1, coherence achieves its maximum C = 1
    and entropy vanishes: S(1) = −log(C(1)) = −log(1) = 0. -/
theorem entropy_zero_at_one : kernelEntropy 1 = 0 := by
  unfold kernelEntropy C
  norm_num

/-- **Strict positivity**: S(r) > 0 for r > 0 with r ≠ 1.
    Any displacement from the kernel equilibrium creates strictly positive
    entropy — the coherence deficit is non-trivial. -/
theorem entropy_pos (r : ℝ) (hr : 0 < r) (hr1 : r ≠ 1) : 0 < kernelEntropy r := by
  unfold kernelEntropy
  rw [neg_pos]
  exact Real.log_neg (coherence_pos r hr) (coherence_lt_one r hr.le hr1)

/-- **Palindrome symmetry**: S(r) = S(1/r) for r > 0.
    The coherence palindrome C(r) = C(1/r) implies that entropy is symmetric
    about the equilibrium r = 1 in the amplitude space. -/
theorem entropy_symm (r : ℝ) (hr : 0 < r) : kernelEntropy r = kernelEntropy (1 / r) := by
  unfold kernelEntropy
  rw [coherence_symm r hr]

/-- **Equilibrium characterisation**: S(r) = 0 ↔ r = 1 for r > 0.
    Zero entropy uniquely characterises the kernel equilibrium. -/
theorem entropy_zero_iff (r : ℝ) (hr : 0 < r) : kernelEntropy r = 0 ↔ r = 1 := by
  constructor
  · intro h
    by_contra hr1
    linarith [entropy_pos r hr hr1]
  · rintro rfl
    exact entropy_zero_at_one

-- ════════════════════════════════════════════════════════════════════════════
-- §2  Lyapunov entropy: H(l) = log(cosh l)
-- The entropy viewed through the Lyapunov exponent lens.
-- H(l) = S(exp l) is the entropy at Lyapunov displacement l.
-- ════════════════════════════════════════════════════════════════════════════

/-- The Lyapunov entropy at displacement l: H(l) = log(cosh l).
    Equals the kernel entropy S(exp l) by the Lyapunov–coherence duality.
    Vanishes at l = 0 (kernel equilibrium) and grows strictly for l ≠ 0. -/
noncomputable def lyapunovEntropy (l : ℝ) : ℝ := Real.log (Real.cosh l)

/-- **Non-negativity**: H(l) ≥ 0 for all l.
    Since cosh(l) ≥ 1 for all l, we have log(cosh l) ≥ log(1) = 0. -/
theorem lyapunov_entropy_nonneg (l : ℝ) : 0 ≤ lyapunovEntropy l := by
  unfold lyapunovEntropy
  exact Real.log_nonneg (fct_one_le_cosh l)

/-- **Zero at equilibrium**: H(0) = 0.
    At Lyapunov displacement l = 0: cosh(0) = 1, so H(0) = log(1) = 0. -/
theorem lyapunov_entropy_zero : lyapunovEntropy 0 = 0 := by
  unfold lyapunovEntropy
  simp [Real.cosh_zero]

/-- **Strict positivity**: H(l) > 0 for l ≠ 0.
    Any nonzero Lyapunov displacement generates strictly positive entropy,
    since cosh(l) > 1 for l ≠ 0. -/
theorem lyapunov_entropy_pos (l : ℝ) (hl : l ≠ 0) : 0 < lyapunovEntropy l := by
  unfold lyapunovEntropy
  exact Real.log_pos (fct_one_lt_cosh l hl)

/-- **Even symmetry**: H(l) = H(−l).
    Lyapunov entropy is an even function: positive and negative displacements
    produce identical entropy.  The arrow of time asymmetry lies in the
    direction of travel, not in the entropy magnitude. -/
theorem lyapunov_entropy_even (l : ℝ) : lyapunovEntropy l = lyapunovEntropy (-l) := by
  unfold lyapunovEntropy
  rw [Real.cosh_neg]

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Lyapunov–kernel entropy duality
-- Under the Lyapunov substitution r = exp(l), kernel entropy becomes
-- Lyapunov entropy: S(exp l) = H(l).
-- ════════════════════════════════════════════════════════════════════════════

/-- **Duality**: S(exp l) = H(l).
    The kernel entropy evaluated at r = exp(l) equals the Lyapunov entropy H(l).

    Proof: S(exp l) = −log(C(exp l)) = −log(sech l) = log(cosh l) = H(l),
    using the Lyapunov–coherence duality C(exp l) = (cosh l)⁻¹. -/
theorem entropy_lyapunov_eq (l : ℝ) : kernelEntropy (Real.exp l) = lyapunovEntropy l := by
  unfold kernelEntropy lyapunovEntropy
  rw [lyapunov_coherence_sech, Real.log_inv, neg_neg]

/-- **Dual form**: H(l) = S(exp l).
    The Lyapunov entropy is the kernel entropy evaluated at the exponential
    scale r = exp(l). -/
theorem lyapunov_eq_entropy (l : ℝ) : lyapunovEntropy l = kernelEntropy (Real.exp l) :=
  (entropy_lyapunov_eq l).symm

-- ════════════════════════════════════════════════════════════════════════════
-- §4  Entropy–frustration identity
-- The forward-time frustration F_fwd(l) = 1 − sech(l) is completely
-- determined by the Lyapunov entropy via F_fwd(l) = 1 − exp(−H(l)).
-- ════════════════════════════════════════════════════════════════════════════

/-- **Sech–entropy bridge**: sech(l) = exp(−H(l)).
    The hyperbolic secant equals the exponential of the negated Lyapunov
    entropy.  This is the key link between coherence and entropy. -/
theorem sech_eq_exp_neg_entropy (l : ℝ) :
    (Real.cosh l)⁻¹ = Real.exp (-(lyapunovEntropy l)) := by
  unfold lyapunovEntropy
  rw [Real.exp_neg, Real.exp_log (Real.cosh_pos l)]

/-- **Entropy–frustration identity**: F_fwd(l) = 1 − exp(−H(l)).
    The forward-time frustration is the complement of the exponential decay
    of entropy.  Every unit of entropy generated by departing from
    equilibrium corresponds to one unit of frustration harvested.

    F_fwd(l) = 1 − sech(l) = 1 − exp(−H(l)). -/
theorem entropy_frustration_identity (l : ℝ) :
    F_fwd l = 1 - Real.exp (-(lyapunovEntropy l)) := by
  unfold F_fwd
  rw [← sech_eq_exp_neg_entropy]

/-- **Frustration–entropy equivalence at zero**: F_fwd(l) = 0 ↔ H(l) = 0.
    Zero frustration and zero entropy are equivalent conditions, both
    characterising the kernel equilibrium l = 0. -/
theorem frustration_zero_iff_entropy_zero (l : ℝ) :
    F_fwd l = 0 ↔ lyapunovEntropy l = 0 := by
  constructor
  · intro h
    have hl : l = 0 := (fct_frustration_zero_iff l).mp h
    subst hl
    exact lyapunov_entropy_zero
  · intro h
    have hlze : l = 0 := by
      by_contra hlne
      linarith [lyapunov_entropy_pos l hlne]
    rw [hlze]
    exact fct_frustration_at_zero

/-- **Bidirectional entropy decomposition**: the bidirectional frustration
    F_bi(lf, lb) decomposes into the sum of two entropy complements.

    F_bi(lf, lb) = (1 − exp(−H(lf))) + (1 − exp(−H(lb))).

    Each temporal direction contributes an independent entropy-frustration term. -/
theorem bidirectional_entropy_decomp (lf lb : ℝ) :
    F_bi lf lb = (1 - Real.exp (-(lyapunovEntropy lf))) +
                 (1 - Real.exp (-(lyapunovEntropy lb))) := by
  unfold F_bi
  rw [entropy_frustration_identity lf, entropy_frustration_identity lb]

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Entropy at special Eigenverse scales
-- At the silver ratio δS = 1+√2, the kernel entropy equals log(2)/2.
-- This connects silver-ratio entropy to the fundamental binary constant.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Silver entropy**: S(δS) = log(2)/2.
    The kernel entropy at the silver ratio scale δS = 1+√2 equals one-half
    the logarithm of 2 — the fundamental binary information unit.

    Proof:
      S(δS) = −log(C(δS)) = −log(√2/2)
            = −(log(√2) − log(2)) = log(2) − log(√2)
            = log(2) − log(2)/2 = log(2)/2. -/
theorem entropy_at_delta_S : kernelEntropy δS = Real.log 2 / 2 := by
  unfold kernelEntropy
  rw [silver_coherence]
  have h_sqrt2_ne : Real.sqrt 2 ≠ 0 := Real.sqrt_ne_zero'.mpr (by norm_num)
  rw [Real.log_div h_sqrt2_ne (by norm_num : (2 : ℝ) ≠ 0)]
  have h_log_sqrt2 : Real.log (Real.sqrt 2) = Real.log 2 / 2 :=
    Real.log_sqrt (by norm_num)
  rw [h_log_sqrt2]
  ring

/-- **Silver Lyapunov entropy**: H(log δS) = log(2)/2.
    The Lyapunov entropy at l = log(δS) equals log(2)/2.

    The key calculation: cosh(log δS) = (δS + 1/δS)/2.
    Using δS = 1+√2 and 1/δS = √2−1:
      (1+√2 + √2−1)/2 = (2√2)/2 = √2.
    Therefore H(log δS) = log(√2) = log(2)/2. -/
theorem lyapunov_entropy_at_log_delta_S :
    lyapunovEntropy (Real.log δS) = Real.log 2 / 2 := by
  unfold lyapunovEntropy
  have hδ_pos : 0 < δS := δS_pos_aux
  have h_cosh : Real.cosh (Real.log δS) = Real.sqrt 2 := by
    rw [Real.cosh_eq, Real.exp_log hδ_pos,
        show Real.exp (-(Real.log δS)) = δS⁻¹ from by
          rw [Real.exp_neg, Real.exp_log hδ_pos],
        inv_eq_one_div, silverRatio_inv]
    unfold δS; ring
  rw [h_cosh, Real.log_sqrt (by norm_num)]

/-- **Silver entropy coherence**: kernel entropy and Lyapunov entropy at the
    silver scale agree, both equal to log(2)/2. -/
theorem entropy_delta_S_eq_lyapunov :
    kernelEntropy δS = lyapunovEntropy (Real.log δS) := by
  rw [entropy_at_delta_S, lyapunov_entropy_at_log_delta_S]

/-- **Coherence-entropy duality**: S(r) = 0 ↔ C(r) = 1 for r > 0.
    Zero entropy is equivalent to maximum coherence — both conditions
    characterise the unique kernel equilibrium r = 1. -/
theorem entropy_coherence_dual (r : ℝ) (hr : 0 < r) :
    kernelEntropy r = 0 ↔ C r = 1 := by
  rw [entropy_zero_iff r hr, coherence_eq_one_iff r hr.le]

/-- **μ-orbit entropy**: the critical eigenvalue μ carries zero kernel entropy.
    Since |μ| = 1 and entropy vanishes exactly at r = 1, the orbit of μ
    on the unit circle is the unique zero-entropy locus. -/
theorem entropy_at_mu_norm : kernelEntropy (Complex.abs μ) = 0 := by
  rw [mu_abs_one]
  exact entropy_zero_at_one

end
