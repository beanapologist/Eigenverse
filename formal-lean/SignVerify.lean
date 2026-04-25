/-
  SignVerify.lean — Sign/Verify protocol over the four-sector Oil-and-Vinegar structure.

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   Builds on FourSector.lean and Observer.lean to formalize a UOV-style  ║
  ║   sign/verify protocol over the four-sector oil-and-vinegar geometry.   ║
  ║                                                                          ║
  ║   Architecture:                                                          ║
  ║     The trapdoor is the zero block in the Oil columns of the mixing     ║
  ║     matrix M = (Vinegar | Oil).  Alice knows which columns are Oil;     ║
  ║     the adversary sees only the combined observation.  This is exactly  ║
  ║     the oil_fiber_map structure: the 5D fiber IS the space of valid     ║
  ║     signatures for the canonical message μ.                             ║
  ║                                                                          ║
  ║   Key results:                                                           ║
  ║     • Correctness: sign always produces a verifiable signature.         ║
  ║     • Unforgeability: signing is injective in the secret key.           ║
  ║     • Zero-knowledge: verify factors through observe (public key only). ║
  ║                                                                          ║
  ║   Sections                                                               ║
  ║   ────────                                                               ║
  ║   §1  Type definitions: Message, Signature, PublicKey, SecretKey        ║
  ║   §2  Protocol functions: keygen, sign, verify                          ║
  ║   §3  MQ hardness axiom                                                 ║
  ║   §4  Correctness theorem                                               ║
  ║   §5  Unforgeability precondition                                       ║
  ║   §6  Zero-knowledge property                                           ║
  ║   §7  #print axioms audit                                               ║
  ║                                                                          ║
  ║   Proof status                                                           ║
  ║   ────────────                                                           ║
  ║   Proven:  correctness, unforgeability_precondition,                    ║
  ║            zero_knowledge, zero_knowledge_key_independence              ║
  ║   Sorry:   none                                                          ║
  ║   Axioms:  MQ_hard  (computational hardness of the MQ problem)         ║
  ║                                                                          ║
  ║   Theorem dependency chain (all paths back to BalanceHypothesis):       ║
  ║   correctness                                                            ║
  ║     → oil_fiber_map_mem (FourSector §5b)                               ║
  ║     → oil_fiber_map, Coherent, observe (FourSector §§2–3)              ║
  ║     → BalanceHypothesis axioms                                          ║
  ║   unforgeability_precondition                                           ║
  ║     → alice_key_determines_state (FourSector §7)                       ║
  ║     → oil_fiber_five_dimensional (FourSector §5b)                      ║
  ║     → oil_fiber_map, OilParams, OilValid (FourSector §5b)              ║
  ║     → BalanceHypothesis axioms                                          ║
  ║   zero_knowledge                                                         ║
  ║     → keygen, observe (FourSector §§3,7)                               ║
  ║     → BalanceHypothesis axioms                                          ║
  ║                                                                          ║
  ║   Axiom dependency table (verifiable via `#print axioms` in §7):        ║
  ║                                                                          ║
  ║   Theorem                      MQ_hard   hidden_recovery_hard   BH†    ║
  ║   ────────────────────────────────────────────────────────────────────  ║
  ║   correctness                    ✗              ✗                ✓      ║
  ║   unforgeability_precondition    ✗              ✗                ✓      ║
  ║   zero_knowledge                 ✗              ✗                ✓      ║
  ║   zero_knowledge_key_independence ✗             ✗                ✗      ║
  ║                                                                          ║
  ║   † BH = BalanceHypothesis project axioms (shared by the whole project) ║
  ║                                                                          ║
  ║   NIST PQC reference: UOV (Unbalanced Oil and Vinegar) is a Round 2    ║
  ║   additional signature candidate.  This formalization is structurally   ║
  ║   compatible with the standard UOV construction over GF(p), with the   ║
  ║   four-sector geometry providing the domain structure.                  ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝
-/

import Observer

open Complex Real

