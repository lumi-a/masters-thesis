#import "preamble.typ": *; #show: preamble
#import "draw-packing.typ";
#import "draw-clustering.typ";
#import "@preview/subpar:0.2.2"
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/lovelace:0.3.0": *;
#let pseudocode-list = pseudocode-list.with(booktabs: true, hooks: 0.5em)

#import "@preview/ctheorems:1.1.3": *; #show: thmrules.with(qed-symbol: $square$)
#let lemma = thmbox("lemma", "Lemma", fill: black.lighten(95%), breakable: true)
#let theorem = thmbox("theorem", "Theorem", fill: cyan.lighten(50%), breakable: true)
#let definition = thmbox("definition", "Definition", fill: red.lighten(90%), breakable: true)
#let example = thmbox("example", "Example", fill: green.lighten(90%), breakable: true)
#let proof = thmproof("proof", "Proof", breakable: true)

#set figure(gap: 1em)


#set heading(numbering: "1.1")

#let Cost = math.op("Cost")
#let Opt = math.op("Opt")
#let PoH = math.op("PoH")
#let BestFit = math.op("BestFit")
#let FirstFit = math.op("FirstFit")
#let NextFit = math.op("NextFit")
#let Apx = math.op("Apx")

= Problems, Definitions and Previous Results <section-problems-definitions>
== Bin-Packing <section-problems-bin-packing>
In the bin-packing problem, we are given a capacity $c$ and a list of $n$ items with weights $w_1, …, w_n$, each bounded by $c$. Our task is to find a _packing_, i.e. we must pack all items into bins of capacity $c$ such that each item is in exactly one bin and for all bins, the sum of its items must not exceed $c$. Our objective is to use as few bins as possible. Finding a packing with the minimum number of bins is NP-hard @binPackingRevisited.

#example[
  We have to assign the following five items to bins with capacity $c=10$:
  $
    w_1, …, w_5 quad=quad 4, 7, 2, 3, 4
  $
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

    caption: [Different Packings for @bin-packing-example, with bins of capacity $10$.],
    columns: (1fr, 1fr),
  )
] <bin-packing-example>

In practice, heuristics are used @binPackingRevisited @binPackingHeuristics. All of the following heuristics are _online_: The items $w_i$ arrive in sequence and the heuristic has to assign $w_i$ permanently to a bin. Once the item $w_i$ has been processed, its assignment can not be changed.
- _Best-Fit_: When item $w_i$ arrives, pack it into a bin which has the least remaining space among the bins that can contain $w_i$. If no such bin exists, open a new one.
- _Next-Fit_: When item $w_i$ arrives, pack it into the bin that $w_(i-1)$ was assigned to, or open a new bin if this is not possible.
- _First-Fit_: Order the bins by the time in which they were opened, and pack $w_i$ into the oldest bin in which it fits. If no such bin exists, open a new one.

For the above algorithms, usually $𝒜(I) < Opt(I)$, see @bin-packing-example. The following definitions allow us to compare the performance of different heuristics:

#definition[
  Let $cal(I)$ be the set of all (nonempty) bin-packing instances. For some instance $I∈cal(I)$, let $Opt(I)$ be the number of bins in an optimal packing, and $cal(A)(I)$ be the number of bins in the packing found by a bin-packing algorithm $cal(A)$. The *(absolute) approximation-ratio of $𝒜$* is $R_𝒜 ≔ sup_(I∈ℐ) 𝒜(I)/Opt(I)$.
]
The approximation-ratio of an algorithm captures the worst-case performance of an algorithm. For instance, the $R_BestFit = 1.7$ (proven by @bestFitAbsoluteRatio[p:]), meaning that:
- For every instance, the packing found by Best-Fit will never use more than $1.7$ times more bins than an optimal packing, and
- There is a sequence of instances $I_1, I_2, …$ such that $BestFit(I_j)/Opt(I_j)$ converges to $1.7$.

@firstFitAnalysis[p:] proved that $R_FirstFit = 1.7$ as well, and @nextFitAnalysis[p:] showed $R_NextFit = 2$.

Comparing algorithms by their absolute approximation-ratios can be a bit pessimistic: In practice, if we are in a position where we must use an online-algorithm, it might not be the case that _the entire input_ $I$ -- including the order of its items -- can be chosen by an adversary. In fact, we might assume that most of our inputs are not decided by an adversary at all. Thus, we define a less pessimistic measure for the performance of an algorithm:

#definition[
  Let $S_n$ be the set of permutations on $n$ elements, i.e. the symmetric group.
  - The *absolute random-order-ratio of $𝒜$* is $"RR"_𝒜 ≔ sup_(I∈ℐ) 𝔼_(π∈S_(|I|))[𝒜(π(I))/Opt(I)]$.
]

That is to say: We still assume an adversary can choose the _items_ of the instance, but the order of the items is randomized before being passed on to algorithm $𝒜$. Note that $Opt(I)$ does not depend on the order of the items.
@bestFitKenyon[p:] showed that $1.08 ≤ "RR"_BestFit ≤ 1.5$, with the lower bound improved to $1.3$ by @binPackingRevisited[p:].

#example[
  This example is (one element of the) lower-bound construction by @binPackingRevisited[p:] showing $1.3 ≤ "RR"_BestFit$ by.
  Consider bins of capacity $c=3000$ and the instance:
  $
    I quad ≔ quad [1004, 1004, #h(0.5em) 1016, 1016, #h(0.5em) 992].
  $
  #figure(
    draw-packing.packing(3000, ((1004, 1004, 992), (1016, 1016))),
    caption: [An optimal packing of $I$.],
  )
  #let lesser-packing = xs => scale(60%, draw-packing.packing(3000, xs))
  #figure(
    grid(
      align: left,
      columns: (33%, 33%, 33%),
      lesser-packing(((1016, 1004), (992, 1004), (1016,))), lesser-packing(((1004, 992, 1004), (1016, 1016))), lesser-packing(((1016, 992), (1004, 1004), (1016,))),
      lesser-packing(((1004, 1004, 992), (1016, 1016))), lesser-packing(((1016, 1004), (1004, 1016), (992,))), lesser-packing(((992, 1016), (1004, 1004), (1016,))),
      lesser-packing(((1016, 1004), (1004, 1016), (992,))), lesser-packing(((1004, 1004, 992), (1016, 1016))), lesser-packing(((992, 1016), (1004, 1016), (1004,))),
      //lesser-packing(((1016, 1016), (992, 1004, 1004))),
    ),
    caption: [Nine different packings produced by Best-Fit on $I$ with randomised order.],
  )
] <example-bin-packing-sota>



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
          color: purple,
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
          color: purple,
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
        width: 90%,
      )
    },

    caption: [All $2^6$ possible solutions to @knapsack-example. Solutions exceeding capacity $c=20$ are marked in purple. The optimum is circled in blue.\ Pareto-optimal solutions are marked by $#sym.star.filled$.],
  ) <fig-example-knapsack>
] <knapsack-example>

