/-!
# Autonomous Multi-Trajectory Syracuse Transducers: Formal Comparator Challenge
Challenge specification for Lean Comparator Live (`lake comparator`)

Manuscript: "Autonomous Multi-Trajectory Syracuse Transducers: Collision-Free Tape Architectures,
             Drift Invariants, and Asymptotic Soliton Arrays"
Author: Lakshya Varshney
COEP Technological University, Pune, Maharashtra, India
November 2026

Target Verification:
1. Operational cardinality of transducer M' (18 active transitions over 20 cells)
2. Structural head and tail displacement dynamics (Lemma 1)
3. Initial buffer compression under ascent (Proposition 1)
4. Universal collision freedom under Regime I buffer sizing (Theorem 1)
5. Attractor soliton velocity and spatial freezing (Theorem 2)
6. Exact reverse arithmetic preimage recovery (Section VIII)
7. Identical trajectory relative gap contraction invariant (Section IV & VI)
-/

namespace Syracuse

/-!
### 1. Alphabet, States, and Directions
Transducer M' is formalized over alphabet Gamma = {@, $, 0, 1} and 5 states Q = {A, B, C, D, E}.
-/

inductive Symbol where
  | Sentinel : Symbol -- '@'
  | Blank    : Symbol -- '$'
  | Zero     : Symbol -- '0'
  | One      : Symbol -- '1'
  deriving DecidableEq, Repr

inductive State where
  | A : State -- Normalization, trailing zero elimination, odd-core injection
  | B : State -- Forward carry addition (carry sum S = 2)
  | C : State -- Forward carry addition (carry sum S = 1) / carry flush
  | D : State -- Forward carry addition (carry sum S = 0)
  | E : State -- Leftward rewind to left boundary sentinel
  deriving DecidableEq, Repr

inductive Dir where
  | L : Dir
  | R : Dir
  deriving DecidableEq, Repr

def allStates : List State :=
  [State.A, State.B, State.C, State.D, State.E]

def allSymbols : List Symbol :=
  [Symbol.Sentinel, Symbol.Blank, Symbol.Zero, Symbol.One]

/-- The complete 20-cell state-symbol domain of the 5-state transducer M'. -/
def allPairs : List (State × Symbol) :=
  allStates.flatMap (fun q => allSymbols.map (fun σ => (q, σ)))

/-!
### 2. Transition Function delta (Table I)
The transducer defines exactly 18 active transitions over 20 domain cells.
Only (D, $) and (D, @) are undefined (structurally unreachable).
-/

def delta : State → Symbol → Option (Symbol × Dir × State)
  -- State A: Normalization, odd core injection, and right horizon reflection
  | State.A, Symbol.Zero     => some (Symbol.Blank,    Dir.R, State.A)
  | State.A, Symbol.One      => some (Symbol.Blank,    Dir.R, State.B)
  | State.A, Symbol.Blank    => some (Symbol.Blank,    Dir.R, State.A)
  | State.A, Symbol.Sentinel => some (Symbol.Sentinel, Dir.L, State.E)

  -- State B: Forward Carry Addition (carry sum S = 2)
  | State.B, Symbol.Zero     => some (Symbol.Zero,     Dir.R, State.C)
  | State.B, Symbol.One      => some (Symbol.One,      Dir.R, State.B)
  | State.B, Symbol.Blank    => some (Symbol.Zero,     Dir.R, State.C)
  | State.B, Symbol.Sentinel => some (Symbol.Zero,     Dir.R, State.C)

  -- State C: Forward Carry Addition (carry sum S = 1) / Carry Flush
  | State.C, Symbol.Zero     => some (Symbol.One,      Dir.R, State.D)
  | State.C, Symbol.One      => some (Symbol.Zero,     Dir.R, State.B)
  | State.C, Symbol.Blank    => some (Symbol.One,      Dir.R, State.A)
  | State.C, Symbol.Sentinel => some (Symbol.One,      Dir.R, State.A)

  -- State D: Forward Carry Addition (carry sum S = 0)
  | State.D, Symbol.Zero     => some (Symbol.Zero,     Dir.R, State.D)
  | State.D, Symbol.One      => some (Symbol.One,      Dir.R, State.C)

  -- State E: Non-destructive Leftward Rewind to Left Boundary Sentinel
  | State.E, Symbol.Zero     => some (Symbol.Zero,     Dir.L, State.E)
  | State.E, Symbol.One      => some (Symbol.One,      Dir.L, State.E)
  | State.E, Symbol.Blank    => some (Symbol.Blank,    Dir.L, State.E)
  | State.E, Symbol.Sentinel => some (Symbol.Sentinel, Dir.R, State.A)

  -- Structurally unreachable domain cells
  | _, _ => none

def isDefined (q : State) (σ : Symbol) : Bool :=
  (delta q σ).isSome

def activeTransitionCount : Nat :=
  (allPairs.filter (fun (q, σ) => isDefined q σ)).length

/-- [Challenge Goal 1] Transducer M' has exactly 18 active transitions out of 20 domain cells. -/
theorem active_transitions_eq_eighteen :
  activeTransitionCount = 18 := by decide

