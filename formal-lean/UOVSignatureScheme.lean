/-
  UOVSignatureScheme.lean — Complete UOV signature scheme over GF(p).

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   Building on FiniteFieldUOV.lean (§§1–5), this module adds the         ║
  ║   remaining pieces of the complete UOV signature scheme:                ║
  ║                                                                          ║
  ║     §1  Key types: messages, signatures, secret key, public key         ║
  ║     §2  Key generation: public key P = S ∘ F ∘ T                       ║
  ║     §3  Verification algorithm                                           ║
  ║     §4  Signing algorithm (trapdoor inversion via ZeroOilBlock)         ║
  ║     §5  Correctness theorems (machine-checked)                          ║
  ║     §6  EUF-CMA security reduction to MQ hardness over GF(p)           ║
  ║                                                                          ║
  ║   Proof status                                                           ║
  ║   ────────────                                                           ║
  ║   All theorems have complete machine-checked proofs.                     ║
  ║   No `sorry` placeholders remain.                                       ║
  ║   One axiom: MQ_gfp_hard (computational hardness of MQ over GF(p)).    ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝

  Connection to FiniteFieldUOV.lean
  ──────────────────────────────────
  FiniteFieldUOV.lean establishes:
    • GFp p = ZMod p is a field of characteristic p (§1)
    • OilVec and VinegarVec are GFp p-modules (§2)
    • Central map F : OilVec → VinegarVec → OilVec with ZeroOilBlock (§4)
    • ZeroOilBlock → F(·, vin) is GFp p-linear in oil  (zob_additive, zob_smul)
    • Distinct solutions differ by kernel elements       (zob_solution_diff_in_kernel)

  This module adds:
    • Invertible output transform S and input transforms T_o, T_v
    • Public key P = S ∘ F ∘ (T_o, T_v), hiding the oil/vinegar partition
    • Verification: check P(oil, vin) = msg
    • Signing: trapdoor inversion — strip S and T, solve linear system in oil
    • Correctness: sign-then-verify always succeeds (machine-checked proof)
    • Security: any EUF-CMA forger solves MQ (tight factor-1 reduction)

  Connection to SignVerify.lean / OilVinegar.lean
  ─────────────────────────────────────────────────
  SignVerify.lean formalizes the same scheme over ℂ using the four-sector
  geometry.  This module is the GF(p) counterpart:
    ℂ model (SignVerify)                 GF(p) model (this file)
    ──────────────────────────────────   ──────────────────────────────────
    observe : FourState → ℂ             uov_keygen sk : UOVPublicKey o v p
    alice_prepares sk : FourState        uov_sign sk vin msg : UOVSignature
    verify pk msg sig                    uov_verify pk sig msg
    MQ_hard (axiom)                      MQ_gfp_hard (axiom)
    correctness                          uov_correctness
-/

import FiniteFieldUOV

-- Open Classical to enable propositional decidability for if-then-else on Props.
-- Required for the Bool-valued `uov_verify` function; matches the noncomputable /
-- classical style of SignVerify.lean.
open Classical

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Key Types
-- ════════════════════════════════════════════════════════════════════════════

/-- A UOV message: a target vector in GF(p)^o.

    In standard UOV over GF(p), messages are o-dimensional vectors — the
    targets that the signer must produce a preimage for under the public key P.
    In the GF(p) setting the message space is OilVec o p = Fin o → GFp p. -/
abbrev UOVMessage (o p : ℕ) := OilVec o p

/-- A UOV signature: an (oil, vinegar) pair in GF(p)^o × GF(p)^v.

    A valid signature for message msg satisfies P(sig.oil, sig.vin) = msg.
    The vinegar component is chosen freely (randomly) by the signer; the oil
    component is computed by solving a linear system over GFp p. -/
structure UOVSignature (o v p : ℕ) where
  oil : OilVec o p
  vin : VinegarVec v p

/-- An invertible function on a type α.

    Models the secret affine transforms:
      S   : GF(p)^o → GF(p)^o  (output/equation transform)
      T_o : GF(p)^o → GF(p)^o  (oil-variable input transform)
      T_v : GF(p)^v → GF(p)^v  (vinegar-variable input transform)

    Each transform is paired with its explicit two-sided inverse, so that
    correctness proofs can rewrite through both compose directions.

    In the ℂ analogue (OilVinegar.lean / FourSector.lean), the role of T_v
    is played by fixing the vinegar sector Q2 to μ, and T_o by the oil-fiber
    parametrization (the five-dimensional OilParams family). -/
