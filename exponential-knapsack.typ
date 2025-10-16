#import "preamble.typ": *; #show: preamble
#import "@preview/ctheorems:1.1.3": *; #show: thmrules.with(qed-symbol: $square$)
#let lemma = thmbox("lemma", "Lemma", fill: black.lighten(95%), breakable: true, base_level: 0)
#let corollary = thmbox("corollary", "Corollary", fill: purple.lighten(75%), breakable: true, base_level: 0)
#let theorem = thmbox("theorem", "Theorem", fill: cyan.lighten(50%), breakable: true)
#let definition = thmbox("definition", "Definition", fill: red.lighten(90%), breakable: true)
#let example = thmbox("example", "Example", fill: green.lighten(90%), breakable: true)
#let proof = thmproof("proof", "Proof", breakable: true, outset: (left: -0.5em), radius: 0em, stroke: (left: 0.1em + gray))

#let Weight = math.op("Weight")
#let Profit = math.op("Profit")

Let $A$ and $B$ be two instances of the Knapsack-problem, given as lists of $vec("Weight", "Profit")$-vectors.
- Let $⊕$ denote list-concatenation. This is associative but not commutative.
- Let $abs(A)$ be the length of the list $A$.
- For some scalar $M∈ℝ_(>0)$, let $M B ≔ [M ⋅b mid(|) b ∈ B]$.
- Let $norm(A) ≔ norm(scripts(∑)_(a∈A)a)_∞ +1$.

For example:
$
  A ⊕ norm(A)B
  quad=quad
  A ⊕ [vec(norm(A)⋅w, norm(A)⋅p) med mid(|)med vec(w, p) ∈ B].
$
Here, $norm(A)$ is a large scalar to make the elements from $B$ more relevant than the elements from $A$.
#lemma[
  For all $M∈ℝ_(>0)$: $abs(A⊕ M B) = abs(A)+abs(B)$.
] <size-lemma>
#proof[
  It's just list-concatenation.
]
#lemma[
  For all $M∈ℝ_(>0)$, if $A_1$ is a sublist of $A_2$ and $B_1$ is a sublist of $B_2$, then $A_1⊕ M B_1$ is a sublist of $A_2⊕ M B_2$.
]<subinstance-lemma>
#proof[
  It's just list-concatenation.
]

For some instance $I$, let $P(I)$ be its pareto-set.
#lemma[
  Let $M ≥ norm(A)$. Let $L ≔ L_A ⊕ M L_B$ be a sublist of $A ⊕ M B$, where $L_A$ is a sublist of $A$ and $L_B$ is a sublist of $B$. The following are equivalent:
  #[
    #set enum(numbering: "(1)")
    + $L ∈ P(A ⊕ M B)$,
    + $L_A ∈ P(A)$ and $L_B ∈ P(B)$.
  ]
  In other words, $P(A ⊕ M B) = lr(size: #150%, [S_A ⊕ M S_B med mid(|)med S_A ∈ P(A), S_B ∈ P(B)])$.
] <pareto-product-lemma>
#proof[
  - $¬(2) ⇒ ¬(1)$: If (2) is false, one of the following must hold:
    - There is a sub-list $D_A⊆A$ such that $D_A$ dominates $L_A$. Then $D_A ⊕ M L_B$ dominates $L$.
    - There is a sub-list $D_B⊆B$ such that $D_B$ dominates $L_B$. Then $L_A ⊕ M D_B$ dominates $L$.
  - $¬(1) ⇒ ¬(2)$: If (1) is false, there exist sublists $D_A ⊆ A$ and $D_B ⊆ B$ such that $D ≔ D_A ⊕ M D_B$ dominates $L$. We only consider the case "$Weight(L) > Weight(D)$ and $Profit(L) ≤ Profit(D)$", the other case is analogous. It follows that:
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
#corollary(numbering: none)[
  For all $M ≥ norm(A):quad abs(P(A ⊕ M B)) = abs(P(A))⋅abs(P(B))$.
]


Now, let $I$ be an instance of the Knapsack-Problem with a sub-instance $J$ such that $abs(P(J)) > abs(P(I))$.

#example(numbering: none)[
  $
    I ≔ [vec(4, 4),quad vec(4, 4),quad vec(2, 1),quad vec(1, 2),quad vec(2, 2)].
  $
  Here, $J = [vec(4, 4), vec(4, 4), vec(2, 1), vec(1, 2)]$ has size $12$, while $P_5 = P(I)$ has size $10$.
]

Let $α ≔ abs(P(J))/abs(P(I))$ be the ratio of their sizes, which is greater than $1$.

Let $M ≔ norm(I)$, fix some $k∈ℕ$ and consider the following two instances:
$
  I^k & ≔ I ⊕ M^1I ⊕ M^2I ⊕ … ⊕ M^k I \
  J^k & ≔ J ⊕ M^1J ⊕ M^2J ⊕ … ⊕ M^k J
$
- @size-lemma implies $abs(I^k) = abs(I)⋅k$.
- @subinstance-lemma implies that $J^k$ is a subinstance of $I^k$.
- The corollary implies that $abs(P(I^k)) = abs(P(I))^k$ and $abs(P(J^k)) = abs(P(J))^k$.

Thus, $abs(P(J^k)) \/ abs(P(I^k)) = α^k$ (exponential growth), whereas $abs(I^k) = abs(I)⋅k$ (linear growth).

In the above example, $I$ has size $5$, and $abs(P(I))/abs(P(J)) = 1.2$, so we get:

#theorem(numbering: none)[
  For a knapsack-instance $I$ of size $n$, there can exist a sub-instance $J$ such that:
  $
    abs(P(J))/abs(P(I))
    quad ≥ quad
    1.2^(n\/5)
    ≈ 1.037^n.
  $
]
For an instance $I$ where $(abs(P(J))\/abs(P(I)))^(1\/abs(I))$ larger than $1.037$, we would get an even better bound.

#line(length: 100%)

For an instance $I$, we say that $P(I)$ is *duplicate-free* iff there is no pair of lists $L_1, L_2 ∈ P(I)$ such that both $Weight(L_1)=Weight(L_2)$ and $Profit(L_1)=Profit(L_2)$. This property is useful because, if $P(I)$ is duplicate-free, then the representation of $P(I)$ in the Nemhauser-Ullmann algorithm has size $abs(P(I))$ too (as opposed to being smaller by ignoring duplicates).

#lemma[
  For $M≥norm(A)$, the pareto-set $P(A ⊕ M B)$ is duplicate-free iff both $P(A)$ and $P(B)$ are duplicate-free.
]
#proof[
  This is consequence of @pareto-product-lemma and the fact that $M ≥ norm(A)$.
]

So the earlier result applies to the Nemhauser-Ullmann algorithm, as well.