A *solution* is any sub-list of the list of items $I$, regardless of whether it exceeds the capacity $c$. For some solution $A$, we denote by $Weight(A)$ its total weight (i.e. the sum of the weights of the items in $A$), and by $Profit(A)$ its total profit. We can visualize the space of _all_ possible solutions -- including those that exceed the maximum weight capacity -- by plotting the tuple $(Weight(A), Profit(A))$.

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
#pseudocode-list[
  + Set $P_0 = {∅}$.
  + For $i=1,…,|I|$:
    + Let $x$ be the $i$-th item of $I$.
    + Set $Q_i ≔ P_(i-1) ∪ {A∪{x} mid(|) A ∈ P_(i-1)}$
    + Compute $P_i ≔ {A ∈ Q_i mid(|) A "is not dominated by any" B∈Q_i}$
] <this>

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

    let draw-pareto = (items, color) => {
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

      let xs = arr => arr.map(wp => wp.at(0))
      let ys = arr => arr.map(wp => wp.at(1))

      context (
        lq.diagram(
          lq.scatter(
            xs(dominated),
            ys(dominated),
            color: color,
            mark: lq.marks.at("."),
          ),
          lq.scatter(
            xs(undominated),
            ys(undominated),
            color: color,
            mark: lq.marks.at("star"),
          ),
          xlabel: [#text(font: font-math)[Total Weight]],
          ylabel: [#text(font: font-math)[Total Profit]],
          xaxis: (lim: (-1, 14)),
          yaxis: (lim: (-1, 14)),
          height: page.width * 0.2,
          width: page.width * 0.3,
        )
      )
    }
    figure(draw-pareto(I.slice(0, -1), blue) + h(1fr) + draw-pareto(I, green), caption: [Drawing the solution-space for $I_(1:4)$ (left) and $I_(1:5)=I$ (right) respectively, by plotting $(Weight(A), Profit(A))$ for every solution $A$, with Pareto-optimal solutions marked by a star. Fewer than $2^4$ (respectively $2^5$) points, and fewer than $12$ (respectively $10$) are actually visible, because some pairs of different solutions share the same total weight and total profit. If only counting Pareto-optimal solutions with unique weight and profit, $I_(1:4)$ has $9$, whereas $I$ only has $8$.])
  }
]
It has been unknown whether $|P_i|$ can be bounded by some $O(|P_n|)$.

== $k$-median Clustering
In the clustering-problem, we are given $n$ unlabeled data points $p_1,…,p_n ∈ ℝ^d$ and a number $k$. Our task is to find a *clustering*: A partition of the $n$ points into $k$ different clusters $C_1,…,C_k$, such that "close" points are clustered closely together. Different objectives exist that quantify this intuition.
- In $k$-means clustering, the cost of a cluster $C$ is: #h(1fr)
  $
    Cost(C) =
    ∑_(x∈C) ‖x-μ(C)‖_2^2,
    quad
    "where" μ(C) ≔ 1/(|C|) ⋅ ∑_(x∈C) x.
  $
  The total cost of a clustering $C_1,…,C_k$ is the sum of its costs: $Cost(C_1) + … + Cost(C_k)$.
- In $k$-median clustering, the $L_1$-norm is used instead, and the distance not measured from the centroid $mu$ but instead the best possible choice among the points in $C$:
  $
    Cost(C)
    = min_(mu in C) sum_(x in C) norm(x - mu)_1
  $
  The total cost of a clustering is again the sum of the cost of its clusters.
- TODO: Add more objectives, particularly ones with existing results on the PoH.

Naturally, these different objectives can yield different optimal clusterings, as seen in @clustering-example.

#let parse = str => str.trim().split().map(line => line.trim().split("").enumerate().filter(ixchar => ixchar.at(1) == "#").map(ixchar => ixchar.at(0) - 1)) // https://typst.app/docs/reference/foundations/str/#definitions-split
#let parse-hierarchical = text => text.split("---").map(section => parse(section))

#{
  /*
      let points = ((0.497, 0.533), (0.536, 0.480), (0.560, 0.598), (0.380, 0.884), (0.592, 0.736), (0.317, 0.743), (0.427, 0.919), (0.239, 0.163), (0.179, 0.280), (0.168, 0.086), (0.506, 0.385), (0.239, 0.860), (0.895, 0.066), (0.391, 0.264), (0.322, 0.828), (0.580, 0.043), (0.451, 0.263), (0.879, 0.332), (0.115, 0.232), (0.340, 0.023))
    let kmedian = parse("
  ###.......#.##.###..............
  .......###........##............
  ...####....#..#.................
  ")
    let kmeans = parse("
  ............#..#.#..............
  .......####..#..#.##............
  #######....#..#.................
  ")
    */
  let points = ((0.472, 0.011), (0.119, 0.697), (0.283, 0.445), (0.557, 0.516), (0.362, 0.565), (0.076, 0.375), (0.625, 0.464), (0.675, 0.229), (0.169, 0.926), (0.221, 0.786), (0.247, 0.298), (0.499, 0.294), (0.597, 0.815), (0.971, 0.311), (0.921, 0.184), (0.608, 0.757), (0.183, 0.766), (0.913, 0.413), (0.131, 0.954), (0.668, 0.647)).map(v => ((v.at(0) + 0.1) * 0.8, (v.at(1) + 0.1) * 0.8))
  let kmedian = parse("
#.#.#.#...#.#......#............
.#...#..##........#.............
.......#.....##..#..............
")
  let kmeans = parse("
#.#..#.....#....................
.#..#.......#..#..#.............
...#...#.....##..#.#............
")
  context [#figure(
      draw-clustering.draw-clustering(points, kmedian, page.width * 0.4, 0.02, red) + h(1fr) + draw-clustering.draw-clustering(points, kmeans, page.width * 0.4, 0.02, blue),
      caption: [Two different $k"="3$-clusterings for the same  $20$ points in $ℝ^2$.\ Left: An optimal $k$-median clustering. Right: An optimal $k$-means clustering.
      ],
      // TODO: Do two examples side by side, one optimal and one sub-optimal
    ) <clustering-example>
  ]
}

