#import "preamble.typ": *; #show: preamble
#import "draw-packing.typ"; #import "draw-knapsack.typ"; #import "draw-clustering.typ"; #import "draw-gasoline.typ"
#import "@preview/subpar:0.2.2"
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/lovelace:0.3.0": *;
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


#set heading(numbering: "1.1")

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

    caption: [All $2^6$ possible solutions to @knapsack-example. Solutions exceeding capacity $c=20$ are marked in purple. The optimum is circled in blue.\ Pareto-optimal solutions are marked by $#sym.star.filled$.],
  ) <fig-example-knapsack>
] <knapsack-example>

A *solution* is any sub-list of the list of items $I$, regardless of whether it exceeds the capacity $c$. For some solution $A$, we denote by $Weight(A)$ its total weight (i.e. the sum of the weights of the items in $A$), and by $Profit(A)$ its total profit. We can visualize the space of _all_ possible solutions -- including those that exceed the maximum weight capacity -- by plotting the tuple $(Weight(A), Profit(A))$.

=== Pareto-Sets

In practice, one might not know the capacity beforehand, or might have unlimited capacity but some tradeoff-function between weights and profits, for example $u(w, p) = p - w^2$. To cover all these cases simultaneously, we can narrow down the space by eliminating all solutions that can never be optimal. The set of those solutions is the _Pareto-set_: #TODO[Add citation]
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
See @fig-example-knapsack for an exmaple. There, the Pareto-set has size $15$, much smaller than $2^6$, the size of the entire solution-space. In fact, the Pareto-set is usually small in practice @moitraSmoothed @RoeglinBookChapter, hence one approach to finding an optimal solution is to compute the Pareto-Set $P(I)$ and finding a solution in $P(I)$ that maximizes the objective. If $P(I)$ has already been computed, a simple linear search yields an optimal solution in time $O(|P(I)|)$.

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

@alg-nemhauser-ullmann can be implemented to run in time $O(|P_1| + … + |P_n|)$ @RoeglinBookChapter. Intuitively, one might think that $P_(i-1)$ is always smaller than $P_i$, but this need not be the case:

#TODO[Maybe use an example where all pareto-sets are distinct, to actually use the implementation-runtime of nemhauser-ullmann]

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
    caption: [Drawing the solution-space for $I_(1:4)$ (left) and $I_(1:5)=I$ (right) respectively, by plotting $(Weight(A), Profit(A))$ for every solution $A$, with Pareto-optimal solutions marked by a star. The number of visible points is smaller than $2^4$ (respectively $2^5$) points, and the number of visible pareto-optimal solutions is smaller than $12$ (respectively $10$), because some pairs of different solutions share the same total weight and total profit. If only counting Pareto-optimal solutions with unique weight and profit, $I_(1:4)$ has $9$, whereas $I$ only has $8$.],
  )
]
Let $n ≔ |I|$ again. It had been unknown whether $|P_i|$ can be bounded by some $O(|P_n|)$, i.e. it had been unknown whether:
$
  Score(I)
  quad ≔ quad
  (|P_n|) / (max_(1≤i≤n) |P(I_(1:i))|)
$
can always be bounded by some constant not depending on $I$. If it could be bounded, @alg-nemhauser-ullmann would have a runtime bounded by $O(n⋅|P(I)|)$. Note that $Score(I) ≤ 2^n$, because $|P_i| ≤ 2^n$ and $|P_n| ≥ 1$.

So far, the instances with the highest score only achieved around $Score(I) ≈ 2$. Using FunSearch, we were able to find a sequence of instances with $Score(I) ≥ n^(O(√n))$, or more precisely: $Score(I) ≥ O((n\/2)^((sqrt(n\/2)-3)\/2))$. This disproves that @alg-nemhauser-ullmann runs in output-polynomial time.

#TODO[Insert link to proof-section]


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
- #TODO[Add more objectives, particularly ones with existing results on the PoH.]

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
  context [#figure(
      h(1fr) + draw-clustering.draw-clustering(points, kmedian, page.width * 0.3, 0.02, red) + h(1fr) + draw-clustering.draw-clustering(points, kmeans, page.width * 0.3, 0.02, blue) + h(1fr),
      caption: [Two different $k"="3$-clusterings for the same  $20$ points in $ℝ^2$.\ Left: An optimal $k$-median clustering. Right: An optimal $k$-means clustering. #TODO[Do two examples side by side, one optimal and one sub-optimal?]
      ],
    ) <clustering-example>
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

