#let draw = (clusterings, size, buff) => {
  let scale = (x, s) => (x.at(0) * s, x.at(1) * s)
  let add = (x, y) => (x.at(0) + y.at(0), x.at(1) + y.at(1))
  let norm = v => calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))
  let normed = v => scale(v, 1 / norm(v))

  let draw-cluster = (clustering, color) => {
    let centre = scale(clustering.fold((0, 0), add), 1 / clustering.len())
    let points = clustering.sorted(key: x => -calc.atan2(x.at(0) - centre.at(0), x.at(1) - centre.at(1)))
    points.push(points.at(0))

    let draw-stops = points
      .windows(2)
      .map(w => {
        let p0 = w.at(0)
        let p1 = w.at(1)
        let ortho = (p0.at(1) - p1.at(1), p1.at(0) - p0.at(0))
        let orthonorm = norm(ortho)
        let orthoscaled = scale(ortho, buff / orthonorm)

        (add(p0, orthoscaled), add(p1, orthoscaled))
      })

    draw-stops.push(draw-stops.at(0))
    let point-radius = 0.25em


    place(
      points
        .map(p => place(dx: p.at(0) * size - point-radius, dy: p.at(1) * size - point-radius, circle(
          radius: point-radius,
          stroke: none,
          fill: black,
        )))
        .sum()
        + curve(
          stroke: 0.1em + color,
          curve.move(scale(draw-stops.at(0).at(1), size)),
          ..draw-stops
            .windows(2)
            .map(yx => {
              let oldp0 = yx.at(0).at(0)
              let oldp1 = yx.at(0).at(1)
              let p0 = yx.at(1).at(0)
              let p1 = yx.at(1).at(1)

              let dist = norm(add(oldp1, scale(p0, -1)))
              let delta-old = normed(add(oldp1, scale(oldp0, -1)))
              let delta-new = normed(add(p0, scale(p1, -1)))
              let control0 = add(oldp1, scale(delta-old, dist / 2))
              let control1 = add(p0, scale(delta-new, dist / 2))

              (curve.cubic(scale(control0, size), scale(control1, size), scale(p0, size)), curve.line(scale(p1, size)))
            })
            .flatten(),
        ),
    )
  }

  let colors = (rgb("#47A"), rgb("#283"), rgb("#E67"), rgb("#CB4"), rgb("#A37"), rgb("#6CE"))
  box(width: size, height: size, clusterings.enumerate().map(indexed-clustering => place(draw-cluster(indexed-clustering.at(1), colors.at(calc.rem(indexed-clustering.at(0), colors.len()))))).sum())
}
