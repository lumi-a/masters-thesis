#import "@preview/lilaq:0.5.0" as lq

#let powerset = items => {
  let p = ((0, 0),)
  for item in items {
    for subset in p {
      let new_subset = (subset.at(0) + item.at(0), subset.at(1) + item.at(1))
      p.push(new_subset)
    }
  }
  p
}
#let dominates = (a, b) => a.at(0) <= b.at(0) and a.at(1) >= b.at(1) and (a.at(0) < b.at(0) or a.at(1) > b.at(1))
#let xsys = items => (items.map(wp => wp.at(0)), items.map(wp => wp.at(1)))

#let draw = (items, subset-ix, color-full, color-partial) => {
  let p-full = powerset(items)
  let dominated-full = p-full.filter(wp => p-full.any(x => dominates(x, wp)))
  let undominated-full = p-full.filter(wp => p-full.all(x => not dominates(x, wp)))

  let p-partial = powerset(items.slice(0, subset-ix))
  let dominated-partial = p-partial.filter(wp => p-partial.any(x => dominates(x, wp)))
  let undominated-partial = p-partial.filter(wp => p-partial.all(x => not dominates(x, wp)))
  let marker-size = 32

  return (
    (
      lq.scatter(
        ..xsys(undominated-partial),
        color: color-partial,
        stroke: none,
        size: range(undominated-partial.len()).map(x => marker-size),
        mark: lq.marks.at("star"),
      ),
      lq.scatter(
        ..xsys(dominated-partial),
        stroke: none,
        color: color-partial,
        size: range(dominated-partial.len()).map(x => marker-size),
        mark: lq.marks.at("."),
      ),
    ),
    (
      lq.scatter(
        ..xsys(undominated-full),
        color: color-full,
        stroke: none,
        size: range(undominated-full.len()).map(x => marker-size),
        mark: lq.marks.at("star"),
      ),
      lq.scatter(
        ..xsys(dominated-full),
        color: color-full,
        stroke: none,
        size: range(dominated-full.len()).map(x => marker-size),
        mark: lq.marks.at("."),
      ),
    ),
  )
}