The structure of hierarchical clusterings is useful for, for example, taxonomy. It does come at a cost, however: Usually, the optimal $k$-clusterings need not have a nested structure, so there might not exist a hierarchical clustering $(H_1, …, H_n)$ such that every $H_i$ is an optimal $i$-clustering. The set of points in @example-hierarchical-clustering is such an example.

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
For a fixed cost-function $Cost$, we say that a hierarchical clustering on an instance $I$ is *optimal* if it has the lowest possible approximation-factor among all hierachical clusterings on $I$. The hierarchical clustering shown in @example-hierarchical-clustering is optimal, it was the output of a program written for finding optimal hierarchical clusterings. Any better hierarchical clustering would have to carry the restriction $H_2 = Opt_2$, but due to the requirement of nested clusterings, this means that (as visible in the figure), $H_3 ≠ Opt_3$.

The approximation-factor of the hierarchical clustering in @example-hierarchical-clustering is $≈1.262$: The hierarchical clusterings and optimal clusterings shown there only differ for $k=2$, where $Cost(H_2) = 1.78$ and $Cost(Opt_i) = 1.41$.

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
  (corporate warranted $x_1"+"…"+"x_7=y_1"+"…"+"y_7$), together with the following permutation of deliveries:
  $
    π(X) ≔ #draw-gasoline.typeset-permutation(iterative-rounding-permutation, deliveries).
  $
  The timeline of our warehouse can be visualised as follows: We use colored bars to represent the current amount of flour (blue) and sugar (purple) in our warehouse. Vectors preceded by "$arrow.t$" indicate deliveries to our warehouse, vectors preceded by "$arrow.b$" indicate us consuming ingredients from the warehouse to bake cookies. The two horizontal colored lines indicate the maximum number of the respective ingredient that the warehouse must store across the week. We choose the initial stocking of our warehouse _minimally_ such that we will always have enough ingredients to never run out (this choice is exactly $β$ from the above optimization problem). This ensures that our warehouse has the smallest possible size for this permutation, and that for both ingredients, there must be a day on which that ingredient's warehouse is fully depleted (otherwise our choice would not be minimal, we would have wasted space).
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

  With the $L_1$ cost-function used above, $π$ has a cost of $11+13=24$, whereas $π_Opt$ has a cost of $10+10=20$ and is indeed an optimal permutation for this instance.
]<example-gasoline-cookies>
Generally, an instance of the Gasoline-Problem #TODO[Explain why it's called that?]
consists of two sequences of $d$-dimensional vectors containing non-negative integral entries:
$
  X = (x_1,…,x_n) ∈ ℕ_(≥0)^(n×d), quad
  Y = (y_1,…,y_n) ∈ ℕ_(≥0)^(n×d),
$
who have the same total sum $x_1"+"…"+"x_n = y_1"+"…"+"y_n$. Our objective is to find a permutation $π ∈ S_n$ of the $X$-entries that minimises the prefix-sum discrepancy:
$
  min_(π in S_n) & quad ‖α-β‖_1 \
   "where"quad α & = min_(1≤k≤n)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^k y_i) ∈ ℤ^d \
               β & =max_(1≤k≤n)(sum_(i=1)^k x_(π(i)) - ∑_(i=1)^(k-1) y_i) ∈ℤ^d.
$
Even for $d=1$, this problem is NP-hard @Gasoline2018. Let $𝟙$ be a vector of appropriate dimensions whose entries only consist of $1$s. The problem can be written as an integer linear program (ILP) with a permutation-matrix $Z ∈ {0,1}^(d×d)$:
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
The objective "$‖α-β‖_1$" is the same as "$𝟙^T (β-α)$" as $β ≥ α$, and thus indeed linear. With this ILP, we can formulate the Iterative-Rounding algorithm:
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
        + Let $RowValue$ be the optimum value of the LP.
        + If $RowValue < BestRowValue$:
          + $BestRowIndex ≔ RowIndex$ and $BestRowValue ≔ RowValue$.
      + Add the constraint "$Z_(BestRowIndex,ColumnIndex) = 1$" to $LP$.
      + Remove $BestRowIndex$ from $UnfixedRows$.
    + $UnfixedRows$ is empty and $Z$ is fixed entirely.
  ],
) <alg-iterative-rounding>