-- Open Classical to enable propositional decidability for if-then-else on Props.
-- This is required for the Bool-valued `verify` function and follows the
-- noncomputable/classical style of the Eigenverse formalization.
open Classical

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Type Definitions
--
-- The four protocol types mirror the standard UOV construction:
--   SecretKey  = the oil-variable parametrization (Alice's trapdoor)
--   PublicKey  = the composed observation map P = S ∘ F ∘ T (no decomposition)
--   Message    = target value in the observation domain (canonical: μ)
--   Signature  = a FourState witnessing membership in the oil fiber
-- ════════════════════════════════════════════════════════════════════════════

/-- Message type: a complex number representing the target output of the public map.

    In the standard UOV construction over GF(p), a message is a vector
    `h ∈ GF(p)^m` (the hash of the message content).  In this formalization
    over ℂ, a message is the target value that the public map must evaluate to.

    The canonical message is `μ`: every valid signature produced by `sign` maps
    to `μ` under the public key.  This reflects the oil-fiber structure:
    `observe s = μ` for every `Coherent` state `s` in Alice's signing range.

    Dependency chain: Message → BalanceHypothesis (μ is defined there). -/
def Message : Type := ℂ

/-- A Signature witnesses a Coherent FourState in the oil fiber.

    In UOV, a signature is a variable vector `x ∈ GF(p)^n` satisfying
    `P(x) = h` (the public map equals the message hash).  Here, the
    "variable vector" is the full `FourState`, and the "public map check"
    is `observe state = μ`.

    The `hcoh` field certifies that the state satisfies the Coherent energy
    predicate (total normSq = 4), analogous to the constraint that the
    signature lies in the allowed domain.

    Alice constructs this witness using her trapdoor (`oil_fiber_map`):
    she fixes the vinegar variable Q2 = μ and freely parametrizes the
    oil variables Q1, Q3, Q4 via her five OilParams `(x₁, y₁, x₃, y₃, t)`.
    The zero block in the Oil columns of the mixing matrix makes this
    choice linear (not quadratic) in the oil variables, enabling efficient
    signing.

    Dependency chain: Signature → Coherent → FourSector §3 → BalanceHypothesis. -/
structure Signature where
  /-- The FourState witnessing the signature: the "variable vector" in UOV terms. -/
  state : FourState
  /-- Proof that the state satisfies the Coherent energy constraint. -/
  hcoh  : Coherent state

/-- The public key: the composed observation map P = S ∘ F ∘ T.

    In UOV, the public key is a set of quadratic polynomials `P = {p₁, …, pₘ}`
    obtained by composing the central map `F` with random linear maps `S`, `T`.
    The secret decomposition (F, S, T separately) is not recoverable from P.

    In this formalization, the public key is the observation function `observe`:
    a projection `FourState → ℂ` that extracts the Q2 (vinegar) component.
    Every key holder shares the same public key (`observe`), analogous to all
    UOV public keys being drawn from the same polynomial-map family.  The
    distinguishing information — *which* oil-fiber decomposition Alice uses —
    is encoded in the `SecretKey` and is not recoverable from `observe` alone.

    Dependency chain: PublicKey → observe → FourSector §3 → BalanceHypothesis. -/
abbrev PublicKey : Type := FourState → ℂ

/-- The secret key: Alice's OilParams (the trapdoor decomposition).

    This is `AliceKey` from FourSector §7: a valid set of five real parameters
    `(x₁, y₁, x₃, y₃, t)` encoding the full hidden-sector state.  Alice's
    advantage is that she knows which columns of the mixing matrix are Oil
    (Q1, Q3, Q4) vs. Vinegar (Q2 = μ).

    The adversary never obtains this value — they only see `observe s = μ`,
    which is identical for every key Alice might hold.

    Dependency chain: SecretKey = AliceKey → OilParams, OilValid → FourSector §5b
                    → BalanceHypothesis. -/
abbrev SecretKey : Type := AliceKey

-- ════════════════════════════════════════════════════════════════════════════
-- §2  Protocol Functions: keygen, sign, verify
--
-- The three protocol algorithms follow the standard UOV structure:
--   keygen  — derives the one-way public map from the secret key
--   sign    — uses the trapdoor to construct a valid signature
--   verify  — checks the public map on the signature equals the message
-- ════════════════════════════════════════════════════════════════════════════

/-- Derive the public key from the secret key.

    The public key is the observation function `observe`: a projection that
    maps every `FourState` to its Q2 (vinegar) component.  This is the
    "composed quadratic map" P = S ∘ F ∘ T in UOV terms.

    Key properties:
    - **One-way**: `keygen` is the same function for all secret keys.  An
      adversary who knows `keygen sk = observe` gains no information about
      `sk` — this is proved by `zero_knowledge` and `adversary_view_constant`.
    - **Uniform**: all users share the same public key family, analogous to
      all UOV public keys being quadratic maps over the same variable space.

    Dependency chain: keygen → observe → FourSector §3 → BalanceHypothesis. -/
def keygen (_ : SecretKey) : PublicKey := observe

/-- Sign a message using the secret key.

    Alice uses her trapdoor (`oil_fiber_map`) to construct a Coherent FourState
    in the oil fiber.  This is the UOV "fix vinegar, solve linear system" step:

    - **Vinegar fixed**: the Q2 component is always μ, fixed by the fiber
      constraint `observe (oil_fiber_map p hv) = μ` (from `oil_fiber_map_mem`).
    - **Oil variables free**: the five OilParams `(x₁, y₁, x₃, y₃, t)` encode
      Q1 = x₁ + iy₁, Q3 = x₃ + iy₃, and Q4 = r₄·t − i·r₄·√(1−t²).
    - **Linear system**: the zero block in the Oil columns of the mixing matrix
      means the Q1, Q3, Q4 components can be freely chosen (subject to the
      Coherent energy constraint), making the "solve" step trivial for Alice.
    - **Trapdoor**: Alice's knowledge of OilParams is the trapdoor — it lets
      her efficiently parametrize the 5D oil fiber.  An adversary without this
      parametrization cannot exploit the linear structure.

    The resulting Signature satisfies `observe sig.state = μ`, so it verifies
    correctly against the canonical message μ under the public key `keygen sk`.

    Note: the `msg` argument is accepted for interface compatibility but does
    not influence the output in this model, reflecting the single-message
    structure (canonical message = μ) of the four-sector oil fiber.

    Dependency chain: sign → alice_prepares → oil_fiber_map_mem → oil_fiber_map
                    → FourSector §§5,5b → BalanceHypothesis. -/
noncomputable def sign (sk : SecretKey) (_ : Message) : Signature :=
  { state := alice_prepares sk
    hcoh  := (oil_fiber_map_mem sk.1 sk.2).1 }

/-- Verify a signature against a public key and message.

    Returns `true` iff the public key evaluates to the message on the
    signature's state: `pk sig.state = msg`.  This is the standard UOV
    verification check `P(x) = h`, where `x = sig.state` is the variable
    vector and `h = msg` is the message hash.

    Implementation note: the `if-then-else` on a `Prop` is handled classically
    (via `open Classical` at the top of this file), consistent with the
    `noncomputable` style of the Eigenverse formalization.  The `verify`
    function is not intended to be executed; it is a specification artifact.

    Dependency chain: verify → PublicKey, Message, Signature → FourSector §§2–3. -/
noncomputable def verify (pk : PublicKey) (msg : Message) (sig : Signature) : Bool :=
  if pk sig.state = msg then true else false

-- ════════════════════════════════════════════════════════════════════════════
-- §3  MQ Hardness Axiom
--
-- The Multivariate Quadratic (MQ) problem is the computational hardness
-- assumption underlying UOV.  We declare it as an axiom, analogous to
-- `hidden_recovery_hard` in FourSector §6.
-- ════════════════════════════════════════════════════════════════════════════

/-- **MQ hardness axiom** — the Multivariate Quadratic problem is computationally hard.

    No total adversary A (receiving only the public key and message) can always
    forge a signature identical to the one Alice would produce.  Two distinct
    secret keys produce distinct signatures (by `unforgeability_precondition`)
    but identical public keys (by `zero_knowledge_key_independence`), so any
    deterministic A fails on at least one key.

    **Structural version (provable)**: the statement below — that no total
    function `A : PublicKey → Message → Signature` can always replicate Alice's
    signing output — is actually provable as a theorem, by the same argument as
    `adversary_cannot_recover` in FourSector §7:
      * Two distinct keys `sk₁ ≠ sk₂` produce distinct signatures (`sign sk₁ ≠ sign sk₂`
        by `unforgeability_precondition`) but the same public key (`keygen sk₁ = keygen sk₂`
        by definition of `keygen`).
      * Any deterministic `A` gives the same output for both keys, so it fails on one.

    **True cryptographic claim (unproven)**: no *polynomial-time* adversary can,
    given `pk = keygen sk` and a message `msg`, produce a Signature `sig` satisfying
    `verify pk msg sig = true` without knowing `sk`.  This is the standard MQ
    hardness assumption over GF(p), and the genuine cryptographic assumption
    underlying UOV.

    **Status**: declared as an `axiom` to flag the computational hardness claim
    as unproven, exactly as `hidden_recovery_hard` flags the observation-inversion
    hardness.  The structural version can be derived as a theorem (see proof of
    `unforgeability_precondition`); the computational version requires an external
    reduction.

    Dependency chain: MQ_hard → keygen, sign → oil_fiber_map → BalanceHypothesis. -/
axiom MQ_hard :
    ∀ (A : PublicKey → Message → Signature),
      ∃ sk : SecretKey, A (keygen sk) μ ≠ sign sk μ

-- ════════════════════════════════════════════════════════════════════════════
-- §4  Correctness Theorem
--
-- Signing with the canonical message μ always produces a valid signature.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Correctness** — signing always produces a valid signature.

    For any secret key `sk`, the signature produced by `sign sk μ` verifies
    correctly under the public key `keygen sk` and the canonical message `μ`.

    Proof outline:
    1. `keygen sk = observe` (by definition of `keygen`).
    2. `(sign sk μ).state = alice_prepares sk` (by definition of `sign`).
    3. `observe (alice_prepares sk) = μ` (by `oil_fiber_map_mem`, which proves
       every oil-fiber state has `observe = μ`; this in turn uses the five-parameter
       oil fiber construction, whose validity depends on the Coherent constraint
       and `visible_unique` from `BalanceHypothesis`).
    4. So `keygen sk (sign sk μ).state = μ`, the `if`-branch is taken, and
       `verify` returns `true`.

    The canonical message `μ` is the unique verifiable message in this model:
    every state Alice can construct has `observe = μ` (by `adversary_view_constant`).
    This reflects the single-message structure of the four-sector oil fiber.

    Dependency chain: correctness → oil_fiber_map_mem → oil_fiber_map
                    → FourSector §5b → visible_unique → BalanceHypothesis. -/
theorem correctness (sk : SecretKey) : verify (keygen sk) μ (sign sk μ) = true :=
  if_pos (oil_fiber_map_mem sk.1 sk.2).2

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Unforgeability Precondition
--
-- Signing is injective in the secret key: any function that replicates Alice's
-- signing behaviour must hold the same secret key.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Unforgeability precondition** — signing requires the secret key.

    If two secret keys produce the same signing function — that is, they produce
    identical signatures on every message — then the keys must be equal.
    Equivalently, the map `sk ↦ sign sk` is injective.

    This is the UOV "signature injection" property: the trapdoor encodes unique
    identity information in every signature.  An adversary who can forge Alice's
    signatures must effectively hold Alice's secret key.

    Proof:
    1. From `∀ msg, sign sk₁ msg = sign sk₂ msg`, apply to `msg = μ` to get
       `sign sk₁ μ = sign sk₂ μ` (a Signature equality).
    2. Extract the `state` field: `alice_prepares sk₁ = alice_prepares sk₂`.
       (The `hcoh` fields are both proofs of `Coherent _` and equal by proof
       irrelevance; the `state` field carries all distinguishing information.)
    3. Apply `alice_key_determines_state` (= `oil_fiber_five_dimensional`):
       `alice_prepares` is injective, so `sk₁ = sk₂`.

    The injectivity of `alice_prepares` is the key structural fact, proved
    by recovering all five OilParams from the FourState components:
    q1 recovers (x₁, y₁), q3 recovers (x₃, y₃), q4.re with the known radius
    recovers t.  This uses the five-dimensional parametrization of the oil fiber.

    Dependency chain: unforgeability_precondition → alice_key_determines_state
                    → oil_fiber_five_dimensional → oil_fiber_map
                    → FourSector §5b → BalanceHypothesis. -/
theorem unforgeability_precondition :
    ∀ sk₁ sk₂ : SecretKey,
      (∀ msg : Message, sign sk₁ msg = sign sk₂ msg) → sk₁ = sk₂ := by
  intro sk₁ sk₂ h
  -- Extract state equality from the Signature equality at msg = μ.
  have hstate : alice_prepares sk₁ = alice_prepares sk₂ :=
    congrArg Signature.state (h μ)
  -- Apply the injectivity of alice_prepares (= oil_fiber_five_dimensional).
  exact alice_key_determines_state hstate

-- ════════════════════════════════════════════════════════════════════════════
-- §6  Zero-Knowledge Property
--
-- The verify function reveals nothing about the secret key beyond what the
-- public observation already exposes.  This is formalized as a factoring
-- property: verify (keygen sk) factors through observe.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Zero-knowledge** — `verify` reveals nothing about the secret key.

    The `verify` function, when applied to a public key derived from any secret
    key `sk` via `keygen`, factors through `observe`.  That is, there exists a
    function `f : ℂ → Message → Signature → Bool` such that:

        `verify (keygen sk) msg sig = f (observe sig.state) msg sig`

    for all `sk`, `msg`, `sig`.  Since `f` depends only on `observe sig.state`
    (not on `sk` or the full `FourState` structure), the output of `verify` is
    entirely determined by the observable sector Q2 — it reveals nothing about
    the hidden sectors Q1, Q3, Q4, and hence nothing about Alice's OilParams.

    The factoring function `f v msg sig = (if v = msg then true else false)` makes
    the chain explicit:

        verify (keygen sk) msg sig
          = if observe sig.state = msg then true else false
          = f (observe sig.state) msg sig

    where the first equality holds because `keygen sk = observe` for all `sk`
    (by definition of `keygen`), and the second by definition of `f`.

    **Deeper structure**: since `keygen sk = observe` is independent of `sk`,
    the public key itself factors through the trivial function (it IS `observe`).
    This is the algebraic form of the zero-knowledge property: the verification
    equation is `observe sig.state = msg`, which depends only on the observable
    Q2 component of the signature — exactly the data that `observe` exposes.

    Dependency chain: zero_knowledge → keygen, verify → observe
                    → FourSector §3 → BalanceHypothesis. -/
theorem zero_knowledge :
    ∃ f : ℂ → Message → Signature → Bool,
      ∀ (sk : SecretKey) (msg : Message) (sig : Signature),
        verify (keygen sk) msg sig = f (observe sig.state) msg sig :=
  ⟨fun v msg sig => if v = msg then true else false, fun _ _ _ => rfl⟩

/-- **Zero-knowledge key independence** — `verify` output is independent of which
    secret key was used to derive the public key.

    Any two secret keys `sk₁`, `sk₂` produce the same verification outcome for
    every message and signature:

        `verify (keygen sk₁) msg sig = verify (keygen sk₂) msg sig`

    Proof: `keygen sk = observe` for ALL `sk` (by definition), so
    `keygen sk₁ = keygen sk₂ = observe`, and `verify (keygen sk₁) msg sig`
    is definitionally equal to `verify (keygen sk₂) msg sig`.

    This is the formal statement of "the public key reveals no information about
    the secret key": an adversary with `keygen sk₁` and `keygen sk₂` cannot
    distinguish the two keys by running `verify`.

    Dependency chain: zero_knowledge_key_independence → keygen, verify
                    → FourSector §3 (observe definition). -/
theorem zero_knowledge_key_independence :
    ∀ sk₁ sk₂ : SecretKey, ∀ (msg : Message) (sig : Signature),
      verify (keygen sk₁) msg sig = verify (keygen sk₂) msg sig :=
  fun _ _ _ _ => rfl

end -- noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §7  #print axioms Audit
--
-- Running `#print axioms <theorem>` reveals the complete transitive closure
-- of axioms a proof depends on.  The expected results are listed below.
--
-- Expected results:
--
--   correctness, unforgeability_precondition, zero_knowledge
--   ─────────────────────────────────────────────────────────
--   Should list:
--     • Lean/Mathlib propositional axioms:
--         propext, funext (Eq.propIntro), Classical.choice, Quot.sound
--     • BalanceHypothesis project axioms (for correctness and unforgeability):
--         balance_from_unit_circle, mu_re_neg, mu_im_pos, mu_abs_one,
--         eta_pos, hidden_recovery_hard  (transitively, through oil_fiber_map)
--     • NOT MQ_hard (it is declared but not used by the three core theorems)
--
--   zero_knowledge_key_independence
--   ────────────────────────────────
--   Should list ONLY Lean/Mathlib propositional axioms (no project axioms
--   at all: the proof is `rfl`, which uses no axioms beyond the standard ones).
-- ════════════════════════════════════════════════════════════════════════════

section AxiomAudit

-- Audit: core protocol theorems (expect Mathlib + BH axioms, NOT MQ_hard).
#print axioms correctness
#print axioms unforgeability_precondition
#print axioms zero_knowledge

-- Audit: key-independence corollary (expect only Mathlib axioms).
#print axioms zero_knowledge_key_independence

end AxiomAudit
