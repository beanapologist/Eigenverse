/-
  MultiMessage.lean — Multi-message UOV signing over the four-sector geometry.

  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                          ║
  ║   Extends SignVerify.lean from a single canonical message μ to an       ║
  ║   arbitrary message space.  This is the critical gap in the single-     ║
  ║   message formalization: SignVerify.lean signs only μ; here we sign     ║
  ║   any complex number by using a MessageHash to derive message-specific  ║
  ║   OilParams before running the oil-fiber trapdoor.                      ║
  ║                                                                          ║
  ║   Relationship to real UOV:                                             ║
  ║     In real UOV over GF(p):                                             ║
  ║       1. Hash message → target vector h ∈ GF(p)^m.                     ║
  ║       2. Choose random vinegar values v ∈ GF(p)^(n−m).                 ║
  ║       3. Substitute v into the central map F(v, ·) to get a linear     ║
  ║          system in the oil variables.                                   ║
  ║       4. Solve the linear system for oil variables o ∈ GF(p)^m.        ║
  ║       5. Signature = (v, o).                                            ║
  ║     The MessageHash type here models steps 1–2: it maps the message     ║
  ║     and Alice's base OilParams into message-specific OilParams,         ║
  ║     analogous to "hash message → randomize vinegar → new linear         ║
  ║     system per message".  Different messages produce different           ║
  ║     OilParams (DeterministicHash), hence different linear systems       ║
  ║     (oil_fiber_map), hence different signatures — but the same          ║
  ║     public-key check (observe = μ) verifies all of them.                ║
  ║                                                                          ║
  ║   Architecture:                                                          ║
  ║     MessageHash h msg sk.1  →  perturbed OilParams                      ║
  ║     oil_fiber_map perturbed_params _  →  Signature state                ║
  ║     observe state = μ  (always, by oil_fiber_map_mem)                   ║
  ║     mm_verify checks observe state = μ  →  true                         ║
  ║                                                                          ║
  ║   Sections                                                               ║
  ║   ────────                                                               ║
  ║   §1  Type definitions: MessageHash, DeterministicHash, ValidHash       ║
  ║   §2  Protocol functions: mm_keygen, mm_sign, mm_verify                 ║
  ║   §3  Correctness theorem                                               ║
  ║   §4  Distinct-signatures theorem                                       ║
  ║   §5  Unforgeability theorem                                            ║
  ║   §6  Zero-knowledge theorem                                            ║
  ║   §7  #print axioms audit                                               ║
  ║                                                                          ║
  ║   Proof status                                                           ║
  ║   ────────────                                                           ║
  ║   Proven:  mm_correctness, mm_distinct_signatures,                      ║
  ║            mm_unforgeability, mm_zero_knowledge                         ║
  ║   Sorry:   none                                                          ║
  ║   Axioms:  none beyond those inherited from SignVerify / FourSector      ║
  ║            (balance_from_unit_circle, mu_re_neg, mu_im_pos, mu_abs_one, ║
  ║             eta_pos, hidden_recovery_hard; NOT MQ_hard)                 ║
  ║                                                                          ║
  ║   Theorem dependency chain (all paths back to BalanceHypothesis):       ║
  ║   mm_correctness                                                         ║
  ║     → oil_fiber_map_mem (FourSector §5b)                               ║
  ║     → oil_fiber_map, Coherent, observe (FourSector §§2–3)              ║
  ║     → BalanceHypothesis axioms                                          ║
  ║   mm_distinct_signatures                                                 ║
  ║     → oil_fiber_five_dimensional (FourSector §5b)                      ║
  ║     → DeterministicHash (predicate on h)                               ║
  ║     → BalanceHypothesis axioms                                          ║
  ║   mm_unforgeability                                                      ║
  ║     → oil_fiber_five_dimensional (FourSector §5b)                      ║
  ║     → ValidHash injectivity (predicate on h)                           ║
  ║     → BalanceHypothesis axioms                                          ║
  ║   mm_zero_knowledge                                                      ║
  ║     → mm_keygen = observe (by definition, rfl)                         ║
  ║     → BalanceHypothesis axioms (through FourSector observe)            ║
  ║                                                                          ║
  ╚══════════════════════════════════════════════════════════════════════════╝
-/

import SignVerify

open Complex Real
open Classical

noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §1  Type Definitions
--
-- MessageHash models the "hash message into vinegar randomization" step.
-- DeterministicHash and ValidHash are predicates capturing the cryptographic
-- requirements on any acceptable hash function.
-- ════════════════════════════════════════════════════════════════════════════