#let IterRound = math.op("IterRound")

Let $ℐ_d$ be the set of all instances of the generalised gasoline-problem in $d$ dimensions. For some instance $I$, let $IterRound(I)$ be the value of the solution found by @alg-iterative-rounding, and let $Opt(I)$ be the value of an optimum solution. The *Approximation-Ratio* in $d$ dimensions of @alg-iterative-rounding is:
$
  ρ^((d))_IterRound
  ≔ sup_(I∈ℐ_d) IterRound(I)/Opt(I).
$
It holds that $ρ^((1))_IterRound ≤ ρ^((2))_IterRound ≤ …$, because embedding a $d$-dimensional instance into $ℝ^(d+1)$ in the obvious way yields a $(d+1)$-dimensional instance with the same $IterRound$- and $Opt$-values.

Though we will not prove this, the permutation $π$ in @example-gasoline-cookies is the output of @alg-iterative-rounding for that instance. There, $IterRound(I) = 24$, whereas $Opt(I) = 20$, which shows $ρ^((2))_IterRound ≥ 1.2$.


@Lorieau[p:] constructed a sequence of instances in $I_1, I_2, … ⊆ ℐ_1$ for which $IterRound(I_j)\/Opt(I_j)$ converged to a value of at least $2$, proving that $ρ^((1))_IterRound ≥ 2$. We will write out this construction in #TODO[Insert reference]
to show how we modified it.

@rajkovic[p:] conjectured that $ρ_(IterRound)^((1)) = 2$, and $ρ_(IterRound)^((d)) = 2$ for any $d > 1$. Though we will not make progress on the first conjecture, we did manage to disprove the second conjecture.



= FunSearch
Making progress on the different open problems in @section-problems-definitions involves a similar task for all of them: We would like to find instances that have a problem-specific undesirable quality.
- For bin-packing, we would like to find an instance where the randomised Best-Fit algorithm performs, in expectation, poorly compared to an optimum solution.
- For the Pareto-sets of knapsack-problems, we would like to find an instance $I$ where an intermittent Pareto-set $P(I_(1:i))$ is much larger than the Pareto-set $P(I)$ of the whole instance.
- For the Price of Hierarchy for $k$-median clustering, we would like to find instances whose Price of Hierarchy is large.
- For the generalised gasoline problem, we would like to find instances where the iterative-rounding algorithm #TODO[Insert reference once you write down the algorithm.]
  performs poorly compared to an optimum soution.


== Local Search
Even without having intuition for or experience with the different problems, we can still attempt to find such instances. A standard approach #TODO[Add many, many citations]
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

Variants of @algorithm-local-search-bin-packing include decreasing the mutation-rate over time, e.g. by decreasing the noise's variance in $Mutation$, or stochastically allowing to replace $I$ with $I'$, even if $I'$ has a worse score, to prevent getting stuck in local optima. See @local-search-plot for trajectories drawn from @algorithm-local-search-bin-packing.

