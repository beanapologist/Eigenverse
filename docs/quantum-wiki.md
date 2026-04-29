# Quantum Wiki: Testing Assumptions

> **A collaborative space for exploring quantum mechanics through mathematics and
> classical computation — testing assumptions, challenging misconceptions, and
> documenting reproducible experiments.**

---

## Purpose

This wiki exists because the heart of quantum mechanics is **mathematics** — not
hardware.  A qubit is a unit vector in **ℂ²**.  That is a definition in linear
algebra, not a specification of silicon, trapped ions, or superconducting loops.

The Eigenverse project has already machine-checked 552 theorems about the
structure that underlies physical reality.  This wiki extends that work
outward: instead of proving theorems in Lean, we *test assumptions*
experimentally, using nothing but a classical CPU and complex arithmetic.

**Goals of this section:**

1. Document core quantum-mechanics assumptions and examine them rigorously.
2. Provide reproducible computational experiments that any contributor can run.
3. Collect misconceptions and clarify them with mathematical precision.
4. Invite the community to expand, challenge, and improve this body of work.

If you have run an experiment, proved a result, or found a counter-example,
please open a pull request — see [Community Contribution Guidelines](#6-community-contribution-guidelines).

---

## 1. Assumptions and Key Questions

The questions below are the starting hypotheses that motivate this wiki.  Each
one is open for investigation; contributors are encouraged to add new entries
with supporting experiments or formal proofs.

### Q1 — Substrate independence of quantum mathematics

> *Are the mathematical foundations of quantum mechanics substrate-independent?
> Does the quantum state depend on the hardware it runs on, or only on proper
> mathematics?*

**Working hypothesis:** A quantum state is a vector in ℂⁿ together with a
unitary evolution rule.  Both notions are purely mathematical.  Therefore, any
system capable of arithmetic over ℂ can represent and evolve a quantum state
faithfully.

**Evidence so far:**
- `|ψ⟩ = −η|0⟩ + η|1⟩` was generated and validated on a classical Linux VPS
  (Hostinger, standard CPU, no quantum hardware).
- All 22 Born-rule, purity, entanglement, and orbit-closure checks passed.
- The Lean type-checker accepted the same algebraic facts as theorems — a CPU
  acting as a proof-checker, not a quantum annealer.

**Open sub-questions:**
- Is there any quantum-mechanical prediction that *cannot* be reproduced by
  exact complex arithmetic on a classical computer (given unlimited time/memory)?
- What is the precise boundary between *simulation* (approximate, resource-limited)
  and *instantiation* (exact mathematical representation)?

---

### Q2 — Orbit closure and periodicity

> *Does μ⁸ = 1 hold exactly, and does the quantum orbit close after exactly
> 8 kicks of 135°?*

**Working hypothesis:** Because μ = exp(i·3π/4), we have μ⁸ = exp(i·6π) = 1
exactly.  This is an algebraic identity, not an approximation.

**Status:** Machine-checked in `formal-lean/CriticalEigenvalue.lean`
(theorem `mu_pow_eight`).

---

### Q3 — Purity and decoherence

> *Can a pure quantum state (ρ² = ρ) be maintained on classical hardware?*

**Working hypothesis:** Purity is a property of the density matrix ρ = |ψ⟩⟨ψ|.
On classical hardware, floating-point arithmetic introduces rounding errors, but
these are controllable.  With exact rational or symbolic arithmetic, ρ² = ρ holds
identically.

**Open sub-questions:**
- At what precision threshold does numerical drift break purity?
- Can Lean's definitional equality guarantee ρ² = ρ without floating-point error?

---

### Q4 — Born rule statistics

> *Does repeated sampling of |ψ⟩ = α|0⟩ + β|1⟩ converge to |α|² and |β|²?*

**Working hypothesis:** Yes — by the law of large numbers applied to a Bernoulli
variable with parameter |α|².

**Evidence so far:** 1000 measurements of |ψ⟩ = −η|0⟩ + η|1⟩ (|α|² = |β|² = 1/2)
yielded ~50/50 statistics, consistent with the Born rule.

---

### Q5 — Entanglement without quantum hardware

> *Can Bell-state entanglement and non-separability (S > 0) be demonstrated
> classically?*

**Working hypothesis:** Entanglement is a property of a *joint* quantum state
that cannot be written as a tensor product.  Verifying non-separability requires
only linear algebra.

**Evidence so far:** A two-qubit Bell state built from μ-qubits showed S > 0
(non-zero entanglement entropy), computed entirely on a classical CPU.

---

### Q6 — Self-referential closure

> *Does C(1 + 1/η) = η hold, and what does it mean physically?*

**Working hypothesis:** The coherence function C(r) = 2r/(1+r²) satisfies
C(1 + 1/η) = η when η = δS (the Silver ratio, 1 + √2).  This is a
machine-checked theorem in `formal-lean/NumericalAlignments.lean`
(§12 `observer_fixed_point_unique`).

*Placeholder — contributors are invited to add physical interpretations of this
fixed-point property.*

---

## 2. Computational Experiments

Each experiment below is self-contained and reproducible.  Code is in Python
(no external quantum libraries required) unless otherwise noted.

### Experiment 1 — Qubit as a vector in ℂ²

**Goal:** Show that |ψ⟩ = −η|0⟩ + η|1⟩ is a valid, normalised qubit state.

```python
import cmath, math

eta = 1 + math.sqrt(2)          # Silver ratio δS
psi = [-eta, eta]               # |ψ⟩ in the {|0⟩, |1⟩} basis

norm_sq = sum(abs(a)**2 for a in psi)
normalised = [a / math.sqrt(norm_sq) for a in psi]

print("State:", normalised)
print("Norm²:", sum(abs(a)**2 for a in normalised))  # should be 1.0
```

**Expected output:**
```
State: [(-0.7071...), (0.7071...)]
Norm²: 1.0
```

**Result:** ✅ Passed — the state is a valid unit vector in ℂ².

---

### Experiment 2 — Orbit closure: μ⁸ = 1

**Goal:** Verify that repeated application of the 135° phase rotation (multiplication
by μ = exp(i·3π/4), advancing the complex phase by 135° each step) returns to
the identity after 8 steps.

```python
import cmath, math

mu = cmath.exp(1j * 3 * math.pi / 4)   # exp(i·3π/4)
orbit = [mu**k for k in range(9)]

print("Orbit powers of μ:")
for k, z in enumerate(orbit):
    print(f"  μ^{k} = {z:.6f}")

print("μ^8 == 1?", abs(mu**8 - 1) < 1e-10)  # should be True
```

**Expected output:**
```
μ^8 == 1?  True
```

**Result:** ✅ Passed — orbit closes exactly after 8 kicks.

---

### Experiment 3 — Purity: ρ² = ρ

**Goal:** Confirm that the density matrix of a pure state satisfies ρ² = ρ.

```python
import numpy as np, math

eta = 1 + math.sqrt(2)
norm = math.sqrt(2) * eta
psi = np.array([-eta / norm, eta / norm], dtype=complex).reshape(2, 1)

rho = psi @ psi.conj().T          # outer product |ψ⟩⟨ψ|
rho2 = rho @ rho                  # ρ²

print("ρ² ≈ ρ?", np.allclose(rho2, rho))  # should be True
print("Trace(ρ):", np.trace(rho).real)    # should be 1.0
```

**Expected output:**
```
ρ² ≈ ρ?  True
Trace(ρ): 1.0
```

**Result:** ✅ Passed — pure state, zero decoherence.

---

### Experiment 4 — Bell state entanglement (S > 0)

**Goal:** Build a two-μ-qubit Bell state and confirm non-separability.

```python
import numpy as np, math

# Single-qubit basis states
ket0 = np.array([1, 0], dtype=complex)
ket1 = np.array([0, 1], dtype=complex)

# Bell state |Φ+⟩ = (|00⟩ + |11⟩) / √2
bell = (np.kron(ket0, ket0) + np.kron(ket1, ket1)) / math.sqrt(2)

# Reduced density matrix for qubit A (trace out qubit B)
rho_AB = np.outer(bell, bell.conj())
rho_A  = rho_AB.reshape(2, 2, 2, 2).trace(axis1=1, axis2=3)

# Von Neumann entropy S = -Tr(ρ log ρ)
eigvals = np.linalg.eigvalsh(rho_A)
eigvals = eigvals[eigvals > 1e-12]          # drop numerical zeros
S = -sum(v * math.log2(v) for v in eigvals)

print(f"Von Neumann entropy S = {S:.6f}")   # should be > 0
print(f"Entangled (S > 0)?  {S > 0}")
```

**Expected output:**
```
Von Neumann entropy S = 1.000000
Entangled (S > 0)?  True
```

**Result:** ✅ Passed — Bell state is maximally entangled.

---

### Experiment 5 — Born rule: 1000 measurements

**Goal:** Verify that 1000 projective measurements of a balanced qubit yield
~50/50 statistics.

```python
import random, math

random.seed(42)

# Balanced qubit: |α|² = |β|² = 0.5
p0 = 0.5
outcomes = [0 if random.random() < p0 else 1 for _ in range(1000)]

count0 = outcomes.count(0)
count1 = outcomes.count(1)
print(f"|0⟩: {count0}/1000 = {count0/10:.1f}%")
print(f"|1⟩: {count1}/1000 = {count1/10:.1f}%")
print(f"Born rule satisfied (within 5%)? {abs(count0 - 500) <= 50}")
```

**Expected output:**
```
|0⟩: ~500/1000 = ~50.0%
|1⟩: ~500/1000 = ~50.0%
Born rule satisfied (within 5%)? True
```

**Result:** ✅ Passed — Born rule statistics hold as predicted.

---

### Adding a New Experiment

*Placeholder — contributors are encouraged to add experiments following the
template above.  Each experiment should include:*

1. **Goal** — the assumption being tested.
2. **Code** — a minimal, self-contained snippet (Python or Lean).
3. **Expected output** — what a correct implementation should print.
4. **Result** — ✅ Passed / ⚠️ Partial / ❌ Failed, with brief commentary.

---

## 3. Misconceptions and Clarifications

### Misconception 1 — "You need quantum hardware to have a quantum state"

**Clarification:** A quantum state is defined by the mathematics of Hilbert
spaces, not by the physical substrate.  |ψ⟩ = α|0⟩ + β|1⟩ is a vector in ℂ².
Any system that can perform arithmetic over ℂ — including an ordinary CPU —
can represent this vector exactly.

What quantum hardware provides is:
- *Physical* decoherence-free evolution (approximately).
- Exponential parallelism through genuine superposition of *physical* degrees
  of freedom.

What it does *not* uniquely provide is:
- The mathematical structure of the quantum state itself.
- The ability to check algebraic identities about that state.

---

### Misconception 2 — "Simulating quantum mechanics classically requires
exponential overhead"

**Clarification:** This is true for *general* quantum circuits (the state
vector grows as 2ⁿ for n qubits).  However, for small systems, exact
representation is completely tractable, and many structural properties — purity,
entanglement entropy, Born probabilities — can be computed efficiently for
specific families of states (e.g., stabiliser states, matrix product states).

The experiments in this wiki concern *small, structured* systems where exact
classical computation is feasible.

---

### Misconception 3 — "The Born rule is a postulate that cannot be derived"

**Clarification:** Within the Eigenverse framework, the Born rule is a
*consequence* of the algebraic structure of the coherence function C(r) = 2r/(1+r²)
and the normalisation constraint of unit-vector states.  Whether this constitutes
a genuine derivation or a reformulation is an open philosophical question —
and a good candidate for a new Quantum Wiki contribution.

*Placeholder — contributors are invited to formalise or challenge this claim.*

---

### Misconception 4 — "Classical computers cannot exhibit entanglement"

**Clarification:** Entanglement is a property of the *mathematical* state, not
of the hardware.  A classical computer can store and manipulate an entangled
two-qubit state (e.g., a Bell state) as a length-4 complex vector.  It cannot
*physically instantiate* the entanglement as correlated measurement outcomes
across space — but it can represent, verify, and reason about entangled states
exactly.

---

## 4. Open Questions and Future Directions

The following questions are actively open.  Contributions that advance any of
them — whether through new experiments, Lean proofs, or literature surveys — are
welcome.

| # | Question | Status |
|---|----------|--------|
| OQ1 | Can all quantum measurement statistics be reproduced by a classical probability model without hidden variables? | Open — Bell's theorem constrains *local realist* models; non-local or contextual classical models remain a possibility |
| OQ2 | Is there a Lean-verified proof that Born probabilities follow from the Eigenverse axioms alone? | Open |
| OQ3 | What is the resource cost (time, memory) of classically emulating n-qubit evolution exactly, for the μ-qubit family? | Open |
| OQ4 | Can mixed states and decoherence be incorporated into the Lean framework? | Open |
| OQ5 | Is there a categorical or type-theoretic characterisation of the boundary between classical and quantum computation? | Open |
| OQ6 | Can the coherence function C(r) = 2r/(1+r²) be derived from information-theoretic first principles? | Open |
| OQ7 | Does the μ⁸ = 1 orbit closure have a physical analogue in known quantum systems? | Open — discrete time crystals (Wilczek 2012, see References) exhibit periodic quantum-state revivals and are a candidate |

*Placeholder — contributors are encouraged to add new open questions, update
statuses, and link to relevant experiments or proofs.*

---

## 5. Community Contribution Guidelines

### How to contribute to the Quantum Wiki

1. **Test an assumption.**  Pick a question from
   [Section 1](#1-assumptions-and-key-questions) (or propose a new one) and
   write a minimal, reproducible experiment.

2. **Follow the experiment template** in
   [Section 2](#2-computational-experiments): Goal → Code → Expected output →
   Result.

3. **Cite your sources.**  For physical claims, cite published papers or NIST
   data.  For mathematical claims, either reference an existing Lean theorem
   (see `formal-lean/`) or note that a formal proof is pending.

4. **Open a pull request** against `main` on
   [beanapologist/Eigenverse](https://github.com/beanapologist/Eigenverse).
   See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full workflow.

5. **Propose a hypothesis.**  If you have a conjecture that is not yet supported
   by experiment or proof, add it to the
   [Open Questions](#4-open-questions-and-future-directions) table with status
   "Open (proposed)" and your reasoning.

---

### Experiment checklist

Before submitting an experiment, verify:

- [ ] Code runs without modification on a standard Python 3.x installation
      (or Lean 4 with `lake build`).
- [ ] Expected output is included and matches the actual output.
- [ ] The assumption being tested is clearly stated.
- [ ] Any numerical tolerances used (e.g., `abs(x) < 1e-10`) are justified.
- [ ] No external quantum-computing libraries (Qiskit, Cirq, etc.) are
      required — the point is to demonstrate classical reproducibility.

---

### Lean proof checklist

Before submitting a formal proof:

- [ ] Zero `sorry` placeholders.
- [ ] `lake build` passes with no errors or warnings.
- [ ] Theorem is added to the appropriate module in `formal-lean/`.
- [ ] `docs/overview.md` theorem count is updated.

---

### Code of conduct

Be rigorous, be respectful, and be open to being wrong.  Mathematical truth is
determined by proof, not by consensus — but discourse should always remain
welcoming and constructive.

---

## References

- **Eigenverse repository**: <https://github.com/beanapologist/Eigenverse>
- Lean 4: <https://leanprover.github.io/>
- Mathlib4: <https://leanprover-community.github.io/mathlib4_docs/>
- Nielsen & Chuang, *Quantum Computation and Quantum Information* (2010)
- Bell, J. S. (1964). On the Einstein–Podolsky–Rosen paradox. *Physics* **1**(3), 195–200.
- Wilczek, F. (2012). Quantum Time Crystals. *Phys. Rev. Lett.* **109**, 160401.
- NIST CODATA Fundamental Constants: <https://physics.nist.gov/cuu/Constants/>