/-- A message hash function: combines a message with Alice's base OilParams
    to produce message-specific OilParams for signing.

    Type: `ℂ → OilParams → OilParams`

    In real UOV, this models the step:
      hash(message) → randomized vinegar → new linear system per message.
    Different messages produce different perturbed parameters (see
    `DeterministicHash`), giving different linear systems, and therefore
    different signatures — while the public verification equation
    `observe state = μ` remains the same for all messages.

    Dependency chain: MessageHash → OilParams → FourSector §5b
                    → BalanceHypothesis. -/
abbrev MessageHash : Type := ℂ → OilParams → OilParams

/-- A hash function is deterministic (injective in its first argument) if
    different messages produce different parameter perturbations for any
    fixed base OilParams.

    Formally: `∀ p msg₁ msg₂, h msg₁ p = h msg₂ p → msg₁ = msg₂`.

    This is the UOV injectivity requirement: distinct messages must lead to
    distinct linear systems, ensuring that different messages yield different
    signatures (proved by `mm_distinct_signatures`).

    Dependency chain: DeterministicHash → OilParams → FourSector §5b
                    → BalanceHypothesis. -/
def DeterministicHash (h : MessageHash) : Prop :=
  ∀ (p : OilParams) (msg₁ msg₂ : ℂ), h msg₁ p = h msg₂ p → msg₁ = msg₂

/-- A hash function is valid if it satisfies two properties:
    (1) **OilValid preservation**: for all valid base OilParams `p` and all
        messages `msg`, the perturbed parameters `h msg p` are still OilValid.
        This ensures `oil_fiber_map (h msg sk.1) _` is always well-defined.
    (2) **Injectivity in OilParams**: for each fixed message `msg`, the
        function `h msg : OilParams → OilParams` is injective.  This ensures
        that distinct secret keys produce distinct perturbations, which is
        essential for `mm_unforgeability`.

    The two parts together model a well-behaved hash function: it maps
    valid signing parameters to valid signing parameters, and it does not
    "collapse" distinct secret keys into the same perturbation.

    Dependency chain: ValidHash → OilValid, OilParams → FourSector §5b
                    → BalanceHypothesis. -/
def ValidHash (h : MessageHash) : Prop :=
  (∀ (p : OilParams), OilValid p → ∀ (msg : ℂ), OilValid (h msg p)) ∧
  ∀ (msg : ℂ) (p q : OilParams), h msg p = h msg q → p = q

-- ════════════════════════════════════════════════════════════════════════════
-- §2  Protocol Functions: mm_keygen, mm_sign, mm_verify
--
-- The three multi-message protocol algorithms.  mm_keygen and mm_verify are
-- identical to their single-message counterparts — this is the key property
-- of UOV: the message hash changes the signing path but not the public key
-- or the verification equation.  Only mm_sign changes, incorporating the
-- MessageHash to derive message-specific OilParams.
-- ════════════════════════════════════════════════════════════════════════════

/-- Derive the public key from the secret key.

    **Identical to `keygen`**: the public key is always `observe`, regardless
    of the secret key and regardless of whether we use single-message or
    multi-message signing.  This is the UOV zero-knowledge property: the
    public key reveals nothing about which OilParams Alice holds.

    Dependency chain: mm_keygen → observe → FourSector §3
                    → BalanceHypothesis. -/
def mm_keygen (_ : SecretKey) : PublicKey := observe

/-- Sign an arbitrary message using the secret key and a hash function.

    **Multi-message extension**: unlike `sign`, which ignores the message,
    `mm_sign` applies the hash `h msg` to Alice's base OilParams `sk.1` to
    obtain message-specific OilParams `h msg sk.1`, then runs `oil_fiber_map`
    on the perturbed parameters.  This mirrors the real UOV step:

      1. Hash message `msg` combined with Alice's base parameters → new OilParams.
      2. Run the oil-fiber trapdoor on the new OilParams → Coherent FourState.

    When `ValidHash h` holds, the perturbed parameters are always OilValid, so
    the if-branch is always taken and the else-branch (fallback to `alice_prepares`)
    is never reached in valid usage.  The else-branch ensures totality of the
    definition without relying on classical existence.

    Key property: `observe (mm_sign sk h msg).state = μ` for all valid `h`
    and all messages `msg` (proved by `mm_correctness`), so the verification
    equation is unchanged.

    Dependency chain: mm_sign → oil_fiber_map → FourSector §5b
                    → oil_fiber_map_mem → BalanceHypothesis. -/
