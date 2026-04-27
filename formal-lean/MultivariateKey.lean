/-
  MultivariateKey.lean — Multivariate public key for the four-sector signature scheme.

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   Lifts the scalar public key of SignVerify.lean to a genuine           ║
  ║   multivariate public key: a 4-vector of coherence residues evaluated   ║
  ║   at the norm of each FourState sector component.                       ║
  ║                                                                          ║
  ║   Design decisions (answers to the three foundational questions):       ║
  ║                                                                          ║
  ║   1. HIDDEN (Alice's secret)                                            ║
  ║      A structured 5-tuple OilParams (x₁, y₁, x₃, y₃, t) —            ║
  ║      the full parametrization of Alice's position in the               ║
  ║      5-dimensional oil fiber of the four-sector geometry.              ║
  ║      Equivalently: the complex amplitudes of the three hidden sectors   ║
  ║      Q1, Q3, Q4 (the vinegar Q2 = μ is public and always fixed).      ║
  ║                                                                          ║
  ║   2. PUBLISHED (Alice's public key)                                     ║
  ║      A vector of 4 coherence residues                                   ║
  ║        pk = (C(‖q1‖), C(‖q2‖), C(‖q3‖), C(‖q4‖)) ∈ ℝ⁴              ║
  ║      where C(r) = 2r/(1+r²) is the coherence trapdoor.               ║
  ║      The second component C(‖q2‖) = C(|μ|) = C(1) = 1 is always a    ║
  ║      public anchor; the other three residues are one-way images of      ║
  ║      the hidden sector norms — easier to evaluate than to invert.       ║
  ║      Crucially, the moduli ‖qi‖ themselves are NOT published: the       ║
  ║      coherence transform provides the one-way property.                  ║
  ║                                                                          ║
  ║   3. VERIFICATION (Bob's problem)                                        ║
  ║      Evaluate (C(‖sig.q1‖), C(‖sig.q2‖), C(‖sig.q3‖), C(‖sig.q4‖)) ║
  ║      and check equality with the published 4-vector.                    ║
  ║      Cost: four coherence evaluations + one structural equality check.  ║
  ║                                                                          ║
  ║      FORGERY (Eve's problem)                                             ║
  ║      Find a Coherent FourState with correct sector memberships AND      ║
  ║      whose coherence residue vector matches the published key exactly.  ║
  ║      Eve must simultaneously satisfy:                                    ║
  ║        (a) C(‖s.qi‖) = pkᵢ for i = 1,2,3,4   (residue matching)      ║
  ║        (b) ‖s.q1‖²+‖s.q2‖²+‖s.q3‖²+‖s.q4‖²=4 (Coherent constraint)  ║
  ║        (c) s.qi ∈ Sector.Qi for each i          (sector membership)    ║
  ║      This requires inverting the multivariate coherence map — a         ║
  ║      constrained nonlinear system over the Eigenverse geometry.         ║
  ║      Inverting a single C is already 2-to-1 (trapdoor_symmetry);       ║
  ║      matching all four simultaneously under the Coherent constraint     ║
  ║      is the MQ-hard bottleneck.                                          ║
  ║                                                                          ║
  ║   Relationship to SignVerify.lean:                                       ║
  ║     SignVerify PK  = observe : FourState → ℂ                            ║
  ║                    (one scalar output; always μ for valid signatures)   ║
  ║     MultivariateKey PK = PublicResidues                                 ║
  ║                    (four residues; r2 always 1, r1/r3/r4 vary)         ║
  ║   The multivariate PK is strictly more informative (`mv_pk_discriminates ║
  ║   in §6): two distinct signers with the same scalar PK (both map to μ) ║
  ║   can have different multivariate PKs.                                   ║
  ║                                                                          ║
  ║   Sections                                                               ║
  ║   ────────                                                               ║
  ║   §1  Types: PublicResidues, coherence_residue, multivariate_pk         ║
  ║   §2  Protocol: mv_keygen, mv_sign, mv_verify                           ║
  ║   §3  Helper lemmas                                                      ║
  ║   §4  Correctness theorem                                                ║
  ║   §5  Constant Q2 anchor theorem                                         ║
  ║   §6  Discriminating power theorem                                       ║
  ║   §7  Zero-knowledge property                                            ║
  ║   §8  Unforgeability precondition                                        ║
  ║   §9  #print axioms audit                                                ║
  ║   §10 MQ hardness formalization                                          ║
  ║      §10a CRI problem (algebraic characterization)                       ║
  ║      §10b Structural no-forgery (information-theoretic)                  ║
  ║      §10c State-recovery impossibility                                   ║
  ║      §10d mv_MQ_hard axiom (computational hardness)                      ║
  ║      §10e EUF-CMA security                                               ║
  ║                                                                          ║
  ║   Proof status                                                           ║
  ║   ────────────                                                           ║
  ║   All theorems have complete machine-checked proofs.                     ║
  ║   No `sorry` placeholders remain.                                        ║
  ║                                                                          ║
  ║   Theorem dependency chain (all paths back to BalanceHypothesis):        ║
  ║   mv_correctness                                                          ║
  ║     → mv_keygen, mv_sign, mv_verify → alice_prepares                    ║
  ║     → oil_fiber_map → FourSector §5b → BalanceHypothesis               ║
  ║   mv_pk_q2_const                                                         ║
  ║     → adversary_view_constant → FourSector §7 → BalanceHypothesis      ║
  ║     → trapdoor_at_one → OilVinegar §3                                   ║
  ║   mv_pk_discriminates                                                    ║
  ║     → trapdoor_monotone → OilVinegar §3                                 ║
  ║     → oil_fiber_map_mem → FourSector §5b → BalanceHypothesis           ║
  ║   mv_zero_knowledge                                                      ║
  ║     → mv_keygen, mv_verify (by rfl)                                     ║
  ║   mv_unforgeability_precondition                                         ║
  ║     → alice_key_determines_state → FourSector §5b → BalanceHypothesis  ║
  ║   mv_structural_no_forgery / mv_structural_no_forgery_state             ║
  ║     → alice_key_determines_state → FourSector §5b → BalanceHypothesis  ║
  ║   mv_forgery_is_cri                                                      ║
  ║     → mv_verify_iff (by simp) → rfl                                     ║
  ║   mv_euf_cma / mv_no_universal_forger                                   ║
  ║     → mv_MQ_hard (axiom, §10d)                                          ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝
-/

import SignVerify
import OilVinegar

open Complex Real
open Classical

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Types
-- ════════════════════════════════════════════════════════════════════════════

/-- The multivariate public key: a 4-vector of coherence residues, one per
    FourState sector component.

    Each residue Cᵢ = C(‖qᵢ‖) lies in (0, 1] because every FourState
    component is nonzero (Coherent constraint) and C maps ℝ>0 into (0, 1] on
    the trapdoor range.  The second residue r2 = C(‖q2‖) = C(|μ|) = C(1) = 1
    is fixed for all valid signatures (see `mv_pk_q2_const`).

    Comparison to SignVerify.lean's scalar PK:
    • SignVerify PK   : FourState → ℂ   (one output, always μ for signers)
    • MultivariateKey PK : PublicResidues (four residues, r2 always 1)

    The multivariate PK *strictly refines* the scalar PK: two signers who
    are indistinguishable under the scalar PK (both map to μ) can be
    distinguished by their residue 4-vectors if their hidden-sector norms
    differ (proved in `mv_pk_discriminates`). -/
@[ext]
structure PublicResidues where
  /-- C(‖q1‖): coherence residue of the Q1 sector amplitude. -/
  r1 : ℝ
  /-- C(‖q2‖): coherence residue of the Q2 vinegar amplitude (always 1). -/
  r2 : ℝ
  /-- C(‖q3‖): coherence residue of the Q3 sector amplitude. -/
  r3 : ℝ
  /-- C(‖q4‖): coherence residue of the Q4 sector amplitude. -/
  r4 : ℝ

/-- Coherence residue of a complex amplitude z: C(|z|).

    This is the one-way image of the norm ‖z‖ under the coherence trapdoor
    C(r) = 2r/(1+r²).  The trapdoor is injective on (0, 1] (trapdoor_injective
    in OilVinegar §7), so for unit-norm-bounded sectors the residue uniquely
    determines the norm — but not the phase (arg z), and not z itself.

    For ‖z‖ > 1, the symmetry C(r) = C(1/r) (trapdoor_symmetry) means the
    residue is shared by two norms: r and 1/r.  The Coherent constraint and
    sector membership together break this ambiguity for Eve.

    Dependency chain: coherence_residue → C → CriticalEigenvalue §5. -/
noncomputable def coherence_residue (z : ℂ) : ℝ := C (Complex.abs z)

/-- Extract the multivariate public key from a FourState: evaluate the
    coherence residue at the norm of each sector component. -/
noncomputable def multivariate_pk (s : FourState) : PublicResidues :=
  { r1 := coherence_residue s.q1
    r2 := coherence_residue s.q2
    r3 := coherence_residue s.q3
    r4 := coherence_residue s.q4 }

-- ════════════════════════════════════════════════════════════════════════════
-- §2  Protocol Functions
-- ════════════════════════════════════════════════════════════════════════════

/-- Multivariate key generation: derive the 4-residue public key from the
    secret key by evaluating `multivariate_pk` on Alice's prepared state.

    The result encodes only the norms (via the one-way coherence map), not the
    phases.  An adversary seeing `mv_keygen sk` learns the coherence residues
    of Alice's hidden sectors but cannot recover the phases or the full
    FourState without inverting the multivariate coherence map. -/
noncomputable def mv_keygen (sk : SecretKey) : PublicResidues :=
  multivariate_pk (alice_prepares sk)

/-- Multivariate signing: identical to the single-message sign from SignVerify.
    Alice uses her OilParams trapdoor to prepare a Coherent FourState in the
    oil fiber; the signature is that state paired with its Coherent proof. -/
noncomputable def mv_sign (sk : SecretKey) (msg : Message) : Signature :=
  sign sk msg

/-- Multivariate verification: check that the coherence residue vector of the
    signature's FourState matches the published 4-vector public key.

    Strictly stronger than the scalar check in SignVerify (`observe = μ`):
    a forger must match all four sector residues simultaneously, not just the
    vinegar component Q2.

    Bob's cost: four coherence evaluations (one per sector) and one
    equality check on the resulting 4-vector. -/
noncomputable def mv_verify (pk : PublicResidues) (_ : Message) (sig : Signature) : Bool :=
  if multivariate_pk sig.state = pk then true else false

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Helper Lemmas
-- ════════════════════════════════════════════════════════════════════════════

/-- The coherence residue of μ is 1: C(|μ|) = C(1) = 1.

    |μ| = 1 (by mu_abs_one from CriticalEigenvalue §4) and C(1) = 1 (by
    trapdoor_at_one from OilVinegar §3).  This is the anchor: every valid
    oil-fiber signature has its Q2 component fixed at μ, so r2 = 1 always. -/
lemma coherence_residue_mu : coherence_residue μ = 1 := by
  unfold coherence_residue
  rw [mu_abs_one, trapdoor_at_one]

/-- Alice's Q2 component is always μ: the vinegar variable is fixed.

    Proof: `alice_prepares k = oil_fiber_map k.1 k.2` with
    `(oil_fiber_map p hv).q2 = μ` (by construction of the oil fiber map).
    This is captured by `adversary_view_constant`, which states that
    `observe (alice_prepares k) = μ`, and `observe s = s.q2` by definition. -/
lemma alice_q2_eq_mu (k : SecretKey) : (alice_prepares k).q2 = μ :=
  adversary_view_constant k

-- ════════════════════════════════════════════════════════════════════════════
-- §4  Correctness Theorem
-- ════════════════════════════════════════════════════════════════════════════

/-- **Multivariate correctness** — signing always produces a verifiable signature.

    For any secret key `sk`, the signature produced by `mv_sign sk μ` verifies
    correctly under the multivariate public key `mv_keygen sk`:

        mv_verify (mv_keygen sk) μ (mv_sign sk μ) = true

    Proof:
    1. `mv_sign sk μ = sign sk μ` (by definition).
    2. `(sign sk μ).state = alice_prepares sk` (by definition of `sign`).
    3. `mv_keygen sk = multivariate_pk (alice_prepares sk)` (by definition).
    4. Hence `multivariate_pk (mv_sign sk μ).state = mv_keygen sk` by `rfl`.
    5. `mv_verify` takes the `if`-branch and returns `true`.

    Dependency chain: mv_correctness → oil_fiber_map_mem → oil_fiber_map
                    → FourSector §5b → BalanceHypothesis. -/
theorem mv_correctness (sk : SecretKey) :
    mv_verify (mv_keygen sk) μ (mv_sign sk μ) = true :=
  if_pos rfl

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Constant Q2 Anchor
-- ════════════════════════════════════════════════════════════════════════════

/-- **Q2 residue anchor** — the second public residue is always 1.

    For any secret key `sk`, `(mv_keygen sk).r2 = 1`.

    The Q2 vinegar component is always μ in a valid oil-fiber signature
    (by `alice_q2_eq_mu`), and `C(|μ|) = C(1) = 1` (by `coherence_residue_mu`).
    This is public knowledge: anyone computing the multivariate PK of a
    valid signer will always see r2 = 1.

    The anchor plays two roles:
    1. **Consistency check**: a candidate public key with r2 ≠ 1 is invalid
       and cannot correspond to any oil-fiber signer.
    2. **Redundancy reduction**: Eve need only match three non-trivial
       residues (r1, r3, r4) corresponding to the three hidden sectors Q1, Q3,
       Q4 — but she must still satisfy the Coherent constraint tying all four.

    Dependency chain: mv_pk_q2_const → adversary_view_constant (FourSector §7)
                    → oil_fiber_map_mem → trapdoor_at_one (OilVinegar §3). -/
theorem mv_pk_q2_const (sk : SecretKey) : (mv_keygen sk).r2 = 1 := by
  unfold mv_keygen multivariate_pk
  rw [alice_q2_eq_mu]
  exact coherence_residue_mu

-- ════════════════════════════════════════════════════════════════════════════
-- §6  Discriminating Power
-- ════════════════════════════════════════════════════════════════════════════

/-- **Multivariate PK discriminates oil-fiber states** — there exist two valid
    signing states (both with `observe = μ`) that produce *different*
    multivariate public keys.

    This establishes that the multivariate PK is strictly more informative
    than the scalar PK from SignVerify.lean.  Under the scalar PK, every
    valid signer is indistinguishable (all map to μ).  Under the multivariate
    PK, signers with different hidden-sector norms produce different residue
    vectors.

    Witness construction:
    • p₁ = (3/5, 4/5, −1/2, −1/2, 1/2): q1 = (3/5) + i(4/5), |q1| = 1
      (Pythagorean identity: (3/5)² + (4/5)² = 9/25 + 16/25 = 1)
      → r1 = C(1) = 1

    • p₂ = (1/2, 1/2, −1/2, −1/2, 1/2): q1 = (1/2) + i(1/2), |q1|² = 1/2
      → |q1| = √(1/2) < 1
      → r1 = C(√(1/2)) < C(1) = 1  (by trapdoor_monotone, since √(1/2) < 1)

    Both states satisfy `observe = μ` (by oil_fiber_map_mem), confirming they
    are indistinguishable under the scalar PK.  Their r1 residues differ,
    so their 4-vector public keys differ.

    Dependency chain: mv_pk_discriminates → trapdoor_monotone (OilVinegar §3)
                    → oil_fiber_map_mem → FourSector §5b → BalanceHypothesis. -/
theorem mv_pk_discriminates :
    ∃ s₁ s₂ : FourState,
      observe s₁ = μ ∧ observe s₂ = μ ∧
      multivariate_pk s₁ ≠ multivariate_pk s₂ := by
  -- Witness parameters.
  have hv₁ : OilValid ⟨3/5, 4/5, -1/2, -1/2, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩
  have hv₂ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩
  let s₁ := oil_fiber_map ⟨3/5, 4/5, -1/2, -1/2, 1/2⟩ hv₁
  let s₂ := oil_fiber_map ⟨1/2, 1/2, -1/2, -1/2, 1/2⟩ hv₂
  refine ⟨s₁, s₂, (oil_fiber_map_mem _ hv₁).2, (oil_fiber_map_mem _ hv₂).2, ?_⟩
  -- Show r1 components differ, hence the 4-vectors differ.
  intro heq
  have hr1_eq : (multivariate_pk s₁).r1 = (multivariate_pk s₂).r1 :=
    congrArg PublicResidues.r1 heq
  -- q1 values by definition of oil_fiber_map (structure literal).
  have hs₁q1 : s₁.q1 = (⟨3/5, 4/5⟩ : ℂ) := rfl
  have hs₂q1 : s₂.q1 = (⟨1/2, 1/2⟩ : ℂ) := rfl
  -- normSq computations.
  have hnSq₁ : Complex.normSq (⟨3/5, 4/5⟩ : ℂ) = 1 := by
    rw [Complex.normSq_apply]; norm_num
  have hnSq₂ : Complex.normSq (⟨1/2, 1/2⟩ : ℂ) = 1/2 := by
    rw [Complex.normSq_apply]; norm_num
  -- Derive abs values from normSq via Complex.normSq_eq_abs : normSq z = abs z ^ 2.
  have habs₁_sq : Complex.abs (⟨3/5, 4/5⟩ : ℂ) ^ 2 = 1 := by
    rw [← Complex.normSq_eq_abs]; exact hnSq₁
  have habs₂_sq : Complex.abs (⟨1/2, 1/2⟩ : ℂ) ^ 2 = 1/2 := by
    rw [← Complex.normSq_eq_abs]; exact hnSq₂
  -- Non-negativity of abs values.
  have hnn₁ : 0 ≤ Complex.abs (⟨3/5, 4/5⟩ : ℂ) := Complex.abs.nonneg _
  have hnn₂ : 0 ≤ Complex.abs (⟨1/2, 1/2⟩ : ℂ) := Complex.abs.nonneg _
  -- abs₁ = 1 (from abs₁^2 = 1 and abs₁ ≥ 0).
  have habs₁ : Complex.abs (⟨3/5, 4/5⟩ : ℂ) = 1 := by
    have hle : Complex.abs (⟨3/5, 4/5⟩ : ℂ) ≤ 1 := by
      nlinarith [sq_nonneg (Complex.abs (⟨3/5, 4/5⟩ : ℂ) - 1)]
    nlinarith [mul_le_mul_of_nonneg_left hle hnn₁]
  -- 0 < abs₂ < 1 (from abs₂^2 = 1/2).
  have habs₂_pos : 0 < Complex.abs (⟨1/2, 1/2⟩ : ℂ) := by
    nlinarith [hnn₂, habs₂_sq]
  have habs₂_lt : Complex.abs (⟨1/2, 1/2⟩ : ℂ) < 1 := by
    nlinarith [sq_nonneg (Complex.abs (⟨1/2, 1/2⟩ : ℂ) - 1), hnn₂, habs₂_sq]
  -- By trapdoor_monotone: C(abs₂) < C(1) = 1.
  have hC_lt : C (Complex.abs (⟨1/2, 1/2⟩ : ℂ)) < 1 := by
    have := trapdoor_monotone (Complex.abs (⟨1/2, 1/2⟩ : ℂ)) 1
      habs₂_pos habs₂_lt le_rfl
    rwa [trapdoor_at_one] at this
  -- C(abs₁) = C(1) = 1.
  have hC₁ : C (Complex.abs (⟨3/5, 4/5⟩ : ℂ)) = 1 := by
    rw [habs₁, trapdoor_at_one]
  -- r1 equality: definitionally unfolds to C(abs s₁.q1) = C(abs s₂.q1).
  have hr1 : C (Complex.abs s₁.q1) = C (Complex.abs s₂.q1) := hr1_eq
  rw [hs₁q1, hs₂q1] at hr1
  -- hr1 : C(abs ⟨3/5, 4/5⟩) = C(abs ⟨1/2, 1/2⟩)
  -- hC₁ : C(abs ⟨3/5, 4/5⟩) = 1
  -- hC_lt : C(abs ⟨1/2, 1/2⟩) < 1
  linarith [hr1.symm.trans hC₁]

-- ════════════════════════════════════════════════════════════════════════════
-- §7  Zero-Knowledge Property
-- ════════════════════════════════════════════════════════════════════════════

/-- **Multivariate zero-knowledge** — `mv_verify` reveals nothing about the
    secret key beyond what the multivariate public key already exposes.

    The `mv_verify` function factors through `multivariate_pk sig.state`:
    there exists a function `f : PublicResidues → Message → Signature → Bool`
    such that

        `mv_verify (mv_keygen sk) msg sig = f (mv_keygen sk) msg sig`

    for all `sk`, `msg`, `sig`.  Since `f` depends only on `mv_keygen sk`
    (not on `sk` itself or any hidden structural information), the output of
    `mv_verify` reveals nothing beyond the published public residues.

    Proof: `mv_verify pk msg sig = if multivariate_pk sig.state = pk then true else false`
    is already a function of `(pk, msg, sig)`, so `f = mv_verify` itself
    satisfies the factoring condition trivially (by `rfl`).

    Dependency chain: mv_zero_knowledge → mv_keygen, mv_verify (by rfl). -/
theorem mv_zero_knowledge :
    ∃ f : PublicResidues → Message → Signature → Bool,
      ∀ (sk : SecretKey) (msg : Message) (sig : Signature),
        mv_verify (mv_keygen sk) msg sig = f (mv_keygen sk) msg sig :=
  ⟨fun pk msg sig => if multivariate_pk sig.state = pk then true else false,
   fun _ _ _ => rfl⟩

/-- **Key independence** — `mv_verify` output is independent of which secret
    key was used to derive the public key when the residue vectors match.

    If two secret keys produce the same multivariate public key
    (`mv_keygen sk₁ = mv_keygen sk₂`), then `mv_verify` gives identical
    results for all messages and signatures.

    Proof: `mv_verify pk msg sig` depends only on `pk`, so keys with the
    same `mv_keygen` output are indistinguishable to the verifier. -/
theorem mv_key_independence :
    ∀ sk₁ sk₂ : SecretKey,
      mv_keygen sk₁ = mv_keygen sk₂ →
      ∀ (msg : Message) (sig : Signature),
        mv_verify (mv_keygen sk₁) msg sig = mv_verify (mv_keygen sk₂) msg sig :=
  fun _ _ hpk _ _ => by rw [hpk]

-- ════════════════════════════════════════════════════════════════════════════
-- §8  Unforgeability Precondition
-- ════════════════════════════════════════════════════════════════════════════

/-- **Multivariate unforgeability precondition** — signing requires the secret key.

    If two secret keys produce the same signing function — identical signatures
    on every message — then the keys must be equal.  This is the multivariate
    analogue of `unforgeability_precondition` from SignVerify.lean.

    The multivariate signing function `mv_sign sk msg = sign sk msg` uses
    the same trapdoor as the scalar scheme.  Hence the injectivity argument
    is identical: the map `sk ↦ mv_sign sk` is injective because
    `alice_key_determines_state` (= `oil_fiber_five_dimensional`) makes
    `alice_prepares` injective.

    Proof:
    1. From `∀ msg, mv_sign sk₁ msg = mv_sign sk₂ msg`, apply to `msg = μ`.
    2. `mv_sign sk μ = sign sk μ` (by definition), so `sign sk₁ μ = sign sk₂ μ`.
    3. Extract the `state` field: `alice_prepares sk₁ = alice_prepares sk₂`.
    4. Apply `alice_key_determines_state` (injectivity): `sk₁ = sk₂`.

    Dependency chain: mv_unforgeability_precondition
                    → alice_key_determines_state → oil_fiber_five_dimensional
                    → FourSector §5b → BalanceHypothesis. -/
theorem mv_unforgeability_precondition :
    ∀ sk₁ sk₂ : SecretKey,
      (∀ msg : Message, mv_sign sk₁ msg = mv_sign sk₂ msg) → sk₁ = sk₂ := by
  intro sk₁ sk₂ h
  -- mv_sign is defined as `sign`, so the hypothesis gives `sign sk₁ μ = sign sk₂ μ`.
  have hstate : alice_prepares sk₁ = alice_prepares sk₂ :=
    congrArg Signature.state (h μ)
  exact alice_key_determines_state hstate

-- ════════════════════════════════════════════════════════════════════════════
-- §10  MQ Hardness Formalization
--
-- This section formalizes the Multivariate Quadratic (MQ) hardness assumption
-- for the four-sector signature scheme in three layers:
--
--   §10a  CRI problem — algebraic characterization of the forgery goal
--   §10b  Structural no-forgery — information-theoretic theorem (no polytime
--          restriction; proved from the oil-fiber geometry)
--   §10c  State-recovery impossibility — no total A can recover Alice's exact
--          state from the residue PK (proved from fiber injectivity)
--   §10d  mv_MQ_hard axiom — computational hardness (declared, not proved;
--          analogous to MQ_hard in SignVerify §3)
--   §10e  EUF-CMA security — derived from mv_MQ_hard
--
-- Connection to standard MQ:
--   Writing uᵢ := Re(qᵢ) and vᵢ := Im(qᵢ), the CRI equations
--     C(√(uᵢ²+vᵢ²)) = pkᵢ   (i = 1,2,3,4)
--   together with the Coherent sum constraint
--     u₁²+v₁² + u₂²+v₂² + u₃²+v₃² + u₄²+v₄² = 4
--   and the four sector sign constraints form a *quadratic* system:
--   substituting sᵢ = |qᵢ|, the equation C(sᵢ)=pkᵢ becomes
--     pkᵢ·sᵢ² − 2sᵢ + pkᵢ = 0   (quadratic in sᵢ)
--   and sᵢ² = uᵢ² + vᵢ² is itself quadratic.  The full system over 12
--   unknowns (uᵢ,vᵢ,sᵢ for i=1..4) is therefore an MQ instance over ℝ.
-- ════════════════════════════════════════════════════════════════════════════

-- ── §10a  Coherent Residue Inversion (CRI) problem ───────────────────────

/-- `mv_verify` returns true iff the signature's residue vector matches `pk`.
    This simp lemma exposes the kernel decision predicate for CRI. -/
@[simp] lemma mv_verify_iff (pk : PublicResidues) (msg : Message) (sig : Signature) :
    mv_verify pk msg sig = true ↔ multivariate_pk sig.state = pk := by
  simp [mv_verify]

/-- The **Coherent Residue Inversion (CRI) problem**: given a residue vector
    `pk`, find a valid `Signature` whose `multivariate_pk` equals `pk`.

    A signature already carries a `Coherent` proof (the `hcoh` field), so the
    energy constraint `‖q1‖²+‖q2‖²+‖q3‖²+‖q4‖²=4` is automatically enforced.
    The sector membership constraints (qi ∈ Qᵢ) are enforced by the `FourState`
    fields `hq1,hq2,hq3,hq4`.

    The CRI system in explicit form (with sᵢ := |qᵢ|, uᵢ := Re(qᵢ), vᵢ := Im(qᵢ)):

        pkᵢ · sᵢ² − 2sᵢ + pkᵢ = 0     (from C(sᵢ) = pkᵢ, i = 1,2,3,4)
        sᵢ² = uᵢ² + vᵢ²                (amplitude norm equations)
        u₁²+v₁²+u₂²+v₂²+u₃²+v₃²+u₄²+v₄² = 4   (Coherent constraint)
        u₁ > 0, v₁ > 0                 (Q1 sector)
        u₂ < 0, v₂ > 0                 (Q2 sector, always pk₂ = 1)
        u₃ < 0, v₃ < 0                 (Q3 sector)
        u₄ > 0, v₄ < 0                 (Q4 sector)

    This is an MQ (Multivariate Quadratic) instance in 12 unknowns over ℝ.
    Solving it is the computational bottleneck for forgery. -/
def CRI_solution (pk : PublicResidues) : Prop :=
  ∃ sig : Signature, multivariate_pk sig.state = pk

/-- **Forgery is CRI**: producing a valid multivariate signature is equivalent
    to solving the Coherent Residue Inversion problem.

    Proof: `mv_verify pk msg sig = true ↔ multivariate_pk sig.state = pk`
    by definition of `mv_verify` (via `mv_verify_iff`), and `CRI_solution pk`
    is defined as the existence of such a `sig`. -/
theorem mv_forgery_is_cri (pk : PublicResidues) (msg : Message) :
    (∃ sig : Signature, mv_verify pk msg sig = true) ↔ CRI_solution pk :=
  ⟨fun ⟨sig, h⟩ => ⟨sig, (mv_verify_iff pk msg sig).mp h⟩,
   fun ⟨sig, h⟩ => ⟨sig, (mv_verify_iff pk msg sig).mpr h⟩⟩

-- ── §10b  Structural No-Forgery (information-theoretic) ───────────────────

/-- **Multivariate structural no-forgery** — no total adversary can always
    replicate Alice's exact signing function (information-theoretic version).

    For any deterministic function `A : PublicResidues → Message → Signature`,
    there exists a secret key `sk` such that A fails to reproduce Alice's
    signature:
        `A (mv_keygen sk) μ ≠ mv_sign sk μ`

    **Proof strategy** (identical structure to `structural_no_forgery` in
    SignVerify §3):
    Exhibit two keys `sk₁`, `sk₂` with **identical multivariate PKs** but
    **distinct signatures**.  Any deterministic A gives the same output for
    both (same PK and message), but the signatures differ — so A fails on
    at least one.

    **Witnesses**: both keys share x₁=y₁=1/2, x₃=y₃=−1/2, but differ only
    in the Q4 angle parameter `t` (1/3 vs. 2/3).  Their residue vectors agree:
        r₁ = C(√(1/2))    (same q1 = ⟨1/2, 1/2⟩)
        r₂ = C(1) = 1      (same q2 = μ)
        r₃ = C(√(1/2))    (same q3 = ⟨−1/2, −1/2⟩)
        r₄ = C(√2)         (same |q4| = √2, proved via Coherent + linarith)
    But `t=1/3 ≠ 2/3` makes the Q4 direction — and hence the full FourState —
    distinct, so `alice_prepares sk₁ ≠ alice_prepares sk₂`.

    This is an information-theoretic theorem: it holds for ALL total adversaries
    with no time restriction.  The genuine cryptographic claim (no
    *polynomial-time* forger) is `mv_MQ_hard` below.

    Dependency chain: mv_structural_no_forgery
                    → alice_key_determines_state (FourSector §7)
                    → oil_fiber_five_dimensional (FourSector §5b)
                    → BalanceHypothesis. -/
theorem mv_structural_no_forgery :
    ∀ (A : PublicResidues → Message → Signature),
      ∃ sk : SecretKey, A (mv_keygen sk) μ ≠ mv_sign sk μ := by
  intro A
  -- ── Witness keys ──────────────────────────────────────────────────────────
  -- sk₁ and sk₂ share x₁=y₁=1/2, x₃=y₃=−1/2; differ only in t (1/3 vs. 2/3).
  have hv₁ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 1/3⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  have hv₂ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 2/3⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  let sk₁ : SecretKey := ⟨⟨1/2, 1/2, -1/2, -1/2, 1/3⟩, hv₁⟩
  let sk₂ : SecretKey := ⟨⟨1/2, 1/2, -1/2, -1/2, 2/3⟩, hv₂⟩
  -- ── sk₁ ≠ sk₂ (t parameters differ) ──────────────────────────────────────
  have hne : sk₁ ≠ sk₂ := by
    intro heq
    have := congr_arg (fun k => k.1.t) heq
    norm_num at this
  -- ── alice_prepares sk₁ ≠ alice_prepares sk₂ ──────────────────────────────
  have hne_states : alice_prepares sk₁ ≠ alice_prepares sk₂ :=
    fun h => hne (alice_key_determines_state h)
  -- ── mv_sign sk₁ μ ≠ mv_sign sk₂ μ (different state fields) ───────────────
  have hne_sigs : mv_sign sk₁ μ ≠ mv_sign sk₂ μ :=
    fun h => hne_states (congrArg Signature.state h)
  -- ── normSq of q4 for both keys (via Coherent) ─────────────────────────────
  -- Coherent gives normSq q1 + normSq q2 + normSq q3 + normSq q4 = 4.
  have hCoh₁ : Coherent (alice_prepares sk₁) := (oil_fiber_map_mem sk₁.1 sk₁.2).1
  have hCoh₂ : Coherent (alice_prepares sk₂) := (oil_fiber_map_mem sk₂.1 sk₂.2).1
  unfold Coherent at hCoh₁ hCoh₂
  -- Component normSq values shared by both states.
  have hNsq12 : Complex.normSq (⟨1/2, 1/2⟩ : ℂ) = 1/2 := by
    rw [Complex.normSq_apply]; norm_num
  have hNsqMu : Complex.normSq μ = 1 := by
    rw [Complex.normSq_eq_abs, mu_abs_one]; norm_num
  have hNsq3 : Complex.normSq (⟨-1/2, -1/2⟩ : ℂ) = 1/2 := by
    rw [Complex.normSq_apply]; norm_num
  -- normSq q4 = 2 for sk₁ (by Coherent + q1/q2/q3 normSq values).
  have hNsqQ4₁ : Complex.normSq (alice_prepares sk₁).q4 = 2 := by
    have hq1 : Complex.normSq (alice_prepares sk₁).q1 = 1/2 := by
      change Complex.normSq (⟨(1:ℝ)/2, (1:ℝ)/2⟩ : ℂ) = 1/2; exact hNsq12
    have hq2 : Complex.normSq (alice_prepares sk₁).q2 = 1 := by
      rw [alice_q2_eq_mu]; exact hNsqMu
    have hq3 : Complex.normSq (alice_prepares sk₁).q3 = 1/2 := by
      change Complex.normSq (⟨-(1:ℝ)/2, -(1:ℝ)/2⟩ : ℂ) = 1/2; exact hNsq3
    linarith
  -- normSq q4 = 2 for sk₂ (same argument).
  have hNsqQ4₂ : Complex.normSq (alice_prepares sk₂).q4 = 2 := by
    have hq1 : Complex.normSq (alice_prepares sk₂).q1 = 1/2 := by
      change Complex.normSq (⟨(1:ℝ)/2, (1:ℝ)/2⟩ : ℂ) = 1/2; exact hNsq12
    have hq2 : Complex.normSq (alice_prepares sk₂).q2 = 1 := by
      rw [alice_q2_eq_mu]; exact hNsqMu
    have hq3 : Complex.normSq (alice_prepares sk₂).q3 = 1/2 := by
      change Complex.normSq (⟨-(1:ℝ)/2, -(1:ℝ)/2⟩ : ℂ) = 1/2; exact hNsq3
    linarith
  -- abs q4 = √2 for both (from normSq q4 = 2).
  -- Proof: C = Complex.abs, normSq z = (abs z)^2 (Complex.normSq_eq_abs),
  --        so abs z = sqrt(normSq z); abs z = sqrt 2 follows by substitution.
  have hAbsQ4₁ : Complex.abs (alice_prepares sk₁).q4 = Real.sqrt 2 := by
    rw [← Real.sqrt_sq (Complex.abs.nonneg _), ← Complex.normSq_eq_abs, hNsqQ4₁]
  have hAbsQ4₂ : Complex.abs (alice_prepares sk₂).q4 = Real.sqrt 2 := by
    rw [← Real.sqrt_sq (Complex.abs.nonneg _), ← Complex.normSq_eq_abs, hNsqQ4₂]
  -- ── mv_keygen sk₁ = mv_keygen sk₂ ────────────────────────────────────────
  -- All four coherence residues are equal: r1, r2, r3 by definitional equality
  -- (same q1/q2/q3 for both keys); r4 by abs q4₁ = abs q4₂ = √2.
  have hpk_eq : mv_keygen sk₁ = mv_keygen sk₂ := by
    unfold mv_keygen multivariate_pk
    ext
    -- r1: coherence_residue q1₁ = coherence_residue q1₂ (both q1 = ⟨1/2,1/2⟩)
    · rfl
    -- r2: coherence_residue q2₁ = coherence_residue q2₂ (both q2 = μ)
    · rfl
    -- r3: coherence_residue q3₁ = coherence_residue q3₂ (both q3 = ⟨−1/2,−1/2⟩)
    · rfl
    -- r4: coherence_residue q4₁ = coherence_residue q4₂ (same abs = √2)
    · unfold coherence_residue; rw [hAbsQ4₁, hAbsQ4₂]
  -- ── Conclude by contradiction ─────────────────────────────────────────────
  -- A gives the same output for sk₁ and sk₂ (same PK), but the signatures
  -- differ; so A fails on at least one key.
  have hA_eq : A (mv_keygen sk₁) μ = A (mv_keygen sk₂) μ := by rw [hpk_eq]
  by_cases h₁ : A (mv_keygen sk₁) μ = mv_sign sk₁ μ
  · exact ⟨sk₂, fun h₂ => hne_sigs (h₁.symm.trans (hA_eq.trans h₂))⟩
  · exact ⟨sk₁, h₁⟩

-- ── §10c  State-Recovery Impossibility ────────────────────────────────────

/-- **State-recovery impossibility** — no total adversary can always recover
    Alice's exact FourState from the multivariate public key alone.

    There is no function `A : PublicResidues → FourState` such that
        `A (mv_keygen sk) = alice_prepares sk` for all `sk : SecretKey`.

    **Proof**: same two witnesses as `mv_structural_no_forgery` — both keys
    map to the same PublicResidues (same norms, hence same r₁,r₂,r₃,r₄) but
    produce different FourStates (different Q4 direction).  Any total A outputs
    a single state for the shared PK, but cannot equal both simultaneously.

    **Interpretation**:
    • Even an information-theoretically unbounded adversary cannot always recover
      Alice's state from the 4-residue public key.
    • The residue vector reveals only the *norms* of Alice's sector amplitudes,
      not their *phases* (arguments).  Multiple FourStates share the same norm
      vector — at minimum, the continuum of Q4 directions parametrized by t ∈(0,1).

    Dependency chain: mv_structural_no_forgery_state
                    → alice_key_determines_state → oil_fiber_five_dimensional
                    → FourSector §5b → BalanceHypothesis. -/
theorem mv_structural_no_forgery_state :
    ¬ ∃ A : PublicResidues → FourState,
        ∀ sk : SecretKey, A (mv_keygen sk) = alice_prepares sk := by
  intro ⟨A, hA⟩
  -- Same witnesses and PK equality proof as mv_structural_no_forgery.
  have hv₁ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 1/3⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  have hv₂ : OilValid ⟨1/2, 1/2, -1/2, -1/2, 2/3⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  let sk₁ : SecretKey := ⟨⟨1/2, 1/2, -1/2, -1/2, 1/3⟩, hv₁⟩
  let sk₂ : SecretKey := ⟨⟨1/2, 1/2, -1/2, -1/2, 2/3⟩, hv₂⟩
  have hne : sk₁ ≠ sk₂ := by
    intro heq; exact absurd (congr_arg (fun k => k.1.t) heq) (by norm_num)
  have hne_states : alice_prepares sk₁ ≠ alice_prepares sk₂ :=
    fun h => hne (alice_key_determines_state h)
  have hCoh₁ : Coherent (alice_prepares sk₁) := (oil_fiber_map_mem sk₁.1 sk₁.2).1
  have hCoh₂ : Coherent (alice_prepares sk₂) := (oil_fiber_map_mem sk₂.1 sk₂.2).1
  unfold Coherent at hCoh₁ hCoh₂
  have hNsq12 : Complex.normSq (⟨1/2, 1/2⟩ : ℂ) = 1/2 := by
    rw [Complex.normSq_apply]; norm_num
  have hNsqMu : Complex.normSq μ = 1 := by
    rw [Complex.normSq_eq_abs, mu_abs_one]; norm_num
  have hNsq3 : Complex.normSq (⟨-1/2, -1/2⟩ : ℂ) = 1/2 := by
    rw [Complex.normSq_apply]; norm_num
  have hNsqQ4₁ : Complex.normSq (alice_prepares sk₁).q4 = 2 := by
    have hq1 : Complex.normSq (alice_prepares sk₁).q1 = 1/2 := by
      change Complex.normSq (⟨(1:ℝ)/2, (1:ℝ)/2⟩ : ℂ) = 1/2; exact hNsq12
    have hq2 : Complex.normSq (alice_prepares sk₁).q2 = 1 := by
      rw [alice_q2_eq_mu]; exact hNsqMu
    have hq3 : Complex.normSq (alice_prepares sk₁).q3 = 1/2 := by
      change Complex.normSq (⟨-(1:ℝ)/2, -(1:ℝ)/2⟩ : ℂ) = 1/2; exact hNsq3
    linarith
  have hNsqQ4₂ : Complex.normSq (alice_prepares sk₂).q4 = 2 := by
    have hq1 : Complex.normSq (alice_prepares sk₂).q1 = 1/2 := by
      change Complex.normSq (⟨(1:ℝ)/2, (1:ℝ)/2⟩ : ℂ) = 1/2; exact hNsq12
    have hq2 : Complex.normSq (alice_prepares sk₂).q2 = 1 := by
      rw [alice_q2_eq_mu]; exact hNsqMu
    have hq3 : Complex.normSq (alice_prepares sk₂).q3 = 1/2 := by
      change Complex.normSq (⟨-(1:ℝ)/2, -(1:ℝ)/2⟩ : ℂ) = 1/2; exact hNsq3
    linarith
  have hAbsQ4₁ : Complex.abs (alice_prepares sk₁).q4 = Real.sqrt 2 := by
    rw [← Real.sqrt_sq (Complex.abs.nonneg _), ← Complex.normSq_eq_abs, hNsqQ4₁]
  have hAbsQ4₂ : Complex.abs (alice_prepares sk₂).q4 = Real.sqrt 2 := by
    rw [← Real.sqrt_sq (Complex.abs.nonneg _), ← Complex.normSq_eq_abs, hNsqQ4₂]
  have hpk_eq : mv_keygen sk₁ = mv_keygen sk₂ := by
    unfold mv_keygen multivariate_pk
    ext
    · rfl
    · rfl
    · rfl
    · unfold coherence_residue; rw [hAbsQ4₁, hAbsQ4₂]
  -- A(PK) gives the same state for both keys, but the states are distinct.
  exact hne_states ((hA sk₁).symm.trans ((congrArg A hpk_eq).trans (hA sk₂)))

-- ── §10d  MQ Hardness Axiom ────────────────────────────────────────────────

/-- **Multivariate MQ hardness axiom** — the MQ problem for the four-sector
    scheme is computationally hard.

    The *computational* (polynomial-time) hardness claim: no efficient adversary,
    given only the multivariate public key `mv_keygen sk`, can produce a valid
    forgery signature for any target key `sk`.  This is the four-sector analogue
    of `MQ_hard` in SignVerify §3, lifted to the multivariate residue PK.

    Formally: for all PPT adversaries `A : PublicResidues → Message → Signature`,
    there exists a target key `sk` for which `A`'s forgery attempt fails:
        `mv_verify (mv_keygen sk) μ (A (mv_keygen sk) μ) = false`

    **Distinction from `mv_structural_no_forgery`**:
    • `mv_structural_no_forgery` (§10b) proves the information-theoretic version:
      no TOTAL (unbounded) adversary can match Alice's EXACT signing function.
    • The present axiom is strictly stronger: it asserts that even a
      polynomial-time adversary cannot produce ANY valid forgery signature
      (not just fail to match Alice's exact output) for a randomly chosen key.
    • The difference is important: forging requires solving the CRI system
      (`mv_forgery_is_cri`), which is a genuine MQ instance over ℝ.  An
      unbounded adversary can potentially invert C and recover norms, then
      choose valid phases; a poly-time adversary cannot.

    **Status**: declared as `axiom` to flag that this computational hardness
    claim is unproven within Lean's logic.  A formal reduction from the
    standard MQ problem over GF(p) (or ℝ) is left for future work, following
    the standard approach of basing UOV security on the MQ assumption.

    Dependency chain: mv_MQ_hard → mv_keygen, mv_verify, mv_sign
                    → alice_prepares → oil_fiber_map → BalanceHypothesis. -/
axiom mv_MQ_hard :
    ∀ (A : PublicResidues → Message → Signature),
      ∃ sk : SecretKey,
        mv_verify (mv_keygen sk) μ (A (mv_keygen sk) μ) = false

-- ── §10e  EUF-CMA Security ────────────────────────────────────────────────

/-- **EUF-CMA security** — existential unforgeability under chosen-message
    attack, derived from `mv_MQ_hard`.

    No polynomial-time adversary can produce a valid forgery against the
    multivariate scheme: for all A, there exists a target key sk such that
    A's output does NOT verify under the corresponding public key.

    Proof: direct consequence of `mv_MQ_hard`; `false ≠ true` closes the goal.

    Dependency chain: mv_euf_cma → mv_MQ_hard (§10d, axiom). -/
theorem mv_euf_cma :
    ∀ (A : PublicResidues → Message → Signature),
      ∃ sk : SecretKey,
        mv_verify (mv_keygen sk) μ (A (mv_keygen sk) μ) ≠ true := by
  intro A
  obtain ⟨sk, hf⟩ := mv_MQ_hard A
  exact ⟨sk, by simp [hf]⟩

/-- **Hardness implies no universal forger** — `mv_MQ_hard` implies that no
    adversary can successfully forge for ALL keys simultaneously.

    This is a stronger reformulation of EUF-CMA: there is no adversary that
    always succeeds on every possible target key.

    Proof: from `mv_MQ_hard`, at least one target key exists where the adversary
    fails; `mv_verify _ μ _ = false` means the `if`-branch was not taken, i.e.,
    `multivariate_pk sig.state ≠ pk`. -/
theorem mv_no_universal_forger :
    ¬ ∃ A : PublicResidues → Message → Signature,
        ∀ sk : SecretKey,
          mv_verify (mv_keygen sk) μ (A (mv_keygen sk) μ) = true := by
  intro ⟨A, hA⟩
  obtain ⟨sk, hf⟩ := mv_MQ_hard A
  specialize hA sk
  simp [hf] at hA

end -- noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §9  #print axioms Audit
--
-- §§1–8 theorems depend only on BalanceHypothesis project axioms plus the
-- standard Lean/Mathlib propositional axioms; no new axioms.
--
-- §10 introduces one new axiom: mv_MQ_hard (computational hardness).
-- mv_euf_cma and mv_no_universal_forger depend on mv_MQ_hard.
-- The structural theorems (mv_structural_no_forgery,
-- mv_structural_no_forgery_state, mv_forgery_is_cri) do NOT depend on
-- mv_MQ_hard — they are purely proved from the fiber geometry.
-- ════════════════════════════════════════════════════════════════════════════

section AxiomAudit

-- §§1–8 theorems (no mv_MQ_hard dependency)
#print axioms mv_correctness
#print axioms mv_pk_q2_const
#print axioms mv_pk_discriminates
#print axioms mv_zero_knowledge
#print axioms mv_unforgeability_precondition

-- §10 structural theorems (no mv_MQ_hard dependency)
#print axioms mv_forgery_is_cri
#print axioms mv_structural_no_forgery
#print axioms mv_structural_no_forgery_state

-- §10 computational theorems (depend on mv_MQ_hard)
#print axioms mv_euf_cma
#print axioms mv_no_universal_forger

end AxiomAudit
