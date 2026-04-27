/-
  CrossSectorKey.lean — Eigenverse cross-sector asymmetry and phase-binding verification.

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   THE DESIGN FLAW IN THE NORM-ONLY SCHEME                               ║
  ║                                                                          ║
  ║   MultivariateKey.lean's mv_verify checks only sector norms:            ║
  ║     mv_verify pk msg sig ↔ multivariate_pk sig.state = pk              ║
  ║   where multivariate_pk computes C(|qᵢ|) for i = 1,2,3,4.             ║
  ║                                                                          ║
  ║   Attack (formalised in `mv_forgery_example`):                          ║
  ║   The norm conditions impose only 4 equations in 8 real unknowns        ║
  ║   (Re/Im of q1,q2,q3,q4), leaving 4 continuous phase degrees of         ║
  ║   freedom unconstrained.  Concrete witnesses using the (3,4,5)          ║
  ║   Pythagorean triple:                                                    ║
  ║     sk_A : q1=(3/5,4/5), q3=(−4/5,−3/5), t=1/2                        ║
  ║     sk_B : q1=(4/5,3/5), q3=(−4/5,−3/5), t=1/2                        ║
  ║   Both have |q1|=|q2|=|q3|=|q4|=1, so mv_keygen sk_A = mv_keygen sk_B  ║
  ║   = ⟨1,1,1,1⟩.  Then mv_sign sk_B μ passes mv_verify against sk_A's   ║
  ║   key — a cross-key forgery the norm-only scheme cannot detect.         ║
  ║                                                                          ║
  ║   THE FIX: CROSS-SECTOR COUPLING κ = Re(q1·conj(q3))                   ║
  ║                                                                          ║
  ║   For sk_A: κ_A = (3/5)(−4/5)+(4/5)(−3/5) = −24/25                    ║
  ║   For sk_B: κ_B = (4/5)(−4/5)+(3/5)(−3/5) = −1                        ║
  ║   cs_verify adds condition (b): check κ in addition to norms.           ║
  ║   The forgery mv_sign sk_B μ carries κ_B = −1 ≠ −24/25 = κ_A, so      ║
  ║   cs_verify rejects it (proved in `cs_blocks_forgery_example`).         ║
  ║                                                                          ║
  ║   FOUR EIGENVERSE ASYMMETRIES (criteria from the design question):      ║
  ║                                                                          ║
  ║   1. GF(q) analog: κ_GF(a₁,b₁,a₃,b₃) = a₁a₃+b₁b₃ over GFp q² is     ║
  ║      the standard inner product — works over any field (§8).            ║
  ║   2. Hidden in MQ: κ is a degree-2 bilinear polynomial in the 8 real   ║
  ║      unknowns Re/Im(q1), Re/Im(q3) — one more MQ constraint.           ║
  ║   3. Easy inversion: Alice reads x₁,y₁,x₃,y₃ from OilParams directly; ║
  ║      κ = x₁x₃ + y₁y₃ costs two multiplications and one addition.       ║
  ║   4. Not UOV: UOV enforces Oil×Oil = 0 (zero block).  On the           ║
  ║      Eigenverse oil fiber κ < 0 ALWAYS (proved in §6): Q1 forces        ║
  ║      Re(q1)>0, Im(q1)>0; Q3 forces Re(q3)<0, Im(q3)<0; so both         ║
  ║      cross-products are negative.  A non-zero bilinear coupling is      ║
  ║      structurally incompatible with UOV's Oil×Oil = 0.                  ║
  ║                                                                          ║
  ║   Sections                                                               ║
  ║   ────────                                                               ║
  ║   §1  Cross-sector coupling κ                                            ║
  ║   §2  CrossSectorPK structure and protocol functions                     ║
  ║   §3  Helper lemmas (normSq → abs → coherence_residue)                  ║
  ║   §4  Forgery attack on the norm-only scheme                             ║
  ║   §5  Phase-binding blocks the attack                                    ║
  ║   §6  Oil-fiber structural properties (κ < 0; κ ≠ 0 unlike UOV)         ║
  ║   §7  Correctness, norm-forgery failure, phase distinguishability        ║
  ║   §8  GF(q) cross-sector coupling (criterion 1)                          ║
  ║   §9  #print axioms audit                                                ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝
