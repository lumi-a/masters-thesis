#import "preamble.typ": *; #show: preamble
#import "@preview/ctheorems:1.1.3": *; #show: thmrules.with(qed-symbol: $square$)
#let lemma = thmbox("lemma", "Lemma", fill: black.lighten(95%), breakable: true, base_level: 0)
#let corollary = thmbox("corollary", "Corollary", fill: black.lighten(95%), breakable: true, base_level: 0)
#let theorem = thmbox("theorem", "Theorem", fill: cyan.lighten(50%), breakable: true)
#let definition = thmbox("definition", "Definition", fill: red.lighten(90%), breakable: true)
#let example = thmbox("example", "Example", fill: green.lighten(90%), breakable: true)
#let proof = thmproof("proof", "Proof", breakable: true, outset: (left: -0.5em), radius: 0em, stroke: (left: 0.1em + gray))

#let Weight = math.op("Weight")
#let Profit = math.op("Profit")

Let $A$ and $B$ be two instances of the Knapsack-problem, given as lists of $vec("Weight", "Profit")$-vectors.
- Let $⊕$ denote list-concatenation. This is associative but not commutative.
- Let $|A|$ be the length of the list $A$.
- For some scalar $M∈R$, let $M B ≔ [M ⋅b mid(|) b ∈ B]$.
- Let $norm(A) ≔ norm(scripts(∑)_(a∈A)a)_∞ +1$.

For example:
$
  A ⊕ norm(A)B
  quad=quad
  A ⊕ [vec(norm(A)⋅w, norm(A)⋅p) med mid(|)med vec(w, p) ∈ B].
$
Here, $norm(A)$ is a large scalar to make the elements from $B$ more relevant than the elements from $A$
#lemma[
  For all $M∈ℝ$ (including $M=0$), $lr(size: #150%, |A⊕ M B|) = |A|+|B|$.
] <size-lemma>
#proof[
  It's just list-concatenation.
]
#lemma[
  For all $M∈ℝ$, if $A_1$ is a sublist of $A_2$ and $B_1$ is a sublist of $B_2$, then $A_1⊕ M B_1$ is a sublist of $A_2⊕ M B_2$.
]<subinstance-lemma>
#proof[
  It's just list-concatenation.
]

For some instance $I$, let $P(I)$ be its pareto-set.
#lemma[
  Let $M ≥ norm(A)$. Let $L ≔ L_A ⊕ M L_B$ be a sublist of $A ⊕ M B$, where $L_A$ is a sublist of $A$ and $L_B$ is a sublist of $B$. The following are equivalent:
  #[
    #set enum(numbering: "(1)")
    + $L ∈ P(A ⊕ M B)$
    + $L_A ∈ P(A)$ and $L_B ∈ P(B)$
  ]
] <pareto-product-lemma>
#proof[
  - $¬(2) ⇒ ¬(1)$: If (2) is false, one of the following must hold:
    - There is a sub-list $D_A⊆A$ such that $D_A$ dominates $L_A$. Then $D_A ⊕ M L_B$ dominates $L$.
    - There is a sub-list $D_B⊆B$ such that $D_B$ dominates $L_B$. Then $L_A ⊕ M D_B$ dominates $L$.
  - $¬(1) ⇒ ¬(2)$: If (1) is false, there exist sublists $D_A ⊆ A$ and $D_B ⊆ B$ such that $D ≔ D_A ⊕ M D_B$ dominates $L$. We only consider the case $Weight(L) > Weight(D)$ and $Profit(L) ≤ Profit(D)$, the other case is analogous.
    $
      Weight(L_A) + M⋅Weight(L_B) quad & >quad Weight(D_A) + M⋅Weight(D_B) \
      Profit(L_A) + M⋅Profit(L_B) quad & ≤quad Profit(D_A) + M⋅Profit(D_B) \
    $
    Because $M ≥ norm(A)$ is so large, this already implies $Weight(L_B) ≥ Weight(D_B)$, otherwise the first inequality wouldn't hold. Similarly, the second inequality implies $Profit(L_B) ≤ Profit(D_B)$. Now, distinguish two cases:
    - If $Weight(L_B) > Weight(D_B)$ or $Profit(L_B) < Profit(D_B)$, then $D_B$ dominates $L_B$, so $L_B∉P(B)$.
    - If $Weight(L_B) = Weight(D_B)$ and $Profit(L_B) = Profit(D_B)$, the above inequalities imply:
      $
        Weight(L_A) quad & >quad Weight(D_A) \
        Profit(L_A) quad & ≤quad Profit(D_A), \
      $
      so $D_A$ dominates $L_A$, hence $L_A ∉P(A)$.
]
In other words, $P(A ⊕ M B) = lr(size: #150%, [L_A ⊕ M L_B med mid(|)med L_A ∈ P(A), L_B ∈ P(B)])$. So $abs(P(A ⊕ M B)) = |A|⋅|B|$, for any $M ≥ norm(A)$.

Let $I$ be some instance of the Knapsack-Problem, and $J$ a sub-instance of $I$. Let $M ≔ norm(I)$, fix some $k∈ℕ$ and consider the following instances:
$
  I^k & ≔ I ⊕ M^1I ⊕ M^2I ⊕ … ⊕ M^k I \
  J^k & ≔ J ⊕ M^1J ⊕ M^2J ⊕ … ⊕ M^k J
$
- @size-lemma implies $abs(I^k) = abs(I)⋅k$.
- @subinstance-lemma implies that $J^k$ is a subinstance of $I^k$.
- @pareto-product-lemma implies that $abs(P(I^k)) = abs(P(I))^k$ and $abs(P(J^k)) = abs(P(J))^k$.

#v(1em)
Assume $α ≔ abs(P(J))/abs(P(I)) > 1$ (such instances exist). Then $abs(P(J^k)) / abs(P(I^k)) = α^k$ (exponential growth), and $abs(I^k) = abs(I)⋅k$ (linear growth).
