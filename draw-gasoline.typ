#let scale = (x, s) => (x.at(0) * s, x.at(1) * s)
#let add = (x, y) => (x.at(0) + y.at(0), x.at(1) + y.at(1))
#let min = (x, y) => (calc.min(x.at(0), y.at(0)), calc.min(x.at(1), y.at(1)))
#let max = (x, y) => (calc.max(x.at(0), y.at(0)), calc.max(x.at(1), y.at(1)))
#let sub = (x, y) => (x.at(0) - y.at(0), x.at(1) - y.at(1))
#let norm = v => calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))
#let normed = v => scale(v, 1 / norm(v))
#let draw-permutation = (pi, deliveries, production) => {
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


#let typeset-permutation = (pi, deliveries) => [$[#pi.map(x => $vec(#[#deliveries.at(x).at(0)], #[#deliveries.at(x).at(1)])$).join(",")]$]