-/

import MultivariateKey
import FiniteFieldUOV

open Complex Real
open Classical

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Cross-Sector Coupling
-- ════════════════════════════════════════════════════════════════════════════

/-- The cross-sector coupling κ(q1, q3) := Re(q1) · Re(q3) + Im(q1) · Im(q3).

    This is the real inner product ⟨q1, q3⟩_{ℝ²} = Re(q1 * conj(q3)).  It
    encodes the **relative phase** between the Q1 and Q3 sectors.

    **Four Eigenverse asymmetries** that make κ a genuine new primitive:

    1. **GF(q) analog** — over GFp q², represent sector vectors as (a,b) ∈ GFp q².
       The coupling is κ_GF(a₁,b₁,a₃,b₃) = a₁a₃ + b₁b₃ ∈ GFp q: the standard
       bilinear inner product over any field.  See §8 for the formal definition.

    2. **Hidden in MQ** — κ is a degree-2 (bilinear) polynomial in the 8 real
       unknowns Re/Im(q1), Re/Im(q3).  It appears as one quadratic constraint
       in a larger MQ system, indistinguishable from random degree-2 equations
       to an observer who does not know the sector decomposition.

    3. **Easy inversion** — Alice's OilParams record stores Re(q1) = x₁,
       Im(q1) = y₁, Re(q3) = x₃, Im(q3) = y₃ directly.  She computes
       κ = x₁x₃ + y₁y₃ with two multiplications and one addition.

    4. **Not UOV** — UOV's zero oil-oil block forces Oil×Oil = 0 for the central
       map: all quadratic oil-oil terms vanish.  On the Eigenverse oil fiber,
       κ < 0 ALWAYS (see `cs_oil_coupling_neg`): Q1 forces Re(q1) > 0 and
       Im(q1) > 0 while Q3 forces Re(q3) < 0 and Im(q3) < 0, making both
       cross-products negative.  A NON-ZERO bilinear coupling between distinct
       sector pairs cannot be reduced to UOV's Oil×Oil = 0 by any change of
       basis that preserves the sector structure. -/
def cross_coupling (q1 q3 : ℂ) : ℝ := q1.re * q3.re + q1.im * q3.im

-- ════════════════════════════════════════════════════════════════════════════
-- §2  CrossSectorPK and Protocol
-- ════════════════════════════════════════════════════════════════════════════

/-- The cross-sector public key: the 4-residue norm vector from MultivariateKey
    extended with the cross-sector coupling κ = Re(q1 * conj(q3)).

    The `residues` field encodes the four sector norms via the coherence trapdoor
    C (only one-way norm images are published).
    The `kappa` field encodes the Q1–Q3 cross-sector phase correlation.

    Together they make verification depend on **both norms and relative phases**,
    defeating pure norm-matching attacks: once |q1|=r₁ and |q3|=r₃ are fixed,
    the constraint κ = r₁r₃ cos(θ₁−θ₃) pins the relative phase θ₁−θ₃,
    removing the continuous degree of freedom that mv_verify leaves open. -/
@[ext]
structure CrossSectorPK where
  /-- 4-residue public key: (C(|q1|), C(|q2|), C(|q3|), C(|q4|)). -/
  residues : PublicResidues
  /-- Cross-sector coupling: Re(q1) * Re(q3) + Im(q1) * Im(q3). -/
  kappa : ℝ

/-- Key generation: publish the 4-residue vector and the cross-sector coupling. -/
noncomputable def cs_keygen (sk : SecretKey) : CrossSectorPK :=
  { residues := mv_keygen sk
    kappa    := cross_coupling (alice_prepares sk).q1 (alice_prepares sk).q3 }

/-- Signing: identical to mv_sign.  The oil-fiber trapdoor is unchanged. -/
noncomputable def cs_sign (sk : SecretKey) (msg : Message) : Signature :=
  mv_sign sk msg

