#let colors = ("#CC6677", "#332288", "#DDCC77", "#117733", "#88CCEE", "#882255", "#44AA99", "#999933", "#AA4499")

#let bin-width = 130pt / 2.3
#let bin-height = 150pt / 2
#let bin-spacing = 20pt / 2
#let inner-margin = 4pt / 2
#let draw-item = (capacity, item) => {
  if item > 0 {
    let color = if item == 0.25 {
      rgb(colors.at(0))
    } else {
      rgb(colors.at(calc.rem(int(item) + 5, colors.len()))).lighten(25%)
    }
    return rect(width: bin-width - 2 * inner-margin, height: (bin-height - 2 * inner-margin) * item / capacity - inner-margin, fill: color, radius: 1.25pt)[#align(center + horizon)[#item]]
  }
}
#let packing = (capacity, items) => {
  box(height: bin-height, width: (bin-width + bin-spacing) * items.len())[#{
    for (ix, bin) in items.enumerate() {
      let bin-x = ix * (bin-width + bin-spacing)
      place(dx: bin-x, rect(width: bin-width, height: bin-height, radius: 2.5pt))

      for (jx, item) in bin.enumerate() {
        let start = (1 - bin.slice(0, jx + 1).sum() / capacity) * (bin-height - 2 * inner-margin) + inner-margin
        place(dx: bin-x + inner-margin, dy: start + inner-margin / 2, draw-item(capacity, item))
      }
    }
  }]
}