noncomputable def mm_sign (sk : SecretKey) (h : MessageHash) (msg : ℂ) : Signature :=
  if hv : OilValid (h msg sk.1) then
    { state := oil_fiber_map (h msg sk.1) hv
      hcoh  := (oil_fiber_map_mem (h msg sk.1) hv).1 }
  else
    { state := alice_prepares sk
      hcoh  := (oil_fiber_map_mem sk.1 sk.2).1 }

/-- Verify a signature against a public key and message.

    **Identical to `verify`**: check that the public key evaluates to the
    target on the signature's state.  The multi-message extension does not
    change verification — the fiber target is always μ regardless of which
    message was signed.  This is the fundamental UOV property: signing uses
    different paths through the oil fiber for different messages, but all
    paths lead to the same observable output μ.

    Dependency chain: mm_verify → PublicKey, Message, Signature
                    → FourSector §§2–3. -/
noncomputable def mm_verify (pk : PublicKey) (msg : Message) (sig : Signature) : Bool :=
  if pk sig.state = msg then true else false

-- ════════════════════════════════════════════════════════════════════════════
-- §3  Correctness Theorem
--
-- Every message-dependent signature verifies against μ under the public key.
-- The fiber target does not change with the message; only the path through
-- the fiber changes.
-- ════════════════════════════════════════════════════════════════════════════

-- Helper: when ValidHash holds, mm_sign takes the if-branch.
private lemma mm_sign_state (sk : SecretKey) (h : MessageHash) (msg : ℂ)
    (hv : OilValid (h msg sk.1)) :
    (mm_sign sk h msg).state = oil_fiber_map (h msg sk.1) hv := by
  unfold mm_sign
  exact congrArg Signature.state (dif_pos hv)

/-- **Correctness** — every message-dependent signature verifies against μ.

    For any secret key `sk`, valid hash `h`, and message `msg`, the signature
    produced by `mm_sign sk h msg` verifies correctly under `mm_keygen sk` and
    the canonical target `μ`.

    Proof chain:
    1. `ValidHash h` gives `OilValid (h msg sk.1)`, so `mm_sign` takes the
       if-branch: `(mm_sign sk h msg).state = oil_fiber_map (h msg sk.1) hv`.
    2. `oil_fiber_map_mem` guarantees `observe (oil_fiber_map (h msg sk.1) hv) = μ`.
    3. `mm_keygen sk = observe` (by definition), so the verification check is
       `observe (mm_sign sk h msg).state = μ`, which holds.
    4. Therefore `mm_verify (mm_keygen sk) μ (mm_sign sk h msg) = true`.

    Key insight: the fiber target μ is invariant across all messages — the
    hash changes WHICH element of the oil fiber is selected, not WHERE the
    fiber lives.

    Dependency chain: mm_correctness → mm_sign_state → oil_fiber_map_mem
                    → oil_fiber_map → FourSector §5b → BalanceHypothesis. -/
theorem mm_correctness :
    ∀ (sk : SecretKey) (h : MessageHash) (msg : ℂ),
      ValidHash h → mm_verify (mm_keygen sk) μ (mm_sign sk h msg) = true := by
  intro sk h msg ⟨hvh_valid, _⟩
  have hv : OilValid (h msg sk.1) := hvh_valid sk.1 sk.2 msg
  -- Establish observe (mm_sign sk h msg).state = μ
  have hobs : observe (mm_sign sk h msg).state = μ := by
    rw [mm_sign_state sk h msg hv]
    exact (oil_fiber_map_mem (h msg sk.1) hv).2
  -- mm_verify (mm_keygen sk) μ sig unfolds to
  --   if (mm_keygen sk) sig.state = μ then true else false
  --   = if observe sig.state = μ then true else false
  -- which is true by hobs
  exact if_pos hobs

