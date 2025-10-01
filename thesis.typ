#import "preamble.typ": *; #show: preamble
#import "draw-packing.typ";
#import "@preview/subpar:0.2.2"
#import "@preview/frame-it:1.2.0": *
#import "@preview/lilaq:0.5.0" as lq

#import "@preview/ctheorems:1.1.3": *; #show: thmrules.with(qed-symbol: $square$)
#let theorem = thmbox("theorem", "Theorem")
#let definition = thmbox("definition", "Definition", fill: red.lighten(87.5%))
#let example = thmbox("example", "Example", fill: green.lighten(87.5%))
#let proof = thmproof("proof", "Proof")


#set heading(numbering: "1.1")


= Problems and Definitions
== Bin-Packing
In the bin-packing problem, we are given a capacity $c$ and a list of $n$ items with weights $w_1, …, w_n$, each bounded by $c$. Our task is to find a _packing_, i.e. we must pack all items into bins of capacity $c$ such that each item is in exactly one bin and for all bins, the sum of its items must not exceed $c$. Our objective is to use as few bins as possible. Finding a packing with the minimum number of bins is NP-hard @binPackingRevisited.

#example[
  We have to assign the following five items to bins with capacity $c=10$:
  $
    w_1, …, w_5 quad=quad 4, 7, 2, 3, 4
  $
  An optimal packing is shown in @bin-packing-optimal.
] <bin-packing-example>


#subpar.grid(
  figure(
    draw-packing.packing(10, ((7, 3), (4, 2, 4))),
    caption: [An optimal packing.],
  ),
  <bin-packing-optimal>,

  figure(
    draw-packing.packing(10, ((4, 3), (7, 2), (4,))),
    caption: [The packing found by _Best-Fit_.],
  ),
  figure(
    draw-packing.packing(10, ((4,), (7, 2), (3, 4))),
    caption: [The packing found by _Next-Fit_.],
  ),

  figure(
    draw-packing.packing(10, ((4, 2, 3), (7,), (4,))),
    caption: [The packing found by _First-Fit_.],
  ),

  caption: [Different Packings for @bin-packing-example.],
  columns: (1fr, 1fr),
)

In practice, heuristics are used @binPackingRevisited @binPackingHeuristics. All of the following heuristics are _online_: The items $w_i$ arrive in sequence and the heuristic has to assign $w_i$ permanently to a bin. Once the item $w_i$ has been processed, its assignment can not be changed.
- _Best-Fit_: When item $w_i$ arrives, pack it into a bin which has the least remaining space among the bins that can contain $w_i$. If no such bin exists, open a new one.
- _Next-Fit_: When item $w_i$ arrives, pack it into the bin that $w_(i-1)$ was assigned to, or open a new bin if this is not possible.
- _First-Fit_: Order the bins by the time in which they were opened, and pack $w_i$ into the oldest bin in which it fits. If no such bin exists, open a new one.

== Knapsack Problem
In the traditional Knapsack-Problem, we are given a capacity $c$ and a list $I$ of $n$ items, each having both a non-negative weight $w_i≤c$ and a non-negative profit $p_i$. Instead of minimising the number of bins we use, we are only allowed to use a single bin of capacity $c$ and the total weight of the items we put in this bin must not exceed $c$. Our objective is to _maximize_ the total profit of the items we put in the bin.

#let Weight = math.op("Weight")
#let Profit = math.op("Profit")

#example[
  We denote items by a column-vector $vec("Weight", "Profit")$. We are given a capacity $c=20$ and the following items:
  $
    I = [vec(4, 9),quad vec(5, 1),quad vec(13, 14),quad vec(3, 8),quad vec(11, 4),quad vec(6, 14)]
  $
  The optimal list of items to put into our bin is $[vec(4, 9), vec(5, 1), vec(3, 8), vec(6, 14)]$, with a total weight of $18$ and a total profit of $32$.
] <knapsack-example>

A *solution* is any sub-list of the list of items $I$, regardless of whether it exceeds the capacity $c$. For some solution $A$, we denote by $Weight(A)$ its total weight (i.e. the sum of the weights of the items in $A$), and by $Profit(A)$ its total profit. We can visualize the space of _all_ possible solutions -- including those that exceed the maximum weight capacity -- by plotting the tuple $(Weight(A), Profit(A))$.

