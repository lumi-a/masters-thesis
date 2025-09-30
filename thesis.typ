#import "preamble.typ": *; #show: preamble
#import "draw-packing.typ";

#show figure.caption: body => box(width: 75%, body)

= Problems and Definitions
== Bin-Packing
In the bin-packing problem, we are given a capacity $c$ and a finite list of non-negative real numbers $w_1, w_2, …$, each bounded by $c$. Our task is to find a _packing_, i.e. we must pack all items into bins of capacity $c$ such that each item is in exactly one bin and for all bins, the sum of its items must not exceed $c$.

#figure(
  draw-packing.packing(10, ((2, 3, 4), (7, 2), (6,), (5,))),
  caption: [A packing of the items $w_1, …, w_6 = 2,3,7,2,4,6,5$ into four bins with capacity $c=10$. This is the packing found by the Best-Fit heuristic.],
) <first-bin-packing-example>

Our objective is to use as few bins as possible. Finding a packing with the minimum number of bins is NP-hard @binPackingRevisited.

#figure(
  draw-packing.packing(10, ((2, 2, 6), (3, 7), (4, 5))),
  caption: [An optimal packing of the same items as in @first-bin-packing-example, using only three bins.],
)

In practice, heuristics are used

#bibliography("bibliography.bib")