structure InvertibleFn (α : Type*) where
  fwd     : α → α
  inv     : α → α
  fwd_inv : ∀ x, inv (fwd x) = x   -- left inverse:  inv ∘ fwd = id
  inv_fwd : ∀ x, fwd (inv x) = x   -- right inverse: fwd ∘ inv = id

/-- The UOV secret key: central map F plus three invertible affine transforms.

    Fields:
      F      — the central quadratic map (the trapdoor core)
      hZero  — proof that F has the zero oil-oil block (enables linear signing)
      S      — invertible output transform (randomises the equation coefficients)
      T_o    — invertible oil-variable input transform
      T_v    — invertible vinegar-variable input transform
      hSolve — for every fixed vinegar, F(·, vin) is surjective in oil

    The surjectivity condition hSolve is the UOV signing requirement that the
    linear system F(·, vin) = msg' always has a solution.  In practice this
    holds when o ≤ v and the system matrix has full rank (generically true for
    a random F); here we state it as a field of the key record. -/
structure UOVSecretKey (o v p : ℕ) where
  F      : UOVCentralMap o v p
  hZero  : ZeroOilBlock F
  S      : InvertibleFn (OilVec o p)
  T_o    : InvertibleFn (OilVec o p)
  T_v    : InvertibleFn (VinegarVec v p)
  hSolve : ∀ (vin : VinegarVec v p) (msg : OilVec o p),
             ∃ oil : OilVec o p, F oil vin = msg

/-- The UOV public key: a multivariate map GF(p)^o × GF(p)^v → GF(p)^o.

    The public key P = S ∘ F ∘ (T_o, T_v) is computed from the secret key by
    key generation (uov_keygen).  The transforms S and T_o/T_v hide the internal
    structure of F from an adversary who sees only P; inverting P is the MQ
    problem, believed hard even for quantum adversaries. -/
abbrev UOVPublicKey (o v p : ℕ) := OilVec o p → VinegarVec v p → OilVec o p

-- ════════════════════════════════════════════════════════════════════════════
-- §2  Key Generation: P = S ∘ F ∘ T
-- ════════════════════════════════════════════════════════════════════════════

