#import "preamble.typ": *; #show: preamble
#import "draw-packing.typ";
#import "@preview/subpar:0.2.2"
#import "@preview/lemmify:0.1.8": *
#let (
  theorem,
  lemma,
  corollary,
  remark,
  proposition,
  example,
  proof,
  rules: thm-rules,
) = default-theorems("thm-group", lang: "en", thm-numbering: fig => thm-numbering-heading(fig, max-heading-level: 1))
#show: thm-rules

#set heading(numbering: "1.1")

#show figure.caption: body => box(width: 80%, body)

= Problems and Definitions
== Bin-Packing
In the bin-packing problem, we are given a capacity $c$ and a finite list of non-negative real numbers $w_1, w_2, …$, each bounded by $c$. Our task is to find a _packing_, i.e. we must pack all items into bins of capacity $c$ such that each item is in exactly one bin and for all bins, the sum of its items must not exceed $c$. Our objective is to use as few bins as possible. Finding a packing with the minimum number of bins is NP-hard @binPackingRevisited.

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

#bibliography("bibliography.bib")