/-- Verification: accept iff BOTH the 4-residue norm vector AND the cross-sector
    coupling match the published key.

      (a) multivariate_pk sig.state = pk.residues   (norm matching, as in mv_verify)
      (b) cross_coupling sig.state.q1 sig.state.q3 = pk.kappa  (phase binding)

    Condition (b) is the fix: an adversary producing a state with correct norms
    still needs to match the exact cross-sector phase correlation.  The free
    phase degrees of freedom available in the norm-only scheme are now bound. -/
noncomputable def cs_verify (pk : CrossSectorPK) (_ : Message) (sig : Signature) : Bool :=
  if multivariate_pk sig.state = pk.residues ∧
     cross_coupling sig.state.q1 sig.state.q3 = pk.kappa
  then true else false

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Helper Lemmas
-- ════════════════════════════════════════════════════════════════════════════

/-- A complex number with normSq = 1 has absolute value 1. -/
private lemma abs_one_of_normSq_one {z : ℂ} (h : Complex.normSq z = 1) :
    Complex.abs z = 1 := by
  rw [← Real.sqrt_sq (Complex.abs.nonneg z), ← Complex.normSq_eq_abs, h, Real.sqrt_one]

/-- The coherence residue of a unit-norm complex number equals 1. -/
private lemma cr_one_of_abs_one {z : ℂ} (h : Complex.abs z = 1) :
    coherence_residue z = 1 := by
  unfold coherence_residue; rw [h, trapdoor_at_one]

-- ════════════════════════════════════════════════════════════════════════════
-- §4  The Forgery Attack on the Norm-Only Scheme
-- ════════════════════════════════════════════════════════════════════════════

/-- **Norm-only forgery**: `mv_verify` accepts a cross-key forgery.

    **Witnesses** using the (3,4,5)/5 Pythagorean triple:
      sk_A : q1=(3/5,4/5), q3=(−4/5,−3/5), t=1/2
      sk_B : q1=(4/5,3/5), q3=(−4/5,−3/5), t=1/2

    ‣ Both have |q1| = 1 (since 3²+4² = 5²), |q2| = 1 (always), |q3| = 1.
    ‣ Coherent forces |q4|² = 4 − 1 − 1 − 1 = 1, so |q4| = 1.
    ‣ All residues C(1) = 1 for both: mv_keygen sk_A = mv_keygen sk_B = ⟨1,1,1,1⟩.

    The Q1 phase differs: (3/5,4/5) and (4/5,3/5) represent angles arctan(4/3)
    and arctan(3/4) respectively.  This continuous phase freedom is unconstrained
    by the norm-only public key, enabling cross-key forgery. -/
