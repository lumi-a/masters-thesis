#import "preamble.typ": *; #show: preamble
#import "draw-packing.typ";
#import "draw-clustering.typ";
#import "@preview/subpar:0.2.2"
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/lovelace:0.3.0": *

#import "@preview/ctheorems:1.1.3": *; #show: thmrules.with(qed-symbol: $square$)
#let theorem = thmbox("theorem", "Theorem")
#let definition = thmbox("definition", "Definition", fill: red.lighten(87.5%))
#let example = thmbox("example", "Example", fill: green.lighten(87.5%))
#let proof = thmproof("proof", "Proof")


#set heading(numbering: "1.1")


= Problems, Definitions and Previous Results <section-problems-definitions>
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

  caption: [Different Packings for @bin-packing-example, with bins of capacity $10$.],
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

#let Cost = math.op("Cost")
#let Opt = math.op("Opt")
#let PoH = math.op("PoH")
#let Apx = math.op("Apx")

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
      draw-clustering.draw-clustering(points, kmedian, page.width * 0.4, 0.04, red) + h(1fr) + draw-clustering.draw-clustering(points, kmeans, page.width * 0.4, 0.04, blue),
      caption: [Two different $k"="3$-clusterings for the same  $20$ points in $ℝ^2$.\ Left: An optimal $k$-median clustering. Right: An optimal $k$-means clustering.
      ],
      // TODO: Do two examples side by side, one optimal and one sub-optimal
    ) <clustering-example>
  ]
}

When trying to cluster unlabeled data, we usually are not given a number $k$ of clusters to use. In such a scenario, we could use heuristics to determine a good choice of $k$ (see e.g. #cite(<stopUsingElbow>, form: "prose")). Alternatively, we could compute a _Hierarchical Clustering_, which is a sequence of nested $k$-clusterings for every choice of $k$ @priceOfHierarchicalClustering.

#definition[
  A *hierarchical clustering* on $n$ points is a sequence $(H_1, …, H_n)$ of clusterings such that:
  - $H_i$ is an $i$-clustering (i.e., it consists of $i$ clusters), for every $i=1,…,n$
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
    #figure(draw-clustering.draw-hierarchical-clustering(points, opt-hierarchical, page.width * 0.4, true) + h(1fr) + draw-clustering.draw-hierarchical-clustering(points, opt-optimal, page.width * 0.4, false), caption: [Left: An optimal hierarchical clustering on $6$ points for the $k$-median objective.\ Right: For each $k=1,...,6$, an optimal $k$-median clustering on the same $6$ points. These clusterings do not have a nested structure.])<example-hierarchical-clustering>
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

As a motivating example for the problem (similar to #cite(<Lorieau>, form: "prose")), we are in charge of a factory that produces cookies every day of the week. In doing so, it consumes exactly two ingredients: Flour and sugar. Each day of the week, both the amount of cookies and their sugar-content must follow a certain schedule. For instance, on Monday, we might be asked to use $vec("Flour", "Sugar")$-amounts equal to $y_1 = vec(3, 1)$ for our cookie-production, whereas each Tuesday, we must consume more and sweeter cookies, hence having to use $y_2 = vec(5, 5)$ amounts of flour and sugar. We can get flour and sugar delivered to our factory overnight, but we must pick these amounts from a list of seven possible delivery-trucks that are the same every week, but we can choose on which day of the week we would like to receive each truck. For instance, we can choose to have $x_1 = vec(4, 4)$ flour and sugar delivered to our factory, or $x_2 = vec(7, 10)$. Within a week, we can only order each delivery-truck exactly once, and we can only accept one delivery-truck per night because our driveway is too narrow. It's unlikely that we will be fortunate enough to have, for every demand-value $y_i$, a matching delivery-value $x_i$, so we must resort to storing leftover ingredients in our yet-to-be-built warehouse overnight.

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
        π(X) = #typeset-permutation(iterative-rounding-permutation).
      $
      The timeline of our warehouse can be visualised as follows: Green bars represent flour, purple bars represent sugar. Vectors preceded by "$arrow.t$" indicate deliveries, vectors preceded by "$arrow.b$" indicate us using ingredients from the warehouse to bake cookies. The two horizontal colored lines indicate the maximum number of that ingredient that the warehouse must store across the week. We choose the initial stocking of our warehouse minimally such that we will always have enough ingredients to never run out (this choice is exactly $β$ from the above optimization problem). This ensures that our warehouse has the smallest possible size for this permutation, and that for both ingredients, there must be a day on which that ingredient's warehouse is fully depleted (otherwise we would be wasting warehouse space).
      #figure(
        draw-permutation(iterative-rounding-permutation),
        kind: image,
        gap: 1.5em,
        caption: [The (cyclical) state of the warehouse across the week for permutation $π$.],
      )
      For this permutation, the warehouse must store a peak of $11$ flour on the night between Tuesday and Wednesday, and a peak of $13$ sugar on several nights between Tuesday and Thursday. There is a better permutation, though:
      $
        π_Opt (X) = #typeset-permutation(opt-permutation),
      $
      #figure(
        draw-permutation(opt-permutation),
        kind: image,
        gap: 1.5em,
        caption: [The (cyclical) state of the warehouse across the week for permutation $π_Opt$.],
      )
      Here, the peak necessary capacity for flour and sugar is both only $10$, meaning $π_Opt$ is a better choice than $π$, because both our flour-warehouse and our sugar-warehouse can be smaller.

      With the $L_1$ cost-function used above, $π$ has a cost of $11+13=24$, whereas $π_Opt$ has a cost of $10+10=20$, and is the best possible permutation of $S_7$ in this case.
    ]
  }
] // TODO: This example is long, but it doesn't seem to want to neatly break across pages?


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
#pseudocode-list[
  + Fix the size $n$ of an instance, e.g. $n=10$.
  + Define the $Score(I)$ of a bin-packing instance $I$:
    + Calculate the value $Opt$ of an optimum solution to $I$
    + Calculate 10000 trials of:
      + Let $I'$ be a random permutation of $I$
      + Run Best-Fit on $I'$
    + Let $Avg$ be the average number of bins used across these trials
    + Return $Avg \/Opt$
  + Define a $Mutation(I)$ of an instance $I$:
    + Define a new list of items $I'$ that arises from $I$ by adding independently standard-normally distributed noise to each entry.
    + Clamp the entries of $I'$ to be between $0$ and $1$.
    + Return $I'$.
  + Initialise $I$ as the list $[1/2, ..., 1/2]$ of length $n$.
  + Repeat the following until some stopping-criterion is met:
    + Calculate $I' = Mutation(I)$
    + If $Score(I') > Score(I)$:
      + Replace $I$ with $I'$
    + Otherwise:
      + Keep $I$ unchanged.
]
// Todo: Use some package for typesetting algorithms

// TODO: Add results of local search


#bibliography("bibliography.bib", style: "springer-mathphys")
