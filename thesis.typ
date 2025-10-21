#import "preamble.typ": *; #show: preamble
#import "visualisations/draw-packing.typ"; #import "visualisations/draw-knapsack.typ"; #import "visualisations/draw-clustering.typ"; #import "visualisations/draw-gasoline.typ"
#import "@preview/subpar:0.2.2"
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/lovelace:0.3.0": *;
#import "@preview/zero:0.5.0": format-table
#let pseudocode-list = pseudocode-list.with(booktabs: true, hooks: 0.5em)
#let TODO = body => text(size: 0.5em, fill: green)[\[TODO: #body\]]


#import "@preview/ctheorems:1.1.3": *; #show: thmrules.with(qed-symbol: $square$)
#let lemma = thmbox("lemma", "Lemma", fill: black.lighten(95%), breakable: true)
#let theorem = thmbox("theorem", "Theorem", fill: cyan.lighten(50%), breakable: true)
#let definition = thmbox("definition", "Definition", fill: red.lighten(90%), breakable: true)
#let example = thmbox("example", "Example", fill: green.lighten(90%), breakable: true)
#let proof = thmproof("proof", "Proof", breakable: true, outset: (left: -0.5em), radius: 0em, stroke: (left: 0.1em + gray))

// #set figure(gap: 1em)
#show figure.caption: emph

#show link: old-link => {
  if old-link.body.has("text") and old-link.body.text == old-link.dest and old-link.dest.starts-with("https://") {
    link(old-link.dest)[#old-link.dest.slice("https://".len())]
  } else {
    old-link
  }
}


#set heading(numbering: "1.1")

#let Weight = math.op("Weight")
#let Profit = math.op("Profit")
#let Cost = math.op("Cost")
#let Opt = math.op("Opt")
#let PoH = math.op("PoH")
#let BestFit = math.op("BestFit")
#let FirstFit = math.op("FirstFit")
#let NextFit = math.op("NextFit")
#let Apx = math.op("Apx")
#let Score = math.op("Score")
#let Mutation = math.op("Mutation")
#let Opt = math.op("Opt")
#let Avg = math.op("Avg")
#let IterRound = math.op("IterRound")

= Problems, Definitions and Previous Results <section-problems-definitions>
#figure(caption: [Comparison across different problems of: Previous state of the art, local search (see @sec-local-search), FunSearch without hand-tuning (@sec-funsearch-introduction), FunSearch with hand-tuning (@sec-funsearch-tuning-introduction), and the best-known upper bounds.])[
  #show: format-table(none, auto, auto, auto, auto)
  #table(
    columns: 5,
    stroke: none,
    align: (left, auto, auto, auto, auto),
    table.header([], [Best-Fit], [Knapsack], [$k$-median], [Gasoline]),
    table.hline(),
    [Previous Best Lower Bound], [1.3], [2.0], [1.0], [2.0],
    table.hline(stroke: gray + 0.05em),
    [Local Search], [1.478], [1.93], [1.36], [2.11],
    [FunSearch without Hand-Tuning], [1.497], [646.93], [1.538], [3.05],
    [FunSearch with Hand-Tuning], [1.5], [$n^(O (sqrt(n)))$], [1.618], [4.65],
    table.hline(stroke: gray + 0.05em),
    [Known Upper Bound], [1.5], [$O (2^n)$], [16.0], [None],
  )
]
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

These heuristics will usually not output an optimal solution, i.e. a packing that uses the fewest number of bins (see @bin-packing-example). The following definitions allow us to compare the performance of different heuristics:

#definition[
  Let $ℐ$ be the set of all (nonempty) bin-packing instances. For some instance $I∈ℐ$, let $Opt(I)$ be the number of bins in an optimal packing, and $𝒜(I)$ be the number of bins in the packing found by a bin-packing algorithm $𝒜$. The *(absolute) approximation-ratio of $𝒜$* is
  $
    R_𝒜 quad≔quad sup_(I∈ℐ) 𝒜(I)/Opt(I).
  $
]
The approximation-ratio of an algorithm captures the worst-case performance of an algorithm. For instance, the $R_BestFit = 1.7$ (proven by @bestFitAbsoluteRatio[p:]), meaning that:
- For every instance, the packing found by Best-Fit will never use more than $1.7$ times more bins than an optimal packing, and
- There is a sequence of instances $I_1, I_2, …$ such that $BestFit(I_j)/Opt(I_j)$ converges to $1.7$.

@firstFitAnalysis[p:] proved that $R_FirstFit = 1.7$ as well, and @nextFitAnalysis[p:] showed $R_NextFit = 2$.

Comparing algorithms by their absolute approximation-ratios can be a bit pessimistic: In practice, if we are in a position where we must use an online-algorithm, it might not be the case that an adversary can choose _the entire input_ $I$ including the order of its items. Consider a less pessimistic measure for the performance of an algorithm:

#definition[
  Let $S_n$ be the set of permutations on $n$ elements, i.e. the symmetric group. The *absolute random-order-ratio of $𝒜$* is
  $
    "RR"_𝒜 quad≔quad sup_(I∈ℐ) 𝔼_(π∈S_(|I|))[𝒜(π(I))/Opt(I)].
  $
]

That is to say: We still assume an adversary can choose the _items_ of the instance, but their order is randomized before being passed on to algorithm $𝒜$. Note that $Opt(I)$ does not depend on the order of the items.
@bestFitKenyon[p:] showed that $1.08 ≤ "RR"_BestFit ≤ 1.5$, with the lower bound improved to $1.3$ by @binPackingRevisited[p:].

#example[
  This example is (one element of the) lower-bound construction by @binPackingRevisited[p:] showing $1.3 ≤ "RR"_BestFit$.
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
      //align: left,
      columns: (33%, 33%, 33%),
      lesser-packing(((1016, 1004), (992, 1004), (1016,))), lesser-packing(((1004, 992, 1004), (1016, 1016))), lesser-packing(((1016, 992), (1004, 1004), (1016,))),
      lesser-packing(((1004, 1004, 992), (1016, 1016))), lesser-packing(((1016, 1004), (1004, 1016), (992,))), lesser-packing(((992, 1016), (1004, 1004), (1016,))),
      lesser-packing(((1016, 1004), (1004, 1016), (992,))), lesser-packing(((1004, 1004, 992), (1016, 1016))), lesser-packing(((992, 1016), (1004, 1016), (1004,))),
      //lesser-packing(((1016, 1016), (992, 1004, 1004))),
    ),
    caption: [Nine different packings produced by Best-Fit on $I$ with randomised order.],
  )
] <example-bin-packing-sota>

Using FunSearch, we find a sequence of instances $I_1, I_2, …$ for which $𝔼_(π∈S_(|I_j|))[𝒜(π(I_j))/Opt(I_j)]$ converges to $1.5$, showing $"RR"_BestFit ≥ 1.5$ and matching the upper bound.

== Knapsack Problem
In the traditional Knapsack-Problem, we are given a capacity $c$ and a list $I$ of $n$ items, each having both a non-negative weight $w_i≤c$ and a non-negative profit $p_i$. Instead of minimising the number of bins we use, we are only allowed to use a single bin of capacity $c$ and the total weight of the items we put in this bin must not exceed $c$. Our objective instead is to _maximize_ the total profit of the items we put in the bin.

#example[
  We denote items by a column-vector $vec("Weight", "Profit")$. We are given a capacity $c=20$ and the following items:
  $
    I = [vec(4, 9),quad vec(5, 1),quad vec(13, 14),quad vec(3, 8),quad vec(11, 4),quad vec(6, 14)]
  $
  The optimal list of items to put into our bin is $[vec(4, 9), vec(5, 1), vec(3, 8), vec(6, 14)]$, with a total weight of $18$ and a total profit of $32$.
  #figure(
    {
      let items = ((4, 9), (5, 1), (13, 14), (3, 8), (11, 4), (6, 14))
      let powerset = draw-knapsack.powerset(items)
      let dominated = powerset.filter(wp => powerset.any(x => draw-knapsack.dominates(x, wp)))
      let undominated = powerset.filter(wp => powerset.all(x => not draw-knapsack.dominates(x, wp)))

      let opt-xs = 4 + 5 + 3 + 6
      let opt-ys = 9 + 1 + 8 + 14

      let dominated-feasible = dominated.filter(wp => wp.at(0) <= 20)
      let dominated-unfeasible = dominated.filter(wp => wp.at(0) > 20)
      let undominated-feasible = undominated.filter(wp => wp.at(0) <= 20)
      let undominated-unfeasible = undominated.filter(wp => wp.at(0) > 20)

      lq.diagram(
        lq.scatter(
          ..draw-knapsack.xsys(dominated-feasible),
          color: green,
          mark: lq.marks.at("."),
        ),
        lq.scatter(
          ..draw-knapsack.xsys(dominated-unfeasible),
          color: purple,
          mark: lq.marks.at("."),
        ),
        lq.scatter(
          ..draw-knapsack.xsys(undominated-feasible),
          color: green,
          mark: lq.marks.star,
        ),
        lq.scatter(
          ..draw-knapsack.xsys(undominated-unfeasible),
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

    caption: [All $2^6$ possible solutions to @knapsack-example. Solutions exceeding capacity $c=20$ are marked in #Purple[purple]. The optimum is circled in #Blue[blue].\ Pareto-optimal solutions are marked by $#sym.star.filled$.],
  ) <fig-example-knapsack>
] <knapsack-example>

A *solution* is any sub-list of the list of items $I$, regardless of whether it exceeds the capacity $c$. For some solution $A$, we denote by $Weight(A)$ its total weight (i.e. the sum of the weights of the items in $A$), and by $Profit(A)$ its total profit. We can visualize the space of _all_ possible solutions -- including those that exceed the maximum weight capacity -- by plotting the tuple $(Weight(A), Profit(A))$.

=== Pareto-Sets

In practice, one might not know the capacity beforehand, or might have unlimited capacity but some tradeoff-function between weights and profits, for example $u(w, p) = p - w^2$. To cover all these cases simultaneously, we can narrow down the space by eliminating all solutions that can never be optimal. The set of those solutions is the _Pareto-set_ @RoeglinBookChapter:
#definition[
  For solutions $A$ and $B$, we say $A$ *dominates* $B$ if and only if:
  $
    Weight(A) ≤ Weight(B)
    quad "and" quad
    Profit(A) ≥ Profit(B),
  $
  and at least one of those inequalities is strict. The *Pareto-set* $P(I)$ is the set of all solutions that are not dominated by any other solution.

  #TODO[Not really a set. Maybe do use index-vectors.]
]
See @fig-example-knapsack for an exmaple. There, the Pareto-set has size $15$, which is much smaller than the size of the entire solution-space, $2^6 = 64$. In fact, the Pareto-set is usually small in practice @moitraSmoothed @RoeglinBookChapter, hence one approach to finding an optimal solution is to compute the Pareto-Set $P(I)$ and finding a solution in $P(I)$ that maximizes the objective. If $P(I)$ has already been computed, a simple linear search yields an optimal solution in time $O(|P(I)|)$.

Let $n≔|I|$. The standard algorithm for computing $P(I)$ is the _Nemhauser-Ullmann algorithm_ @NU69 @RoeglinBookChapter, which incrementally computes the Pareto-sets $P_i ≔ P(I_(1:i))$ for $i=1,…,n$, where "$I_(1:i)$" denotes the instance containing the first $i$ items of $I$. It works as follows:
#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  pseudocode-list(numbered-title: "Nemhauser-Ullmann Algorithm for Pareto-Sets")[
    + Set $P_0 = {∅}$.
    + For $i=1,…,|I|$:
      + Let $x$ be the $i$-th item of $I$.
      + Set $Q_i ≔ P_(i-1) ∪ {A∪{x} mid(|) A ∈ P_(i-1)}$
      + Compute $P_i ≔ {A ∈ Q_i mid(|) A "is not dominated by any" B∈Q_i}$
  ],
)<alg-nemhauser-ullmann>

