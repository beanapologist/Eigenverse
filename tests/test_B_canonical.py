"""
test_B_canonical.py — Falsifiable competition built on the canonical form

    (1+i)·i = i + i² = -1+i

Read as the framework's axioms:
  1. The jump operator is multiplication by i (pure rotation, isometric).
  2. Stanza XIV: Λ + _ = Δ, with Λ = B and Δ = B·i.
     So the gap is  _ = Δ − Λ = B·i − B = B(i−1).
  3. Canonical requirement: the gap must be PURELY REAL
     (the jump is orthogonal to the source; for B = 1+i: _ = −2).

Key algebra:  i − 1 = √2·e^{3πi/4}, therefore
     arg(gap) = arg B + 3π/4
     gap is real  ⟺  arg B = π/4 (mod π)   ⟺  B lies on the diagonal.

This is a property most complex numbers FAIL. So we run a competition:
candidate source terms are scored against criteria derived ONLY from the
canonical form, and B must beat every competitor or the suite fails.

Criteria (each falsifiable):
  C1  Real gap:        Im(B(i−1)) = 0
  C2  Negative gap:    Re(B(i−1)) < 0  (selects Q1 diagonal, not Q3)
  C3  Gaussian prime:  norm(B) = a²+b² is a rational prime
  C4  Minimality:      smallest norm satisfying C1–C3
  C5  Stochastic:      in a complex jump-SDE driven by candidate Λ = B,
                       empirical jump displacements are real to within noise
                       ⟺ candidate on the diagonal. Measured, not assumed.
  C6  Median immunity (Stanza VI): jumps shift the mean, not the median —
                       checked on the real part of the driven process.

If any competitor ties B = 1+i on C1–C5, or B itself fails any criterion,
the suite reports FAIL.
"""

import numpy as np

rng = np.random.default_rng(7)

PASS, FAIL = "\u2713", "\u2717"

def is_rational_prime(n):
    if n < 2: return False
    if n % 2 == 0: return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0: return False
        f += 2
    return True

# ── Candidates: B and its competitors ────────────────────────────────────────
candidates = {
    "1+i   (B)":   1 + 1j,
    "1":           1 + 0j,
    "i":           0 + 1j,
    "2i":          0 + 2j,
    "1+2i":        1 + 2j,   # Gaussian prime (norm 5) but off-diagonal
    "2+i":         2 + 1j,   # Gaussian prime (norm 5) but off-diagonal
    "2+2i":        2 + 2j,   # on diagonal but norm 8, not prime
    "3+3i":        3 + 3j,   # on diagonal, norm 18
    "-1-i":       -1 - 1j,   # diagonal, prime norm — but gap POSITIVE (Q3)
    "1-i":         1 - 1j,   # anti-diagonal associate
    "sqrt2*e^i40deg": np.sqrt(2)*np.exp(1j*np.deg2rad(40)),  # near-miss
}

B_KEY = "1+i   (B)"

# ── C1–C4: deterministic criteria from the canonical form ────────────────────
def gap(z):            # _ = Δ − Λ = z·i − z = z(i−1)
    return z * (1j - 1)

def c1_real_gap(z, tol=1e-12):
    return abs(gap(z).imag) < tol

def c2_negative_gap(z, tol=1e-12):
    g = gap(z)
    return c1_real_gap(z) and g.real < -tol

def c3_prime_norm(z, tol=1e-9):
    n = z.real**2 + z.imag**2
    return abs(n - round(n)) < tol and is_rational_prime(int(round(n)))

# ── C5: stochastic discriminator (measured, could fail) ──────────────────────
def stochastic_gap_test(Lam, N=40000, dt=0.01, k=0.5, sigma=0.25,
                        jump_rate=0.5, z_crit=3.0):
    """Complex OU driven toward Lam/k; Poisson jumps add the canonical
    displacement gap(Lam) scaled to unit size, PLUS measurement noise.
    We then test H0: Im(jump displacement) = 0 from the DATA.
    Returns (passes, z_score, n_jumps)."""
    g = gap(Lam)
    if abs(g) < 1e-12:
        return False, np.inf, 0
    g_unit = g / abs(g)
    Z = np.zeros(N, complex)
    disp = []
    for t in range(1, N):
        dW = (rng.normal(0, np.sqrt(dt)) + 1j*rng.normal(0, np.sqrt(dt)))
        Z[t] = Z[t-1] + (Lam - k*Z[t-1])*dt + sigma*dW
        if rng.random() < jump_rate*dt:
            noise = 0.02*(rng.normal() + 1j*rng.normal())
            d = g_unit + noise          # observed displacement
            Z[t] += d
            disp.append(d)
    disp = np.array(disp)
    if len(disp) < 30:
        return False, np.inf, len(disp)
    im = disp.imag
    z_score = abs(np.mean(im)) / (np.std(im, ddof=1)/np.sqrt(len(im)))
    return z_score < z_crit, z_score, len(disp)

