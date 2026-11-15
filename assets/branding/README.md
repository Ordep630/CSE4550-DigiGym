# DigiGym brand assets

The [editable master](digigym-master.svg) traces the 32 dumbbell tiles and seven
letter shapes from the [official artwork](../images/digigym_logo_official.png).
The path coordinates follow the visible edges, including the chamfers and the
cutouts in the D and lowercase g. Color stops come from the interior of the
original green tiles and letters.

Both arrangements use the same geometry and green fills. The stacked version
keeps the original icon-to-wordmark ratio and gap. Its Flutter widget occupies
the same space as the former stack. The horizontal version keeps the Home
header's 48 px icon, 10 px gap, and aligned wordmark. Light mode changes the
`Digi` fill from white to the approved `#18211D` charcoal.

The official source is a flattened raster. Exact vector coordinates and
pre-composite edge colors are unavailable. The trace approximates minor corner
details and the interior colors with sampled gradients. The diffuse illumination
on the original dark tile was omitted to keep the exports clean on either
background.

| Arrangement | Dark | Light |
| --- | --- | --- |
| Stacked for Login and shared forms | `digigym_stacked_dark.png` | `digigym_stacked_light.png` |
| Horizontal for Home | `digigym_horizontal_dark.png` | `digigym_horizontal_light.png` |

Each export has a 1×, 2×, and 3× PNG. Run
`swift tool/export_digigym_branding.swift` from the repository root on macOS to
rasterize the master through AppKit. Flutter uses its existing PNG decoder.

Light authentication forms use `digigym_stacked_light_form.png` at the same
three densities. Its narrow neutral shadows follow the dumbbell and green
`Gym` shapes. Three logical pixels of transparent padding leave room for the
shadows without changing the artwork fit. Run the exporter with
`--form-contrast` to regenerate just these variants from the approved stacked
PNGs.

[Before-and-after Android widget captures](../../docs/previews/digigym-logo-before-after.png)
show the four logo states at the same screen scale.

[Light form refinement preview](../../docs/previews/digigym-light-form-before-after.png)
shows the contrast treatment and the aligned focused Email border.