This algorithm works correctly because $P_i$ is always a subset of $Q_i$. With some work, @alg-nemhauser-ullmann can be implemented to run in time $O(|P_1| + … + |P_n|)$ @RoeglinBookChapter. Intuitively, one might think that $P_(i-1)$ is always smaller than $P_i$, but this need not be the case:

#example[
  Consider the items:
  $
    I ≔ [vec(4, 4),quad vec(4, 4),quad vec(2, 1),quad vec(1, 2),quad vec(2, 2)].
  $
  Here, $P_4$ has size $12$, while $P_5 = P(I)$ has size $10$.
  #let items = ((4, 4), (4, 4), (2, 1), (1, 2), (2, 2))
  #let diagrams = draw-knapsack.draw(items, items.len() - 1, blue, green)
  #let diagram-args = (xaxis: (lim: (auto, 14)), yaxis: (lim: (auto, 14)), width: 180pt)
  #figure(
    (
      h(1fr)
        + lq.diagram(
          ..diagrams.at(0),
          ..diagram-args,
        )
        + h(3fr)
        + lq.diagram(
          ..diagrams.at(1),
          ..diagram-args,
        )
        + h(1fr)
    ),
    caption: [The solution-space for $I_(1:4)$ (left) and $I_(1:5)=I$ (right) respectively, plotting $(Weight(A), Profit(A))$ for every solution $A$, with Pareto-optimal solutions marked by a star. The number of visible points is smaller than $2^4$ (respectively $2^5$), and the number of visible pareto-optimal solutions is smaller than $12$ (respectively $10$), because some pairs of different solutions share the same total weight and total profit. If treating Pareto-optimal solutions with the same weight and profit as identical, $I_(1:4)$ has $9$, whereas $I$ only has $8$.],
  )
]<example-shrinking-pareto-set>
Let $n ≔ |I|$ again. It had been unknown whether $|P_i|$ can be bounded by some $O(|P_n|)$, i.e. it had been unknown whether
$
  Score(I)
  quad ≔ quad
  (max_(1≤i≤n) |P(I_(1:i))|) / (|P_n|)
$
can always be bounded by some constant not depending on $I$. If it could be bounded, @alg-nemhauser-ullmann would have a runtime bounded by $O(n⋅|P(I)|)$.

For the specific $I$ in @example-shrinking-pareto-set, $Score(I) = 12/10 = 1.2$. Note that, for any instance, $Score(I) ≤ 2^n$, because every $|P_i|$ is at most $2^n$.

So far, the instances with the highest score only achieved around $Score(I) ≈ 2$. Using FunSearch, we were able to find a sequence of instances $I_1,I_2,…$ with $Score(I_j) ≥ n^(O(√n))$, or more precisely $Score(I_j) ≥ O((n\/2)^((sqrt(n\/2)-3)\/2))$. This disproves that @alg-nemhauser-ullmann runs in output-polynomial time.

#TODO[Insert link to proof-section]


== $k$-median Clustering
In the clustering-problem, we are given $n$ unlabeled data points $p_1,…,p_n ∈ ℝ^d$ and a number $k$. Our task is to find a *$k$-clustering*: A partition of the $n$ points into $k$ different clusters $C_1,…,C_k$, such that "close" points belong to the same cluster. There exist different objectives to quantify "closeness" @priceOfHierarchicalClustering:
- In $k$-median clustering, the $L_1$-norm is used instead, and the distance not measured from the centroid $mu$ but instead the best possible choice among the points in $C$:
  $
    Cost(C)
    = min_(mu in C) sum_(x in C) norm(x - mu)_1
  $
  The total cost of a clustering $C_1,…,C_k$ is the sum of its costs: $Cost(C_1) + … + Cost(C_k)$.
- In $k$-means clustering, the cost of a cluster $C$ is: #h(1fr)
  $
    Cost(C) =
    ∑_(x∈C) ‖x-μ(C)‖_2^2,
    quad
    "where" μ(C) ≔ 1/(|C|) ⋅ ∑_(x∈C) x.
  $
  The total cost of a clustering is again the sum of the cost of its clusters.
- In $k$-center clustering, the cost of the cluster $C$ is the _radius_ of that cluster:
  $
    Cost(C) = min_(μ ∈ ℝ^d) (max_(x∈C) ‖x-μ‖_2)
  $
  The cost of a clustering is the _maximum_ of the costs of its clusters.
- In $k$-diameter clustering, the cost of the cluster $C$ is the _diameter_ of that cluster:
  $
    Cost(C) = max_(x,y ∈ C) ‖x-y‖_2
  $
  The cost of a clustering is again the _maximum_ of the costs of its clusters.

Naturally, different objectives can yield different optimal clusterings, as seen in @clustering-example.

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
  let points = ((0.48, 0.0), (0.112, 0.715), (0.283, 0.452), (0.569, 0.526), (0.366, 0.577), (0.068, 0.379), (0.64, 0.472), (0.692, 0.227), (0.165, 0.953), (0.219, 0.807), (0.246, 0.299), (0.508, 0.295), (0.61, 0.837), (1.0, 0.312), (0.948, 0.18), (0.622, 0.777), (0.179, 0.786), (0.94, 0.419), (0.125, 0.982), (0.684, 0.662))
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
  let kmedian-agglomerative = parse("
#..#.......####..#..
.#......##........#.
....##....#.........
")
  let kmeans-agglomerative = parse("
#...##.#....#..#...#
.#......##........#.
.............##..#..
")

  [#subpar.grid(
      columns: (1fr, 1fr),
      context figure(draw-clustering.draw-clustering(points, kmedian-agglomerative, page.width * 0.3, 0.02, green), caption: [A sub-optimal $k$-median clustering/* (objective $5.104$)*/, obtained via agglomerative clustering.]), context figure(draw-clustering.draw-clustering(points, kmeans-agglomerative, page.width * 0.3, 0.02, cyan), caption: [A sub-optimal $k$-means clustering/* (objective $5.083$)*/, obtained via agglomerative clustering.]),
      context figure(draw-clustering.draw-clustering(points, kmedian, page.width * 0.3, 0.02, red), caption: [An optimal $k$-median clustering/* (objective $4.467$)*/.]), context figure(draw-clustering.draw-clustering(points, kmeans, page.width * 0.3, 0.02, blue), caption: [An optimal $k$-means clustering/* (objective $4.555$)*/.]),
      gap: 1em,
      caption: [Four different $k"="3$-clusterings for the same $20$ points in $ℝ^2$.],
      label: <clustering-example>,
    )
  ]
}

When trying to cluster unlabeled data, we usually are not given a number $k$ of clusters to use. In such a scenario, we could use heuristics to determine a good choice of $k$ (see e.g. @stopUsingElbow[p:]). Alternatively, we could compute a _Hierarchical Clustering_, which is a sequence of nested $k$-clusterings for every choice of $k$ @priceOfHierarchicalClustering:

#definition[
  A *hierarchical clustering* on $n$ points is a sequence $(H_1, …, H_n)$ of clusterings such that:
  - $H_i$ is an $i$-clustering (i.e., it consists of $i$ clusters), for every $i=1,…,n$, and
  - For every $i=1,…,n-1$, the clustering $H_i$ can be obtained by merging two clusters in $H_(i+1)$. In other words, there exist clusters $C,C'∈H_(i+1)$ such that:
    $
      H_i quad = quad (H_(i+1) ∖ {C, C'}) ∪ {C∪C'}.
    $
]

This nested structure of hierarchical clusterings is useful for, for example, taxonomy. In practice, finding _some_ hierarchical clustering can be done via *agglomerative clustering*, a greedy method where we start with $H_n$ as having each point in a singleton cluster, and construct $H_(i-1)$ from $H_i$ by choosing to merge a pair of clusters that increases the objective the least.

The additional structure of hierarchical clustering does come at a cost, however: Usually, the optimal $k$-clusterings need not have a nested structure, so a hierarchical clustering $(H_1, …, H_n)$ such that every $H_i$ is an optimal $i$-clustering *need not exist*. The set of points in @example-hierarchical-clustering is such an example.

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
    #figure(draw-clustering.draw-hierarchical-clustering(points, opt-hierarchical, page.width * 0.4, true) + h(1fr) + draw-clustering.draw-hierarchical-clustering(points, opt-optimal, page.width * 0.4, false), caption: [Left: An optimal hierarchical clustering on $6$ points for the $k$-median objective.\ Right: For each $k=1,...,6$, an optimal $k$-median clustering on the same $6$ points.\ There is no set of optimal clusterings with a nested structure.\
      The shown hierarchical and optimal clusterings only differ at level $k=2$.
    ])<example-hierarchical-clustering>
  ]
}

To measure the quality of a hierarchical clustering $(H_1, …, H_n)$, we could simply sum the the costs of each level: $Cost(H_1) + … + Cost(H_n)$. However, $k$-clusterings for small $k$ usually have significantly higher cost than $k$-clusterings for large $k$, so this would lose information about the quality of the $H_i$ for small $i$. To avoid this, we can instead compare each level $H_i$ of the hierarchy to an _optimal_ $i$-clustering, and taking the maximum across all levels @priceOfHierarchicalClustering:

#definition[
  For a clustering-instance $I$ and a cost-function $Cost$, the *approximation-factor of a hierarchical clustering* $(H_1, …, H_n)$ on $I$ is:
  $
    Apx_Cost (H_1, …, H_n)
    quad ≔quad
    max_(i=1,…,n)
    Cost(H_i) / Cost(Opt_i),
  $
  where $Opt_i$ is an optimal $i$-clustering on $I$ with respect to $Cost$.

  For a fixed cost-function $Cost$, we say that a hierarchical clustering on an instance $I$ is *optimal* if it has the lowest possible approximation-factor among all hierachical clusterings on $I$.
] <def-optimal-hierarchical-clustering>
The hierarchical clustering shown in @example-hierarchical-clustering is optimal, it was the output of a program written for finding optimal hierarchical clusterings. Any better hierarchical clustering would have to carry the restriction $H_2 = Opt_2$, but due to the requirement of nested clusterings, this means that (as visible in the figure), $H_3 ≠ Opt_3$.

The hierarchical clusterings and optimal clusterings in @example-hierarchical-clustering only differ for $k=2$, where $Cost(H_2) = 1.78$ and $Cost(Opt_i) = 1.41$, so the approximation-factor of that hierarchical-clustering is $1.78/1.41 ≈ 1.262$.

Although agglomerative clustering computes a hierarchical clustering whose approximation-factor is low in practice, this hierarchical clustering need not be optimal. In this work, we only concern ourselves with optimal hierarchical clusterings.

For a cost-function $Cost$, we can ask what we sacrifice by imposing a hierarchical structure, not just for some fixed instance $I$, but for _all_ instances $I$. This is the Price of Hierarchy @priceOfHierarchicalClustering:

#definition[
  Let $ℐ$ be the set of all clustering-instances, and $Cost$ some cost-function. For a fixed clustering-instance $I$, let $cal(H)(I)$ be the (finite) set of all hierarchical clusterings on $I$.
  The *Price of Hierarchy for $Cost$* is defined as:
  $
    PoH_Cost
    quad ≔quad
    sup_(I∈ℐ) (min_(H ∈ cal(H)(I)) Apx_Cost (H)).
  $
]
In particular, the instance in @example-hierarchical-clustering proves that $PoH_(k"-median") ≥ 1.26$, because the hierarchical clustering there is optimal for this instance.

For the above cost-functions, the following bounds on the Price of Hierarchy were previously known:
- $PoH_(k"-median") ≤ 16$ @dai2014
- $PoH_(k"-means") ≤ 32$ @upperBoundKMeans
- $PoH_(k"-center") = 4$ @priceOfHierarchicalClustering
- $PoH_(k"-diameter") = 3+2√2$ @priceOfHierarchicalClustering

Using FunSearch, we construct a sequence of instances that shows the first non-trivial lower-bound on the Price of Hierarchy for $k$-median of $PoH_(k"-median") ≥ (1+√5)/2 ≈ 1.618$.