When trying to cluster unlabeled data, we usually are not given a number $k$ of clusters to use. In such a scenario, we could use heuristics to determine a good choice of $k$ (see e.g. @stopUsingElbow[p:]). Alternatively, we could compute a _Hierarchical Clustering_, which is a sequence of nested $k$-clusterings for every choice of $k$ @priceOfHierarchicalClustering.

#definition[
  A *hierarchical clustering* on $n$ points is a sequence $(H_1, …, H_n)$ of clusterings such that:
  - $H_i$ is an $i$-clustering (i.e., it consists of $i$ clusters), for every $i=1,…,n$, and
  - For every $i=1,…,n-1$, the clustering $H_i$ can be obtained by merging two clusters in $H_(i+1)$. In other words, there exist clusters $C,C'∈H_(i+1)$ such that:
    $
      H_i quad = quad (H_(i+1) ∖ {C, C'}) ∪ {C∪C'}.
    $
]

The structure of hierarchical clusterings is, for example, useful for taxonomy, but does come at a cost: Usually, the optimal $k$-clusterings need not have a nested structure, so there might not exist a hierarchical clustering $(H_1, …, H_n)$ such that every $H_i$ is an optimal $i$-clustering. The set of points in @example-hierarchical-clustering is such an example.

#{
  let points = ((0.94, 0.68), (0.99, 0.12), (0.17, 1), (0.99, 0.04), (0.14, 0.92), (0.7, 0.87)).map(v => ((v.at(0) + 0.1) * 0.8, (v.at(1) + 0.1) * 0.8))
  let opt-hierarchical = parse-hierarchical("
######..........................
---
.#.#............................
#.#.##..........................
---
.#.#............................
..#.#...........................
#....#..........................
---
..#.#...........................
#...............................
.#.#............................
.....#..........................
---
....#...........................
#...............................
.#.#............................
.....#..........................
..#.............................
---
.....#..........................
....#...........................
#...............................
...#............................
..#.............................
.#..............................
")

  let opt-optimal = parse-hierarchical("
######..........................
---
##.#............................
..#.##..........................
---
.#.#............................
..#.#...........................
#....#..........................
---
..#.#...........................
#...............................
.#.#............................
.....#..........................
---
....#...........................
#...............................
.#.#............................
.....#..........................
..#.............................
---
.....#..........................
....#...........................
#...............................
...#............................
..#.............................
.#..............................
")
  context [
    #figure(draw-clustering.draw-hierarchical-clustering(points, opt-hierarchical, page.width * 0.4, true) + h(1fr) + draw-clustering.draw-hierarchical-clustering(points, opt-optimal, page.width * 0.4, false), caption: [Left: An optimal hierarchical clustering on $6$ points for the $k$-median objective.\ Right: For each $k=1,...,6$, an optimal $k$-median clustering on the same $6$ points, which do not form a nested structure.\
      The two sets of clusterings only differ at level $k=2$.
    ])<example-hierarchical-clustering>
  ]
}

To measure the quality of a hierarchical clustering $(H_1, …, H_n)$, we could simply sum the the costs of each level: $Cost(H_1) + … + Cost(H_n)$. However, $k$-clusterings for small $k$ can have significantly higher cost than $k$-clusterings for large $k$, so this would not capture a lot of information about the quality of the clusterings $H_i$ for low $i$. To avoid this, we can instead compare each level $H_i$ of the hierarchy to an _optimal_ $i$-clustering, and taking the maximum across all levels @priceOfHierarchicalClustering.

#definition[
  For a clustering-instance $I$ and a cost-function $Cost$, the *approximation-factor of a hierarchical clustering* $(H_1, …, H_n)$ on $I$ is:
  $
    Apx_Cost (H_1, …, H_n)
    quad ≔quad
    max_(i=1,…,n)
    Cost(H_i) / Cost(Opt_i),
  $
  where $Opt_i$ is an optimal $i$-clustering on $I$ with respect to $Cost$.
]

The approximation-factor of the hierarchical clustering in @example-hierarchical-clustering is $≈1.262$: The hierarchical clusterings and optimal clusterings shown there only differ for $k=2$, where $Cost(H_2) = 1.78$ and $Cost(Opt_i) = 1.41$.

For a fixed cost-function $Cost$, we say that a hierarchical clustering on an instance $I$ is *optimal* if it has the lowest possible approximation-factor among all hierachical clusterings on $I$. The hierarchical clustering shown in @example-hierarchical-clustering is optimal, it was the output of a program written for finding optimal hierarchical clusterings. Any better hierarchical clustering would have to carry the restriction $H_2 = Opt_2$, but due to the requirement of nested clusterings, this means that (as visible in the figure), $H_3 ≠ Opt_3$.

For a cost-function $Cost$, we can ask what we sacrifice by imposing a hierarchical structure, not just for some fixed instance $I$, but for _all_ instances $I$. This is the Price of Hierarchy @priceOfHierarchicalClustering.

#definition[
  For a cost-function $Cost$, let $cal(I)$ be the set of all clustering-instances for $Cost$. For a fixed clustering-instance $I$, let $cal(H)(I)$ be the (finite) set of all hierarchical clusterings on $I$.
  The *Price of Hierarchy for $Cost$* is defined as:
  $
    PoH_Cost
    quad ≔quad
    sup_(I∈cal(I)) (min_(H ∈ cal(H)(I)) Apx_Cost (H)).
  $
]
In particular, the instance in @example-hierarchical-clustering proves that $PoH_(k"-median") ≥ 1.26$.

== Generalised Gasoline-Problem

As a motivating example for the problem (similar to @Lorieau[p:]), we are in charge of a factory that produces cookies every day of the week. In doing so, it consumes exactly two ingredients: Flour and sugar. Each day of the week, both the amount of cookies and their sugar-content must follow a certain schedule. For instance, on Monday, we might be asked to use $vec("Flour", "Sugar")$-amounts equal to $y_1 = vec(3, 1)$ for our cookie-production, whereas each Tuesday, we must consume more and sweeter cookies, hence having to use $y_2 = vec(5, 5)$ amounts of flour and sugar. We can get flour and sugar delivered to our factory overnight, but we must pick these amounts from a list of seven possible delivery-trucks that are the same every week, but we can choose on which day of the week we would like to receive each truck. For instance, we can choose to have $x_1 = vec(4, 4)$ flour and sugar delivered to our factory, or $x_2 = vec(7, 10)$. Within a week, we can only order each delivery-truck exactly once, and we can only accept one delivery-truck per night because our driveway is too narrow. It's unlikely that we will be fortunate enough to have, for every demand-value $y_i$, a matching delivery-value $x_i$, so we must resort to storing leftover ingredients in our yet-to-be-built warehouse overnight.