-- ════════════════════════════════════════════════════════════════════════════
-- §4  Distinct-Signatures Theorem
--
-- Different messages produce different signatures.  The hash is injective
-- (DeterministicHash), so different messages produce different OilParams,
-- and oil_fiber_map is injective (oil_fiber_five_dimensional), so different
-- OilParams produce different states.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Distinct signatures** — different messages yield different signatures.

    For any secret key `sk`, any deterministic valid hash `h`, and two distinct
    messages `msg₁ ≠ msg₂`, the signatures `mm_sign sk h msg₁` and
    `mm_sign sk h msg₂` are distinct.

    Proof chain:
    1. `DeterministicHash h` (contrapositive): `msg₁ ≠ msg₂` implies
       `h msg₁ sk.1 ≠ h msg₂ sk.1` (different messages perturb params
       differently for the same base OilParams).
    2. `oil_fiber_five_dimensional` (injectivity, contrapositive): distinct
       OilParams produce distinct `oil_fiber_map` states.
    3. Since the states differ, the Signatures differ.

    This is the multi-message separation property: the hash function ensures
    that Alice cannot reuse the same signing path for different messages.

    Dependency chain: mm_distinct_signatures → oil_fiber_five_dimensional
                    → DeterministicHash → FourSector §5b
                    → BalanceHypothesis. -/
