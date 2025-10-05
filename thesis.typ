#import "preamble.typ": *; #show: preamble
#import "draw-packing.typ";
#import "draw-clustering.typ";
#import "@preview/subpar:0.2.2"
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/lovelace:0.3.0": *;
#let pseudocode-list = pseudocode-list.with(booktabs: true, hooks: 0.5em)

#import "@preview/ctheorems:1.1.3": *; #show: thmrules.with(qed-symbol: $square$)
#let theorem = thmbox("theorem", "Theorem", breakable: true)
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
  This example (one element of the) lower-bound construction by @binPackingRevisited[p:] showing $1.3 ≤ "RR"_BestFit$ by.
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

    caption: [All $2^6$ possible solutions to @knapsack-example. Solutions exceeding capacity $c=20$ are marked in purple. The optimum is circled in blue. Pareto-optimal solutions are marked by $#sym.star.filled$.],
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
  - For every $i=1,…,n-1$, the clustering $H_i$ can be obtained by merging two clusters in $H_(i+1)$. In other words, there exist clusters $C,C′∈H_(i+1)$ such that:
    $
      H_i quad = quad (H_(i+1) ∖ {C, C′}) ∪ {C∪C′}.
    $
]

The structure of hierarchical clusterings is, for example, useful for taxonomy, but does come at a cost: Usually, the optimal $k$-clusterings need not have a nested structure, so there might not exist a hierarchical clustering $(H_1, …, H_n)$ such that every $H_i$ is an optimal $i$-clustering. The set of points in @example-hierarchical-clustering is such an example.

#{
  let points = ((0.94, 0.68), (0.99, 0.12), (0.17, 1), (0.99, 0.04), (0.14, 0.92), (0.7, 0.87)).map(v => ((v.at(0) + 0.1) * 0.8, (v.at(1) + 0.1) * 0.8))
  let parse-hierarchical = text => text.split("---").map(section => parse(section))
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
    [together with the following permutation of deliveries:
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

Variants of @algorithm-local-search-bin-packing include decreasing the mutation-rate over time, e.g. by decreasing the variance of the noise on $Mutation$, or stochastically allowing replacing $I$ with $I′$, even if $I′$ has a worse score, to prevent getting stuck in local optima. See @local-search-plot for trajectories drawn from @algorithm-local-search-bin-packing.

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

Instead, to motivate our next steps, we will try learning from the instance, perhaps spotting structures in it, hoping to use these to manually construct instances of even higher scores. Alas, @local-search-instance gives us little hope: Unlike e.g. the instance in @example-bin-packing-sota, the instance found by @algorithm-local-search-bin-packing does not seem to have a discernible pattern or noticeable symmetries. The four zero-weight items are a product of negative items in the mutation $I′$ being rounded up to $0$, and contribute nothing to the instance.

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

For example, this is the instance of @example-bin-packing-sota as hardcoded python-code:
#align(center)[
  ```py
  items = [1004, 1004, 1016, 1016, 992]
  ```
]
But we can also write this in a way that exposes structure and symmetries:
#align(center)[
  ```py
  x = 4
  items = [1000+x]*2 + [1000+4*x]*2 + [1000-2*x]
  ```
]
(In Python, lists are concatenated via "`+`", for instance `[1,2]+[4,5] == [1,2,4,5]`).

#bibliography("bibliography.bib", style: "chicago-author-date")
