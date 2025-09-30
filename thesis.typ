#import "preamble.typ": *; #show: preamble
#import "draw-packing.typ";
#import "@preview/subpar:0.2.2"
#import "@preview/lemmify:0.1.8": *
#import "@preview/lilaq:0.5.0" as lq

#let (
  theorem,
  lemma,
  corollary,
  remark,
  proposition,
  example,
  proof,
  rules: thm-rules,
) = default-theorems("thm-group", lang: "en", thm-numbering: thm-numbering-linear)
#show: thm-rules

#set heading(numbering: "1.1")

#show figure.caption: body => box(width: 80%, body)

= Problems and Definitions
== Bin-Packing
In the bin-packing problem, we are given a capacity $c$ and a list of $n$ items with weights $w_1, …, w_n$, each bounded by $c$. Our task is to find a _packing_, i.e. we must pack all items into bins of capacity $c$ such that each item is in exactly one bin and for all bins, the sum of its items must not exceed $c$. Our objective is to use as few bins as possible. Finding a packing with the minimum number of bins is NP-hard @binPackingRevisited.

#example()[
  We have to assign the following six items to bins with capacity $c=10$:
  $
    w_1, …, w_6 quad=quad 4, 7, 2, 3, 4
  $
  An optimal packing is shown in @bin-packing-optimal.
]<bin-packing-example>

#subpar.grid(
  figure(
    draw-packing.packing(10, ((7, 2), (3, 4, 3))),
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
In the traditional Knapsack-Problem, we are given a capacity $c$ and a list of $n$ items, each having both a non-negative weight $w_i≤c$ and a non-negative profit $p_i$. Instead of minimising the number of bins we use, we are only allowed to use a single bin of capacity $c$ and the total weight of the items we put in this bin must not exceed $c$. Our objective is to _maximize_ the total profit of the items we put in the bin.

#let Weight = math.op("Weight")
#let Profit = math.op("Profit")

// TODO: This isn't numbered correctly, for some reason.
#example[
  We denote items by a column-vector $vec("Weight", "Profit")$. We are given a capacity $c=20$ and the following items:
  $
    vec(4, 9),quad vec(5, 1),quad vec(13, 14),quad vec(3, 8),quad vec(11, 4),quad vec(6, 14)
  $
  The optimal list of items to put into our bin is $[vec(4, 9), vec(5, 1), vec(3, 8), vec(6, 14)]$, with a total weight of $18$ and a total profit of $32$.
] <knapsack-example>

If $A$ is a subset of the items, we denote by $Weight(A)$ its total weight (i.e. the sum of the weights of the items in $A$), and by $Profit(A)$ its total profit. We can visualize the space of _all_ possible solutions -- including those that exceed the maximum weight capacity -- by plotting the tuple $(Weight(A), Profit(A))$ for all subsets $A$ of the items.

#figure(
  {
    let items = ((4, 9), (5, 1), (13, 14), (3, 8), (11, 4), (6, 14))
    let powerset = ((),)
    for item in items {
      for subset in powerset {
        let new_subset = subset + (item,)
        powerset.push(new_subset)
      }
    }
    lq.diagram(
      lq.scatter(
        powerset.map(items => items.map(x => x.at(0)).sum(default: 0)),
        powerset.map(items => items.map(x => x.at(1)).sum(default: 0)),
        color: powerset.map(items => if items.map(x => x.at(0)).sum(default: 0) <= 20 { green } else { red }),
      ),
      xlabel: [#text(font: font-math)[Total Weight]],
      ylabel: [#text(font: font-math)[Total Profit]],
      height: 25%,
      width: 50%,
    )
  },
  caption: [All $2^6$ possible solutions to @knapsack-example. Solutions not exceeding capacity $c=20$ are marked in green.],
)




#bibliography("bibliography.bib")