== Generalised Gasoline-Problem

As a motivating example for the problem (similar to @Lorieau[p:]), we are in charge of a factory that produces cookies every day of the week. In doing so, it consumes exactly two ingredients: Flour and sugar. Each day of the week, both the amount of cookies and their sugar-content must follow a certain schedule. For instance, on Monday, we might be asked to use $vec("Flour", "Sugar")$-amounts equal to $y_1 = vec(3, 1)$ for our cookie-production, whereas each Tuesday, we must consume more and sweeter cookies, hence having to use $y_2 = vec(5, 5)$ amounts of flour and sugar. We can get flour and sugar delivered to our factory overnight, but we must pick these amounts from a list of seven possible delivery-trucks that are the same every week, but we can choose on which day of the week we would like to receive each truck. For instance, we can choose to have $x_1 = vec(4, 4)$ flour and sugar delivered to our factory on some day, or $x_2 = vec(7, 10)$. Within a week, we can only order each of the seven delivery-trucks exactly once, and we can only accept one delivery-truck per night because our driveway is too narrow. It's unlikely that we will be fortunate enough to have, for every demand-vector $y_i$, a matching delivery-vector $x_i$ (in which case we would just order exactly the ingredients that we'd need on the next day), so we must resort to storing leftover ingredients overnight in our yet-to-be-built warehouse.

Corporate has been kind enough to ensure that $y_1 + … + y_7 = x_1 + … + x_7$, meaning that, at the end of every week, we will have exactly the same amount of ingredients in our warehouse as at the beginning of the week. However, storing ingredients takes costly space, so we would like to minimise the total amount of warehouse we need to build, while the only free variable under our control is the permutation of the delivery-trucks across the week. Let $S_n$ be the set of permutations on $n$ elements. Mathematically, our task is:
$
  min_(π in S_7) & quad ‖α-β‖_1 \
   "where"quad α & =min_(1≤k≤7)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^k y_i)quad #box(width: 14em, baseline: 50%)["In the evening, we must have at least $α$ ingredients left over."] \
               β & =max_(1≤k≤7)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^(k-1) y_i)quad #box(width: 14em, baseline: 50%)["After the delivery overight, we must store at most $β$ ingredients"]
$
where the minimum across vectors is taken entry-wise. As an objective, we choose $‖α-β‖_1$, meaning we trade off the cost for space in the flour-warehouse linearly against the cost of space in the sugar-warehouse. We do not lose generality on the tradeoff-ratio between the two, since tradeoffs like "Sugar-warehouse space is twice as expensive as flour-warehouse space" can be captured by choosing different units for measuring amounts of flour and sugar. Non-linear tradeoffs are not captured, however. We write $X = (x_1,…,x_7)$ and $Y = (y_1,…,y_7)$.

#example[
  #let deliveries = ((5, 3), (3, 10), (7, 8), (1, 2), (8, 9), (7, 4), (1, 1))
  #let production = ((3, 4), (2, 8), (8, 1), (1, 5), (9, 4), (2, 10), (7, 5))
  #let iterative-rounding-permutation = (0, 1, 2, 6, 5, 3, 4)
  #let opt-permutation = (6, 2, 0, 3, 4, 5, 1)
  Consider:
  $
    X = & [vec(5, 3), vec(3, 10), vec(7, 8), vec(1, 2), vec(8, 9), vec(7, 4), vec(1, 1)],
          quad
          Y = & [vec(3, 4), vec(2, 8), vec(8, 1), vec(1, 5), vec(9, 4), vec(2, 10), vec(7, 5)],
  $
  ($x_1"+"…"+"x_7=y_1"+"…"+"y_7$, as warranted by corporate), together with the following permutation of deliveries:
  $
    π(X) ≔ #draw-gasoline.typeset-permutation(iterative-rounding-permutation, deliveries).
  $
  The timeline of our warehouse can be visualised as follows: We use colored bars to represent the current amount of flour (#Blue[blue]) and sugar (#Purple[purple]) in our warehouse. Vectors preceded by "$arrow.t$" indicate deliveries to our warehouse at night, vectors preceded by "$arrow.b$" indicate us consuming ingredients from the warehouse to bake cookies during the day. The two horizontal colored lines indicate the maximum number of the respective ingredient that the warehouse must store across the week. We choose the initial stocking of our warehouse _minimally_ such that we will always have enough ingredients to never run out (this choice is exactly $β$ from the above optimization problem). This ensures that our warehouse has the smallest possible size for this permutation, and that for both ingredients, there must be a day on which that ingredient's warehouse is fully depleted (otherwise our choice would not be minimal, we would have wasted space).
  #figure(
    draw-gasoline.draw-permutation(iterative-rounding-permutation, deliveries, production),
    kind: image,
    gap: 1.5em,
    caption: [The (cyclical) state of the warehouse across the week for permutation $π$.],
  )
  For this permutation, the warehouse must store a peak of $11$ flour on the night between Tuesday and Wednesday, and a peak of $13$ sugar on several nights between Tuesday and Thursday. There is a better permutation, though:
  $
    π_Opt (X) ≔ #draw-gasoline.typeset-permutation(opt-permutation, deliveries),
  $
  #figure(
    draw-gasoline.draw-permutation(opt-permutation, deliveries, production),
    kind: image,
    gap: 1.5em,
    caption: [The (cyclical) state of the warehouse across the week for permutation $π_Opt$.],
  )
  Here, the peak-capacity of the warehouse is only $10$ for both flour and sugar, so $π_Opt$ is a better choice than $π$ regardless of the tradeoff between the cost of flour-warehouse space and sugar-warehouse space.

  For a different visualisation, we can trace the state of the warehouse in phase-space:

  #figure(
    h(1fr) + draw-gasoline.trace-permutation(iterative-rounding-permutation, deliveries, production, green, (-1, 12), (-1, 15), true) + h(2fr) + draw-gasoline.trace-permutation(opt-permutation, deliveries, production, blue, (-1, 12), (-1, 15), true) + h(1fr),
    caption: [Tracing the states of the warehouses of $π$ (left) and $π_Opt$ (right) in phase-space, along with the smallest rectangles containing all points.],
  ) <example-cookies-phase-space>

  The width and height of the smallest rectangle encompassing all those points is exactly the maximum capacity that our flour-warehouse and sugar-warehouse require.

  With the $L_1$ cost-function used above, $π$ has a cost of $11+13=24$, whereas $π_Opt$ has a cost of $10+10=20$ and is indeed an optimal permutation for this instance.
]<example-gasoline-cookies>
Generally, an instance of the Gasoline-Problem (named so due to a puzzle by @Lovsz1979CombinatorialPA[p:] involving gas-stations along a circular race-track)
consists of two sequences of $d$-dimensional vectors containing non-negative integral entries:
$
  X = (x_1,…,x_n) ∈ ℤ_(≥0)^(n×d), quad
  Y = (y_1,…,y_n) ∈ ℤ_(≥0)^(n×d),
$
who have the same total sum $x_1"+"…"+"x_n = y_1"+"…"+"y_n$. In the above example, $d=2$ (the number of different ingredients) and $n=7$ (the length of a week). Our objective is to find a permutation $π ∈ S_n$ of the $X$-entries that minimises the prefix-sum discrepancy:
$
  min_(π in S_n) & quad ‖α-β‖_1 \
   "where"quad α & = min_(1≤k≤n)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^k y_i) ∈ ℤ^d \
               β & =max_(1≤k≤n)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^(k-1) y_i) ∈ℤ^d.
$
A different interpretation of the problem is: We are given two sequences $X$ and $Y$ of vectors, with the same total sum. We must find a permutation $π$ of $X$ such that, when we plot the polygonal-chain in $ℝ^d$ traced by the prefix-sums of $π(x_1)-y_1+π(x_2)-y_2 + … +π(x_n)-y_n$, the sum of the sidelengths of the box containing all those points is minimal (see @example-cookies-phase-space).

Even for $d=1$, this problem is NP-hard @Gasoline2018, so _approximation-algorithms_ have been studied instead:

#definition[
  Let $ℐ_d$ be the set of all $d$-dimensional instances of the gasoline-problem. For some instance $I∈ℐ_d$, let $Opt(I)$ be the value of an optimal solution, and $𝒜(I)$ be the value of the solution found by some algorithm $𝒜$. The *approximation-ratio of $𝒜$ in $d$ dimensions* is:
  $
    ρ^((d))_𝒜 quad≔quad sup_(I∈ℐ) 𝒜(I)/Opt(I).
  $
]

For $d=1$, an algorithm with approximation-ratio $2$ exists @Gasoline2018. For general $d$, a different algorithm exists, based on iterative rounding, for which we first write the gasoline-problem as an ILP. Let $𝟙$ be a vector of appropriate dimensions whose entries consist only of $1$s.
#figure(
  kind: "Program",
  supplement: "Program",
  $
    min_(Z, α, β)quad & ‖α-β‖_1 \
            "s.t"quad
            α         & ≤ ∑_(i=1)^k Z x_i - ∑_(i=1)^k y_i, quad k=1,…,n \
                    β & ≥ ∑_(i=1)^k Z x_i - ∑_(i=1)^(k-1) y_i, quad k=1,…,n \
                𝟙^T Z & ≤ 𝟙^T, quad Z^T 𝟙 ≤ 𝟙 quad quad (\"Z "is a permutation-matrix"\") \
                    Z & ∈ {0,1}^(d×d) \
                  α,β & ∈ ℝ^d.
  $,
  caption: [The integer linear program for the generalised gasoline-problem.],
)<ilp-gasoline>
The objective "$‖α-β‖_1$" is the same as "$𝟙^T (β-α)$" because $β ≥ α$, so this is indeed a linear objective.

#let UnfixedRows = math.op("UnfixedRows")
#let ColumnIndex = math.op("ColumnIndex")
#let BestRowIndex = math.op("BestRowIndex")
#let RowIndex = math.op("RowIndex")
#let BestRowValue = math.op("BestRowValue")
#let RowValue = math.op("RowValue")
#let LP = math.op("LP")
#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  pseudocode-list(numbered-title: [Iterative-Rounding for the Gasoline-Problem])[
    + Initialise $UnfixedRows ≔ {1,…,n}$. This keeps track of which rows of $Z$ we did not fix to integral values yet.
    + Initialise $LP$ as the LP-relaxation of @ilp-gasoline, i.e. replace the constraint $Z ∈ {0,1}^(d×d)$ with the constraint $Z ∈ [0,1]^(d×d)$.
    + For $ColumnIndex = 1,…,n$:
      + Initialise $BestRowIndex ≔ -1$ and $BestRowValue ≔ ∞$
      + For $RowIndex ∈ UnfixedRows$:
        + Let $LP'$ be the program $LP$ with the added constraint "$Z_(RowIndex,ColumnIndex) = 1$".
        + Let $RowValue$ be the optimum value of the $LP'$.
        + If $RowValue < BestRowValue$:
          + $BestRowIndex ≔ RowIndex$ and $BestRowValue ≔ RowValue$.
      + Add the constraint "$Z_(BestRowIndex,ColumnIndex) = 1$" to $LP$.
      + Remove $BestRowIndex$ from $UnfixedRows$.
    + $UnfixedRows$ is empty and $Z$ is fixed entirely.
  ],
) <alg-iterative-rounding>

In this work, we are interested in finding lower bounds on the approximation-ratio $ρ^((d))_IterRound$ of @alg-iterative-rounding. It holds that $ρ^((1))_IterRound ≤ ρ^((2))_IterRound ≤ …$, because embedding a $d$-dimensional instance into $ℝ^(d+1)$ in the obvious way yields a $(d+1)$-dimensional instance with the same $IterRound$- and $Opt$-values (see @Lorieau[p:Section 3.2]).