Corporate has been kind enough to ensure that $y_1 + … + y_7 = x_1 + … + x_7$, meaning that, at the end of every week, we will have exactly the same amount of ingredients in our warehouse as at the beginning of the week. However, storing ingredients takes costly space, so we would like to minimise the total amount of warehouse we need to build, while the only free variable under our control is the permutation of the delivery-trucks across the week. Let $S_n$ be the set of permutations on $n$ elements. Mathematically, our task is:
$
  min_(π in S_7) & quad ‖α-β‖_1 \
   "where"quad α & =min_(1≤k≤7)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^k y_i)quad #box(width: 14em, baseline: 50%)["In the evening, we must have at least $α$ ingredients left over."] \
               β & =max_(1≤k≤7)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^(k-1) y_i)quad #box(width: 14em, baseline: 50%)["After the delivery overight, we must store at most $β$ ingredients"]
$
where the minimum across vectors is taken entry-wise. As an objective, we choose $‖α-β‖_1$, meaning we trade off the cost for space in the flour-warehouse linearly against the cost of space in the sugar-warehouse. We do not lose generality on the tradeoff-ratio between the two, since tradeoffs like "Sugar-warehouse space is twice as expensive as flour-warehouse space" can be captured by choosing different units for measuring amounts of flour and sugar. Non-linear tradeoffs are not captured, however. We write $X = (x_1,…,x_7)$ and $Y = (y_1,…,y_7)$.

#example[
  Consider:
  $
    X = & [vec(5, 3), vec(3, 10), vec(7, 8), vec(1, 2), vec(8, 9), vec(7, 4), vec(1, 1)],
          quad
          Y = & [vec(3, 4), vec(2, 8), vec(8, 1), vec(1, 5), vec(9, 4), vec(2, 10), vec(7, 5)],
  $
  #{
    let deliveries = ((5, 3), (3, 10), (7, 8), (1, 2), (8, 9), (7, 4), (1, 1))
    let production = ((3, 4), (2, 8), (8, 1), (1, 5), (9, 4), (2, 10), (7, 5))

    let scale = (x, s) => (x.at(0) * s, x.at(1) * s)
    let add = (x, y) => (x.at(0) + y.at(0), x.at(1) + y.at(1))
    let min = (x, y) => (calc.min(x.at(0), y.at(0)), calc.min(x.at(1), y.at(1)))
    let max = (x, y) => (calc.max(x.at(0), y.at(0)), calc.max(x.at(1), y.at(1)))
    let sub = (x, y) => (x.at(0) - y.at(0), x.at(1) - y.at(1))
    let norm = v => calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))
    let normed = v => scale(v, 1 / norm(v))
    let draw-permutation = pi => {
      let heightscale = 0.25em
      let barwidth = 0.85em
      let production-deliveries = production
        .enumerate()
        .map(ixp => {
          let p-ix = ixp.at(0)
          let p = ixp.at(1)
          let d = deliveries.at(pi.at(p-ix))
          (p, d)
        })

      let draw-state = (warehouse-history, production-delivery) => {
        let old-warehouse = warehouse-history.last()
        let p = production-delivery.at(0)
        let d = production-delivery.at(1)
        let morning = add(old-warehouse, d)
        let evening = sub(morning, p)
        warehouse-history + (morning, evening)
      }

      let timeline = production-deliveries.fold(((0, 0),), draw-state)
      let minhouse = timeline.fold((1000000, 100000), min)
      let maxhouse = timeline.map(pd => sub(pd, minhouse)).fold((-1000000, -100000), max)
      let maxmaxhouse = calc.max(maxhouse.at(0), maxhouse.at(1))

      let flourbar = warehouse => rect(fill: green, stroke: barwidth * 0.1 + black, width: barwidth, height: sub(warehouse, minhouse).at(0) * heightscale)
      let sugarbar = warehouse => rect(fill: purple, stroke: barwidth * 0.1 + black, width: barwidth, height: sub(warehouse, minhouse).at(1) * heightscale)
      let squares = timeline.map(warehouse => (flourbar(warehouse), sugarbar(warehouse), h(barwidth))).flatten()

      let line = (y, color) => place(dy: (maxmaxhouse - y) * heightscale, line(length: ((2 / 6) + production-deliveries.len()) * 6 * barwidth, stroke: (paint: color, thickness: 0.1em)))
      align(left + bottom)[
        #line(maxhouse.at(0) - 0.15, green)
        #line(maxhouse.at(1) + 0.15, purple)
        #line(0, gray)
        #stack(dir: ltr, ..squares, [...])
      ]
      align(left + bottom, stack(dir: ltr, h(barwidth), ..production-deliveries.map(pd => {
        let p = pd.at(0)
        let d = pd.at(1)
        [#box(width: 3 * barwidth, align(center)[$arrow.t$$vec(#[#d.at(0)], #[#d.at(1)])$])#box(width: 3 * barwidth, align(center)[$arrow.b$$vec(#[#p.at(0)], #[#p.at(1)])$])]
      })))
    }

    let iterative-rounding-permutation = (0, 1, 2, 6, 5, 3, 4)
    let opt-permutation = (6, 2, 0, 3, 4, 5, 1)
    let typeset-permutation = pi => [$[#pi.map(x => $vec(#[#deliveries.at(x).at(0)], #[#deliveries.at(x).at(1)])$).join(",")]$]
    [(corporate warranted $x_1"+"…"+"x_7=y_1"+"…"+"y_7$), together with the following permutation of deliveries:
      $
        π(X) ≔ #typeset-permutation(iterative-rounding-permutation).
      $
      The timeline of our warehouse can be visualised as follows: We use colored bars to represent the current amount of flour (green) and sugar (purple) in our warehouse. Vectors preceded by "$arrow.t$" indicate deliveries to our warehouse, vectors preceded by "$arrow.b$" indicate us consuming ingredients from the warehouse to bake cookies. The two horizontal colored lines indicate the maximum number of the respective ingredient that the warehouse must store across the week. We choose the initial stocking of our warehouse _minimally_ such that we will always have enough ingredients to never run out (this choice is exactly $β$ from the above optimization problem). This ensures that our warehouse has the smallest possible size for this permutation, and that for both ingredients, there must be a day on which that ingredient's warehouse is fully depleted (otherwise our choice would not be minimal, we would have wasted space).
      #figure(
        draw-permutation(iterative-rounding-permutation),
        kind: image,
        gap: 1.5em,
        caption: [The (cyclical) state of the warehouse across the week for permutation $π$.],
      )
      For this permutation, the warehouse must store a peak of $11$ flour on the night between Tuesday and Wednesday, and a peak of $13$ sugar on several nights between Tuesday and Thursday. There is a better permutation, though:
      $
        π_Opt (X) ≔ #typeset-permutation(opt-permutation),
      $
      #figure(
        draw-permutation(opt-permutation),
        kind: image,
        gap: 1.5em,
        caption: [The (cyclical) state of the warehouse across the week for permutation $π_Opt$.],
      )
      Here, the peak-capacity of the warehouse is only $10$ for both flour and sugar, so $π_Opt$ is a better choice than $π$ regardless of the tradeoff between the cost of flour-warehouse space and sugar-warehouse space.

      With the $L_1$ cost-function used above, $π$ has a cost of $11+13=24$, whereas $π_Opt$ has a cost of $10+10=20$ and is indeed an optimal permutation for this instance.
    ]
  }
]
Generally, an instance of the Gasoline-Problem // TODO: Explain why it's called that?
consists of two sequences of $d$-dimensional vectors containing strictly positive integral entries:
$
  X = (x_1,…,x_n) ∈ ℕ_(≥1)^(n×d), quad
  Y = (y_1,…,y_n) ∈ ℕ_(≥1)^(n×d),