#figure(
  {
    let trajectories = range(10).map(i => read("assets/data/randomised-best-fit-local-search/" + str(i) + ".log", encoding: "utf8").split("\n").map(line => line.split("\t")).filter(split => split.len() >= 2).map(split => (split.at(0), split.at(1)))).map(history => history + ((10000, history.last().at(1)),))
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

== Local Search on Code Instead of Vectors

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

#TODO[Describe FunSearch more. Concurrency, multiple programs in a prompt, islands, potential merging (though it didnt matter), favouring shorter programs in the prompt]

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

We used FunSearch to find "bad" instances for the four problems listed above. After FunSearch concluded, we manually searched through its output for promising code, manually tuned that code (e.g. by removing redundant items or making the instance more symmetrical, see #TODO[insert references to later tuning-figures])


#TODO[Describe the tuning of the instances more]

= Results
== Bin-Packing
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


== Gasoline
The following example is the instance found by @Lorieau[p:]:

#example[
  This is a $d"="1$-dimensional instance. Fix some $k∈ℕ$. For any $i$, define $u_i ≔ 2^k (1 - 2^(-i))$. Let $plus.circle$ denote list-concatenation, e.g. $[1,2] plus.circle [3,4] = [1,2,3,4]$. The $1$-dimensional instance found by @Lorieau[p:] can be written as follows:
  $
    X & = (plus.circle.big_(i = 1)^(k - 1) plus.circle.big_1^(2^i) [u_i]) plus.circle (plus.circle.big_1^(2^k - 1) [2^k]) plus.circle [0], quad quad
        Y & = plus.circle.big_(i = 1)^k plus.circle.big_1^(2^i) [u_i].
  $
  #let deliveries = ((4, 0), (4, 0), (6, 0), (6, 0), (6, 0), (6, 0), (8, 0), (8, 0), (8, 0), (8, 0), (8, 0), (8, 0), (8, 0), (0, 0)) // ((2, 0), (2, 0), (4, 0), (4, 0), (4, 0), (0, 0))
  #let production = ((4, 0), (4, 0), (6, 0), (6, 0), (6, 0), (6, 0), (7, 0), (7, 0), (7, 0), (7, 0), (7, 0), (7, 0), (7, 0), (7, 0)) // ((2, 0), (2, 0), (3, 0), (3, 0), (3, 0), (3, 0))
  For $k=3$, this amounts to:
  #let list = arr => $[#arr.map(x => str(x.at(0))).join(", ")]$
  $
    X = #list(deliveries), quad quad
    Y = #list(production)
  $
  #let opt-permut = (9, 13, 12, 1, 10, 0, 7, 5, 8, 3, 11, 4, 6, 2)
  #let iterround-permut = range(deliveries.len())

  #let list = arr => $[#arr.map(x => str(deliveries.at(x).at(0))).join(", ")]$
  The permutation found by @alg-iterative-rounding, and an optimal permutation, are as follows:
  $
    π_IterRound (X) = X & = #list(iterround-permut), quad quad \
              π_Opt (X) & = #list(opt-permut), quad quad
  $
  #let draw-vec = d => $#d.at(0)$
  We use the same visualisation as in @example-gasoline-cookies. Because $d=1$, we only draw one bar per time-point.
  #figure(
    draw-gasoline.draw-permutation(iterround-permut, deliveries, production, draw-vec: draw-vec, box-height: 0pt, one-d: true),
    gap: 1em,
    caption: [Visualising $π_IterRound$ over time. The maximum capacity is $14$.],
  )
  #h(1em)
  #figure(
    draw-gasoline.draw-permutation(opt-permut, deliveries, production, draw-vec: draw-vec, box-height: 0pt, one-d: true),
    gap: 1em,
    caption: [Visualising $π_Opt$ over time. The maximum capacity is $8$.],
  )
  Thus, $IterRound(I)\/Opt(I)$ for this instance $I$ is $14\/8 = 1.75$.
]<example-plot-gasoline-lucas>

In contrast, the FunSearch found the following two very similar instances. Fix the dimension $d ≥ 2$ and parameter $k$.
#math.equation(block: true, numbering: "(G1)")[$
  X & ≔ (plus.big.circle_(i=1)^(k-1) plus.big.circle_1^(2^i) plus.big.circle_(j=2)^d [u_i e_1 + 2e_j]) plus.circle (plus.big.circle_(j=2)^d (plus.big.circle_1^(2^k-1) [2^k e_1]) plus.circle[2 e_j]),quad
      Y & ≔ plus.big.circle_(i=1)^k plus.big.circle_1^(2^i) plus.big.circle_(j=2)^d [u_i e_1 + 2e_j]
          #h(2em)
$]<gasoline-weak>
#math.equation(block: true, numbering: "(G1)")[$
  X & ≔ (plus.big.circle_(i=1)^(k-1) plus.big.circle_1^(2^i) plus.big.circle_(j=2)^d [u_i e_1 + 4 e_j]) plus.circle (plus.big.circle_(j=2)^d (plus.big.circle_1^(2^k-1) [2^k e_1]) plus.circle[4 e_j]),quad
      Y & ≔ plus.big.circle_(i=1)^k plus.big.circle_1^(2^i) plus.big.circle_(j=2)^d [u_i e_1 + 2e_j]
          #h(2em)