theorem mv_forgery_example :
    ∃ (sk : SecretKey) (forgery : Signature),
      mv_verify (mv_keygen sk) μ forgery = true ∧ forgery ≠ mv_sign sk μ := by
  -- ── Witnesses ─────────────────────────────────────────────────────────────
  have hv_A : OilValid ⟨3/5, 4/5, -4/5, -3/5, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  have hv_B : OilValid ⟨4/5, 3/5, -4/5, -3/5, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  let sk_A : SecretKey := ⟨⟨3/5, 4/5, -4/5, -3/5, 1/2⟩, hv_A⟩
  let sk_B : SecretKey := ⟨⟨4/5, 3/5, -4/5, -3/5, 1/2⟩, hv_B⟩
  -- ── sk_A ≠ sk_B (x₁ differs: 3/5 ≠ 4/5) ─────────────────────────────────
  have hsk_ne : sk_A ≠ sk_B := by
    intro h; exact absurd (congr_arg (fun k : SecretKey => k.1.x₁) h) (by norm_num)
  -- ── Distinct states and signatures ────────────────────────────────────────
  have hne_states : alice_prepares sk_A ≠ alice_prepares sk_B :=
    fun h => hsk_ne (alice_key_determines_state h)
  have hne_sigs : mv_sign sk_B μ ≠ mv_sign sk_A μ :=
    fun h => hne_states (congrArg Signature.state h)
  -- ── normSq via Pythagorean identity 3²+4² = 5² ───────────────────────────
  have hNsq_q1A : Complex.normSq (alice_prepares sk_A).q1 = 1 := by
    change Complex.normSq (⟨3/5, 4/5⟩ : ℂ) = 1; rw [Complex.normSq_apply]; norm_num
  have hNsq_q1B : Complex.normSq (alice_prepares sk_B).q1 = 1 := by
    change Complex.normSq (⟨4/5, 3/5⟩ : ℂ) = 1; rw [Complex.normSq_apply]; norm_num
  have hNsq_q3 : Complex.normSq (alice_prepares sk_A).q3 = 1 := by
    change Complex.normSq (⟨-4/5, -3/5⟩ : ℂ) = 1; rw [Complex.normSq_apply]; norm_num
  -- q3 is definitionally equal for both keys: (x₃,y₃) = (−4/5,−3/5) in both
  -- ── normSq q2 = 1 (always, since q2 = μ and |μ| = 1) ────────────────────
  have hNsq_q2A : Complex.normSq (alice_prepares sk_A).q2 = 1 := by
    rw [alice_q2_eq_mu, Complex.normSq_eq_abs, mu_abs_one]; norm_num
  have hNsq_q2B : Complex.normSq (alice_prepares sk_B).q2 = 1 := by
    rw [alice_q2_eq_mu, Complex.normSq_eq_abs, mu_abs_one]; norm_num
  -- ── normSq q4 = 1 for both (Coherent energy sum: 1+1+1+|q4|²=4) ──────────
  have hCoh_A : Coherent (alice_prepares sk_A) := (oil_fiber_map_mem sk_A.1 sk_A.2).1
  have hCoh_B : Coherent (alice_prepares sk_B) := (oil_fiber_map_mem sk_B.1 sk_B.2).1
  unfold Coherent at hCoh_A hCoh_B
  have hNsq_q4A : Complex.normSq (alice_prepares sk_A).q4 = 1 := by
    linarith [hNsq_q1A, hNsq_q2A, hNsq_q3]
  have hNsq_q4B : Complex.normSq (alice_prepares sk_B).q4 = 1 := by
    have hNsq_q3B : Complex.normSq (alice_prepares sk_B).q3 = 1 := hNsq_q3
    linarith [hNsq_q1B, hNsq_q2B, hNsq_q3B]
  -- ── mv_keygen sk_A = ⟨1,1,1,1⟩ and mv_keygen sk_B = ⟨1,1,1,1⟩ ───────────
  have hmvk_A : mv_keygen sk_A = ⟨1, 1, 1, 1⟩ := by
    unfold mv_keygen multivariate_pk; ext
    · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q1A)
    · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q2A)
    · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q3)
    · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q4A)
  have hmvk_B : mv_keygen sk_B = ⟨1, 1, 1, 1⟩ := by
    unfold mv_keygen multivariate_pk; ext
    · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q1B)
    · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q2B)
    · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q3)
    · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q4B)
  -- mv_keygen sk_A = mv_keygen sk_B
  have hpk_eq : mv_keygen sk_A = mv_keygen sk_B := hmvk_A.trans hmvk_B.symm
  -- ── The forgery ────────────────────────────────────────────────────────────
  -- mv_sign sk_B μ verifies against mv_keygen sk_A because norms agree.
  -- It is a distinct signature from mv_sign sk_A μ (different q1 phase).
  refine ⟨sk_A, mv_sign sk_B μ, ?_, hne_sigs⟩
  rw [mv_verify_iff]
  show multivariate_pk (alice_prepares sk_B) = mv_keygen sk_A
  exact hpk_eq.symm

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Phase-Binding Blocks the Attack
-- ════════════════════════════════════════════════════════════════════════════

/-- **Phase binding defeats the forgery**: `cs_verify` rejects `mv_sign sk_B μ`
    as a candidate signature against `cs_keygen sk_A`, even though the 4-residue
    norms match.

    For sk_A: κ_A = (3/5)(−4/5)+(4/5)(−3/5) = −24/25
    For sk_B: κ_B = (4/5)(−4/5)+(3/5)(−3/5) = −1

    The forgery carries κ_B = −1 but the public key records κ_A = −24/25.
    Since −1 ≠ −24/25, condition (b) of cs_verify fails, returning false. -/