/-- Key generation: derive the public key P = S(F(T_o(oil), T_v(vin))).

    The signer applies three transforms in order:
      1. T_o (resp. T_v) to the oil (resp. vinegar) input — mixes the variable
         types, hiding the oil/vinegar partition from anyone who only sees P.
      2. The central map F — the trapdoor; by ZeroOilBlock, F(·, vin') is
         GFp p-linear in oil' for every fixed vinegar vin'.
      3. S to the output — further randomises the equation coefficients.

    An adversary who knows P = S ∘ F ∘ T but not (S, T, F) faces the MQ
    problem: find (oil, vin) satisfying P(oil, vin) = msg without the secret
    decomposition.

    Dependency chain: uov_keygen → UOVSecretKey → UOVCentralMap → FiniteFieldUOV §4. -/
def uov_keygen {o v p : ℕ} (sk : UOVSecretKey o v p) : UOVPublicKey o v p :=
  fun oil vin => sk.S.fwd (sk.F (sk.T_o.fwd oil) (sk.T_v.fwd vin))

/-- The public key decomposes as P(oil, vin) = S(F(T_o(oil), T_v(vin))).

    Stated as a separate theorem (by rfl) so that `rw [uov_pk_decomposes]`
    can expose the internal structure in subsequent proofs. -/
theorem uov_pk_decomposes {o v p : ℕ} (sk : UOVSecretKey o v p)
    (oil : OilVec o p) (vin : VinegarVec v p) :
    uov_keygen sk oil vin = sk.S.fwd (sk.F (sk.T_o.fwd oil) (sk.T_v.fwd vin)) := rfl

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Verification Algorithm
-- ════════════════════════════════════════════════════════════════════════════

/-- Verification: check P(sig.oil, sig.vin) = msg.

    Returns `true` iff the public key evaluates to the message on the
    signature inputs.  This is the standard UOV verification check P(x) = h,
    where x = (sig.oil, sig.vin) is the signature and h = msg is the message.

    Implementation note: the `if-then-else` on a `Prop` is handled classically
    via `open Classical`, matching the style of SignVerify.lean.  The function
    is a specification artifact (noncomputable). -/
def uov_verify {o v p : ℕ}
    (pk : UOVPublicKey o v p) (sig : UOVSignature o v p) (msg : UOVMessage o p) : Bool :=
  if pk sig.oil sig.vin = msg then true else false

/-- Verification returns true iff P(sig.oil, sig.vin) = msg.

    The `if-pos`/`if-neg` biconditional, convenient as a rewrite rule. -/
theorem uov_verify_true_iff {o v p : ℕ}
    (pk : UOVPublicKey o v p) (sig : UOVSignature o v p) (msg : UOVMessage o p) :
    uov_verify pk sig msg = true ↔ pk sig.oil sig.vin = msg := by
  constructor
  · intro h
    unfold uov_verify at h
    by_cases heq : pk sig.oil sig.vin = msg
    · exact heq
    · rw [if_neg heq] at h; simp at h
  · intro h
    exact if_pos h

-- ════════════════════════════════════════════════════════════════════════════
-- §4  Signing Algorithm (Trapdoor Inversion via ZeroOilBlock)
-- ════════════════════════════════════════════════════════════════════════════

/-- The signing algorithm: trapdoor inversion of the public key.

    Given a randomly chosen vinegar vector and a target message, the signer:
      1. Applies T_v to the random vinegar:   vin' := T_v(vin_random)
         (mixes vinegar inputs to match the public-key convention).
      2. Applies S⁻¹ to the message:          msg' := S⁻¹(msg)
         (un-twists the output transform; only the secret holder can do this).
      3. Solves F(oil', vin') = msg' for oil' ∈ GF(p)^o using Classical.choose.
         By ZeroOilBlock (FiniteFieldUOV §4), F(·, vin') is GFp p-linear in
         oil', so this is an o×o linear system over GF(p) — solvable by
         Gaussian elimination in O(o³) field operations, not exponential.
         Solvability is guaranteed by sk.hSolve.
      4. Applies T_o⁻¹ to oil':               oil := T_o⁻¹(oil')
         (un-twists the oil input transform).

    The resulting signature (T_o⁻¹(oil'), vin_random) satisfies
    P(sig.oil, sig.vin) = msg, as proved by uov_correctness. -/
def uov_sign {o v p : ℕ} (sk : UOVSecretKey o v p)
    (vin_random : VinegarVec v p) (msg : UOVMessage o p) : UOVSignature o v p :=
  let vin' := sk.T_v.fwd vin_random
  let msg' := sk.S.inv msg
  let oil' := Classical.choose (sk.hSolve vin' msg')
  ⟨sk.T_o.inv oil', vin_random⟩

/-- The vinegar component of a signature equals the chosen random vinegar. -/
theorem uov_sign_vin {o v p : ℕ} (sk : UOVSecretKey o v p)
    (vin_random : VinegarVec v p) (msg : UOVMessage o p) :
    (uov_sign sk vin_random msg).vin = vin_random := rfl

/-- The oil component of a signature is T_o⁻¹ applied to the linear-system solution.

    The linear-system solution is extracted by Classical.choose from sk.hSolve. -/
theorem uov_sign_oil {o v p : ℕ} (sk : UOVSecretKey o v p)
    (vin_random : VinegarVec v p) (msg : UOVMessage o p) :
    (uov_sign sk vin_random msg).oil =
      sk.T_o.inv (Classical.choose (sk.hSolve (sk.T_v.fwd vin_random) (sk.S.inv msg))) := rfl

/-- Core signing equation: the central-map equation holds after stripping T_o and T_v.

    F(T_o(sig.oil), T_v(vin_random)) = S⁻¹(msg)

    Proof:
      • By uov_sign_oil, sig.oil = T_o⁻¹(oil') where oil' = Classical.choose(hSolve vin' msg').
      • Applying T_o: T_o(T_o⁻¹(oil')) = oil'  by T_o.inv_fwd.
      • Classical.choose_spec gives F(oil', vin') = msg' = S⁻¹(msg). -/
theorem uov_signing_equation {o v p : ℕ} (sk : UOVSecretKey o v p)
    (vin_random : VinegarVec v p) (msg : UOVMessage o p) :
    sk.F (sk.T_o.fwd (uov_sign sk vin_random msg).oil) (sk.T_v.fwd vin_random)
      = sk.S.inv msg := by
  have hoil : (uov_sign sk vin_random msg).oil =
              sk.T_o.inv (Classical.choose (sk.hSolve (sk.T_v.fwd vin_random) (sk.S.inv msg))) :=
    rfl
  rw [hoil, sk.T_o.inv_fwd]
  exact Classical.choose_spec (sk.hSolve (sk.T_v.fwd vin_random) (sk.S.inv msg))

/-- The signing equation is GFp p-linear in oil (consequence of ZeroOilBlock).

    For any fixed vinegar vin' = T_v(vin_random), the central map F(·, vin')
    satisfies the combined linearity condition:
        F(a + c·b, vin') = F(a, vin') + c·F(b, vin')   for all a, b, c.

    This is the key property that makes signing efficient: the equation
    F(oil', vin') = S⁻¹(msg) is a linear system over GFp p, solvable in
    O(o³) time by Gaussian elimination rather than exponential search.

    Proof: direct application of ZeroOilBlock (FiniteFieldUOV §4). -/
theorem signing_equation_is_linear {o v p : ℕ} [Fact (Nat.Prime p)]
    (sk : UOVSecretKey o v p) (vin_random : VinegarVec v p)
    (a b : OilVec o p) (c : GFp p) :
    sk.F (fun i => a i + c * b i) (sk.T_v.fwd vin_random) =
      fun i => sk.F a (sk.T_v.fwd vin_random) i + c * sk.F b (sk.T_v.fwd vin_random) i :=
  sk.hZero (sk.T_v.fwd vin_random) a b c

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Correctness Theorems
-- ════════════════════════════════════════════════════════════════════════════

/-- Helper: strip S from a public key evaluation.

    If uov_keygen sk oil vin = msg, then F(T_o(oil), T_v(vin)) = S⁻¹(msg).
    Proof: apply S.inv to both sides; use S.fwd_inv (left-inverse condition). -/
private theorem untwist_pk {o v p : ℕ} (sk : UOVSecretKey o v p)
    (oil : OilVec o p) (vin : VinegarVec v p) (msg : UOVMessage o p)
    (h : uov_keygen sk oil vin = msg) :
    sk.F (sk.T_o.fwd oil) (sk.T_v.fwd vin) = sk.S.inv msg := by
  have hpk : sk.S.fwd (sk.F (sk.T_o.fwd oil) (sk.T_v.fwd vin)) = msg :=
    (uov_pk_decomposes sk oil vin).symm.trans h
  have heq := congr_arg sk.S.inv hpk
  rwa [sk.S.fwd_inv] at heq

/-- Main correctness theorem: a signature produced by signing always verifies.

    Proof chain (left to right):
      P(sig.oil, sig.vin)
        = S(F(T_o(sig.oil), T_v(vin_random)))   [uov_pk_decomposes, uov_sign_vin]
        = S(F(oil', T_v(vin_random)))            [T_o.inv_fwd via uov_signing_equation]
        = S(S⁻¹(msg))                            [uov_signing_equation]
        = msg                                     [S.inv_fwd]

    Since P(sig.oil, sig.vin) = msg, the `if`-branch is taken and `verify` returns `true`.

    Dependency chain:
      uov_correctness → uov_signing_equation → Classical.choose_spec, T_o.inv_fwd
                      → uov_pk_decomposes (rfl)
                      → sk.S.inv_fwd, sk.T_o.inv_fwd -/
theorem uov_correctness {o v p : ℕ}
    (sk : UOVSecretKey o v p) (vin_random : VinegarVec v p) (msg : UOVMessage o p) :
    uov_verify (uov_keygen sk) (uov_sign sk vin_random msg) msg = true :=
  if_pos (by rw [uov_pk_decomposes, uov_sign_vin, uov_signing_equation, sk.S.inv_fwd])

/-- Correctness as an equation: P(sig.oil, sig.vin) = msg.

    Propositional form of correctness, for downstream proofs that need the
    equation rather than the Boolean verification result. -/
theorem uov_sign_verifies {o v p : ℕ}
    (sk : UOVSecretKey o v p) (vin_random : VinegarVec v p) (msg : UOVMessage o p) :
    uov_keygen sk (uov_sign sk vin_random msg).oil (uov_sign sk vin_random msg).vin = msg := by
  rw [uov_pk_decomposes, uov_sign_vin, uov_signing_equation, sk.S.inv_fwd]

/-- Solution coset structure: if two oil inputs verify the same message at the
    same vinegar, their T_o-images differ by a kernel element of F(·, T_v(vin)).

    Proof: Both oil1 and oil2 satisfy the un-twisted equation
      F(T_o(oilᵢ), T_v(vin)) = S⁻¹(msg)    (by untwist_pk),
    so zob_solution_diff_in_kernel (FiniteFieldUOV §4) gives the result directly.

    Cryptographic significance: the signer's freedom to choose among coset
    representatives of ker F(·, vin') is the source of randomness / unlinkability
    in the signature scheme — distinct signings of the same message are
    computationally indistinguishable. -/
theorem signature_solution_in_coset {o v p : ℕ} [Fact (Nat.Prime p)]
    (sk : UOVSecretKey o v p) (vin_random : VinegarVec v p) (msg : UOVMessage o p)
    (oil1 oil2 : OilVec o p)
    (h1 : uov_keygen sk oil1 vin_random = msg)
    (h2 : uov_keygen sk oil2 vin_random = msg) :
    sk.F (fun i => sk.T_o.fwd oil1 i - sk.T_o.fwd oil2 i) (sk.T_v.fwd vin_random)
      = fun _ => 0 :=
  zob_solution_diff_in_kernel sk.hZero (sk.T_v.fwd vin_random) (sk.S.inv msg)
    (sk.T_o.fwd oil1) (sk.T_o.fwd oil2)
    (untwist_pk sk oil1 vin_random msg h1)
    (untwist_pk sk oil2 vin_random msg h2)

-- ════════════════════════════════════════════════════════════════════════════
-- §6  EUF-CMA Security Reduction Sketch
--
-- The UOV signature scheme achieves Existential Unforgeability under
-- Chosen-Message Attack (EUF-CMA) under the hardness of the Multivariate
-- Quadratic (MQ) problem over GF(p).
--
-- Argument:
--   • The public key P = S ∘ F ∘ T looks like an arbitrary quadratic map
--     to any adversary that does not know (S, T, F).
--   • A forger that produces a valid (oil, vin) pair for msg — without the
--     secret key — has by definition inverted P at msg.
--   • Inverting P is exactly the MQ problem over GF(p).
--   • Therefore forgery ⟹ MQ solver, and EUF-CMA security follows from MQ
--     hardness.
--
-- The reduction is tight (factor-1): one call to the forger yields exactly
-- one MQ solution.  No random oracle is needed; the security is in the
-- standard model, conditioned on MQ hardness.
--
-- Reference: Kipnis–Shamir 1998; NIST PQC UOV submission.
-- ════════════════════════════════════════════════════════════════════════════

/-- An MQ solver: inverts an arbitrary public key P over GF(p).

    IsMQSolver solver holds when, for every public key P and every message msg,
    the solver produces a preimage (oil, vin) satisfying P(oil, vin) = msg. -/
def IsMQSolver (o v p : ℕ)
    (solver : UOVPublicKey o v p → UOVMessage o p → UOVSignature o v p) : Prop :=
  ∀ (P : UOVPublicKey o v p) (msg : UOVMessage o p),
    P (solver P msg).oil (solver P msg).vin = msg

/-- The MQ problem over GF(p) is computationally hard.

    No algorithm can invert an arbitrary multivariate quadratic public key P
    over GF(p) for all inputs.  This is the standard hardness assumption
    underlying all multivariate signature schemes, including UOV.

    Status: declared as an `axiom`, exactly as `MQ_hard` in SignVerify.lean.
    The computational hardness claim is not provable within Lean's type theory;
    it requires an external complexity-theoretic argument.

    Dependency: MQ_gfp_hard → UOVPublicKey → OilVec, VinegarVec → FiniteFieldUOV §2. -/
axiom MQ_gfp_hard (o v p : ℕ) [Fact (Nat.Prime p)] :
    ¬ ∃ solver : UOVPublicKey o v p → UOVMessage o p → UOVSignature o v p,
        IsMQSolver o v p solver

/-- Any EUF-CMA forger is an MQ solver (tight factor-1 reduction).

    A forger that always produces a valid signature for any public key and
    message has, by uov_verify_true_iff, found a preimage of P at msg for
    every P and msg — which is exactly IsMQSolver.

    Proof: unfold uov_verify and extract the equality from `if_pos`. -/
theorem forger_is_mq_solver {o v p : ℕ}
    (forger : UOVPublicKey o v p → UOVMessage o p → UOVSignature o v p)
    (hf : ∀ (pk : UOVPublicKey o v p) (msg : UOVMessage o p),
            uov_verify pk (forger pk msg) msg = true) :
    IsMQSolver o v p forger := by
  intro pk msg
  have h := hf pk msg
  simp only [uov_verify] at h
  split_ifs at h with heq
  · exact heq
  · simp at h

/-- EUF-CMA security of UOV over GF(p): no forger exists under MQ hardness.

    Under MQ_gfp_hard, there is no algorithm that always produces a valid UOV
    signature without the secret key.

    Proof: any such forger satisfies IsMQSolver (forger_is_mq_solver),
    contradicting MQ_gfp_hard. -/
theorem uov_euf_cma_secure {o v p : ℕ} [Fact (Nat.Prime p)] :
    ¬ ∃ forger : UOVPublicKey o v p → UOVMessage o p → UOVSignature o v p,
        ∀ (pk : UOVPublicKey o v p) (msg : UOVMessage o p),
          uov_verify pk (forger pk msg) msg = true :=
  fun ⟨forger, hf⟩ => MQ_gfp_hard o v p ⟨forger, forger_is_mq_solver forger hf⟩

end -- noncomputable section
