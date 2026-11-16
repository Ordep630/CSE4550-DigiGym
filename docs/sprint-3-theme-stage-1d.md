# FIT-114 — Stage 1D review

Completed exclusively in `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3` on
`isaac/sprint-3`, HEAD `a65bba5`. This report describes the increment against a
saved Stage 1C working-tree checkpoint. Prior uncommitted Sprint 3 work remains
preserved. No commit, merge, push, branch/history change, backend/database change,
authentication change, dependency change or expansion to other light screens occurred.

## Typography investigation

The bundled family is `DigiGymDoto`, using the unchanged
`assets/fonts/Doto-Variable.ttf`. Inspection of the actual font's `fvar` table
shows these axes:

| Axis | Minimum | Default | Maximum | Effect |
| --- | ---: | ---: | ---: | --- |
| `wght` | 100 | 900 | 900 | Enlarges/fullens existing dots as weight increases |
| `ROND` | 0 | 0 | 100 | Changes square dots toward rounded dots |

A real-font render at weights 100, 600, 840 and 900 with both ROND endpoints
confirmed those effects. The asset provides no dot-density axis or GSUB alternate
glyph configuration for selecting fewer dots. A heavier weight changes dot size,
not the underlying dot arrangement.

The original Workout “30 MIN” reference already used the intentional
`DotMatrixText` 5×7 round-dot painter at height 43.2px and fill `.74`, with a
separate Inter MIN label at 22px/weight 500. Earlier dashboard Doto font glyphs
had different topology/cap-height metrics; Stage 1C already standardized them on
that existing painter. Stage 1D tunes the existing shared configuration only.
No font replacement, new custom numeral renderer, glyph pattern, font asset,
new dependency, or handwritten shader was introduced.

## Exact typography adjustments

| Property | Stage 1C | Stage 1D |
| --- | --- | --- |
| Shared overall numeral scale | 1 | `.92` (8% smaller nominally) |
| Shared dot fill ratio | `.74` | `.88` |
| Nominal font-size → dot-height multiplier | `.9` | `.828` |
| Workout numeral height | 43.2px | 39.744px |
| Calendar paint height, dark | 48px | 44.16px within its original 48px slot |
| Calendar paint height, light | 50.88px | 46.8096px within its original slot |
| Progress | Existing fitted height | `.92` of that height within the original slot |
| Prominent light numeral ink | Near-black / calendar green | Pure `#000000` |

At an unfitted reference size, dot diameter increases by **7.18%** despite the
8% reduction in overall height. Dots retain a 12% pitch gap; the shared Workout
size has approximately 0.69 logical pixels of clear gap. Glyph count, softened
shapes, compact dotted percent, spacing formula, accessibility semantics, and
existing fitting behavior remain intact. Width fitting can moderate the apparent
size change for long values. Primary dark numerals retain `#F4F7F5`; the dark
calendar's existing accent-green date also remains unchanged in color.

Existing invisible Doto reference metrics preserve card line slots and intrinsic
layout. Inter units keep their existing font family, weight and nominal sizes,
and retain bottom alignment and gaps. Non-numeric typography is unchanged.

## Icon findings and illumination

Both themes already use the same icon sources and geometry: active Home is
`Icons.home` at 24px in both themes, and Workout navigation uses the same
`digigym_workout_icon.png` asset at width 38 with sharp filtering. No substitution
was necessary. Dark navigation uses a single sigma-4 blurred same-tint copy at
opacity `.85`, behind its sharp foreground. Dark icon wells, rim effects,
foreground tints and glow rendering paths remain unchanged.

Stage 1C's light copies were behind an opaque foreground, so they could brighten
only the surrounding halo. Stage 1D adds a **neutral inner light core above the
foreground**: the existing glyph alpha is copied, inset with Flutter's built-in
`ImageFilter.erode` at radius `.55`, recolored neutral white through `srcIn`, and
composited at opacity `.62` (scaled by existing per-icon intensity). This leaves
the green outer edges and the original sharp foreground intact. The same image
filter/layer pipeline supplies a tight sigma `.45` same-green halo and a softer
sigma `2.8` outer halo. Navigation's overall halo multiplier rises `.50 → .70`;
its existing edge fade and clipping remain in place. Decorative copies ignore
pointer events and semantics. Disabled glow intensity remains honored.