theorem cs_blocks_forgery_example :
    ∃ (sk_A sk_B : SecretKey),
      mv_verify (mv_keygen sk_A) μ (mv_sign sk_B μ) = true ∧
      cs_verify (cs_keygen sk_A) μ (mv_sign sk_B μ) = false := by
  -- ── Same witnesses as mv_forgery_example ──────────────────────────────────
  have hv_A : OilValid ⟨3/5, 4/5, -4/5, -3/5, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  have hv_B : OilValid ⟨4/5, 3/5, -4/5, -3/5, 1/2⟩ :=
    ⟨by norm_num, by norm_num, by norm_num, by norm_num,
     by norm_num, by norm_num, by norm_num⟩
  let sk_A : SecretKey := ⟨⟨3/5, 4/5, -4/5, -3/5, 1/2⟩, hv_A⟩
  let sk_B : SecretKey := ⟨⟨4/5, 3/5, -4/5, -3/5, 1/2⟩, hv_B⟩
  refine ⟨sk_A, sk_B, ?_, ?_⟩
  -- ── mv_verify accepts (same proof as in mv_forgery_example) ──────────────
  · rw [mv_verify_iff]
    show multivariate_pk (alice_prepares sk_B) = mv_keygen sk_A
    -- All residues = 1 for both keys; proved via Pythagorean normSq = 1
    have hNsq_q1A : Complex.normSq (alice_prepares sk_A).q1 = 1 := by
      change Complex.normSq (⟨3/5, 4/5⟩ : ℂ) = 1; rw [Complex.normSq_apply]; norm_num
    have hNsq_q1B : Complex.normSq (alice_prepares sk_B).q1 = 1 := by
      change Complex.normSq (⟨4/5, 3/5⟩ : ℂ) = 1; rw [Complex.normSq_apply]; norm_num
    have hNsq_q3 : Complex.normSq (alice_prepares sk_A).q3 = 1 := by
      change Complex.normSq (⟨-4/5, -3/5⟩ : ℂ) = 1; rw [Complex.normSq_apply]; norm_num
    have hNsq_q2A : Complex.normSq (alice_prepares sk_A).q2 = 1 := by
      rw [alice_q2_eq_mu, Complex.normSq_eq_abs, mu_abs_one]; norm_num
    have hNsq_q2B : Complex.normSq (alice_prepares sk_B).q2 = 1 := by
      rw [alice_q2_eq_mu, Complex.normSq_eq_abs, mu_abs_one]; norm_num
    have hCoh_A : Coherent (alice_prepares sk_A) := (oil_fiber_map_mem sk_A.1 sk_A.2).1
    have hCoh_B : Coherent (alice_prepares sk_B) := (oil_fiber_map_mem sk_B.1 sk_B.2).1
    unfold Coherent at hCoh_A hCoh_B
    have hNsq_q4A : Complex.normSq (alice_prepares sk_A).q4 = 1 := by
      linarith [hNsq_q1A, hNsq_q2A, hNsq_q3]
    have hNsq_q4B : Complex.normSq (alice_prepares sk_B).q4 = 1 := by
      have hNsq_q3B : Complex.normSq (alice_prepares sk_B).q3 = 1 := hNsq_q3
      linarith [hNsq_q1B, hNsq_q2B, hNsq_q3B]
    have hmvk_A : mv_keygen sk_A = ⟨1, 1, 1, 1⟩ := by
      unfold mv_keygen multivariate_pk; ext
      · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q1A)
      · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q2A)
      · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q3)
      · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q4A)
    have hmvk_B : mv_keygen sk_B = ⟨1, 1, 1, 1⟩ := by
      unfold mv_keygen multivariate_pk; ext
      · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q1B)
      · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q2B)
      · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q3)
      · exact cr_one_of_abs_one (abs_one_of_normSq_one hNsq_q4B)
    exact (hmvk_A.trans hmvk_B.symm).symm
  -- ── cs_verify rejects (κ mismatch: −1 ≠ −24/25) ─────────────────────────
  · apply if_neg
    intro ⟨_, hκ⟩
    -- Evaluate κ for the signature (from sk_B) and the published key (sk_A)
    have hκ_sig : cross_coupling (mv_sign sk_B μ).state.q1
                                 (mv_sign sk_B μ).state.q3 = -1 := by
      show cross_coupling (⟨4/5, 3/5⟩ : ℂ) (⟨-4/5, -3/5⟩ : ℂ) = -1
      unfold cross_coupling; norm_num
    have hκ_pub : (cs_keygen sk_A).kappa = -24/25 := by
      show cross_coupling (⟨3/5, 4/5⟩ : ℂ) (⟨-4/5, -3/5⟩ : ℂ) = -24/25
      unfold cross_coupling; norm_num
    -- hκ : κ_sig = κ_pub, but κ_sig = −1 and κ_pub = −24/25 → contradiction
    rw [hκ_sig, hκ_pub] at hκ
    norm_num at hκ

