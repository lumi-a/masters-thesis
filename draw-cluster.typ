#let draw = (clustering, size, buff) => {
  let scale = (x, s) => (x.at(0) * s, x.at(1) * s)
  let add = (x, y) => (x.at(0) + y.at(0), x.at(1) + y.at(1))
  let norm = ortho => calc.sqrt(calc.pow(ortho.at(0), 2) + calc.pow(ortho.at(1), 2))

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

  box(width: size, height: size,
  points
    .map(p => place(dx: p.at(0) * size - point-radius, dy: p.at(1) * size - point-radius, circle(
      radius: point-radius,
      stroke: none,
      fill: black,
    ))).sum() + curve(
    curve.move(scale(draw-stops.at(0).at(1), size)),
    ..draw-stops
      .windows(2)
      .map(yx => {
        let old = yx.at(0).at(1)
        let p0 = yx.at(1).at(0)
        let p1 = yx.at(1).at(1)

        let diff = add(p0, scale(old, -1))
        let ortho = (-diff.at(1), diff.at(0))
        let control = scale(add(scale(add(p0, old), 0.5), scale(ortho, norm(ortho) / (3 * buff))), size)

        (curve.quad(control, scale(p0, size)), curve.line(scale(p1, size)))
      })
      .flatten(),
  ))
}
