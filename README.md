# Autonomous Multi-Trajectory Syracuse Transducers: Collision-Free Tape Architectures, Drift Invariants, and Asymptotic Soliton Arrays

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24223304.svg)](https://doi.org/10.5281/zenodo.24223304)
[![Lean 4](https://img.shields.io/badge/Lean_4-v4.14.0-blue.svg)](https://leanprover.github.io/)
[![Formal Verification](https://img.shields.io/badge/Verification-0_sorry-success.svg)](lean/CyclicTransducer.lean)
[![Format](https://img.shields.io/badge/Format-IEEEtran_4.0_pages-blue.svg)](paper/syracuse_cyclic_array.pdf)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

This repository provides the formal specification, **machine-checked Lean 4 verification suite (0 unproved axioms or `sorry` gaps)**, discrete-event simulation harness, and publication-grade IEEE manuscript for the autonomous, cyclically pipelined 5-state, 4-symbol Turing transducer `M'`.

---

## 1. Abstract & System Model

While conventional arithmetic Turing machines evaluate scalar, single-shot operands on isolated tapes, streaming multi-trajectory evaluation introduces non-trivial spatial coupling: asymmetric bit-length expansion (`ΔL ≈ log₂(3) − k`) during Collatz ascent can induce inter-word carry overrun. 

Machine `M'` operates on a standard right-infinite tape:

```text
T = @ N1 [$] N2 [$] ... Nn [$] @^ω
```

bounded on the left by sentinel `@` at cell 0 and extending rightward into an open absorbing horizon `@^ω`.

In each physical pass `t`, `M'` computes the single-pass dyadic affine operator:

$$\widetilde{T}(n) = \frac{3 \cdot \text{odd}(n) + 1}{2}$$

where on-the-fly division by 2 is performed by overwriting the first sum bit with blank `$`. Residual (`ν₂ − 1`) divisions manifest as trailing zeros on the tape, which are consumed on the subsequent pass.

![Single-word tape cell coordinates and bit-serial execution](paper/figures/fig1_tape_execution.png)

*Figure 1: Single-word tape cell coordinates and bit-serial execution of `M'` for N = 11 (`1101` -> `10001` = 17). Left sentinel `@` remains stationary at cell 0. Blank `$` overwrites the consumed LSB at cell 1 (on-the-fly /2 odd-core reduction, Δtail = 1). Carries propagate rightward into the `$` buffer, advancing head by Δhead = 2.*

---

## 2. Transition Function Specification

Transducer `M'` is formalized over state set `Q = {A, B, C, D, E}` and alphabet `Γ = {@, $, 0, 1}`, containing **exactly 18 active transitions** over 20 domain cells. Structurally unreachable cells are `(D, $)` and `(D, @)`.

| State | Symbol `@` | Symbol `$` | Symbol `0` | Symbol `1` | Operational Semantics |
| :---: | :---: | :---: | :---: | :---: | :--- |
| **A** | `(@, L, E)` | `($, R, A)` | `($, R, A)` | `($, R, B)` | Normalization, odd-core detection, right reflection |
| **B** | `(0, R, C)` | `(0, R, C)` | `(0, R, C)` | `(1, R, B)` | Forward carry addition (`c_in = 0`) / Carry flush 1 |
| **C** | `(1, R, A)` | `(1, R, A)` | `(1, R, D)` | `(0, R, B)` | Forward carry addition (`c_in = 1`) / Carry flush 2 |
| **D** | `⊥` | `⊥` | `(0, R, D)` | `(1, R, C)` | Internal zero carry propagation |
| **E** | `(@, R, A)` | `($, L, E)` | `(0, L, E)` | `(1, L, E)` | Non-destructive leftward rewind to cell 0 |

---

## 3. Key Theoretical Contributions

### 3.1 Universal Safety via Regime I (Asymptotic Buffer Sizing)
For any arbitrary input vector `N = <N1, ..., Nn>`, inter-word collision is provably impossible for all passes `t >= 0` if the initial spacing satisfies:

$$S_i \ge \mathcal{D}_{\max}(N_i, N_{i+1}) + 2$$

where `D_max` is the cumulative drift differential. Modifying writes are strictly bounded by `write_max(N_i, t) = head(N_i, t) + 2 < tail(N_{i+1}, t)`, preventing carry overrun.

![Space-time inter-word displacement mechanics](paper/figures/fig2_drift_mechanics.png)

*Figure 2: Space-time inter-word displacement mechanics under `M'`. In vector mode, inter-word coupling is fully governed by the single 1D spatial recurrence variable Δgap = Δtail - Δhead. Maintaining gap >= 2 preserves complete scalar operational equivalence for each word across the pipeline.*

### 3.2 Limits of Uniform Spacing: The Word-Length Invariant
For synchronized identical trajectories (`N1 = N2 = N`), relative buffer contraction equals the exact net bit-growth of the number:

$$\Delta \text{gap}_t = -\Delta L(N, t)$$

Under uniform spacing `S = 3`, counterexample `N = <27, 27>` contracts as `gap: 3 -> 2 -> 2 -> 2 -> 1 -> 1 -> 0`, collapsing and fusing at Pass 6.

### 3.3 Asymptotic Phase-Locking: Soliton Array Formation
Contingent upon Collatz convergence, every trajectory reaches the unique singleton stationary fixed point `N = 2` (binary kernel `s = 01`):
1. **Uniform Group Velocity**: Each soliton translates rigidly rightward at `v = 2` cells per cycle.
2. **Spatial Distance Freezing**: Spatial gap velocity satisfies `Δgap = 2 - 2 = 0`, freezing relative inter-soliton distances permanently.
3. **Travelling Wave Train**: The tape relaxes into a coherent, phase-locked soliton array:

```text
T_∞ = @ $^d0 s $^d1 s $^d2 ... s @^ω,    di >= 2
```

### 3.4 Reversible Inversion via Spatial Drift Decoupling
While `T_tilde` is locally non-injective over odd integers, absolute and relative displacements `Δtail(N, t) = max{1, k_{t-1}}` record lost valuation entropy directly onto the spatial tape wake. A companion left-anchored transducer `M'_rev` reconstructs unique odd ancestors `n = (m · 2^k − 1)/3` sequentially without auxiliary registers.

---

## 4. Repository Structure

```text
syracuse-turing-vectorised/
|-- paper/
|   |-- syracuse_cyclic_array.tex      # Full IEEEtran 4.0-page manuscript source
|   |-- syracuse_cyclic_array.pdf      # Compiled publication-ready PDF
|   `-- figures/
|       |-- fig1_tape_execution.png    # Figure 1: Single-word tape execution
|       `-- fig2_drift_mechanics.png   # Figure 2: Space-time drift mechanics
|-- lean/
|   |-- lakefile.lean                  # Lake package configuration
|   |-- lean-toolchain                 # Pinned to leanprover/lean4:v4.14.0
|   `-- CyclicTransducer.lean          # Formal M' specification & theorems (0 sorrys)
|-- simulator/
|   `-- verify_cyclic_transducer.py    # Discrete-event regression harness
|-- docs/
|   |-- notes.txt                      # Technical notes and audit records
|   `-- challenge.txt                  # Adversarial benchmarks & research roadmap
|-- Makefile                           # Automated build, lint, and test targets
|-- CITATION.cff                       # Citation metadata (v1.2.0)
|-- LICENSE                            # MIT License
`-- README.md                          # Repository documentation
```

---

## 5. Machine-Checked Lean 4 Verification

The formal certification is contained in `lean/CyclicTransducer.lean` (**0 `sorry`s, 0 unproved axioms**):

| # | Formal Theorem Identifier | Mathematical Invariant | Proof Technique |
| :---: | :--- | :--- | :---: |
| 1 | `active_transitions_eq_eighteen` | Exactly 18 active transitions over 20 domain cells | `decide` |
| 2 | `state_count_eq_five` | State space cardinality &#124;Q&#124; = 5 | `decide` |
| 3 | `symbol_count_eq_four` | Tape alphabet cardinality &#124;Γ&#124; = 4 | `decide` |
| 4 | `tail_disp_pos` | Universal tail progress: Δtail ≥ 1 | `omega` |
| 5 | `tail_disp_eq_one_of_k_one` | Shift is 1 when k = 1: Δtail = 1 | `rfl` |
| 6 | `tail_disp_ge_two_of_k_ge_two` | Shift is ≥ 2 when k ≥ 2: Δtail ≥ 2 | `omega` |
| 7 | `initial_compression_eq_neg_one` | Initial compression: Δgap₀ = 1 − 2 = −1 | `rfl` |
| 8 | `regime_I_collision_freedom` | Buffer preservation: S > D_max ⇒ gap ≥ 1 | `omega` |
| 9 | `regime_I_safe_separation` | Safe separation: S ≥ D_max + 2 ⇒ gap ≥ 2 | `omega` |
| 10 | `write_separation_sound` | Safety invariant: head₁ + 2 < tail₂ | `omega` |
| 11 | `soliton_rigid_translation` | Attractor velocity equality: v_tail = v_head | `rfl` |
| 12 | `soliton_group_velocity` | Attractor group velocity: v = 2 cells/pass | `rfl` |
| 13 | `soliton_gap_freezing` | Spatial gap velocity freezing: v_tail − v_head = 0 | `decide` |
| 14 | `reverse_exactness` | Algebraic preimage recovery: n = (m · 2^k − 1)/3 | `omega` |
| 15 | `identical_words_gap_compression` | Identical trajectories: Δgap = −ΔL | `omega` |

---

## 6. Build and Verification Guide

### 6.1 Running the Python Discrete-Event Simulator
```bash
python simulator/verify_cyclic_transducer.py
```
**Regression Output**:
```text
======================================================================
M' SYRACUSE TRANSDUCER FORMAL REGRESSION TEST SUITE
======================================================================
[Test 1] Attractor Soliton Orbit: N = <1>, S = 3 -> Group velocity v = 2 cells/pass: VERIFIED.
[Test 2] Critical Safety Boundary: N = <7, 1>, S = 3 -> Word isolation preserved: VERIFIED.
[Test 3] Counterexample to S=3 Sufficiency: N = <27, 27>, S = 3 -> Collision at Pass 6: VERIFIED.
[Test 4] Regime I Resolution: N = <27, 27>, S = 15 -> Complete isolation preserved: VERIFIED.
======================================================================
ALL 4 REGRESSION BENCHMARKS PASSED SUCCESSFULLY.
======================================================================
```

### 6.2 Compiling the Lean 4 Corpus
Requires Lean 4 (toolchain `leanprover/lean4:v4.14.0`).
Inside `lean/`:
```bash
lake build
```
Or paste `lean/CyclicTransducer.lean` into the [Lean 4 Web Editor](https://live.lean-lang.org/).

### 6.3 Recompiling the IEEE Manuscript
Inside `paper/`:
```bash
pdflatex -interaction=nonstopmode syracuse_cyclic_array.tex
pdflatex -interaction=nonstopmode syracuse_cyclic_array.tex
```

---

## 7. BibTeX Citation

```bibtex
@article{varshney2026autonomous,
  author    = {Lakshya Varshney},
  title     = {Autonomous Multi-Trajectory Syracuse Transducers: Collision-Free Tape Architectures, Drift Invariants, and Asymptotic Soliton Arrays},
  journal   = {arXiv preprint},
  year      = {2026},
  doi       = {10.5281/zenodo.24223304},
  url       = {https://doi.org/10.5281/zenodo.24223304},
  note      = {Formal verification in Lean 4 (0 sorrys)}
}
```

---

## 8. Author

**Lakshya Varshney**  
Department of Electronics and Telecommunication Engineering  
COEP Technological University, Pune 411005, Maharashtra, India  
Email: [creativelakshya.1@gmail.com](mailto:creativelakshya.1@gmail.com)  
ORCID: [0009-0004-7688-1091](https://orcid.org/0009-0004-7688-1091)  
GitHub: [@lakshyaV-rshney](https://github.com/lakshyaV-rshney)