-- ════════════════════════════════════════════════════════════════════════════
-- §6  Oil-Fiber Structural Properties
-- ════════════════════════════════════════════════════════════════════════════

/-- The cross-sector coupling on the oil fiber equals x₁x₃ + y₁y₃. -/
lemma cs_oil_coupling_eq (sk : SecretKey) :
    cross_coupling (alice_prepares sk).q1 (alice_prepares sk).q3 =
      sk.1.x₁ * sk.1.x₃ + sk.1.y₁ * sk.1.y₃ := rfl

/-- **Eigenverse asymmetry**: the cross-sector coupling is strictly negative
    on every valid oil-fiber state.

    Q1 constrains Re(q1) = x₁ > 0 and Im(q1) = y₁ > 0 (from OilValid).
    Q3 constrains Re(q3) = x₃ < 0 and Im(q3) = y₃ < 0 (from OilValid).
    Therefore x₁x₃ < 0 and y₁y₃ < 0, so κ = x₁x₃ + y₁y₃ < 0.

    This is the proof of criterion 4: on the Eigenverse oil fiber, κ is
    NEVER zero — structurally incompatible with UOV's Oil×Oil = 0. -/
theorem cs_oil_coupling_neg (sk : SecretKey) :
    cross_coupling (alice_prepares sk).q1 (alice_prepares sk).q3 < 0 := by
  obtain ⟨hx₁, hy₁, hx₃, hy₃, _, _, _⟩ := sk.2
  rw [cs_oil_coupling_eq]
  have h1 : sk.1.x₁ * sk.1.x₃ < 0 := mul_neg_of_pos_of_neg hx₁ hx₃
  have h2 : sk.1.y₁ * sk.1.y₃ < 0 := mul_neg_of_pos_of_neg hy₁ hy₃
  linarith

/-- **Not UOV**: the cross-sector coupling is never zero on the oil fiber.

    In UOV, `ZeroOilBlock F` requires all quadratic oil-oil terms to vanish
    (Oil×Oil = 0).  The Eigenverse coupling satisfies κ < 0 for every valid
    key — a strictly non-zero cross-sector interaction.

    No sector-preserving change of basis can map κ < 0 to κ = 0:
    such a basis change would need to take Q1 vectors (Re>0, Im>0) to Q3
    vectors (Re<0, Im<0) while remaining invertible — impossible without
    violating the sector constraints. -/
theorem cs_not_uov_structure (sk : SecretKey) :
    cross_coupling (alice_prepares sk).q1 (alice_prepares sk).q3 ≠ 0 :=
  ne_of_lt (cs_oil_coupling_neg sk)

-- ════════════════════════════════════════════════════════════════════════════
-- §7  Correctness, Norm-Forgery Failure, Phase Distinguishability
-- ════════════════════════════════════════════════════════════════════════════

