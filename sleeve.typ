// ---- Parameters -------------------------------------------------------------
#let arg(key, default) = sys.inputs.at(key, default: default)
#let arg-mm(key, default) = float(arg(key, str(default))) * 1mm

#let name = arg("name", "Generic A5")
#let note-msg = arg("note", none) // optional extra line for the note
#let cover-w = arg-mm("cover-w", 148) // book cover width
#let height = arg-mm("height", 210) // book height = sleeve height
#let spine = arg-mm("spine", 10) // spine width (book thickness + ease)
#let flap = arg-mm("flap", 40) // part tucked inside the cover
#let ease-flap = arg-mm("ease-flap", 1) // extra width for the flap fold
#let ease-spine = arg-mm("ease-spine", 1) // extra width for the spine fold

#let side = cover-w + ease-flap + ease-spine  // part lying on front/back cover

#let gap = 1mm // gap between cut edge and outside marks
#let len = 5mm // length of outside marks

#let cut-stroke = 0.1pt + luma(180)
#let fold-stroke = (paint: luma(215), thickness: 0.1pt, dash: (0.8pt, 6pt))
#let mark-stroke = 0.15pt + luma(80)
#let field-stroke = 0.2pt + luma(140)

// ---- Derived geometry -------------------------------------------------------
#let width = 2 * flap + 2 * side + spine
#set page(paper: "a3", flipped: true, margin: 0pt)
#let x0 = (420mm - width) / 2
#let y0 = (297mm - height) / 2

// Fold positions, relative to the sleeve's left edge. Fold line is drawn
// in the middle of the specified ease band.
#let folds = (
  flap + ease-flap / 2,
  flap + side - ease-spine / 2,
  flap + side + spine + ease-spine / 2,
  flap + 2 * side + spine - ease-flap / 2,
)

#let line-at(x1, y1, x2, y2, stroke) = place(
  top + left,
  line(start: (x1, y1), end: (x2, y2), stroke: stroke),
)

#let fmt-mm(l) = str(calc.round(l / 1mm, digits: 2))

// ---- Cut border -------------------------------------------------------------
#place(top + left, dx: x0, dy: y0, rect(
  width: width,
  height: height,
  stroke: cut-stroke,
))

// Corner crop marks just outside the border.
#for (cx, sx) in ((x0, -1), (x0 + width, 1)) {
  for (cy, sy) in ((y0, -1), (y0 + height, 1)) {
    line-at(cx + sx * gap, cy, cx + sx * (gap + len), cy, mark-stroke)
    line-at(cx, cy + sy * gap, cx, cy + sy * (gap + len), mark-stroke)
  }
}

// ---- Fold guides ----------------------------------------------------------
#for f in folds {
  let x = x0 + f
  // Fine dashed line across the sleeve.
  line-at(x, y0, x, y0 + height, fold-stroke)
  // Ticks outside the border, so folds can be found from the cut edge.
  line-at(x, y0 - gap, x, y0 - gap - len, mark-stroke)
  line-at(x, y0 + height + gap, x, y0 + height + gap + len, mark-stroke)
}

// ---- Spine writing field --------------------------------------------------
// Segments: type | title.
// Fixed size, centred across the spine.

#let field-w = 7mm
#let field-top-bottom-margin = 6mm  // distance from top and bottom edges
#let field-len = height - 2 * field-top-bottom-margin
#assert(
  spine >= field-w + 1mm,
  message: "spine too narrow for spine field: "
    + fmt-mm(spine)
    + " mm spine does not fit "
    + fmt-mm(field-w)
    + " mm field with 0.5 mm margin on either side!",
)

#let segment(w, last: false) = box(
  width: w,
  height: field-w,
  stroke: (right: if last { none } else { field-stroke }),
)

#place(
  top + left,
  dx: x0 + flap + side + (spine - field-w) / 2,
  dy: y0 + field-top-bottom-margin,
  rotate(90deg, reflow: true, box(
    width: field-len,
    height: field-w,
    stroke: field-stroke,
    radius: 0.8mm,
    clip: true,
    stack(
      dir: ltr,
      segment(35mm),
      segment(field-len - 35mm, last: true),
    ),
  )),
)

// ---- Front title lines ------------------------------------------------------
#let title-lines = 4
#let title-width = 80mm
#let title-pitch = 9mm
#let title-top = 55mm  // first line, measured from the top edge

#let front-cx = x0 + flap + side + spine + side / 2
#let title-y0 = y0 + title-top

#for i in range(title-lines) {
  let y = title-y0 + i * title-pitch
  line-at(
    front-cx - title-width / 2,
    y,
    front-cx + title-width / 2,
    y,
    field-stroke,
  )
}

// ---- Note -------------------------------------------------------------------

#let note-gap = 3mm
#let note = text(size: 6pt, fill: luma(120), font: "Libertinus Serif")[
  #name ·
  cover #fmt-mm(cover-w) × #fmt-mm(height) mm ·
  spine #fmt-mm(spine) mm ·
  flap #fmt-mm(flap) mm ·
  ease-flap #fmt-mm(ease-flap) mm ·
  ease-spine #fmt-mm(ease-spine) mm ·
  sleeve #fmt-mm(width) × #fmt-mm(height) mm
  #if note-msg != none [ \ #note-msg ]
]

#let note-y = y0 + height + gap + len + note-gap

#place(top + left, dx: x0, dy: note-y, note)

// ---- Scale ruler ------------------------------------------------------------
// 20 cm ruler, right-aligned with the sleeve, to check the print was not
// scaled.

#let ruler-len = 200mm
#let ruler-x0 = x0 + width - ruler-len
#let ruler-label-y = note-y + 3.5mm
#let ruler-label(body) = text(
  size: 6pt,
  fill: luma(120),
  font: "Libertinus Serif",
  body,
)

#line-at(ruler-x0, note-y, ruler-x0 + ruler-len, note-y, mark-stroke)
#for i in range(21) {
  let x = ruler-x0 + i * 10mm
  let tick = if calc.rem(i, 10) == 0 { 3mm } else if calc.rem(i, 5) == 0 {
    2mm
  } else { 1.2mm }
  line-at(x, note-y, x, note-y + tick, mark-stroke)
  if calc.rem(i, 10) == 0 {
    place(top + left, dx: x - 10mm, dy: ruler-label-y, box(
      width: 20mm,
      align(center, ruler-label[#(i) cm]),
    ))
  }
}

// ---- Printable area check ---------------------------------------------------
// Everything printed (sleeve, outside marks, note, ruler) must fit inside A3
// landscape minus typical printer minimum margins.
#let print-margin = 5mm

#context {
  // Outermost printed extents on each side of the page.
  let left = x0 - gap - len
  let right = x0 + width + gap + len
  let top = y0 - gap - len
  let bottom = calc.max(
    note-y + measure(note).height,
    ruler-label-y + measure(ruler-label[0 cm]).height,
  )
  assert(
    left >= print-margin and right <= 420mm - print-margin,
    message: "sleeve too wide for A3: "
      + fmt-mm(right - left)
      + " mm incl. marks > "
      + fmt-mm(420mm - 2 * print-margin)
      + " mm printable, reduce flap",
  )
  assert(
    top >= print-margin and bottom <= 297mm - print-margin,
    message: "sleeve too tall for A3: marks/note extend beyond the "
      + fmt-mm(print-margin)
      + " mm printer margin",
  )
  assert(
    measure(note).width + 5mm <= width - ruler-len,
    message: "note overlaps scale ruler",
  )
}