Though we will not prove this, the permutation $π$ in @example-gasoline-cookies is the output of @alg-iterative-rounding for that instance. There, $IterRound(I) = 24$, whereas $Opt(I) = 20$, which shows $ρ^((2))_IterRound ≥ 1.2$. r@Lorieau[p:] constructed a sequence of instances in $I_1, I_2, … ⊆ ℐ_1$ for which $IterRound(I_j)\/Opt(I_j)$ converged to a value of at least $2$, proving that $ρ^((1))_IterRound ≥ 2$.

@rajkovic[p:] conjectured that $ρ_(IterRound)^((1)) = 2$, and $ρ_(IterRound)^((d)) = 2$ for any $d > 1$. Though we will not make progress on the first conjecture, we did manage to disprove the second conjecture.



= FunSearch
Making progress on the different open problems in @section-problems-definitions involves a similar task for all of them: We would like to find instances that have a problem-specific undesirable quality.
- For bin-packing, we would like to find an instance where the randomised Best-Fit algorithm performs, in expectation, poorly compared to an optimum solution.
- For the Pareto-sets of knapsack-problems, we would like to find an instance $I$ where an intermittent Pareto-set $P(I_(1:i))$ is much larger than the Pareto-set $P(I)$ of the whole instance.
- For the Price of Hierarchy for $k$-median clustering, we would like to find instances whose Price of Hierarchy is large.
- For the generalised gasoline problem, we would like to find instances where @alg-iterative-rounding performs poorly compared to an optimum soution.


== Local Search <sec-local-search>
Even without having intuition for or experience with the different problems, we can still attempt to find such instances. A standard approach
is to employ some search-algorithm that searches for an instance of a high "score" across the space of all instances, where the score is e.g. the approximation-ratio of the instance (see e.g. @localSearch0[p:] @localSearch1[p:], or for a general overview @localSearch2[p:]). For bin-packing with capacity $c=1$, such an an algorithm might look as follows:
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

Variants of @algorithm-local-search-bin-packing include decreasing the mutation-rate over time, e.g. by decreasing the noise's variance in $Mutation$, or stochastically allowing to replace $I$ with $I'$, even if $I'$ has a worse score, to prevent getting stuck in local optima. See @local-search-plot for trajectories drawn from @algorithm-local-search-bin-packing.

#figure(
  {
    let trajectories = range(10).map(i => read("data/randomised-best-fit-local-search/" + str(i) + ".log", encoding: "utf8").split("\n").map(line => line.split("\t")).filter(split => split.len() >= 2).map(split => (split.at(0), split.at(1)))).map(history => history + ((10000, history.last().at(1)),))
    trajectories.push(trajectories.remove(0)) // For cycling colors, the default ones put an illegible one at the top.
    context (
      lq.diagram(
        yaxis: (lim: (1.0, 1.5)),
        xaxis: (exponent: none),
        height: page.width * 0.3,
        width: page.width * 0.6,
        xlabel: [#text(font: font-math)[Iteration]],
        ylabel: [#text(font: font-math)[Best Score]],
        ..trajectories.map(iteration-score => lq.plot(step: start, mark: none, stroke: 0.1em, iteration-score.map(x => int(x.at(0))), iteration-score.map(x => float(x.at(1))))),
      )
    )
  },
  caption: [Ten example trajectories of @algorithm-local-search-bin-packing, with the termination-condition for the loop in @codeline-iteration-count set after 10000 iterations. For each of the ten trajectories, we plot the score of the best solution $I$ over time.],
) <local-search-plot>

Enterprising readers will remember from @section-problems-bin-packing that the best-known instance for randomised Best-Fit had a score of $1.3$, which the results from @local-search-plot seem#footnote[The score-measurement we employ in @algorithm-local-search-bin-packing only uses a stochastic _estimation_ of the expected value, so this is not certain but highly probable.] to beat, the best trial achieving a score of $1.3725$, higher than the existing lower bound. _If_ we wanted to prove this rigorously, we would calculate the true score by running best-fit for all $10! ≈ 3.6⋅10^6$ possible permutations (the found instance (see @local-search-instance) has many exploitable symmetries, decreasing the required computations even further). We will not do so, however, in favour of proving a better result later on.

Instead, to motivate our next steps, we will try learning from the instance, perhaps spotting structures in it, hoping to use these to manually construct instances of even higher scores. Alas, @local-search-instance gives us little hope: Unlike e.g. the instance in @example-bin-packing-sota, the instance found by @algorithm-local-search-bin-packing does not seem to have any discernible pattern or noticeable symmetries. The four zero-weight items are a product of negative items in the mutation $I'$ being rounded up to $0$, and contribute nothing to the instance.

#figure(
  table(
    columns: (1fr, 2fr, 4fr, 1fr),
    gutter: 0em,
    stroke: none,
    align: center + horizon,
    [],
    `[0, 0, 0, 0, 0.13941968656458636, 0.1415175313246237, 0.18488603733618258, 0.20818251654978343, 0.6014145332633378, 0.7129758245684663]`,
    lq.diagram(
      yaxis: (lim: (0.0, 1.0)),
      xaxis: (ticks: none, subticks: none),
      lq.bar(
        fill: green,
        range(10),
        (0.0, 0.0, 0.0, 0.0, 0.13941968656458636, 0.1415175313246237, 0.18488603733618258, 0.20818251654978343, 0.6014145332633378, 0.7129758245684663),
      ),
    ),
    [],
  ),
  kind: image,
  caption: [The sorted best instance found in the trials of @local-search-plot, achieving a score of $1.3725$.],
) <local-search-instance>

== FunSearch: Local Search on Code Instead of Vectors <sec-funsearch-introduction>

To mitigate these issues we could --instead of searching for lists of numbers-- search for _short descriptions_ of lists of numbers, i.e. we search for short _python-code_ generating a list of numbers. While plain lists of numbers encode symmetric and structured instances just the same way as any other instances, python-code almost always produces symmetric and structured instances, assuming we avoid #raw(block: false, lang: "py", "import random") and hard-coding lists of numbers.

#example[
  An instance in the lower-bound construction by @bestFitAbsoluteRatio[p:] can be expressed via hardcoded numbers:
  #figure(
    box(fill: white.darken(2%), stroke: gray + 0.1em, radius: 0.25em, inset: 0.5em)[```py
    items = [0.17166666666666666, 0.16791666666666666, 0.16697916666666665, 0.16674479166666667, 0.16668619791666667, 0.3283333333147069, 0.3320833333147069, 0.3330208333147069, 0.3332552083147069, 0.3333138020647069, 0.14666666666666667, 0.16166666666666665, 0.16541666666666666, 0.16635416666666666, 0.16658854166666665, 0.3533333333147069, 0.3383333333147069, 0.33458333331470685, 0.3336458333147069, 0.33341145831470687, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264, 0.5000000000186264]
    ```],
    caption: [The instance for the lower-bound construction in @bestFitAbsoluteRatio[p:] for $k=1$.],
  )<hardcoded-best-fit>
  However, @bestFitAbsoluteRatio[p:] actually defined these items as follows:
  #figure(
    box(fill: white.darken(2%), stroke: gray + 0.1em, radius: 0.25em, inset: 0.5em)[```py
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
    ```],
    caption: [The same instance as in @hardcoded-best-fit, using a more structured definition.],
  )<structured-best-fit>
  For larger $k$, @hardcoded-best-fit grows even longer (though would run into floating-point rounding issues), while @structured-best-fit remains short and interpretable.
]

However, if we now tried to implement @algorithm-local-search-bin-packing by searching on the space of python-code instead of the space $ℝ^10$, we will have trouble defining the $Mutation$-function, which is meant to return a mutated variant of our current solution. Defining $Mutation$ by throwing noise onto the python-code (e.g. randomly change or swap characters) like we did for $ℝ^10$ would lead to most mutated programs failing to compile. One can try circumventing this by not interpreting python-code as a sequence of characters, but as a composition-tree of basic computational functions, an approach known as _Genetic Programming_ @genetic0 @genetic2 @genetic1.

Instead of Genetic Programming, we will follow the approach of @romera2024mathematical[p:] called *FunSearch*. Instead of mutating python-code by randomly changing characters, this approach mutates python-code by querying a large language model (LLM). An example for such a query is shown in @example-prompt, and an example-response in @example-response. The advantage of this method is that we retain both interpretable structure, and python-code that compiles most of the time. Furthermore (though this was not done in the shown examples), the python-code can be generalised on some sets of parameters. For instance, the `get_items` functions could accept an integer-parameter that tells the function the maximum allowed size of the list. Our evaluation-function $Score$ then rejects lists exceeding that length, and we may mathematically analyse the asymptotic behaviour of the function for large list-lengths after the fact.