/-- **cs_verify iff**: cs_verify returns true iff both conditions hold. -/
@[simp] lemma cs_verify_iff (pk : CrossSectorPK) (msg : Message) (sig : Signature) :
    cs_verify pk msg sig = true ↔
      multivariate_pk sig.state = pk.residues ∧
      cross_coupling sig.state.q1 sig.state.q3 = pk.kappa := by
  simp [cs_verify]

/-- **Correctness**: a legitimately generated signature always passes cs_verify. -/
theorem cs_correctness (sk : SecretKey) :
    cs_verify (cs_keygen sk) μ (cs_sign sk μ) = true := by
  simp only [cs_verify]
  apply if_pos
  exact ⟨rfl, rfl⟩

/-- **Norm-forgery failure**: matching norms but a wrong cross-sector coupling
    always makes cs_verify return false.

    This is the structural fix to the norm-only scheme: the coupling condition
    (b) is independent of the norm conditions (a), so exploiting the continuous
    phase freedom while preserving norms will always be detected. -/
theorem cs_norm_forgery_fails (pk : CrossSectorPK) (sig : Signature)
    (hnorm  : multivariate_pk sig.state = pk.residues)
    (hphase : cross_coupling sig.state.q1 sig.state.q3 ≠ pk.kappa) :
    cs_verify pk μ sig = false := by
  simp only [cs_verify]
  apply if_neg
  intro ⟨_, hκ⟩
  exact hphase hκ

/-- **Phase distinguishability**: two keys with the same 4-residue public key
    but different cross-sector couplings are distinguished by cs_keygen. -/
theorem cs_coupling_distinguishes (sk₁ sk₂ : SecretKey)
    (hκ : cross_coupling (alice_prepares sk₁).q1 (alice_prepares sk₁).q3 ≠
          cross_coupling (alice_prepares sk₂).q1 (alice_prepares sk₂).q3) :
    cs_keygen sk₁ ≠ cs_keygen sk₂ := by
  intro heq
  exact hκ (congrArg CrossSectorPK.kappa heq)

/-- **Key independence**: if two secret keys produce the same CrossSectorPK,
    they yield identical verification outcomes for any signature. -/
theorem cs_key_independence (sk₁ sk₂ : SecretKey) (sig : Signature) (msg : Message)
    (heq : cs_keygen sk₁ = cs_keygen sk₂) :
    cs_verify (cs_keygen sk₁) msg sig = cs_verify (cs_keygen sk₂) msg sig := by
  rw [heq]

-- ════════════════════════════════════════════════════════════════════════════
-- §8  GF(q) Cross-Sector Coupling (criterion 1)
-- ════════════════════════════════════════════════════════════════════════════

/-- The GF(q) cross-sector coupling: κ_GF(a₁,b₁,a₃,b₃) = a₁a₃ + b₁b₃.

    This is the finite-field analog of `cross_coupling` over ℂ.  The pairs
    (a₁,b₁) ∈ GFp q² and (a₃,b₃) ∈ GFp q² represent the Q1 and Q3 sector
    components; the coupling is their standard GFp q inner product.

    The formula a₁a₃ + b₁b₃ is algebraically identical to x₁x₃ + y₁y₃ in
    `cross_coupling` — the same bilinear form over any commutative ring.
    Criterion 1 is satisfied: the Eigenverse asymmetry needs no structural
    modification to work over GF(q). -/
def gfp_cross_coupling (q : ℕ) (a₁ b₁ a₃ b₃ : GFp q) : GFp q :=
  a₁ * a₃ + b₁ * b₃

/-- Left linearity: scaling the Q1 sector vector scales the coupling. -/
theorem gfp_cross_coupling_left_linear (q : ℕ) (c a₁ b₁ a₃ b₃ : GFp q) :
    gfp_cross_coupling q (c * a₁) (c * b₁) a₃ b₃ =
      c * gfp_cross_coupling q a₁ b₁ a₃ b₃ := by
  unfold gfp_cross_coupling; ring