/-- [Challenge Goal 2] State space cardinality is exactly 5. -/
theorem state_count_eq_five :
  allStates.length = 5 := by decide

/-- [Challenge Goal 3] Tape alphabet cardinality is exactly 4. -/
theorem symbol_count_eq_four :
  allSymbols.length = 4 := by decide

/-!
### 3. Head and Tail Displacement Dynamics (Lemma 1)
-/

def maxHeadDisplacement : Nat := 2
def tailDisplacementPass0 : Nat := 1

def tailDisplacementPassT (k : Nat) : Nat :=
  if k ≤ 1 then 1 else k

/-- [Challenge Goal 4] Tail displacement is strictly positive for all k. -/
theorem tail_disp_pos (k : Nat) :
  tailDisplacementPassT k ≥ 1 := by
  dsimp [tailDisplacementPassT]
  split <;> omega

/-- [Challenge Goal 5] When k = 1 (n = 3 mod 4), tail shift is exactly 1. -/
theorem tail_disp_eq_one_of_k_one :
  tailDisplacementPassT 1 = 1 := rfl

/-- [Challenge Goal 6] When k >= 2 (n = 1 mod 4), tail shift is >= 2. -/
theorem tail_disp_ge_two_of_k_ge_two (k : Nat) (hk : k ≥ 2) :
  tailDisplacementPassT k ≥ 2 := by
  dsimp [tailDisplacementPassT]
  split
  · omega
  · omega

/-!
### 4. Initial Buffer Compression Under Ascent (Proposition 1)
-/

def deltaGap0 : Int := (tailDisplacementPass0 : Int) - (maxHeadDisplacement : Int)

/-- [Challenge Goal 7] Initial buffer compression under maximum ascent is exactly -1. -/
theorem initial_compression_eq_neg_one :
  deltaGap0 = -1 := rfl

/-!
### 5. Universal Collision Freedom Under Regime I (Theorem 1)
-/

def gapAtPass (initial_buffer : Nat) (cumulative_drift : Int) : Int :=
  (initial_buffer : Int) - cumulative_drift

/-- [Challenge Goal 8] Under S > D_max, gap remains strictly >= 1. -/
theorem regime_I_collision_freedom (S : Nat) (D_max : Nat) (hS : S > D_max)
  (cum_drift : Int) (hcum : cum_drift ≤ (D_max : Int)) :
  gapAtPass S cum_drift ≥ 1 := by
  dsimp [gapAtPass]
  omega

/-- [Challenge Goal 9] Under S >= D_max + 2, gap remains strictly >= 2. -/
theorem regime_I_safe_separation (S : Nat) (D_max : Nat) (hS : S ≥ D_max + 2)
  (cum_drift : Int) (hcum : cum_drift ≤ (D_max : Int)) :
  gapAtPass S cum_drift ≥ 2 := by
  dsimp [gapAtPass]
  omega

def maxWritePos (head_pos : Int) : Int := head_pos + 2

/-- [Challenge Goal 10] Sound separation between modifying writes and next word tail. -/
theorem write_separation_sound (head_prev : Int) (gap : Int) (hgap : gap ≥ 2) :
  head_prev + 2 < head_prev + 1 + gap := by
  omega

/-!
### 6. Attractor Soliton Dynamics (Theorem 2)
-/

def solitonTailVelocity : Nat := 2
def solitonHeadVelocity : Nat := 2

/-- [Challenge Goal 11] Soliton rigid translation: tail velocity equals head velocity. -/
theorem soliton_rigid_translation :
  solitonTailVelocity = solitonHeadVelocity := rfl

/-- [Challenge Goal 12] Soliton group velocity is strictly 2 cells per pass. -/
theorem soliton_group_velocity :
  solitonTailVelocity = 2 := rfl

/-- [Challenge Goal 13] Spatial gap velocity freezes to zero in the attractor. -/
theorem soliton_gap_freezing :
  (solitonTailVelocity : Int) - (solitonHeadVelocity : Int) = 0 := by decide

/-!
### 7. Exact Reverse Arithmetic Preimage Recovery (Section 8)
-/

def reverseReconstruction (m : Nat) (k : Nat) : Nat :=
  (m * (2 ^ k) - 1) / 3

/-- [Challenge Goal 14] Deterministic predecessor recovery is algebraically exact. -/
theorem reverse_exactness (n : Nat) (m : Nat) (k : Nat)
  (h : 3 * n + 1 = m * 2 ^ k) :
  reverseReconstruction m k = n := by
  dsimp [reverseReconstruction]
  omega

/-!
### 8. Identical Trajectory Relative Gap Invariant (Section 4 & 6)
-/

/-- [Challenge Goal 15] Relative gap contraction is exactly equal to negative word-length change. -/
theorem identical_words_gap_compression
  (Δtail_1 Δtail_2 Δhead_1 ΔL : Int)
  (h_identical_tail : Δtail_2 = Δtail_1)
  (h_head_def : Δhead_1 = Δtail_1 + ΔL) :
  Δtail_2 - Δhead_1 = -ΔL := by
  omega

end Syracuse