$
who have the same total sum $x_1"+"…"+"x_n = y_1"+"…"+"y_n$. Our objective is to find a permutation $π ∈ S_n$ of the $X$-entries that minimises the prefix-sum discrepancy:
$
  min_(π in S_n) & quad ‖α-β‖_1 \
   "where"quad α & = min_(1≤k≤n)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^k y_i) ∈ ℤ^d \
               β & =max_(1≤k≤n)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^(k-1) y_i) ∈ℤ^d.
$
Even for $d=1$, this problem is NP-hard @Gasoline2018. Let $𝟙$ be a vector of appropriate dimensions whose entries only consist of $1$s. The problem can be written as an integer linear program (ILP) with a permutation-matrix $Z ∈ {0,1}^(d×d)$:
$
  min_(Z, α, β)quad & ‖α-β‖_1 \
          "s.t"quad
          α         & ≤ ∑_(i=1)^k Z x_i - ∑_(i=1)^k y_i, quad k=1,…,n \
                  β & ≥ ∑_(i=1)^k Z x_i - ∑_(i=1)^(k-1) y_i, quad k=1,…,n \
              𝟙^T Z & ≤ 𝟙^T, quad Z^T 𝟙 ≤ 𝟙 quad quad (\"Z "is a permutation-matrix"\") \
                  Z & ∈ {0,1}^(d×d) \
                α,β & ∈ ℝ^d.
$
The objective "$‖α-β‖_1$" is the same as "$𝟙^T (β-α)$" as $β ≥ α$, and thus indeed linear. With this ILP, we can formulate the Iterative-Rounding algorithm:
#let UnfixedRows = math.op("UnfixedRows")
#let ColumnIndex = math.op("ColumnIndex")
#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  pseudocode-list(numbered-title: [Iterative-Rounding Algorithm for the Gasoline-Problem])[
    + Initialise $UnfixedRows = {1,…,n}$. This keeps track of which rows of $Z$ we did not fix to integral values yet.
    + For $ColumnIndex = 1,…,n$:
      +
  ],
)



= FunSearch
Making progress on the different open problems in @section-problems-definitions involves a similar task for all of them: We would like to find instances that have a problem-specific undesirable quality.
- For bin-packing, we would like to find an instance where the randomised Best-Fit algorithm performs, in expectation, poorly compared to an optimum solution.
- For the Pareto-sets of knapsack-problems, we would like to find an instance $I$ where an intermittent Pareto-set $P(I_(1:i))$ is much larger than the Pareto-set $P(I)$ of the whole instance.
- For the Price of Hierarchy for $k$-median clustering, we would like to find instances whose Price of Hierarchy is large.
- For the generalised gasoline problem, we would like to find instances where the iterative-rounding algorithm // TODO: Insert reference once you write down the algorithm.
  performs poorly compared to an optimum soution.


#let Score = math.op("Score")
#let Mutation = math.op("Mutation")
#let Opt = math.op("Opt")
#let Avg = math.op("Avg")
Even without having intuition for or experience with the different problems, we can still attempt to find such instances. A standard approach // TODO: Add many, many citation
is to employ some search-algorithm that searches for an instance of a high "score" across the space of all instances, where the score is e.g. the approximation-ratio of the instance. For bin-packing with capacity $c=1$, such an an algorithm might look as follows:
#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  pseudocode-list(numbered-title: [Local Search for Instances Randomised Best-Fit Performs Poorly On])[
    + Fix the size $n$ of an instance, e.g. $n=10$.
    + Define the $Score(I)$ of a bin-packing instance $I$:
      + Calculate the value $Opt$ of an optimum solution to $I$, for instance\ using the implementation by @fontan[p:].
      + Calculate 10000 trials of:
        + Let $I'$ be a random permutation of $I$
        + Run Best-Fit on $I'$
      + Let $Avg$ be the average number of bins used across these trials
      + Return $Avg \/Opt$
    + Define a $Mutation(I)$ of an instance $I$:
      + Define a new list of items $I'$ that arises from $I$ by adding independently\ standard-normally distributed noise to each entry.
      + Clamp the entries of $I'$ to be between $0$ and $1$.
      + Return $I'$.
    + Initialise $I$ as the list $[1/2, ..., 1/2]$ of length $n$.
    + #line-label(<codeline-iteration-count>) Repeat the following until some stopping-criterion is met:
      + Calculate $I' = Mutation(I)$
      + If $Score(I') > Score(I)$:
        + Replace $I$ with $I'$
      + Otherwise:
        + Keep $I$ unchanged.
  ],
) <algorithm-local-search-bin-packing>

Variants of @algorithm-local-search-bin-packing include decreasing the mutation-rate over time, e.g. by decreasing the variance of the noise on $Mutation$, or stochastically allowing replacing $I$ with $I'$, even if $I'$ has a worse score, to prevent getting stuck in local optima. See @local-search-plot for trajectories drawn from @algorithm-local-search-bin-packing.