$]<gasoline-strong>
The two instances only differ in three places: In the constant scalars preceding the $e_j$.

For both instances, the first entry of every vector is always the same as in @example-plot-gasoline-lucas, whereas the remaining entries only have values from ${0, 1, 2}$ (for @gasoline-weak #TODO[These references are weird, why don't they use the equation labels?]) or ${0,2,4}$ (for @gasoline-strong), regardless of the dimension $d$ and choice of $k$.

#example[
  #let deliveries = ((8, 2, 0), (8, 0, 2), (8, 2, 0), (8, 0, 2), (12, 2, 0), (12, 0, 2), (12, 2, 0), (12, 0, 2), (12, 2, 0), (12, 0, 2), (12, 2, 0), (12, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (0, 1, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (0, 0, 1))
  #let production = ((8, 1, 0), (8, 0, 1), (8, 1, 0), (8, 0, 1), (12, 1, 0), (12, 0, 1), (12, 1, 0), (12, 0, 1), (12, 1, 0), (12, 0, 1), (12, 1, 0), (12, 0, 1), (14, 1, 0), (14, 0, 1), (14, 1, 0), (14, 0, 1), (14, 1, 0), (14, 0, 1), (14, 1, 0), (14, 0, 1), (14, 1, 0), (14, 0, 1), (14, 1, 0), (14, 0, 1), (14, 1, 0), (14, 0, 1), (14, 1, 0), (14, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1), (15, 1, 0), (15, 0, 1))
  #let opt-permut = (40, 43, 53, 59, 29, 0, 41, 1, 55, 2, 45, 3, 42, 10, 57, 9, 54, 8, 48, 5, 51, 4, 33, 11, 50, 6, 56, 7, 38, 14, 39, 23, 36, 18, 47, 21, 44, 26, 46, 17, 30, 22, 32, 27, 49, 12, 28, 15, 37, 24, 34, 19, 52, 16, 31, 13, 35, 20, 58, 25)
  #let iterround-permut = (28, 43, 29, 59, 4, 5, 30, 0, 7, 31, 1, 6, 32, 8, 13, 33, 9, 12, 34, 10, 15, 35, 11, 14, 36, 16, 17, 18, 19, 20, 37, 21, 38, 22, 39, 23, 40, 24, 41, 25, 42, 26, 44, 27, 45, 46, 47, 48, 49, 50, 2, 51, 52, 53, 54, 55, 56, 3, 57, 58)
  /*
  #let breakjoin = arr => {
    let chunks = arr.chunks(calc.floor(arr.len() / 2))
    $#chunks.map(els => els.join(", ")).join($\ &$)$
  }
  #let list = arr => $[&#breakjoin(arr.map(x => $#math.vec(..x.map(str))$))]$
  For $d=2$ and $k=4$, the instance #TODO[insert reference to instance] is:
  #TODO[Does _anyone_ profit from seeing the specific instance and permutations??]
  #text(size: 0.5em)[$
    X = #list(deliveries) \
    Y = #list(production)
  $]
  #let list = arr => $[&#breakjoin(arr.map(x => $#math.vec(..deliveries.at(x).map(str))$))]$
  The permutation found by @alg-iterative-rounding, and an optimal permutation, are as follows:
  #text(size: 0.45em)[$
    π_IterRound (X) = #list(iterround-permut), quad quad \
    π_Opt (X) = #list(opt-permut), quad quad
  $]
  */
  We plot @gasoline-weak for $d=3$ and $k=4$. #TODO[If you want, there's commented-out code above for showing the explicit instance and permutations, but it's output is _large_ and I don't think it contributes much.] Plotting bar-charts with annotations about which elements got added / removed from our "warehouse" makes for too wide a plot, so we drop the annotations (they can be inferred from the permutations, if necessary) and use a regular line-chart instead. As in @example-gasoline-cookies, the first component is shown in #Blue[blue] and the second in #Purple[purple], while the third one is shown in #Red[red].
  #figure(
    draw-gasoline.draw-permutation(iterround-permut, deliveries, production, lq: true, y-axis-lim: 25),
    gap: 1em,
    caption: [Visualising $π_IterRound$ over time. The maximum capacity is $23+7+7 = 37$.],
  )
  #figure(
    draw-gasoline.draw-permutation(opt-permut, deliveries, production, lq: true, y-axis-lim: 25),
    gap: 1em,
    caption: [Visualising $π_Opt$ over time. The maximum capacity is $16+2+2=20$.],
  )
  Here, $IterRound(I)\/Opt(I) = 37\/20 = 1.85$.
]<example-plot-gasoline-funsearch-weak>
#example[
  #let deliveries = ((8, 4, 0), (8, 0, 4), (8, 4, 0), (8, 0, 4), (12, 4, 0), (12, 0, 4), (12, 4, 0), (12, 0, 4), (12, 4, 0), (12, 0, 4), (12, 4, 0), (12, 0, 4), (14, 4, 0), (14, 0, 4), (14, 4, 0), (14, 0, 4), (14, 4, 0), (14, 0, 4), (14, 4, 0), (14, 0, 4), (14, 4, 0), (14, 0, 4), (14, 4, 0), (14, 0, 4), (14, 4, 0), (14, 0, 4), (14, 4, 0), (14, 0, 4), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (0, 4, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (16, 0, 0), (0, 0, 4))
  #let production = ((8, 2, 0), (8, 0, 2), (8, 2, 0), (8, 0, 2), (12, 2, 0), (12, 0, 2), (12, 2, 0), (12, 0, 2), (12, 2, 0), (12, 0, 2), (12, 2, 0), (12, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (14, 2, 0), (14, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2), (15, 2, 0), (15, 0, 2))
  #let opt-permut = (41, 59, 34, 43, 38, 3, 46, 2, 57, 1, 49, 0, 36, 5, 37, 10, 42, 9, 31, 6, 51, 7, 28, 8, 40, 11, 58, 4, 29, 13, 32, 12, 35, 27, 47, 24, 30, 19, 53, 18, 44, 15, 56, 26, 39, 23, 55, 14, 54, 17, 50, 22, 33, 21, 45, 16, 48, 25, 52, 20)
  #let iterround-permut = (28, 1, 0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59)
  /*
  #let breakjoin = arr => {
    let chunks = arr.chunks(calc.floor(arr.len() / 2))
    $#chunks.map(els => els.join(", ")).join($\ &$)$
  }
  #let list = arr => $[&#breakjoin(arr.map(x => $#math.vec(..x.map(str))$))]$
  For $d=2$ and $k=4$, the instance #TODO[insert reference to instance] is:
  #TODO[Does _anyone_ profit from seeing the specific instance and permutations??]
  #text(size: 0.5em)[$
    X = #list(deliveries) \
    Y = #list(production)
  $]
  #let list = arr => $[&#breakjoin(arr.map(x => $#math.vec(..deliveries.at(x).map(str))$))]$
  The permutation found by @alg-iterative-rounding, and an optimal permutation, are as follows:
  #text(size: 0.45em)[$
    π_IterRound (X) = #list(iterround-permut), quad quad \
    π_Opt (X) = #list(opt-permut), quad quad
  $]
  */
  We plot @gasoline-strong for $d=3$ and $k=4$ in the same way as @example-plot-gasoline-funsearch-weak.
  #figure(
    draw-gasoline.draw-permutation(iterround-permut, deliveries, production, lq: true, y-axis-lim: 32),
    gap: 1em,
    caption: [Visualising $π_IterRound$ over time. The maximum capacity is $30+30+30=90$.],
  )
  #figure(
    draw-gasoline.draw-permutation(opt-permut, deliveries, production, lq: true, y-axis-lim: 32),
    gap: 1em,
    caption: [Visualising $π_Opt$ over time. The maximum capacity is $16+4+4=24$.],
  )
  Here, $IterRound(I)\/Opt(I) = 90\/24 = 3.75$.
]<example-plot-gasoline-funsearch-strong>
#TODO[Colourise all mentions of colours, so that color-blind readers may have an easier time inferring what colours are used (despite us using Paul Tol's CVD-respecting palette)]
#TODO[Grammar-/ Spell Checker]

#bibliography("bibliography.bib", style: "chicago-author-date")