The actual source green values remain exact: accent and active navigation
`#237C47`, primary `#70FF45`, primary container `#E0F0E2`, on-primary-container
`#237C47`, progress track `#D4DDD5`. Neutral illumination intentionally increases
the rendered core luminance; it does not substitute a new green palette value.
The active Home glyph is the primary illuminated navigation element; inactive
icons and labels retain their existing treatment.

## Flames and navigation glass

Each light flame now matches its corresponding unchanged dark reference:

- Daily calorie target: `#FFD35B`, matching the existing Meals flame constant.
- Header streak: `#FFAA58`.

The two existing dark flame roles intentionally have different warm colors; both
light roles now match their own dark counterpart. Geometry, data and behavior
are unchanged.

Light navigation fill changes `#D9F8F9FB → #6BF8F9FB` (85.1% → 42.0% alpha),
retaining the same RGB. Backdrop blur changes sigma `14 → 16`. The white reflective
border `#EBFFFFFF`, shadow `#1A000000`/blur 18/offset (0,5), corner radius 48,
dimensions, placement, safe-area padding, icon spacing and tap behavior remain
unchanged. A rendered transmission test confirms over 45% of underlying contrast
survives the glass, including the shadow. Dark navigation remains unchanged.

## Protection and validation

- The light silver background, atmosphere, glass fill, glass lighting, glass edge
  and glass shadow definition block is byte-identical to Stage 1C.
- Card/background widget files and BMI dialog/material code are unchanged.
- Light Android/iOS pixel comparisons against retained Stage 1C captures have
  **zero changed pixels outside approved numeral, flame/icon illumination and
  navigation regions**. Layout bounds are exact. This protects the approved
  background, cards, labels, logo and composition.
- Dark Android/iOS comparisons have **zero changed pixels outside numeric
  display slots**. The entire dark palette block is byte-identical.
- All old goldens remain unchanged. Six separate Stage 1D goldens capture the
  approved changes; unrelated golden differences were not accepted.
- Formatting: all 15 affected Dart files checked; 0 further changes required.
- `flutter analyze --no-pub lib test`: **no issues**.
- Full frontend baseline: **396 passed, 2 skipped, 1 existing failure**.
- Full frontend after Stage 1D: **401 passed, 2 skipped, same 1 existing failure**.
- Final targeted suite: **23 passed** (new refinements, goldens/layouts,
  appearance settings, controller persistence/restoration/Follow System).
- Both Android/iOS layouts pass at 320×640, 390×844 and 426×952 through 1×–3× text
  scaling with long names and large numeric values. Workout units, card sizing
  and a three-digit duration remain bounded/aligned.
- Real Material Icon raster checks at 1× and 3× density confirm brighter pixels
  inside the glyph, preserved original green edges, and no filled bounding box.
- Theme switching, default Dark, persistence, restart restoration and live system
  brightness behavior pass. Preference/app wiring files are unchanged.
- Hash audit confirms backend files, assets/logo, services/authentication,
  persistence and prior reports/goldens remain unchanged. No database process or
  emulator application was started. `git diff --check` passes; branch/HEAD remain
  `isaac/sprint-3` / `a65bba5`.

The pre-existing failure remains
`dashboard_theme_test.dart: narrow phones and enlarged text stack and scroll without overflow`.
It uses the live November clock but searches for `month-day-2026-10-31`, throwing
`Bad state: No element`. This was reproduced before Stage 1D and left unchanged.
There are no newly introduced failures.

## Modified files