#figure(
  align(left, box(stroke: 0.1em + gray, radius: 0.5em, inset: 1em, text(font: font-monospace, size: 0.75em)[I'm trying to find instances of the bin-packing problem where, if the input is shuffled, the best-fit online-heuristic performs poorly in expectation. All bins have capacity 1.0.

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
  align(left, box(stroke: 0.1em + gray, radius: 0.5em, fill: white.darken(1%), inset: 1em, text(font: font-monospace, size: 0.75em)[
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

== Tuning the FunSearch-Output <sec-funsearch-tuning-introduction>

We used FunSearch to find "bad" instances for the four problems listed above. After FunSearch concluded, we manually searched through its output for promising code. We then manipulated the code, for instance by removing redundant items (see e.g. @evolution-bin-packing and @evolution-clustering) or making the instance more symmatrical (see @evolution-clustering, where we replaced `np.linspace` (which produces a sequence of evenly-spaced numbers) with `np.ones` (which produces a sequence of identical numbers)), and checking after every step whether the program's score decreased noticeably.

Not all programs lent themselves to this, some programs just produced pseudo-random numbers, e.g. using trigonometric functions, but if successfull, we ended up with a concise, interpretable, symmetric instance that we could use to try and prove new results.

== Implementation Details <sec-implementation-details>
Our implementation#footnote(link("https://github.com/lumi-a/funsearch")) is a fork of Johannes Aalto's implementation#footnote(link("https://github.com/jonppe/funsearch")), which is a fork of Google DeepMind's repository#footnote(link("https://github.com/google-deepmind/funsearch")).

We replaced the single-threaded evaluation-loop (query the LLM to get one new program, evaluate the program, repeat) with a multi-threaded producer-consumer pattern, where multiple queries are made in parallel, and evaluated asynchronously. Furthermore, each query is batched, producing several new programs (default: $4$) instead of just one, which is more cost-effective as the input-tokens are only billed once per batch.

We also created an interface to display results about FunSearch runs in the form of a website#footnote(link("https://lumi-a.github.io/funsearch")) (see @website). This helped with collaboration, analysing the outcomes and benchmarking different choices of parameters.

#figure(
  block(stroke: 0.1em + gray, width: 90%, image("assets/website.png")),
  caption: [The #link("https://lumi-a.github.io/funsearch")[website] showing outcomes of FunSearch runs.],
) <website>

When a query returns a program, it is evaluated by assigning it a score (higher being better). These scores were problem-specific.

=== Scoring Bin-Packing
For a bin-packing instance $I$, we calculated the optimal (smallest) number of bins $Opt(I)$ by calling the existing solver `packingsolver`#footnote(link("https://github.com/fontanf/packingsolver")) @fontan, which is based on column-generation.

We did not calculate the expected number of bins used by Best-Fit $𝔼_(π∈S_(|I|))[BestFit(π(I))]$ exactly, but instead ran $10000$ trials of Best-Fit under random permutations, and used the mean number of bins $"Mean"$ as an estimate.

The score assigned to $I$ was $op("Mean")\/Opt(I)$.

=== Scoring Knapsack
For this, we implemented @alg-nemhauser-ullmann in the way described in @RoeglinBookChapter[p:Theorem 5], but using multi-sets for the sets $op("val")(P_i)$ in order to accurately track the true size of the Pareto-Set, and not just the size of the Pareto-Set when solutions with the same total weight and total profit are treated as identical. Our implementation proved troublesome, containing several bugs we had to fix along the way.

For a knapsack-instance $I$, we run this implementation of @alg-nemhauser-ullmann, but keep track of the largest Pareto-Set $P_"largest"$ over time and the running maximum of $abs(P_"largest") \/ abs(P_i)$. The final score is this maximum. That is, the assigned score is:
$
  Score(I)
  quad = quad
  max_(i = 1,…,abs(I))
  [max_(j = 1,…,i) abs(P_j) / abs(P_i)]
$

=== Scoring Hierarchical Clustering
For this, we had to compute an _optimal_ hierarchical clustering in the sense of @def-optimal-hierarchical-clustering. We did not find any existing solver for this, and brute-force methods are intractable: The number of different hierarchical clusterings on $32$ points is around $1.78⋅10^42$.

At first, we attempted to formulate the problem as an ILP to be solved with Gurobi @gurobi, but that also proved ineffective, so we wrote our own solver instead.

For every $k=1,…,n$, it first computes an approximate $k$-clustering via heuristics ($k$means++ or agglomerative clustering), which is used as an upper bound on the optimal $k$-clustering, which is then computed via branch-and-bound: Let $P = [p_1,…,p_n]$ be the list of vertices. We keep a priority-queue storing partial clusterings, i.e. partitions of some initial sub-list $[p_1,…,p_i]$. The neighbors of such a partial clustering are all possible partial clusterings obtained by adding $p_(i+1)$ to either an existing clustering, or putting it into a new singleton-cluster (if the total number of clusters is smaller than $k$). At each step, we take the partial clustering with the lowest priority off the priority-queue and add its neighbours to the priority-queue, where their priority is simply the total cost of that partial clustering, unless they exceed the upper bound on the optimal clustering.

After computing an optimal $k$-clustering for each $k$, we compute _some_ hierarchical clustering via agglomerative clustering, and then an optimal hierarchical clustering, again via branch-and-bound, but this time proceeding level-wise from level $k=n$ to level $k=1$ (if we started from $k=2$, we would immediately have $2^n$ neighbours to inspect). This time, the priority of a partial hierarchical clustering is the maximum of $Cost(H_i) / Opt_i$ over all levels $H_i$ that have been clustered so far (compare @def-optimal-hierarchical-clustering).

To speed up the search even further, we used memoization for computing costs of clusters, efficient memory-representation via bit-vectors and allocating on the stack as much as possible. With this, we were able to compute optimal hierarchical clusterings on $32$ points.

Written in rust, it is available on crates.io#footnote(link("https://crates.io/crates/exact-clustering")) with documentation on docs.rs #footnote(link("https://docs.rs/exact-clustering")), the repository is on GitHub #footnote(link("https://github.com/lumi-a/exact-clustering")). We also provide python-bindings (on PyPi#footnote(link("https://pypi.org/project/exact-clustering")), GitHub#footnote(link("https://github.com/lumi-a/py-exact-clustering"))) via #link("https://www.maturin.rs")[Maturin]. The code is heavily benchmarked, tested, and documented, so that other researchers may easily use it.

=== Scoring Gasoline
An instance $I$ was scored by its approximation-ratio $IterRound(I)\/Opt(I)$, for which we could simply use the code#footnote(link("https://github.com/ath4nase/gasoline")) by @Lorieau[p:], specifically $Score(I) =$ `iterative_rounding.SlotOrdered().run(I)`.


#TODO[Describe the tuning of the instances more]

= Results
== Bin-Packing

#[
  #show raw: set text(size: 0.75em)
  #show raw: body => box(fill: white.darken(2%), stroke: gray + 0.1em, radius: 0.25em, inset: 1em, align(left, body))

  #subpar.grid(
    columns: (1fr, 1fr),
    kind: raw,
    figure(caption: [Initial program.])[
      ```py
      def get_items() -> list[float]:
          """Return a new bin-packing-instance, specified by the list of items.

          The items must be floats between 0 and 1."""
          items = [0.4, 0.5, 0.6]
          return items
      ```
    ],
    figure(caption: [After tuning @code-bin-packing-funsearch-output by hand.])[
      ```py
      def get_items() -> list[float]:
          a = 7
          b = 5
          return [1.0 / a] * a + [1.0 / b] * b
      ```
    ],
    grid.cell(
      colspan: 2,
    )[
      #figure(caption: [A program found by FunSearch after $10$ trials of $2,400$ samples each.])[```py
      def get_items() -> list[float]:
          """Return a new bin-packing-instance, specified by the list of items.

          The items must be floats between 0 and 1."""
          """Yet another version of `get_items_v0`, `get_items_v1`, and `get_items_v2`, with some lines altered."""
          items = [0.8, 0.2, 0.6, 0.4]
          # Split the first item into seven smaller items and the fourth item into five smaller items
          items = [0.114, 0.114, 0.114, 0.114, 0.114, 0.114, 0.114] + items[1:3] + [0.08, 0.08, 0.08, 0.08, 0.08]
          return items
      ```]<code-bin-packing-funsearch-output>
    ],
    gap: 1em,
    caption: [The evolution of programs generating bin packing instances, with model open-mistral-nemo and a temperature of $1.5$.],
    label: <evolution-bin-packing>,
  )
]

For fixed $m in ℕ$, consider the instance:

$
  I ≔ [underbrace(m + 1\,#h(0.5em) …\,#h(0.5em) m + 1, m upright(" times")),#h(1em) underbrace(m \,#h(0.5em) … \,#h(0.5em) m, m + 1 upright(" times"))] \, #h(2em) upright("maximum bin capacity ") c colon.eq m ⋅ (m + 1).
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
  gap: 0em,
  caption: [Nine different packings produced by randomised Best-Fit.],
)

It turns out that this is the _only_ optimal packing (up to re-labeling the two bins):
#lemma[
  An optimal packing can not have a bin containing both an item of weight $m$ and an item of weight $m+1$.
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

With more effort, one could obtain tighter bounds on the probability. But that simply will not be necessary, as this weak bound already yields a sufficient lower-bound on the absolute random-order-ratio:
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
#TODO[Knapsack-Code output]

// Sadly, any non-trivial instantiation of our instance is too large to draw.
To analyze the sizes of the instance's and subinstances' Pareto-sets, we define the two segments
of the instance: For $a, b, d, n in bb(Z)_(≥ 1)$ with
$d < a ≤ b$, define $x_i colon.eq (1 + frac(2^(- i), 2^d - 1))$, and
two lists:
$
  I_(a, b) ≔ [vec(2^a, 2^a), vec(2^(a + 1), 2^(a + 1)), …, vec(2^b, 2^b)], #h(2em)
  J_(d, n) ≔ [ vec(x_1 ⋅ 2^d, x_1 ⋅ (2^d - 1)), …, vec(x_n ⋅ 2^d, x_n ⋅ (2^d - 1)) ].
$

#lemma[
  If a Pareto-optimal packing
  $A in P ([I_(a, b), J_(d, n)])$ does not contain all items from
  $I_(a, b)$, it contains fewer than $2^(a - d)$ items from
  $J_(d, n)$.
] <small-Jdn>
#proof[
  Subsets of $I_(a, b)$ can be represented by binary
  numbers of $(b - a + 1)$ bits. If $A$ does not contain all items from
  $I_(a, b)$ and contains at least $2^(a - d)$ items from $J_(d, n)$,
  we define a new packing $A'$ as follows: Increment the binary number
  representing $A ∩ I_(a, b)$ by $1$, and remove $2^(a - d)$ items
  from $A ∩ J_(d, n)$. This changes the weights and profits by:
  $
    Weight(A') - Weight(A)
    quad & ≤quad 2^a - 2^(a-d)⋅ underbrace((1+(2^(-n))/(2^d-1)), >1)⋅2^d
           quad<quad 0 \
    Profit(A') - Profit(A)
    quad & ≥quad 2^a - 2^(a-d)⋅ (1+(2^(-1))/(2^d-1)) (2^d-1) \
    quad & = quad 2^a - 2^(a-d)⋅ (2^d-2^(-1))
           quad=quad 2^(a-d-1)
           quad>quad 0
  $
  Thus, $A'$ dominates $A$, and
  $A in.not P ([I_(a, c), J_(d, n)])$.
]
On the other hand, all other packings are Pareto-optimal:

#lemma[If a packing $A$ of
  $[I_(a, b), J_(d, n)]$ contains all items from $I_(a, b)$ or
  contains fewer than $2^(a - d)$ items from $J_(d, n)$, then $A$ is
  Pareto-optimal.
]
#proof[All items from $I_(a, b)$ have a profit-per-weight ratio
  of $1$, while all items from $J_(d, n)$ have a profit-per-weight ratio
  of $frac(2^d - 1, 2^d) < 1$. Hence, a packing $B$ that dominates $A$
  must satisfy
  $ Weight(A ∩ I_(a, b)) quad<quad Weight(B ∩ I_(a, b)), $
  otherwise $B$ can not have enough profit to dominate $A$. If $A$ already
  contains all items from $I_(a, b)$, this is not possible, so only the
  case that $A$ contains fewer than $2^(a - d)$ items from $J_(d, n)$
  remains. Due to the definition of $I_(a, b)$, the above inequality
  implies:
  $ Weight(A ∩ I_(a, b)) + 2^a quad≤quad Weight(B ∩ I_(a, b)) . $
  If $B$ dominates $A$, it must hold that:
  $
    Weight(A ∩ I_(a, b)) + Weight(A ∩ J_(d, n)) & quad≥quad Weight(B ∩ I_(a, b)) + Weight(B ∩ J_(d, n)) \
                   ⟹ Weight(A ∩ J_(d, n)) - 2^a & quad≥quad Weight(B ∩ J_(d, n)).f
  $
  But $A$ contains fewer than $2^(a - d)$ items from $J_(d, n)$, so:
  $
    Weight(A ∩ J_(d,n)) & quad ≤quad 2^(a-d) ⋅ (1+(2^(-1))/(2^d-1)) ⋅(2^(d)-1)
                          quad =quad 2^(a-d) ⋅ (2^d-2^(-1)) \
                        & quad=quad 2^(a) - 2^(a-d-1)
                          quad<quad 2^a.
  $
  This implies $0 > Weight(B ∩ J_(d, n))$, a
  contradiction.
]

Hence, we can describe the Pareto-set exactly:
$
  P ([I_(a, b), J_(d, n)]) quad=quad
  { A ∪ B mid(|) A subset.neq I_(a, b),med med B subset.eq J_(d, n),med med lr(|B|) < 2^(a - d) } quad dot(union)quad { I_(a, b) union B mid(|) B subset.eq J_(d, n) }.
$
Its size is exactly (using notation for binomial coefficients, not vectors):
$ lr(|P ([I_(a, b), J_(d, n)])|) = (2^(b - a + 1) - 1) ⋅ [ sum_(i = 0)^(min (n,med 2^(a - d) - 1)) binom(n, i) ] + 2^n . $
For $k, n in bb(N)$ with $2^k ≤ n \/ 2$, consider two instances:
$
  𝕀_1 & colon.eq [I_(2 k, med 2 k + n), med J_(k, n)], \
  𝕀_2 & colon.eq [𝕀_1, med vec(2^(k + 1), 2^(k + 1)), vec(2^(k + 2), 2^(k + 2)), …, vec(2^(2 k - 1), 2^(2 k - 1))] .
$
$𝕀_1$ is a sub-instance of $𝕀_2$. $𝕀_2$ (which is exactly
the instance #TODO[Insert reference.]) contains the same items as
$[I_(k + 1, thin 2 k + n), med J_(k, n)]$. The sizes of their
Pareto-sets can be bounded by:
$
  abs(P( 𝕀_1)) quad & ≥quad
                      ( 2^(n + 1) - 1 ) ⋅ binom(n, 2^k - 1) + 2^n quad && ≥quad
                                                                          ( 2^(n + 1) - 1 ) ⋅ (n/(2^k - 1))^(( 2^k - 1 )) \
  abs(P( 𝕀_2)) quad & ≤quad
                      ( 2^(k + n) - 1 ) ⋅ ( n + 1 ) + 2^n quad         && ≤quad
                                                                          ( 2^(k + n) - 1 ) ⋅ ( n + 2 ).
$

The ratio between the two sizes is:
$
  abs(P ( 𝕀_1 ))/abs(P ( 𝕀_2 )) quad≥quad frac(2^(n + 1) - 1, 2^(k + n) - 1) ⋅ ( frac(n, 2^k - 1) )^(( 2^k - 1 )) ⋅ 1/(n+2)
$
For $k = log_2 ( sqrt(n) ) + 1$, we obtain:
$
  frac(abs(P ( 𝕀_1 )), abs(P ( 𝕀_2 ))) quad≥quad frac(2^(n + 1) - 1, ( sqrt(n) + 1 ) ⋅ 2^n - 1) ⋅ ( n / sqrt(n) )^(sqrt(n)) ⋅ 1/(n+2) quad=quad θ( n^(( sqrt(n) - 3 )\/ 2) ).
$

The length of the instance
$𝕀_2$ is not $n$ but $m colon.eq lr(|𝕀_2|) = 2 n + k$, resulting
in an actual lower bound of $O ( (m\/ 2)^((sqrt(m \/ 2) - 3) \/ 2) )$.

#theorem[
  There exist instances $I$ such that:
  $
    Score(I) quad=quad (max_(j=1,…,|I|) abs(P(I_(1:j))))/(abs(P(I))) quad≥quad O ( (abs(I)/ 2)^((sqrt(abs(I) \/ 2) - 3) \/ 2) ).
  $
]<nemhauser-ullmann-theorem>

In implementations of the Nemhauser-Ullmann algorithm, two
Pareto-optimal packings can be treated as equivalent if they have the
same total weight and total profit. Hence, the runtime can be
upper-bounded not only by the sum of the sizes of the Pareto-sets
$lr(|P (I_(1 : 1))|) + . . . + lr(|P (I_(1 : n))|)$, but even the sizes
of the Pareto-sets when two packings with the same total weight and
total profit are treated as identical. The only purpose of the leading
factors
$x_i = ( 1 + frac(2^(-i), 2^d - 1) )$
in $J_(d, n)$ is to prevent two Pareto-optimal packings from having
the same total profit. As a consequence, we also obtain the same bound
for the runtime of the Nemhauser-Ullmann algorithm.

#lemma[If
  $A, B subset.eq [I_(a, b), J_(d, n)]$ are two distinct Pareto
  optimal packings, then $Profit(A) ≠ Profit(B)$.
]
#proof[
  Because both $A$ and $B$ are Pareto-optimal, we know by @small-Jdn that $abs(A ∩ J_(d, n)) < 2^(a - d)$ (same for $B$), hence:
  $
    Profit(A ∩ J_(d,n)) & < 2^(a-d) ⋅ (1+(2^(-1))(2^d-1)) ⋅ (2^d-1) \
                        & = 2^(a-d) ⋅ (2^d-1/2) \
                        & = 2^a - 2^(a-d-1) quad<quad 2^a.
  $
  (same for $Profit(B ∩ J_(d, n))$).

  - If $A ∩ I_(a, b) ≠ B ∩ I_(a, b)$, the difference
    between $Profit(A ∩ I_(a, b))$ and
    $Profit(B ∩ I_(a, b))$ would be at least $2^a$, due to the
    definition of $I_(a, b)$. In this case, the above inequality already
    shows $Profit(A) ≠ Profit(B)$.

  - If $A ∩ I_(a, b) = B ∩ I_(a, b)$, then
    $A ∩ J_(d, n) ≠ B ∩ J_(d, n)$, and we need to show that
    $Profit(A ∩ J_(d, n)) ≠ Profit(B ∩ J_(d, n))$.
    This is equivalent to showing that any two distinct subsets of:
    $ { (2^d - 1) + 2^(- 1), med med (2^d - 1) + 2^(- 2), med med . . ., med med (2^d - 1) + 2^(- n) }, $
    have a distinct sum. This is true, because the total sum of the summands
    $2^(- 1), . . ., 2^(- n)$ is always smaller than $1$, whereas
    $2^d - 1 ≥ 1$.
]


== $k$-median Clustering
#[
  #show raw: set text(size: 0.75em)
  #show raw: body => box(fill: white.darken(2%), stroke: gray + 0.1em, radius: 0.25em, inset: 1em, align(left, body))

  #subpar.grid(
    columns: (1fr, 1fr),
    kind: raw,
    figure(caption: [Initial program.])[
      ```py
      def get_weighted_points() -> list[tuple[float, np.ndarray]]:
          """Return a new weighted clustering-problem, specified by a list of weighted points.
          The returned tuple consists of the weight of the point, and the point itself."""
          weighted_points = [(1.0, np.array([0, 0, 0, 0])), (1e8, np.array([1, 0, 0, 0]))]
          return weighted_points
      ```
    ],
    figure(caption: [After tuning @code-clustering-funsearch-output by hand.])[
      ```py
      def get_weighted_points() -> list[tuple[float, np.ndarray]]:
          return [
              (1.0, np.zeros(14)),
              *[(1.0, -np.eye(14)[i]) for i in range(14)],
              (1e10, np.ones(14) / 20),
          ]
      ```
    ],
    grid.cell(
      colspan: 2,
    )[
      #figure(caption: [A program found by FunSearch after $10$ trials of $2,200$ samples each.])[```py
      def get_weighted_points() -> list[tuple[float, np.ndarray]]:
          """Return a new weighted clustering-problem, specified by a list of weighted points.
          The returned tuple consists of the weight of the point, and the point itself."""
          return [
              (1.0, np.zeros(14)),
              (1e10, np.ones(14)),
              *[(1.0, np.eye(14)[i]) for i in range(7)],
              *[(1.0, np.eye(14)[i]*-1) for i in range(7, 13)],
              *[(1e10-i*1e9, np.linspace(i*0.1, (i+1)*0.1, 14, endpoint=False)) for i in range(7)],
              (1e11, np.array([13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])),
              (1e12, np.array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13])),
              (1e13, np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14])*10),
              (1e14, np.array([14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1])*100),
              (1e15, np.array([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])*1000),
      ```]<code-clustering-funsearch-output>
    ],
    gap: 1em,
    caption: [The evolution of programs generating clustering-instances. The model used was open-mistral-nemo with a temperature of $1.5$.],
    label: <evolution-clustering>,
  )
]

Fix the dimension $d ≥ 4$. Put
$c colon.eq frac(sqrt(4 d^2 + (3 - d)^2) + d - 3, 2)$, which is one of
the two roots of $0 = c^2 - c (d - 3) - d^2$. Because $d ≥ 4$, we
know that $5 d^2 - 6 d ≥ 4 d^2$, hence:
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
      v(0.5em) + draw-clustering.draw-hierarchical-clustering(points, hierarchy, page.width * 0.35, true, ..massdict) + h(1em) + draw-clustering.draw-hierarchical-clustering(points, optimal, page.width * 0.35, false, ..massdict) + v(0.5em),
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
    in its first cluster, and all other points in its second cluster. Assuming
    the center of the second cluster is $(0, …, 0)$, we
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

#theorem[
  The Price of Hierarchy for $k$-median clustering $PoH_(k"-median")$ is at least $(1+√5)/2 ≈ 1.618$.
]


== Gasoline
#[
  #show raw.where(block: true): set text(size: 0.75em)
  #show raw.where(block: true): body => box(fill: white.darken(2%), stroke: gray + 0.1em, radius: 0.25em, inset: 1em, align(left, body))

  #subpar.grid(
    columns: 1fr,
    kind: raw,
    figure(caption: [Initial program.])[
      ```py
      def gasoline(n: int) -> tuple[list[np.ndarray], list[np.ndarray]]:
          """Return a new gasoline-problem, specified by the two lists of 2d-non-negative-integer-points.
          Both lists must have length at most n and consist only of points in N^2.
          """
          k = int(math.log2(n + 2)) - 1
          xs, ys = [], []
          for i in range(1, k):
              rounded = int(2**k * (1 - 2 ** (-i)))
              xs.extend([np.array([rounded, 0]) for _ in range(2**i)])
              ys.extend([np.array([rounded, 0]) for _ in range(2**i)])

          xs.extend([np.array([2**k, 0]) for _ in range(2**k - 1)])
          xs.append(np.array([0, 0]))

          rounded = int(2**k * (1 - 2 ** (-k)))
          ys.extend([np.array([rounded, 0]) for _ in range(2**k)])

          return xs, ys
      ```
    ],
    figure(caption: [The difference between the initial program and a program found by\ FunSearch after $10$ trials of 950 samples each, which we only tuned by discarding\ the final element of both lists.])[
      ```diff
       def gasoline(n: int) -> tuple[list[np.ndarray], list[np.ndarray]]:
           """Yet another variation of the gasoline-problem generator."""
           k = int(math.log2(n + 2)) - 1
           xs, ys = [], []
           for i in range(1, k):
               rounded = int(2**k * (1 - 2 ** (-i)))
               xs.extend([np.array([rounded, 0]) for _ in range(2**i)])
      -        ys.extend([np.array([rounded, 0]) for _ in range(2**i)])
      +        ys.extend([np.array([rounded, 2]) for _ in range(2**i)])  # No change

      -    xs.extend([np.array([2**k, 0]) for _ in range(2**k - 1)])
      +    xs.extend([np.array([2**k, 4]) for _ in range(2**k - 2)])  # No change
      -    xs.append(np.array([0, 0]))
      +    xs.append(np.array([0, 1]))  # Changed from [0, 2] to [0, 1]
      +    xs.append(np.array([2**k, 2]))  # Changed from [2**k, 0] to [2**k, 2]

           rounded = int(2**k * (1 - 2 ** (-k)))
      -    ys.extend([np.array([rounded, 0]) for _ in range(2**k)])
      +    ys.extend([np.array([rounded, 2]) for _ in range(2**k - 1)])  # No change
      +    ys.append(np.array([0, 1]))  # Changed from [0, 2] to [0, 1]
      ```
    ],
    gap: 1em,
    caption: [The evolution of programs generating $2$-dimensional gasoline-instances. The model used was open-mistral-nemo with a temperature of $1.5$. Lists were clipped to length $n$ before evaluation, and the final element of `ys` set such that `sum(xs) == sum(ys)`.],
  )
]

The following example is the instance found by @Lorieau[p:]:

#example[
  This is a $d"="1$-dimensional instance. Fix some $k∈ℕ$. For any $i$, define $u_i ≔ 2^k (1 - 2^(-i))$. Let $plus.circle$ denote list-concatenation, e.g. $[1,2] plus.circle [3,4] = [1,2,3,4]$. The $1$-dimensional instance found by @Lorieau[p:] can be written as follows:
  $
    X & = (plus.circle.big_(i = 1)^(k - 1) plus.circle.big_1^(2^i) [u_i]) plus.circle (plus.circle.big_1^(2^k - 1) [2^k]) plus.circle [0], quad quad
        Y & = plus.circle.big_(i = 1)^k plus.circle.big_1^(2^i) [u_i].
  $
  #let deliveries = ((16,), (16,), (24,), (24,), (24,), (24,), (28,), (28,), (28,), (28,), (28,), (28,), (28,), (28,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (32,), (0,))
  #let production = ((16,), (16,), (24,), (24,), (24,), (24,), (28,), (28,), (28,), (28,), (28,), (28,), (28,), (28,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (30,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,), (31,))
  We consider the case $k=5$. This instance has $62$ items, which is too large to write out in full. We plot the permutation-matrices for some optimal solution $π_Opt$ and the solution $π_IterRound$ found by @alg-iterative-rounding. Filled squares represent a $1$, empty squares a $0$.
  #let opt-permut = (30, 61, 31, 0, 32, 1, 33, 2, 34, 3, 35, 4, 36, 5, 37, 6, 38, 7, 39, 8, 40, 9, 41, 10, 42, 11, 43, 12, 44, 13, 45, 14, 46, 15, 47, 16, 48, 17, 49, 18, 50, 19, 51, 20, 52, 21, 53, 22, 54, 23, 55, 24, 56, 25, 57, 26, 58, 27, 59, 28, 60, 29)
  #let iterround-permut = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61)
  #figure(
    h(1fr) + draw-gasoline.permutation-matrix(iterround-permut) + h(2fr) + draw-gasoline.permutation-matrix(opt-permut) + h(1fr),
    caption: [The permutation-matrices for $π_IterRound$ (left) and some $π_Opt$ (right).],
  )<permutation-matrices-lucas>
  Indeed, $π_IterRound$ is the identity. We also plot the progression of $BestRowValue$ over the course of @alg-iterative-rounding for this instance. These values are the result of minimisation-LPs whose set of constraints grows over time, so this plot must be non-decreasing over time.
  #let best-row-values = (31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 62)
  #figure(
    lq.diagram(width: 400pt, height: 150pt, yaxis: (lim: (0, 67)), lq.plot(color: green, range(best-row-values.len()), best-row-values), xlabel: $ColumnIndex$, ylabel: $BestRowValue$),
    caption: [The progression of $BestRowValue$ during @alg-iterative-rounding for this instance.],
  ) <best-row-value-progression-lucas>
  Plotting bar-charts with annotations about which elements got added / removed from our "warehouse" (like in @example-gasoline-cookies) makes for too wide a plot, so we drop the annotations (they can be inferred from the permutations, if necessary) and instead use a regular line-chart. This instance here is $1$-dimensional, so only the stock of one "ingredient" needs to be tracked over time.
  #figure(
    draw-gasoline.draw-permutation(iterround-permut, deliveries, production, lq: true, y-axis-lim: 64, diagram-height: 120pt),
    gap: 1em,
    caption: [Visualising the "warehouse" for $π_IterRound$ over time. The maximum capacity is $62$.],
  )
  #figure(
    draw-gasoline.draw-permutation(opt-permut, deliveries, production, lq: true, y-axis-lim: 64, diagram-height: 120pt),
    gap: 1em,
    caption: [Visualising the "warehouse" for $π_Opt$ over time. The maximum capacity is $32$.],
  )
  Thus, for this instance, $IterRound(I)/Opt(I) = 62/32 = 1.9375$. More generally, if $I_k$  is the above instance for some $k$, @Lorieau[p:] showed that $IterRound(I_k)/Opt(I_k)$ is at least $2-2^(1-k)$.
]<example-plot-gasoline-lucas>

#let gasoline-weak-label = "[G-Low]"
#let gasoline-strong-label = "[G-High]"

FunSearch found the following two very similar instances. Fix the dimension $d ≥ 2$ and parameter $k$.

$
  X & ≔ (plus.big.circle_(i=1)^(k-1) plus.big.circle_1^(2^i) plus.big.circle_(j=2)^d [u_i e_1 + 2e_j]) plus.circle (plus.big.circle_(j=2)^d (plus.big.circle_1^(2^k-1) [2^k e_1]) plus.circle[2 e_j]),quad
      Y & ≔ plus.big.circle_(i=1)^k plus.big.circle_1^(2^i) plus.big.circle_(j=2)^d [u_i e_1 + 1e_j]
          #h(2em) #text(font: font-text, weight: "regular")[#gasoline-weak-label]
$<eq-gasoline-weak>
#let gasoline-weak = link(<eq-gasoline-weak>, gasoline-weak-label)
#v(2em)
$
  X & ≔ (plus.big.circle_(i=1)^(k-1) plus.big.circle_1^(2^i) plus.big.circle_(j=2)^d [u_i e_1 + 4 e_j]) plus.circle (plus.big.circle_(j=2)^d (plus.big.circle_1^(2^k-1) [2^k e_1]) plus.circle[4 e_j]),quad
      Y & ≔ plus.big.circle_(i=1)^k plus.big.circle_1^(2^i) plus.big.circle_(j=2)^d [u_i e_1 + 2e_j]
          #h(2em) #text(font: font-text, weight: "regular")[#gasoline-strong-label]
$<eq-gasoline-strong>
#let gasoline-strong = link(<eq-gasoline-strong>, gasoline-strong-label)
The two instances only differ in three places, in the constant scalars preceding the $e_j$. Specifically, #gasoline-strong is just #gasoline-weak multiplied by the diagonal matrix $op("diag")(1,2,…,2)$. Compared to the values $u_i$ preceding the $e_1$, these constant scalars are quite small.

While #gasoline-strong seems to achieve higher scores, #gasoline-weak seems better suited for proving asymptotic bounds, because the outputs of @alg-iterative-rounding have more structure there (compare e.g. @permutation-matrices-weak to @permutation-matrices-strong, and @best-row-value-progression-weak to @best-row-value-progression-strong below). That said, we did not manage to prove any asymptotic bounds for either instance and only note scores for specific parameters, and patterns we spotted in those scores.

#example[Consider an optimal solution $π_Opt$ and the solution $π_IterRound$ found by @alg-iterative-rounding for #gasoline-weak, with $d=3$ and $k=5$. This instance has $124$ elements. We draw the same plots as in @example-plot-gasoline-lucas.
  #let deliveries = ((16, 2, 0), (16, 0, 2), (16, 2, 0), (16, 0, 2), (24, 2, 0), (24, 0, 2), (24, 2, 0), (24, 0, 2), (24, 2, 0), (24, 0, 2), (24, 2, 0), (24, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (0, 2, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (0, 0, 2))
  #let production = ((16, 1, 0), (16, 0, 1), (16, 1, 0), (16, 0, 1), (24, 1, 0), (24, 0, 1), (24, 1, 0), (24, 0, 1), (24, 1, 0), (24, 0, 1), (24, 1, 0), (24, 0, 1), (28, 1, 0), (28, 0, 1), (28, 1, 0), (28, 0, 1), (28, 1, 0), (28, 0, 1), (28, 1, 0), (28, 0, 1), (28, 1, 0), (28, 0, 1), (28, 1, 0), (28, 0, 1), (28, 1, 0), (28, 0, 1), (28, 1, 0), (28, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (30, 1, 0), (30, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1), (31, 1, 0), (31, 0, 1))
  #let opt-permut = (60, 91, 61, 123, 62, 0, 63, 1, 64, 2, 65, 3, 66, 4, 67, 5, 68, 6, 69, 7, 70, 8, 71, 9, 72, 10, 73, 11, 74, 12, 75, 13, 76, 14, 77, 15, 78, 16, 79, 17, 80, 18, 81, 19, 82, 20, 83, 21, 84, 22, 85, 23, 86, 24, 87, 25, 88, 26, 89, 27, 90, 28, 92, 29, 93, 30, 94, 31, 95, 32, 96, 33, 97, 34, 98, 35, 99, 36, 100, 37, 101, 38, 102, 39, 103, 40, 104, 41, 105, 42, 106, 43, 107, 44, 108, 45, 109, 46, 110, 47, 111, 48, 112, 49, 113, 50, 114, 51, 115, 52, 116, 53, 117, 54, 118, 55, 119, 56, 120, 57, 121, 58, 122, 59)
  #let iterround-permut = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123)
  #figure(
    h(1fr) + draw-gasoline.permutation-matrix(iterround-permut) + h(2fr) + draw-gasoline.permutation-matrix(opt-permut) + h(1fr),
    caption: [The permutation-matrices for $π_IterRound$ (left) and some $π_Opt$ (right).],
  )<permutation-matrices-weak>
  #let best-row-values = (34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 125, 125, 125)
  #figure(
    lq.diagram(width: 400pt, height: 150pt, yaxis: (lim: (0, auto)), lq.plot(color: green, range(best-row-values.len()), best-row-values), xlabel: $ColumnIndex$, ylabel: $BestRowValue$),
    caption: [The progression of $BestRowValue$ during @alg-iterative-rounding for this instance.],
  ) <best-row-value-progression-weak>
  The first component is shown in #Blue[blue], the second in #Purple[purple], and the third one in #Red[red].
  #figure(
    draw-gasoline.draw-permutation(iterround-permut, deliveries, production, lq: true, y-axis-lim: 64),
    gap: 1em,
    caption: [Visualising the "warehouse" for $π_IterRound$ over time.\ The maximum capacity is $62+32+31=125$.],
  )
  #figure(
    draw-gasoline.draw-permutation(opt-permut, deliveries, production, lq: true, y-axis-lim: 64),
    gap: 1em,
    caption: [Visualising the "warehouse" for some $π_Opt$ over time.\ The maximum capacity is $32+2+2=36$.],
  )
  Here, $IterRound(I)/Opt(I) = 125/36 ≈ 3.47$. This shows $ρ_IterRound^((3)) ≥ 3.46$, disproving one the conjecture of @rajkovic[p:] that $ρ_IterRound^((d))=2$ for $d>2$.
]<example-plot-gasoline-funsearch-weak>

@Lorieau[p:Section 2.3.3] already attempted to disprove this conjecture using local search, but was unsuccessful. In our experiments with local search, we were also unable to find instances with $IterRound(I)/Opt(I) > 2$ when starting from a _random instance_. However, when starting local search from the instance in @example-plot-gasoline-lucas instead -- $k=4$, embedded into $ℝ^2$ in the canonical way -- we _did_ find instances with $IterRound(I)/Opt(I) = 2.1$. However, we were unable to generalise these instances to higher dimensions nor spot any patterns (as described for the FunSearch instance below in @sec-empirical-data-gasoline).

#example[
  We plot solutions for #gasoline-strong with $d=3$ and $k=5$ in the same way as @example-plot-gasoline-funsearch-weak.

  #let deliveries = ((16, 4, 0), (16, 0, 4), (16, 4, 0), (16, 0, 4), (24, 4, 0), (24, 0, 4), (24, 4, 0), (24, 0, 4), (24, 4, 0), (24, 0, 4), (24, 4, 0), (24, 0, 4), (28, 4, 0), (28, 0, 4), (28, 4, 0), (28, 0, 4), (28, 4, 0), (28, 0, 4), (28, 4, 0), (28, 0, 4), (28, 4, 0), (28, 0, 4), (28, 4, 0), (28, 0, 4), (28, 4, 0), (28, 0, 4), (28, 4, 0), (28, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (30, 4, 0), (30, 0, 4), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (0, 4, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (32, 0, 0), (0, 0, 4))
  #let production = ((16, 2, 0), (16, 0, 2), (16, 2, 0), (16, 0, 2), (24, 2, 0), (24, 0, 2), (24, 2, 0), (24, 0, 2), (24, 2, 0), (24, 0, 2), (24, 2, 0), (24, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (28, 2, 0), (28, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (30, 2, 0), (30, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2), (31, 2, 0), (31, 0, 2))
  #let opt-permut = (60, 91, 61, 123, 62, 0, 63, 1, 64, 2, 65, 3, 66, 4, 67, 5, 68, 6, 69, 7, 70, 8, 71, 9, 72, 10, 73, 11, 74, 12, 75, 13, 76, 14, 77, 15, 78, 16, 79, 17, 80, 18, 81, 19, 82, 20, 83, 21, 84, 22, 85, 23, 86, 24, 87, 25, 88, 26, 89, 27, 90, 28, 92, 29, 93, 30, 94, 31, 95, 32, 96, 33, 97, 34, 98, 35, 99, 36, 100, 37, 101, 38, 102, 39, 103, 40, 104, 41, 105, 42, 106, 43, 107, 44, 108, 45, 109, 46, 110, 47, 111, 48, 112, 49, 113, 50, 114, 51, 115, 52, 116, 53, 117, 54, 118, 55, 119, 56, 120, 57, 121, 58, 122, 59)
  #let iterround-permut = (60, 1, 0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123)
  #figure(
    h(1fr) + draw-gasoline.permutation-matrix(iterround-permut) + h(2fr) + draw-gasoline.permutation-matrix(opt-permut) + h(1fr),
    caption: [The permutation-matrices for $π_IterRound$ (left) and some $π_Opt$ (right).],
  )<permutation-matrices-strong>
  #let iterround-values = (36, 38, 40, 42, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88, 90, 92, 94, 96, 98, 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138, 140, 142, 144, 146, 148, 150, 152, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 184, 186, 186, 186)
  #figure(
    lq.diagram(width: 400pt, height: 150pt, yaxis: (lim: (0, auto)), lq.plot(color: green, range(iterround-values.len()), iterround-values)),
    caption: [The progression of $BestRowValue$ during @alg-iterative-rounding for this instance.],
  ) <best-row-value-progression-strong>
  #figure(
    draw-gasoline.draw-permutation(iterround-permut, deliveries, production, lq: true, y-axis-lim: 64),
    gap: 1em,
    caption: [Visualising the "warehouse" for  $π_IterRound$ over time.\ The maximum capacity is $62+62+62=186$.],
  )
  #figure(
    draw-gasoline.draw-permutation(opt-permut, deliveries, production, lq: true, y-axis-lim: 64),
    gap: 1em,
    caption: [Visualising the "warehouse" for $π_Opt$ over time.\ The maximum capacity is $32+4+4=40$.],
  )
  Here, $IterRound(I)\/Opt(I) = 186\/40 = 4.65$, which shows $ρ_IterRound^((3)) ≥ 4.65$.
]<example-plot-gasoline-funsearch-strong>

Despite the instance being similar, the proof used by @Lorieau[p:] to show $ρ^((1))_IterRound ≥ 2$ does not work here. It relied on using the same optimal solution for $LP'$ for all iterations during the first half of the algorithm. This can not apply to #gasoline-weak or #gasoline-strong: Compare @best-row-value-progression-lucas to @best-row-value-progression-weak and @best-row-value-progression-strong. In @Lorieau[p:]'s instance, the $BestRowValue$ is constant at first (this is necessary, as the same optimal solution can be used for the different $LP'$). However, for #gasoline-weak and #gasoline-strong, the $BestRowValue$ inrceases immediately, meaning the optimum for $LP'$ must keep changing for the first half of the algorithm. If we wanted to prove asymptotic bounds for either instance, our next step would be to prove properties of optimal $LP'$-solutions at each iteration of the first half of @alg-iterative-rounding. Proving optimality of these $LP'$-solutions would also be more difficult, as we can't use the same argument as @Lorieau[p:] did, and the dual LP is unwieldy.


Lastly, we also show traces in phase-space (like in @example-cookies-phase-space for @example-gasoline-cookies) for specific $2$-dimensional instances.
#{
  let deliveries = ((16, 2), (16, 2), (24, 2), (24, 2), (24, 2), (24, 2), (28, 2), (28, 2), (28, 2), (28, 2), (28, 2), (28, 2), (28, 2), (28, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (0, 2))
  let production = ((16, 1), (16, 1), (24, 1), (24, 1), (24, 1), (24, 1), (28, 1), (28, 1), (28, 1), (28, 1), (28, 1), (28, 1), (28, 1), (28, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (30, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1), (31, 1))
  let opt-permut = (46, 61, 45, 0, 58, 1, 30, 2, 57, 4, 44, 3, 53, 5, 47, 11, 42, 9, 40, 10, 32, 13, 56, 8, 59, 7, 54, 6, 51, 12, 35, 20, 39, 15, 50, 27, 38, 17, 43, 29, 55, 21, 36, 25, 33, 19, 31, 14, 49, 18, 48, 28, 34, 26, 52, 24, 37, 22, 41, 16, 60, 23)
  let iterround-permut = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 61, 60)

  figure(
    h(1fr) + draw-gasoline.trace-permutation(iterround-permut, deliveries, production, green, (-7, 70), (-7, 70), false) + h(2fr) + draw-gasoline.trace-permutation(opt-permut, deliveries, production, blue, (-7, 70), (-7, 70), false) + h(1fr),
    caption: [Tracing $π_IterRound$ (left) and $π_Opt$ (right) in phase-space, for #gasoline-weak with $d=2$ and $k=5$.],
  )
}
#{
  let deliveries = ((16, 4), (16, 4), (24, 4), (24, 4), (24, 4), (24, 4), (28, 4), (28, 4), (28, 4), (28, 4), (28, 4), (28, 4), (28, 4), (28, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (30, 4), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (32, 0), (0, 4))
  let production = ((16, 2), (16, 2), (24, 2), (24, 2), (24, 2), (24, 2), (28, 2), (28, 2), (28, 2), (28, 2), (28, 2), (28, 2), (28, 2), (28, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (30, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2), (31, 2))
  let opt-permut = (32, 61, 52, 1, 57, 0, 34, 3, 30, 5, 44, 4, 56, 2, 48, 13, 42, 7, 60, 12, 35, 6, 58, 9, 50, 10, 36, 8, 46, 11, 51, 22, 55, 26, 37, 18, 45, 14, 53, 23, 40, 29, 43, 16, 59, 21, 47, 24, 54, 28, 38, 17, 39, 20, 31, 15, 49, 25, 33, 27, 41, 19)
  let iterround-permut = (0, 30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 61, 60)

  figure(
    h(1fr) + draw-gasoline.trace-permutation(iterround-permut, deliveries, production, green, (-7, 70), (-7, 70), false) + h(2fr) + draw-gasoline.trace-permutation(opt-permut, deliveries, production, blue, (-7, 70), (-7, 70), false) + h(1fr),
    caption: [Tracing $π_IterRound$ (left) and $π_Opt$ (right) in phase-space, for #gasoline-strong with $d=2$ and $k=5$.],
  )
}

== Empirical Data <sec-empirical-data-gasoline>
While we could not _prove_ asymptotic results, plotting the values $Opt$ and $IterRound$ against the _size of the instances_ showed perfectly straight lines, except for $d=5$, where the case $k=2$ broke linearity for $IterRound$, the actual values being $20$ and $24$, respectively. Calculating $IterRound$ and $Opt$ for larger instances is computationally prohibitive. If these linear relationships held true asymptotically, we would obtain respective bounds on $ρ_IterRound^((d))$, as noted below.

#let gasoline-plots = file => {
  let data = json(file)
  let colormap = (green, blue)

  let simplify(x, n: 1, times-n: false) = {
    // We want to typeset fractions nicely, but doing so is _really_ hard.
    // Next time, better just hardcode the sixteen numbers you care about.
    if calc.abs(calc.round(x * n) - (x * n)) < 0.00001 {
      if n != 1 {
        if times-n {
          if (x * n) == 1 {
            $n \/ #n$
          } else {
            $#(x * n) n \/ #n$
          }
        } else {
          if x == 0 {
            $$
          } else if x > 0 {
            $+#(x * n) \/ #n$
          } else {
            $#(x * n) \/ #n$
          }
        }
      } else {
        if times-n {
          if x == 1 {
            $n$
          } else {
            $#x n$
          }
        } else {
          if x == 0 {
            $$
          } else if x > 0 {
            $+#x$
          } else {
            $#x$
          }
        }
      }
    } else {
      simplify(x, n: n + 1, times-n: times-n)
    }
  }

  let maxlengths = calc.max(..data.values().map(v => calc.max(..v.at("lengths")))) * 1.05
  let maxscore = calc.max(..data.values().map(v => calc.max(..v.at("apx")))) + 20

  data
    .keys()
    .map(d => {
      let D = data.at(d)

      let apx-slope = (D.at("apx").at(-1) - D.at("apx").at(-2)) / (D.at("lengths").at(-1) - D.at("lengths").at(-2))
      let apx-intercept = D.at("apx").at(0) - apx-slope * D.at("lengths").at(0)

      let opt-slope = (D.at("opt").at(-1) - D.at("opt").at(-2)) / (D.at("lengths").at(-1) - D.at("lengths").at(-2))
      let opt-intercept = D.at("opt").at(0) - opt-slope * D.at("lengths").at(0)

      set text(.8em)
      show lq.selector(lq.legend): set grid(gutter: 0pt)

      figure(
        lq.diagram(
          ylabel: [Value],
          xlabel: [Length of $X$],
          width: 7cm,
          xaxis: (lim: (0, maxlengths)),
          yaxis: (lim: (0, maxscore)),
          legend: (position: top + left),
          cycle: colormap,
          lq.plot(D.at("lengths"), D.at("apx"), mark: ".", label: [Iterative Rounding]),
          lq.plot(D.at("lengths"), D.at("opt"), mark: "x", label: [Optimal Value]),
          ..D
            .at("lengths")
            .zip(D.at("apx"))
            .enumerate()
            .map(vs => {
              let k = vs.at(0) + 2
              let x = vs.at(1).at(0)
              let y = vs.at(1).at(1)
              lq.place(x, y + 9, text(0.8em)[$k"="#k$])
            }),
        ),
        caption: [For $d=#d$, #if d == "5" [ignoring $k=2$,] $IterRound ∼ #simplify(apx-slope, times-n: true) #simplify(apx-intercept)$ and $Opt ∼ #simplify(opt-slope, times-n: true) #simplify(opt-intercept)$. If true asymptotically, it would imply $ρ^((#d))_IterRound ≥ #(calc.round(1000000 * apx-slope / opt-slope) / 1000000)$.],
      )
    })
}
#subpar.grid(
  columns: (1fr, 1fr),
  ..gasoline-plots("data/gasoline-empirical-values-weak.json"),
  gap: 1.5em,
  caption: [Optimal values and $IterRound$-values on #gasoline-weak for different choices of $d$ and $k$  (starting at $k=2$) plotted against the length $n≔|X|$, along with linear extrapolations. The asymptotic bounds empirically follow a pattern of $ρ_IterRound^((d)) ≥ d+1$.]
)

#subpar.grid(
  columns: (1fr, 1fr),
  ..gasoline-plots("data/gasoline-empirical-values-strong.json"),
  gap: 1.5em,
  caption: [Optimal values and $IterRound$-values on #gasoline-strong for different choices of $d$ and $k$ (starting at $k=2$) plotted against the length $n≔|X|$, along with linear extrapolations. The asymptotic bounds empirically follow a pattern of $ρ_IterRound^((d)) ≥ 2d$.]
)

As mentioned, #gasoline-strong is the same as #gasoline-weak scaled by the diagonal-matrix $op("diag")(1,2,…,2)$, which raises the question: What is the behaviour for diagonal values other than $2$? For some rational $p\/q≕α∈Q_(≥0)$, define $I_α$ as #gasoline-weak scaled by $op("diag")(q,p,…,p)$ (scaling by $op("diag")(1,α,…,α)$ would lead to an equivalent instance, but $X$ and $Y$ were required to be integral in the problem-statement).

#{
  let data = csv("data/gasoline-α-d=3-k=3.csv")
  figure(
    lq.diagram(
      width: 100%,
      height: 150pt,
      yaxis: (lim: (1, auto)),
      ylabel: $IterRound(I_α)\/Opt(I_α)$,
      xlabel: $α$,
      lq.scatter(
        data.map(x => float(x.at(0))),
        data.map(x => float(x.at(1))),
        mark: ",",
        color: (data.map(x => if x.at(2) == "True" { blue } else { red })),
      ),
    ),
    caption: [Scores of $I_α$ for different choices of $α ∈ {z/100 mid(|) z∈ℤ}$, with $d=k=3$. A point is coloured #Blue[blue] iff the permutation $π_IterRound$ found by @alg-iterative-rounding is the identity (for the shown $α$, this happens iff $α≤1.0$).],
  )
}

This is weak evidence for $I_2 = #gasoline-strong$ being best-possible among all $I_α$, and $I_1=#gasoline-weak$ being best-possible among those $I_α$ where the output of @alg-iterative-rounding has simple structure.


#TODO[Grammar-/ Spell Checker]

#bibliography("bibliography.bib", style: "chicago-author-date")
