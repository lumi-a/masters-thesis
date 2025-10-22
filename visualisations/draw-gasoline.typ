#import "@preview/lilaq:0.5.0" as lq
#import "@preview/tiptoe:0.3.1"

#let scale = (x, s) => x.map(r => r * s)
#let add = (x, y) => x.zip(y).map(v => v.at(0) + v.at(1))
#let min = (x, y) => x.zip(y).map(v => calc.min(v.at(0), v.at(1)))
#let max = (x, y) => x.zip(y).map(v => calc.max(v.at(0), v.at(1)))
#let sub = (x, y) => x.zip(y).map(v => v.at(0) - v.at(1))
#let norm = v => calc.sqrt(v.map(r => r * r).sum())
#let normed = v => scale(v, 1 / norm(v))

#let get-pds-timeline = (pi, deliveries, production) => {
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

  let dimension = deliveries.at(0).len()
  let timeline = production-deliveries.fold((range(dimension).map(_ => 0),), draw-state)
  (production-deliveries, timeline)
}

#let draw-permutation = (pi, deliveries, production, ..args) => {
  let heightscale = 0.25em
  let one-d = args.at("one-d", default: false)
  let barwidth = if (one-d) { 0.9em } else { 0.85em }
  let draw-vec = args.at("draw-vec", default: d => $vec(#[#d.at(0)], #[#d.at(1)])$)
  let box-height = args.at("box-height", default: 0.5em)
  let boxbuffer = if one-d { 1.5 } else { 3 }
  let dimension = deliveries.at(0).len()

  let (production-deliveries, timeline) = get-pds-timeline(pi, deliveries, production)

  let minhouse = timeline.fold(range(dimension).map(_ => 100000), min)
  let maxhouse = timeline.map(pd => sub(pd, minhouse)).fold(range(dimension).map(_ => -10000), max)
  let maxmaxhouse = calc.max(..maxhouse)

  if args.at("lq", default: false) {
    timeline = timeline.map(warehouse => sub(warehouse, minhouse))
    lq.diagram(
      width: 100%,
      height: args.at("diagram-height", default: 128pt),
      yaxis: (lim: (auto, args.at("y-axis-lim", default: auto))),
      xaxis: (ticks: none, lim: (-3, timeline.len() + 2)),
      ..range(timeline.at(0).len()).map(d => lq.plot(
        range(timeline.len()),
        timeline.map(warehouse => warehouse.at(d)),
        color: (blue, purple, red).at(d),
        // stroke: stroke((blue, purple, red).at(d).transparentize(25%)),
      )),
    )
  } else {
    let flourbar = warehouse => rect(fill: blue, stroke: barwidth * 0.1 + black, width: barwidth, height: sub(warehouse, minhouse).at(0) * heightscale)
    let sugarbar = warehouse => if one-d { [] } else { rect(fill: purple, stroke: barwidth * 0.1 + black, width: barwidth, height: sub(warehouse, minhouse).at(1) * heightscale) }
    let squares = timeline.map(warehouse => (flourbar(warehouse), sugarbar(warehouse), h(if one-d { (barwidth / 2) } else { barwidth }))).flatten()

    let line = (y, color) => place(dy: (maxmaxhouse - y) * heightscale, line(length: ((2 / 6) + production-deliveries.len()) * 2 * boxbuffer * barwidth, stroke: (paint: color, thickness: 0.1em)))


    align(left + bottom)[
      #line(maxhouse.at(0) + 0.15, blue)
      #if one-d [] else { line(maxhouse.at(1) - 0.15, purple) }
      #line(0, gray)
      #stack(dir: ltr, ..squares, [...])
    ]

    align(left + bottom, stack(dir: ltr, h(if one-d { barwidth / 2 } else { barwidth }), ..production-deliveries.map(pd => {
      let p = pd.at(0)
      let d = pd.at(1)
      [#box(width: barwidth * boxbuffer, height: box-height, align(center)[$arrow.t$#draw-vec(d)])#box(width: barwidth * boxbuffer, height: box-height, align(center)[$arrow.b$#draw-vec(p)])]
    })))

    if args.at("weekdays", default: false) {
      align(left + bottom, stack(dir: ltr, h(barwidth * 2.75), ..range(production-deliveries.len()).map(ix => { box(width: 2 * barwidth * boxbuffer, height: box-height, align(center)[#("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun").at(ix)]) })))
    }
  }
}

#let trace-permutation = (pi, deliveries, production, color, xlim, ylim, labels, ..args) => {
  let (_, timeline) = get-pds-timeline(pi, deliveries, production)
  let dimension = deliveries.at(0).len()
  let minhouse = timeline.fold(range(dimension).map(_ => 100000), min)
  let maxhouse = timeline.map(pd => sub(pd, minhouse)).fold(range(dimension).map(_ => -10000), max)

  timeline.push(timeline.at(0))

  lq.diagram(
    xaxis: (lim: xlim),
    width: if labels { 180pt } else { 222pt },
    height: if labels { 120pt } else { 150pt },
    ..if labels {
      (xlabel: [Flour], ylabel: [Sugar])
    } else {
      (:)
    },
    yaxis: (lim: ylim),
    ..timeline
      .windows(2)
      .map(start-stop => {
        let start = sub(start-stop.at(0), minhouse)
        let stop = sub(start-stop.at(1), minhouse)
        lq.line(start, stop, tip: tiptoe.triangle.with(length: 0.5em), stroke: color)
      }),
    lq.rect(
      0,
      0,
      width: maxhouse.at(0),
      height: maxhouse.at(1),
      stroke: stroke(paint: color.transparentize(50%), dash: "dashed"),
    ),
  )
}


#let typeset-permutation = (pi, deliveries) => [$[#pi.map(x => $vec(#[#deliveries.at(x).at(0)], #[#deliveries.at(x).at(1)])$).join(",")]$]

#let permutation-matrix = pi => {
  let cellwidth = 0.15em
  // We don't use a table here, way too many cells. We just colour the cells we care about⎵⎵.⎵⎵
  box(stroke: 0.1em + gray, outset: 0.05em, width: pi.len() * cellwidth, height: pi.len() * cellwidth, pi.enumerate().map(ix-x => place(dx: ix-x.at(0) * cellwidth, dy: ix-x.at(1) * cellwidth, square(fill: black, stroke: none, width: cellwidth))).sum())
}