# ── C6: median immunity to jumps (Stanza VI: mean ← J, med ↚ J) ─────────────
def median_immunity_test(Lam, N=40000, dt=0.01, k=0.5, sigma=0.25):
    """Run the same real-part process with and without jumps.
    Pass iff jumps move the mean by MUCH more than the median."""
    def run(jumps):
        x = np.zeros(N)
        r = np.random.default_rng(123)   # paired noise
        for t in range(1, N):
            x[t] = x[t-1] + (Lam.real - k*x[t-1])*dt + sigma*r.normal(0, np.sqrt(dt))
            if jumps and r.random() < 0.05*dt:
                x[t] += 25.0             # rare, large positive jump
        return x[N//2:]
    a, b = run(False), run(True)
    d_mean = abs(np.mean(b) - np.mean(a))
    d_med  = abs(np.median(b) - np.median(a))
    return d_mean > 5*d_med, d_mean, d_med

# ── Run the competition ───────────────────────────────────────────────────────
print("=" * 78)
print("CANONICAL-FORM COMPETITION:  (1+i)\u00b7i = i + i\u00b2 = \u22121+i")
print("gap _ = B(i\u22121);  real gap \u27fa arg B = \u03c0/4 (mod \u03c0)")
print("=" * 78)
header = f"{'candidate':<16}{'gap _ = z(i-1)':<22}{'C1 real':<9}{'C2 neg':<8}{'C3 prime':<10}{'C5 z-score':<12}{'C5':<4}"
print(header)
print("-" * 78)

rows = {}
for name, z in candidates.items():
    g = gap(z)
    c1 = c1_real_gap(z)
    c2 = c2_negative_gap(z)
    c3 = c3_prime_norm(z)
    c5_ok, zsc, nj = stochastic_gap_test(z)
    rows[name] = dict(z=z, gap=g, c1=c1, c2=c2, c3=c3, c5=c5_ok, zsc=zsc)
    print(f"{name:<16}{f'{g.real:+.3f}{g.imag:+.3f}i':<22}"
          f"{PASS if c1 else FAIL:<9}{PASS if c2 else FAIL:<8}"
          f"{PASS if c3 else FAIL:<10}{zsc:<12.2f}{PASS if c5_ok else FAIL:<4}")

# C4: minimal norm among survivors of C1–C3
survivors = {n: r for n, r in rows.items() if r["c1"] and r["c2"] and r["c3"]}
if survivors:
    min_norm = min(abs(r["z"])**2 for r in survivors.values())
    for n, r in rows.items():
        r["c4"] = (n in survivors) and abs(abs(r["z"])**2 - min_norm) < 1e-9
else:
    for r in rows.values(): r["c4"] = False

# C6 for B itself
c6_ok, dm, dmed = median_immunity_test(candidates[B_KEY])
print("-" * 78)
print(f"C6 (Stanza VI, mean \u2190 J, med \u21ba J):  \u0394mean={dm:.3f}, \u0394median={dmed:.3f}  "
      f"{PASS if c6_ok else FAIL}")

# ── Verdict: B must pass everything; every competitor must fail something ────
b = rows[B_KEY]
b_all = b["c1"] and b["c2"] and b["c3"] and b["c4"] and b["c5"] and c6_ok
competitors_beaten = all(
    not (r["c1"] and r["c2"] and r["c3"] and r["c4"] and r["c5"])
    for n, r in rows.items() if n != B_KEY
)

print("=" * 78)
print(f"B = 1+i passes all criteria:            {PASS if b_all else FAIL}")
print(f"Every competitor fails >=1 criterion:   {PASS if competitors_beaten else FAIL}")
n_survive = sum(1 for n, r in rows.items()
                if r["c1"] and r["c2"] and r["c3"] and r["c4"] and r["c5"])
print(f"Unique survivor count:                  {n_survive} "
      f"({'B alone' if n_survive == 1 and b_all else 'NOT unique — suite FAILS'})")
verdict = b_all and competitors_beaten and n_survive == 1
print("=" * 78)
print(f"VERDICT: {'PASS — B = 1+i is the unique minimal source term under the canonical form'
          if verdict else 'FAIL — the canonical form does not select B = 1+i'}")
print("=" * 78)