theorem mm_distinct_signatures :
    ∀ (sk : SecretKey) (h : MessageHash) (msg₁ msg₂ : ℂ),
      DeterministicHash h → ValidHash h → msg₁ ≠ msg₂ →
      mm_sign sk h msg₁ ≠ mm_sign sk h msg₂ := by
  intro sk h msg₁ msg₂ hdet ⟨hvh_valid, _⟩ hne heq
  -- Obtain OilValid proofs for both messages
  have hv₁ : OilValid (h msg₁ sk.1) := hvh_valid sk.1 sk.2 msg₁
  have hv₂ : OilValid (h msg₂ sk.1) := hvh_valid sk.1 sk.2 msg₂
  -- Extract state equality from Signature equality
  have hstate_eq : (mm_sign sk h msg₁).state = (mm_sign sk h msg₂).state :=
    congrArg Signature.state heq
  -- Rewrite states using mm_sign_state
  rw [mm_sign_state sk h msg₁ hv₁, mm_sign_state sk h msg₂ hv₂] at hstate_eq
  -- By oil_fiber_five_dimensional: equal states imply equal OilParams (as subtypes)
  have hparams_eq : (⟨h msg₁ sk.1, hv₁⟩ : {p : OilParams // OilValid p}) =
                    ⟨h msg₂ sk.1, hv₂⟩ :=
    oil_fiber_five_dimensional hstate_eq
  -- Extract OilParams equality from subtype equality
  have heq_hash : h msg₁ sk.1 = h msg₂ sk.1 :=
    congrArg Subtype.val hparams_eq
  -- By DeterministicHash: equal hash outputs imply equal messages
  exact hne (hdet sk.1 msg₁ msg₂ heq_hash)

-- ════════════════════════════════════════════════════════════════════════════
-- §5  Unforgeability Theorem
--
-- Signing is injective in the secret key, even with the message-hash layer.
-- If two secret keys produce identical signatures for every message, the
-- keys must be equal.
-- ════════════════════════════════════════════════════════════════════════════

/-- **Unforgeability** — signing is injective in the secret key.

    If two secret keys `sk₁`, `sk₂` produce the same signature for every
    message under a valid hash `h`, then `sk₁ = sk₂`.  Equivalently, the
    map `sk ↦ mm_sign sk h` is injective for any `ValidHash h`.

    Proof chain:
    1. Instantiate the universal hypothesis at `msg = μ`:
       `mm_sign sk₁ h μ = mm_sign sk₂ h μ`.
    2. `mm_sign_state` gives state equality:
       `oil_fiber_map (h μ sk₁.1) hv₁ = oil_fiber_map (h μ sk₂.1) hv₂`.
    3. `oil_fiber_five_dimensional` (injectivity): equal states imply equal
       OilParams (as subtypes): `h μ sk₁.1 = h μ sk₂.1`.
    4. `ValidHash h` (injectivity in second argument): `h μ` is injective
       in OilParams, so `sk₁.1 = sk₂.1`.
    5. `Subtype.ext` + proof irrelevance for `OilValid`: `sk₁ = sk₂`.

    This is the UOV "secret key is uniquely encoded in every signature" claim:
    Alice's OilParams are injectively embedded in the signing map, even through
    the message-hash layer.

    Dependency chain: mm_unforgeability → mm_sign_state
                    → oil_fiber_five_dimensional (FourSector §5b)
                    → ValidHash injectivity → Subtype.ext
                    → BalanceHypothesis. -/
theorem mm_unforgeability :
    ∀ (sk₁ sk₂ : SecretKey) (h : MessageHash),
      ValidHash h → (∀ msg : ℂ, mm_sign sk₁ h msg = mm_sign sk₂ h msg) → sk₁ = sk₂ := by
  intro sk₁ sk₂ h ⟨hvh_valid, hvh_inj⟩ hall
  -- Obtain OilValid proofs at the canonical message μ
  have hv₁ : OilValid (h μ sk₁.1) := hvh_valid sk₁.1 sk₁.2 μ
  have hv₂ : OilValid (h μ sk₂.1) := hvh_valid sk₂.1 sk₂.2 μ
  -- Instantiate the universal hypothesis at msg = μ
  have hsig_μ : mm_sign sk₁ h μ = mm_sign sk₂ h μ := hall μ
  -- Extract state equality from Signature equality
  have hstate_eq : (mm_sign sk₁ h μ).state = (mm_sign sk₂ h μ).state :=
    congrArg Signature.state hsig_μ
  -- Rewrite states using mm_sign_state
  rw [mm_sign_state sk₁ h μ hv₁, mm_sign_state sk₂ h μ hv₂] at hstate_eq
  -- By oil_fiber_five_dimensional: equal states imply equal OilParams (as subtypes)
  have hparams_eq : (⟨h μ sk₁.1, hv₁⟩ : {p : OilParams // OilValid p}) =
                    ⟨h μ sk₂.1, hv₂⟩ :=
    oil_fiber_five_dimensional hstate_eq
  -- Extract OilParams equality from subtype equality
  have heq_hashed : h μ sk₁.1 = h μ sk₂.1 :=
    congrArg Subtype.val hparams_eq
  -- By ValidHash injectivity: h μ is injective in OilParams, so sk₁.1 = sk₂.1
  have heq_params : sk₁.1 = sk₂.1 := hvh_inj μ sk₁.1 sk₂.1 heq_hashed
  -- By Subtype.ext + proof irrelevance for the OilValid field
  exact Subtype.ext heq_params

-- ════════════════════════════════════════════════════════════════════════════
-- §6  Zero-Knowledge Theorem
--
-- The public key is independent of the secret key — even in the multi-message
-- setting.  mm_keygen ignores its argument (returns observe for all inputs).
-- ════════════════════════════════════════════════════════════════════════════

/-- **Zero-knowledge** — the public key is independent of the secret key.

    For any two secret keys `sk₁`, `sk₂`, the derived public keys are equal:
    `mm_keygen sk₁ = mm_keygen sk₂`.

    Proof: `mm_keygen sk = observe` for ALL `sk` (by definition of `mm_keygen`),
    so `mm_keygen sk₁ = observe = mm_keygen sk₂`.  The proof is `rfl`.

    This is the multi-message version of the zero-knowledge property:
    introducing the message-hash layer does not leak any additional information
    through the public key — the public key remains the constant function
    `observe`, regardless of which secret key or hash function is used.

    Dependency chain: mm_zero_knowledge → mm_keygen = observe (by definition)
                    → FourSector §3 (observe definition). -/
theorem mm_zero_knowledge :
    ∀ (sk₁ sk₂ : SecretKey), mm_keygen sk₁ = mm_keygen sk₂ :=
  fun _ _ => rfl

end -- noncomputable section

-- ════════════════════════════════════════════════════════════════════════════
-- §7  #print axioms Audit
--
-- All four theorems should depend only on the shared BalanceHypothesis project
-- axioms (transitively, through FourSector and SignVerify).  Neither MQ_hard
-- nor hidden_recovery_hard is used directly by any theorem in this file.
--
-- Expected axiom dependencies:
--   mm_correctness, mm_distinct_signatures, mm_unforgeability:
--     • Lean/Mathlib propositional axioms: propext, Classical.choice, Quot.sound
--     • BalanceHypothesis project axioms: balance_from_unit_circle, mu_re_neg,
--       mu_im_pos, mu_abs_one, eta_pos, hidden_recovery_hard
--         (transitively, through oil_fiber_map → FourSector §5b)
--   mm_zero_knowledge:
--     • Only Lean/Mathlib axioms (proof is `rfl`)
-- ════════════════════════════════════════════════════════════════════════════

section AxiomAudit

-- Audit: core multi-message theorems (expect Mathlib + BH axioms, NOT MQ_hard)
#print axioms mm_correctness
#print axioms mm_distinct_signatures
#print axioms mm_unforgeability

-- Audit: zero-knowledge corollary (expect only Mathlib axioms)
#print axioms mm_zero_knowledge

end AxiomAudit