#figure(
  {
    let trajectories = range(10).map(i => read("assets/data/randomised-best-fit-local-search/" + str(i) + ".log", encoding: "utf8").split("\n").map(line => line.split("\t")).filter(split => split.len() >= 2).map(split => (split.at(0), split.at(1)))).map(history => history + ((10000, history.last().at(1)),))
    context (
      lq.diagram(
        yaxis: (lim: (1.0, 1.5)),
        xaxis: (exponent: none),
        height: page.width * 0.3,
        width: page.width * 0.6,
        xlabel: [#text(font: font-math)[Iteration]],
        ylabel: [#text(font: font-math)[Best Score]],
        ..trajectories.map(iteration-score => lq.plot(step: start, iteration-score.map(x => int(x.at(0))), iteration-score.map(x => float(x.at(1))))),
      )
    )
  },
  caption: [Ten example trajectories of @algorithm-local-search-bin-packing, with the termination-condition for the loop in @codeline-iteration-count set after 10000 iterations. For each of the ten trajectories, we plot the score of the best solution $I$ over time.],
) <local-search-plot>

Enterprising readers will remember from @section-problems-bin-packing that the best-known instance for randomised Best-Fit had a score of $1.3$, which the results from @local-search-plot seem to beat (though the score-measurement we employ in @algorithm-local-search-bin-packing only uses an _estimation_ of the expected value), the best trial achieving a score of $1.3725$, higher than the existing lower bound. _If_ we wanted to prove this rigorously, we would calculate the true score by running best-fit for all $10! ≈ 3.6⋅10^6$ possible permutations (the found instance (see @local-search-instance) has many exploitable symmetries, decreasing the required computations even further). We will not do so, however, in favour of proving a better result later on.

Instead, to motivate our next steps, we will try learning from the instance, perhaps spotting structures in it, hoping to use these to manually construct instances of even higher scores. Alas, @local-search-instance gives us little hope: Unlike e.g. the instance in @example-bin-packing-sota, the instance found by @algorithm-local-search-bin-packing does not seem to have a discernible pattern or noticeable symmetries. The four zero-weight items are a product of negative items in the mutation $I'$ being rounded up to $0$, and contribute nothing to the instance.

#figure(
  lq.diagram(
    yaxis: (lim: (0.0, 1.0)),
    xaxis: (ticks: none, subticks: none),
    lq.bar(
      fill: green,
      range(10),
      (0.0, 0.0, 0.0, 0.0, 0.13941968656458636, 0.1415175313246237, 0.18488603733618258, 0.20818251654978343, 0.6014145332633378, 0.7129758245684663),
    ),
  )
    + v(0.5em)
    + `[0.0, 0.0, 0.0, 0.0, 0.13941968656458636, 0.1415175313246237, 0.18488603733618258, 0.20818251654978343, 0.6014145332633378, 0.7129758245684663]`,
  kind: image,
  caption: [The sorted best instance found in the trials of @local-search-plot, achieving a score of $1.3725$.],
) <local-search-instance>

To mitigate these issues we could, instead of searching for lists of numbers, search for _short descriptions_ of lists of numbers, i.e. we search for short _python-code_ generating a list of numbers: Plain lists of numbers encode symmetric and structured instances just the same way as any other instances. But it is easier to write python-code that produces symmetric and structured instances, assuming we avoid #raw(block: false, lang: "py", "import random") and hard-coding lists of numbers.

For example, an instance in the lower-bound construction by @bestFitAbsoluteRatio[p:] can be expressed as hardcoded numbers as follows:
#figure(
  ```py
  items = [0.17166666666666666, 0.16791666666666666, 0.16697916666666665, 0.16674479166666667, 0.16668619791666667, 0.3283333333147069, 0.3320833333147069, 0.3330208333147069, 0.3332552083147069, 0.3333138020647069, 0.14666666666666667, 0.16166666666666665, 0.16541666666666666, 0.16635416666666666, 0.16658854166666665, 0.3533333333147069, 0.3383333333147069, 0.33458333331470685, 0.3336458333147069, 0.33341145831470687, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264]
  ```,
  caption: [The instance for the lower-bound construction in @bestFitAbsoluteRatio[p:] for $k=1$.],
)<hardcoded-best-fit>
However, @bestFitAbsoluteRatio[p:] actually defined these items as follows:
#figure(
  ```py
  k = 1
  OPT = 10*k
  δ = 1/50
  d = lambda j: δ/(4**j)
  ε = d(10*k + 5)

  b_plus = [1/6 + d(j) for j in range(1,1+OPT//2)]
  c_minus = [1/3 - d(j) - ε for j in range(1,1+OPT//2)]
  b_minus = [1/6 - d(j) for j in range(0,OPT//2)]
  c_plus = [1/3 + d(j) - ε for j in range(0,OPT//2)]
  trailing = [1/2 + ε] * OPT

  items = b_plus + c_minus + b_minus + c_plus + trailing
  ```,
  caption: [The same instance as in @hardcoded-best-fit.],
)
For larger $k$, the code for the hardcoded instance grows even larger (though would run into floating-point rounding issues), while the structured definition remains short and interpretable.

If we now tried to implement @algorithm-local-search-bin-packing by searching on the space of python-code instead of the space $ℝ^10$, we will have trouble defining the $Mutation$-function, which is meant to return a mutated variant of our current solution. Defining $Mutation$ by throwing noise onto the python-code (e.g. randomly change or swap characters) like we did for $ℝ^10$, most mutated programs would fail to compile. One can try circumventing this by not interpreting python-code as a sequence of characters, but as a composition-tree of basic computational functions, an approach known as _Genetic Programming_ @genetic0 @genetic2 @genetic1.

Instead of Genetic Programming, we will follow the approach of @romera2024mathematical[p:] called *FunSearch*. Instead of mutating python-code by randomly changing characters, this approach mutates python-code by querying a large language model (LLM). An example for such a query is shown in @example-prompt, and an example-response in @example-response. The advantage of this method is that we retain both interpretable structure, and python-code that compiles most of the time. Furthermore (though this was not done in the shown examples), the python-code can be generalised on some sets of parameters. For instance, the `get_items` functions could accept an integer-parameter that tells the function the maximum allowed size of the list. Our evaluation-function $Score$ then rejects lists exceeding that length, and we could mathematically analyse the asymptotic behaviour of the function after the fact.

// TODO: Describe FunSearch more. Concurrency, multiple programs in a prompt, islands, potential merging (though it didnt matter), favouring shorter programs in the prompt