- [lib/theme/digigym_dot_typography.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_dot_typography.dart) — Shared 0.92 size scale and 0.88 dot fill ratio; unchanged 5×7 glyph topology.
- [lib/theme/digigym_dashboard_theme.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_dashboard_theme.dart) — Semantic numeral ink, inner-light core, navigation frost; matching light flame tints. Background/card definitions and dark palette unchanged.
- [lib/widgets/dashboard_number.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/dashboard_number.dart) — Black light numeral ink within unchanged reference line boxes; Inter units retained.
- [lib/widgets/segmented_progress_ring.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/segmented_progress_ring.dart) — Smaller, fuller black light digits inside the same ring/label slots.
- [lib/widgets/monthly_activity_calendar.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/monthly_activity_calendar.dart) — Smaller, fuller black light date; retained dark accent color and calendar layout.
- [lib/widgets/workout_overview.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_overview.dart) — Shared reduced numeral height and semantic ink; original line slot and MIN unit retained.
- [lib/widgets/soft_glow_icon.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/soft_glow_icon.dart) — Light-only inset neutral core above the unchanged green foreground; existing tight/outer halos and dark path retained.
- [lib/widgets/floating_bottom_navigation_bar.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/floating_bottom_navigation_bar.dart) — Light-only inset active-icon highlight, 42% glass fill and sigma-16 frost, unchanged geometry and interaction.
- [test/stage1d_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage1d_refinement_test.dart) — Five new checks for actual dot fullness/gaps, colors, black numeral rendering, glyph stroke pixels at 1×/3× density, and real backdrop transmission.
- [test/theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/theme_visual_test.dart) — New Stage 1D goldens; exact protection of Stage 1C light background/cards outside approved change regions; retained dark protection and responsive checks.
- [test/light_visual_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/light_visual_refinement_test.dart) — Approved shared size/fill and tighter light glow expectations.
- [test/dashboard_appearance_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/dashboard_appearance_test.dart) — Updated approved dot-fill expectation; retained card and unit metric checks.
- [test/floating_bottom_navigation_bar_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/floating_bottom_navigation_bar_test.dart) — Approved light blur and highlight-layer expectations; dark checks retained.
- [test/meals_groceries_screen_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/meals_groceries_screen_test.dart) — Updated shared prominent numeral dot fill; ordinary text and data assertions retained.
- [test/workouts_screen_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workouts_screen_test.dart) — Updated approved numeral height/fullness; retained MIN alignment, original card slot and accessibility checks.
- [test/goldens/dashboard_sprint3_dark_stage1d_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_dark_stage1d_android.png) — New Stage 1D reference; every pre-existing golden remains byte-identical.
- [test/goldens/dashboard_sprint3_dark_stage1d_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_dark_stage1d_iOS.png) — New Stage 1D reference; every pre-existing golden remains byte-identical.
- [test/goldens/dashboard_sprint3_light_stage1d_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_stage1d_android.png) — New Stage 1D reference; every pre-existing golden remains byte-identical.
- [test/goldens/dashboard_sprint3_light_stage1d_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_stage1d_iOS.png) — New Stage 1D reference; every pre-existing golden remains byte-identical.
- [test/goldens/dashboard_sprint3_light_bmi_stage1d_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_stage1d_android.png) — New Stage 1D reference; every pre-existing golden remains byte-identical.
- [test/goldens/dashboard_sprint3_light_bmi_stage1d_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_stage1d_iOS.png) — New Stage 1D reference; every pre-existing golden remains byte-identical.
- [docs/sprint-3-theme-stage-1d.md](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/sprint-3-theme-stage-1d.md) — This review report.

## Remaining emulator review

Review dot fullness at the Pixel's actual density, the inset light core on small
icons and the active Home icon, warm flame legibility, and scrolling content
transmission through the floating navigation. The added small-area core filter
also warrants normal emulator/device smoothness review. The green base remains
deeper than the dark theme's electric green by design; its perceived luminosity
varies with the bright silver backdrop and display brightness.

These are deterministic real-font Flutter widget renders. Native iOS font
substitution in the existing fixture and headless raster rendering remain the
visual-test limitations; no live emulator review was performed in this stage.
Stage 1D stops here for emulator feedback.