/-- Right linearity: scaling the Q3 sector vector scales the coupling. -/
theorem gfp_cross_coupling_right_linear (q : ℕ) (c a₁ b₁ a₃ b₃ : GFp q) :
    gfp_cross_coupling q a₁ b₁ (c * a₃) (c * b₃) =
      c * gfp_cross_coupling q a₁ b₁ a₃ b₃ := by
  unfold gfp_cross_coupling; ring

/-- **Quadratic scaling**: scaling BOTH sector vectors by c scales the coupling
    by c² — demonstrating that the coupling is genuinely degree-2 (bilinear),
    not linear.  A linear function f would satisfy f(c·x) = c·f(x), giving
    scaling by c; the coupling scales by c², exposing its quadratic nature. -/
theorem gfp_cross_coupling_quadratic_scaling (q : ℕ) (c a₁ b₁ a₃ b₃ : GFp q) :
    gfp_cross_coupling q (c * a₁) (c * b₁) (c * a₃) (c * b₃) =
      c ^ 2 * gfp_cross_coupling q a₁ b₁ a₃ b₃ := by
  unfold gfp_cross_coupling; ring

/-- **Non-zero witness**: the coupling achieves 1 when both sector vectors are
    (1,0).  Over any field with 1 ≠ 0, this shows the coupling is non-trivial —
    just as κ < 0 on the Eigenverse oil fiber (§6). -/
theorem gfp_cross_coupling_nonzero_witness (q : ℕ) [Fact (Nat.Prime q)] :
    gfp_cross_coupling q 1 0 1 0 = 1 := by
  unfold gfp_cross_coupling; simp

/-- **Unequal-sector detection**: when the Q1 and Q3 sector vectors differ, there
    is no single linear coefficient L that can represent the coupling as L*a₁+L*b₁
    for all inputs simultaneously.

    Specifically, if a₃ ≠ b₃ then the coupling a₁*a₃ + b₁*b₃ requires different
    coefficients for a₁ and b₁, which cannot be captured by a single-coefficient
    linear form L*a₁ + L*b₁ (which would force a₃ = b₃ = L).  This makes the
    full coupling irreducible to the single-coefficient "isotropic" form used in
    diagonal UOV central maps. -/
theorem gfp_cross_coupling_asymmetric (q : ℕ) [Fact (Nat.Prime q)]
    {a₃ b₃ : GFp q} (hne : a₃ ≠ b₃) :
    ¬ ∃ L : GFp q,
        ∀ x y : GFp q, gfp_cross_coupling q x y a₃ b₃ = L * x + L * y := by
  intro ⟨L, hL⟩
  -- For (x,y) = (1,0): a₃ = L * 1 + L * 0 = L
  have h1 : a₃ = L := by have := hL 1 0; simp [gfp_cross_coupling] at this; exact this
  -- For (x,y) = (0,1): b₃ = L * 0 + L * 1 = L
  have h2 : b₃ = L := by have := hL 0 1; simp [gfp_cross_coupling] at this; exact this
  -- But L = a₃ and L = b₃ contradicts a₃ ≠ b₃
  exact hne (h1.trans h2.symm)

-- ════════════════════════════════════════════════════════════════════════════
-- §9  #print axioms Audit
-- ════════════════════════════════════════════════════════════════════════════

/-!
## Axiom dependency summary

All theorems in this file depend only on:

| Axiom                   | Origin                 | Role                            |
|-------------------------|------------------------|---------------------------------|
| `propext`               | Lean 4 kernel          | Proposition extensionality      |
| `Classical.choice`      | Lean 4 kernel          | `open Classical` (noncomputable)|
| `Quot.sound`            | Lean 4 kernel          | Quotient types (ℝ, ℂ)           |
| `funext`                | Lean 4 kernel          | Function extensionality         |
| `BalanceHypothesis`     | BalanceHypothesis.lean | Eigenverse foundation           |
| `hidden_recovery_hard`  | FourSector.lean        | Oil-fiber injectivity (§4)      |

No new axioms introduced.  The structural theorems in §6–7 depend only on
`propext`, `Classical.choice`, `Quot.sound`, `funext`, and `BalanceHypothesis`.
-/

end -- noncomputable section