#figure(
  align(left, box(stroke: 0.1em + gray, radius: 0.5em, fill: white.darken(2%), inset: 1em, text(font: font-monospace, size: 0.75em)[I'm trying to find instances of the bin-packing problem where, if the input is shuffled, the best-fit online-heuristic performs poorly in expectation. All bins have capacity 1.0.

    To generate instances that best-fit performs poorly on, I have tried the following functions so far. Please write another one that returns an instance and is similar, but has some lines altered.

    \`\`\`python
    ```python

    import math


    def get_items_v0() -> list[float]:
        """Return a new bin-packing-instance, specified by the list of items.

        The items must be floats between 0 and 1.
        """
        """Generate a bin-packing-instance similar to v0 but with some modifications to induce worse performance after shuffling."""
        items = []
        for i in range(1, 11):
            if i % 3 == 0:
                items.append(0.7)  # add larger items that challenge best-fit
            else:
                items.append(1.0 / i)
        # add some small items to increase total items and create fragmentation
        items.extend([0.05, 0.05, 0.05])
        return items


    def get_items_v1() -> list[float]:
        """Improved version of `get_items_v0`."""
        """Return a new bin-packing-instance, similar to get_items_v0,
        but with some lines altered to create input that challenges best-fit heuristics.
        """
        items = []
        for i in range(2, 11):
            items.append(1.0 / i + 0.05)
        # Add some larger items to cause early packed bins
        items.extend([0.6, 0.55])
        # Add smaller items to increase mix complexity
        for i in range(15, 20):
            items.append(1.0 / i)
        return items
    ```
    \`\`\`
  ])),
  caption: [An example prompt given to the LLM, along with the system-prompt "`You are a helpful coding assistant who only responds with python-code and no markdown-formatting.`"],
)<example-prompt>
#figure(
  align(left, box(stroke: 0.1em + gray, radius: 0.5em, fill: white.darken(2%), inset: 1em, text(font: font-monospace, size: 0.75em)[
    ```py
    def get_items_v2() -> list[float]:
        """Return a bin-packing-instance similar to previous ones but with some lines altered to cause worse performance after shuffling."""
        items = []
        # Replace small fractional items with slightly larger ones to increase fragmentation
        for i in range(1, 9):
            if i % 2 == 0:
                items.append(0.4 + 0.02 * i)  # slightly larger items that challenge best-fit
            else:
                items.append(1.0 / (i + 3))
        # Include some large items to force inefficient packing
        items.extend([0.65, 0.63])
        # Add very small items close to 0.02 to fill gaps after shuffling
        items.extend([0.02, 0.02, 0.02])
        return items
    ```
  ])),
  caption: [A response to the prompt in @example-prompt. The responding LLM was `gpt-4.1-nano` with a temperature-parameter of $1.2$.],
) <example-response>

// TODO: Describe more the tuning of the instances

= Results
== Bin-Packing
For fixed $m in ℕ$, consider the instance:

$
  I ≔ [underbrace(m + 1\,#h(0.5em) dots.h\,#h(0.5em) m + 1, m upright(" times")),#h(1em) underbrace(m \,#h(0.5em) dots.h \,#h(0.5em) m, m + 1 upright(" times"))] \, #h(2em) upright("maximum bin capacity ") c colon.eq m dot.op (m + 1).
$

An optimal packing puts the first $m$ items into one bin, and the
remaining $m + 1$ items into a second bin. This fills both bins exactly
to their maximum capacity.

#let m = 6
#figure(
  draw-packing.packing(m * (m + 1), ((m + 1,) * m, (m,) * (m + 1))),
  caption: [An optimal packing for $m=6$, using two bins. The bins have capacity $c = m⋅(m+1) =42$.],
)

#let lesser-packing = xs => scale(70%, draw-packing.packing(m * (m + 1), xs))
#figure(
  grid(
    align: left,
    columns: (33%, 33%, 33%),
    lesser-packing(((6, 7, 6, 6, 7, 7), (6, 7, 6, 6, 7, 6), (7,))), lesser-packing(((6, 7, 6, 6, 7, 6), (7, 6, 7, 6, 7, 6), (7,))), lesser-packing(((6, 6, 7, 7, 7, 6), (6, 6, 6, 6, 7, 7), (7,))),
    lesser-packing(((7, 6, 7, 7, 7, 6), (6, 7, 7, 6, 6, 6), (6,))), lesser-packing(((7, 6, 6, 7, 6, 6), (7, 6, 7, 7, 6, 6), (7,))), lesser-packing(((7, 6, 7, 7, 6, 7), (7, 6, 6, 7, 6, 6), (6,))),
    lesser-packing(((6, 6, 6, 7, 6, 6), (7, 7, 6, 7, 6, 7), (7,))), lesser-packing(((6, 7, 6, 6, 7, 6), (7, 7, 7, 7, 6, 6), (6,))), lesser-packing(((7, 6, 7, 6, 7, 6), (7, 7, 6, 6, 6, 6), (7,))),
  ),
  caption: [Nine different packings produced by randomised Best-Fit.],
)

#lemma[
  An optimal packing can not have a bin containing both an item of weight $m$ and an item of weight $m+1$
]
#proof[
  Every optimal packing must fill both bins exactly to their full capacity $c$. Assume, for contradiction, a bin contains $0<i<m$ items of weight $m$ and $0<j<m$ items of weight $m+1$:
  $
    (m+1) ⋅ m quad=quad
    c quad=quad
    i m + j(m+1)
  $
  Rearranged:
  $
    (m+1-i)⋅m = j⋅(m+1)
  $
  Because $m$ and $m+1$ are coprime, their least common multiple is $m(m+1)$, so $j$ must be either $0$ or $m$, contradicting $0<j<m$.
]

Hence, if any bin contains both an item $m$ and an item $m + 1$,
the packing must use at least $3$ bins. Because the instance is
shuffled, Best-Fit will put both an item of size $m$ and an item of size
$m + 1$ into the same bin with high probability:

#lemma[
  Randomised Best-Fit returns an optimal packing with probability $≤2/(m+2)$.
]
#proof[
  - If the first item has weight $m$, then for Best-Fit to find the optimal solution, the next $m-1$ items must have weight $m$, as well. The probability of this happening is:
    $
      m/(2m) ⋅ (m-1)/(2m-1) ⋅ … ⋅ 2/(m+2)
      quad ≤ quad
      2 / (m+2).
    $
  - If the first item has weight $m+1$, then the next $m-1$ items must have weight $m$, as well. The probability of this happening is:
    $
      (m-1)/(2m) ⋅ (m-2)/(2m-1) ⋅ … ⋅ ⋅ 1/(m+1)
      quad ≤ quad
      2/(m+2).
    $
]

With more effort, one could find better bounds on the probability, but that simply will not be necessary, as we already obtain a sufficient lower-bound on the absolute random-order-ratio:
$
  "RR"_BestFit
  quad=quad sup_(I' ∈ ℐ) 𝔼_(π∈S_(|I'|))[BestFit(π(I'))/Opt(I')]
  quad≥quad 1/2 ⋅ [2 ⋅ 2/(m+2) + 3⋅m/(m+2)]
  quad=quad 3/2 - 1/(m+2).
$
For $m→∞$, this shows $"RR"_BestFit ≥ 1.5$ which, combined with the upper bound of $"RR"_BestFit ≤ 1.5$ by @bestFitKenyon[p:], proves:

#theorem[
  The absolute random-order-ratio of Best-Fit $"RR"_BestFit$ is exactly $1.5$.
]

== Knapsack Problem

== $k$-median Clustering
Fix the dimension $d gt.eq 4$. Put
$c colon.eq frac(sqrt(4 d^2 + (3 - d)^2) + d - 3, 2)$, which is one of
the two roots of $0 = c^2 - c (d - 3) - d^2$. Because $d gt.eq 4$, we
know that $5 d^2 - 6 d gt.eq 4 d^2$, hence:
$ c = frac(sqrt(4 d^2 + (d - 3)^2) + d - 3, 2) > frac(2 d + d - 3, 2) > d . $
Let $e_i$ be the $i$th $d$-dimensional standard basis vector. Consider
the following weighted instance of $d + 2$ points:
$ (1, …, 1), quad (0, …, 0), quad - c e_1, med …, med - c e_d, $
where the point $(1, …, 1)$ has weight $oo$ and all other
points have weight $1$.

#{
  let c = 2.57
  let points = ((1, -1), (0, 0), (-c, 0), (0, c)).map(x => ((x.at(0) + c + 0.1) / (3.66 * 1.1), (x.at(1) + 1.3) / (3.66 * 1.1)))

  let hierarchy = parse-hierarchical("
  #.##............................
---
###.............................
...#............................
---
...#............................
##..............................
..#.............................
---
#...............................
...#............................
..#.............................
.#..............................
")
  let optimal = parse-hierarchical("
#.##............................
---
.###............................
#...............................
---
...#............................
##..............................
..#.............................
---
#...............................
...#............................
..#.............................
.#..............................
")
  context {
    let massdict = (v: 0.22 * page.width, h: 0em)
    massdict.insert(str(points.at(0).at(0)) + "," + str(points.at(0).at(1)), 2.0)
    figure(
      draw-clustering.draw-hierarchical-clustering(points, hierarchy, page.width * 0.35, true, ..massdict) + h(1em) + draw-clustering.draw-hierarchical-clustering(points, optimal, page.width * 0.35, false, ..massdict),
      caption: [We only defined instances for $d≥4$, but this is a depiction of the same instance for\ $d=2$ and $c=2.57$. The large point in the upper right has weight $∞$, the others have weight $1$.\
        Left: An optimal hierarchical clustering, having approximation-factor $≈1.278$.\
        Right: Optimal clusterings for each $k$.
      ],
    )
  }
}

#lemma[
  For $k$-median clustering, this instance's
  price of hierarchy is at least $c / d$.
]
#proof[
  For contradiction, assume there exists a hierarchical
  clustering $H = (H_1, …, H_(d + 2))$ such that, on every level,
  the cost of $H_k$ is strictly less than $c / d$ times the cost of the
  best clustering using $k$ clusters. This enables us to narrow down the
  structure of $H$:

  - For $k = d + 1$, there is one cluster $C$ containing two points, while
    all other clusters contain only a single point. Depending on which two
    points constitute $C$, we can calculate the total cost of the
    clustering:

    - If $C = { (0, …, 0), (1, …, 1) }$, the total
      cost is:
      $ norm((0, …, 0) - (1, …, 1))_1 = d . $

    - If $C = { (0, …, 0), - c e_i }$ for some $i$, the total
      cost is $c$.

    - If $C = { (1, …, 1), - c e_i }$ for some $i$, the total
      cost is $d + c$.

    - If $C = { - c e_i, - c e_j }$ for some $i ≠ j$, the total
      cost is $2 c$.

    Because $d < c$, this constrains $H_k$ to
    $C = { (0, …, 0), (1, …, 1) }$, otherwise the
    total cost of $H_k$ would be at least $c / d$ times the cost of an
    optimal $(d + 1)$-clustering.

  - For $k = 2$: The clustering now contains exactly two clusters. Because
    $H$ is a hierarchical clustering, we now know that $H_2$ has a cluster
    that contains $(0, …, 0)$, $(1, …, 1)$ and some
    number $0 ≤ n ≤ d - 1$ of the $- c e_i$, while its other
    cluster contains the remaining $d - 1 - n$ of the $- c e_i$. Due to
    symmetry, this number $n$ is sufficient for calculating the total cost
    of $H_2$. Because $(1, …, 1)$ has infinite weight, this point
    must be the center of the first cluster, so this cluster has cost:
    $ norm((1, …, 1) - (0, …, 0)) + n ⋅ norm((1, …, 1) - (- c e_1))_1 = d + n ⋅ (c + d) $
    The cluster containing the remaining $d - 1 - n$ of the $- c e_i$ can
    choose any point as its center. It has cost:
    $ (d - 2 - n) ⋅ norm(c e_1 - c e_2)_1 = (d - 2 - n) ⋅ 2 c $
    Given $n$, the total cost of $H_2$ is $d + c (2 d - 4) + n (d - c)$.
    Because $d - c < 0$, the best choice for $n$ would be $n = d - 1$,
    resulting in a cost of $c (d - 3) + d^2$. This is only a lower bound
    on the cost of $H_2$, because other levels in the hierarchy might put
    additional constraints on $H_2$.

    For an _upper_ bound on the _optimal_ cost of a
    $2$-clustering, consider the clustering that has $(1, …, 1)$
    in its first cluster, and all other points in its second cluster. By
    assuming the center of the second cluster is $(0, …, 0)$, we
    get an upper bound on the total cost of this clustering of:
    $ d ⋅ norm((0, …, 0) - (- c e_1))_1 = d ⋅ c . $
    Hence, the ratio between the cost of $H_2$ and the cost of an optimal
    $2$-clustering is at least:
    $ (c (d - 3) + d^2)/(d ⋅ c) = (d - 3)/d + d / c $ We
    defined $c$ as one of the roots of $0 = c^2 - c (d - 3) - d^2$.
    Dividing out $c d$, we get $(d - 3)/d + d / c = c / d$. However,
    this contradicts the assumption that the ratio between $H_2$ and an
    optimal $2$-clustering is strictly less than $c / d$.

  Thus, the instance's price of hierarchy is at least $c / d$.
]
For large $d$, this fraction
$c / d = (sqrt(4 d^2 + (3 - d)^2) + d - 3)/(2 d)$ converges to
$(1+ sqrt(5))/2$, the golden ratio.


== Gasoline


#bibliography("bibliography.bib", style: "chicago-author-date")