#figure(
  {
    let items = ((4, 9), (5, 1), (13, 14), (3, 8), (11, 4), (6, 14))
    let powerset = ((0, 0),)
    for item in items {
      for subset in powerset {
        let new_subset = (subset.at(0) + item.at(0), subset.at(1) + item.at(1))
        powerset.push(new_subset)
      }
    }
    let dominates = (a, b) => a.at(0) <= b.at(0) and a.at(1) >= b.at(1) and (a.at(0) < b.at(0) or a.at(1) > b.at(1))
    let dominated = powerset.filter(wp => powerset.any(x => dominates(x, wp)))
    let undominated = powerset.filter(wp => powerset.all(x => not dominates(x, wp)))

    let opt-xs = 4 + 5 + 3 + 6
    let opt-ys = 9 + 1 + 8 + 14

    let dominated-feasible = dominated.filter(wp => wp.at(0) <= 20)
    let dominated-unfeasible = dominated.filter(wp => wp.at(0) > 20)
    let undominated-feasible = undominated.filter(wp => wp.at(0) <= 20)
    let undominated-unfeasible = undominated.filter(wp => wp.at(0) > 20)

    let xs = arr => arr.map(wp => wp.at(0))
    let ys = arr => arr.map(wp => wp.at(1))

    lq.diagram(
      lq.scatter(
        xs(dominated-feasible),
        ys(dominated-feasible),
        color: green,
        mark: lq.marks.at("."),
      ),
      lq.scatter(
        xs(dominated-unfeasible),
        ys(dominated-unfeasible),
        color: red,
        mark: lq.marks.at("."),
      ),
      lq.scatter(
        xs(undominated-feasible),
        ys(undominated-feasible),
        color: green,
        mark: lq.marks.star,
      ),
      lq.scatter(
        xs(undominated-unfeasible),
        ys(undominated-unfeasible),
        color: red,
        mark: lq.marks.star,
      ),
      lq.scatter(
        (opt-xs,),
        (opt-ys,),
        color: blue,
        mark: mark => place(center + horizon, circle(radius: 4pt, fill: none, stroke: blue + 1pt)),
        z-index: 10,
      ),
      xlabel: [#text(font: font-math)[Total Weight]],
      ylabel: [#text(font: font-math)[Total Profit]],
      height: 30%,
      width: 60%,
    )
  },
  caption: [All $2^6$ possible solutions to @knapsack-example. Solutions exceeding capacity $c=20$ are marked in red. The optimum is circled in blue. Pareto-optimal solutions are marked by $#sym.star.filled$.],
) <fig-example-knapsack>

=== Pareto-Sets

In practice, one might not know the capacity beforehand, or might have unlimited capacity but some tradeoff-function between weights and profits, for example $u(w, p) = p - w^2$. To cover all these cases simultaneously, we can narrow down the space by eliminating all solutions that can never be optimal. The set of those solutions is the _Pareto-set_:

// TODO: Add citation
#definition[
  For solutions $A$ and $B$, we say $A$ *dominates* $B$ if and only if:
  $
    Weight(A) ≤ Weight(B)
    quad "and" quad
    Profit(A) ≥ Profit(B),
  $
  and at least one of those inequalities is strict. The *Pareto-set* $P(I)$ is the set of all solutions that are not dominated by any other solution.

  TODO: Not really a set. Maybe do use index-vectors.
]
See @fig-example-knapsack. In this example, the Pareto-set has size $15$, much smaller than the size of the entire solution-space. In fact, the Pareto-set is usually small in practice @RoeglinBookChapter @moitraSmoothed, hence one approach to finding an optimal solution is to compute the Pareto-Set $P(I)$ and finding a solution in $P(I)$ that maximizes the objective. Let $n≔|I|$. If $P(I)$ has already been computed, a simple linear search yields an optimal solution in time $O(|P(I)|)$.

The standard algorithm for computing $P(I)$ is the _Nemhauser-Ullman algorithm_ @NU69 @RoeglinBookChapter, which incrementally computes the Pareto-sets $P_i ≔ P(I_(1:i))$ for $i=1,…,n$, where "$I_(1:i)$" denotes the instance containing the first $i$ items of $I$. It works as follows:
+ Set $P_0 = {∅}$.
+ For $i=1,…,|I|$:
  + Let $x$ be the $i$-th item of $I$.
  + Set $Q_i ≔ P_(i-1) ∪ {A∪{x} mid(|) A ∈ P_(i-1)}$
  + Compute $P_i ≔ {A ∈ Q_i mid(|) A "is not dominated by any" B∈Q_i}$

This algorithm can be implemented to run in time $O(|P_1| + … + |P_n|)$ @RoeglinBookChapter. Intuitively, one might think that $P_(i-1)$ is always smaller than $P_i$, but this need not be the case:

// TODO: Maybe use an example where all pareto-sets are distinct, to actually use the implementation-runtime of nemhauser-ullmann

#example[
  Consider the items:
  $
    I ≔ [vec(4, 4),quad vec(4, 4),quad vec(2, 1),quad vec(1, 2),quad vec(2, 2)].
  $
  #{
    let I = ((4, 4), (4, 4), (2, 1), (1, 2), (2, 2))
    let ps = (((),),)
    let dominates = (a, b) => a.at(0) <= b.at(0) and a.at(1) >= b.at(1) and (a.at(0) < b.at(0) or a.at(1) > b.at(1))
    let sumvecs = As => As.fold((0, 0), (x, y) => (x.at(0) + y.at(0), x.at(1) + y.at(1)))
    let indices-dominates = (As, Bs) => dominates(sumvecs(As.map(i => I.at(i))), sumvecs(Bs.map(i => I.at(i))))
    for i in range(I.len()) {
      let qi = ps.at(i) + ps.at(i).map(x => x + (i,))
      let pi = qi.filter(x => not qi.any(y => indices-dominates(y, x)))
      ps.push(pi)
    }
    // let display = paretoset => paretoset.map(solution => ${#solution.map(x => math.vec([#I.at(x).at(0)], [#I.at(x).at(1)])).intersperse($,$).sum(default: [])}$).intersperse($,$).sum()
    [Here, $P_#{ I.len() - 1 }$ has size $#ps.at(I.len() - 1).len()$, while $P_#{ I.len() } = P(I)$ has size $#ps.at(I.len()).len()$.]
    /*
    grid(
      stroke: none,
      columns: (1.5em,) * I.len(),
      rows: (1.5em,) * ps.map(x => x.len()).sum(),
      ..I.map(x => [$vec(#[#x.at(0)], #[#x.at(1)])$]),
      ..ps
        .map(
          paretoset => (
            paretoset.map(
              solution => range(I.len()).map(i => if solution.contains(i) { square(size: 1.25em, fill: black) } else { [] }),
            )
              + (grid.hline(),)
          ),
        )
        .flatten()
    )
    */
  }
]
It has been unknown whether $|P_i|$ can be bounded by some $O(|P_n|)$.



#bibliography("bibliography.bib", style: "springer-mathphys")
