# FIT-114 — Stage 1E visual experiment

Completed only in `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3` on
`isaac/sprint-3`, HEAD `a65bba5`. Production changes are confined to two files.

## Calorie flame

Reused the existing light `warmAccent` token, consumed only by the dashboard's
calorie icon, and restored its earlier rich amber/gold **#99640D**. No new palette
field was needed. Its base-tint contrast against representative near-white glass
`#F8F9FC` is approximately **4.77:1**, compared with **1.36:1** for the previous
`#FFD35B`; against white it is approximately **5.02:1**. The existing reflective
core and glow remain in place, so these ratios describe the base tint rather
than every illuminated pixel.

Icon shape, size and position are unchanged. The header streak stays `#FFAA58`.
The dark calorie flame and separate Meals flame remain `#FFD35B`. Other flames,
accent colors and highlighted dashboard icons are untouched.

## Exact dark active-navigation treatment

The original dark implementation is reused, with no new rendering approximation:

- Active Home: the same `Icons.home` glyph, 24px. Profile retains `Icons.person`;
  Meals and Groceries retain their original Material glyphs.
- Workout: the same `digigym_workout_icon.png`, width 38, proportional height,
  sharp filtering, source-in tint.
- Active tint: **#70FF45** from the existing dark palette.
- Glow: one same-glyph blurred copy at sigma **4**, opacity **.85**, behind the
  unchanged sharp foreground. There is no added spread or inset light core.
- Existing 44×32 slot, clipping, alpha edge fade (0/.22/.78/1), ignored pointer
  events and excluded glow semantics are retained.
- Active labels use the dark color, size 10, height 1.2, weight 600 and **no label
  shadow**. The explicit style matches dark mode.

The light widget selects dark active values locally and runs the existing dark
ImageFiltered branch for all five destinations. Global light green tokens stay
unchanged. Inactive light icons/labels retain `#626C66`. The light glass remains
`#6BF8F9FB`, blur sigma 16, white border `#EBFFFFFF` and the same shadow, rounded
corners, dimensions, spacing, safe area and navigation callbacks.

## Independent reversibility

- Calorie experiment: restore only light `warmAccent` to `#FFD35B`. This has no
  effect on active navigation, streak or Meals flames.
- Navigation experiment: set `useDarkActiveTreatmentInLight` to false (at the
  widget call site, or change its constructor default). This restores the prior
  light active tint, two halos, inset core and label shadows while leaving the
  calorie experiment and glass unchanged. The opt-out is covered by a test.

No product settings or preference/storage behavior were added or changed.

## Validation

- Formatting: all 7 affected Dart files checked; no outstanding format changes.
- `flutter analyze --no-pub lib test`: **no issues**.
- Focused navigation/theme/experiment suite: **25 passed**.
- Android/iOS visual/layout suite: **5 passed**.
- Full frontend suite: **405 passed, 2 skipped, 1 pre-existing failure** (previous
  accepted baseline: 401 passed, 2 skipped, the same failure).
- Real-font raster comparisons confirm the active icon subtree is **pixel-identical
  between dark and light for all five destinations on Android and iOS**, against
  a common backdrop. The actual two navbar backgrounds intentionally differ.
- Both full dark dashboard renders match the existing accepted references
  exactly. In light renders, every pixel outside the calorie-flame and selected
  icon/label regions matches the accepted typography-correction reference.
- Inactive styling, asset filtering, navigation state/tap dispatch, safe areas,
  narrow/wide layouts, enlarged text and responsive Android/iOS bounds pass.
- Theme switching, default Dark, persisted preference/restoration and live Follow
  System behavior pass in the full suite.
- Every existing golden remains byte-identical; four light experiment snapshots
  were added. No unrelated golden failure was accepted.
- Checkpoint hash audit confirms typography, background/card widgets, other icon
  rendering, BMI popup, streak, logo/assets, app wiring, appearance persistence,
  services/authentication and backend files are unchanged. The dark palette is
  byte-identical; the only palette edit is the scoped light amber.
- `git diff --check` passes. Branch/HEAD remain unchanged. No commit, merge, push,
  backend/database operation, emulator application startup or Stage 2 work occurred.

The existing failure remains `dashboard_theme_test.dart: narrow phones and enlarged
text stack and scroll without overflow`. Its live November clock conflicts with
a hardcoded October 31 key and throws `Bad state: No element`. No new failures remain.

## Modified files

- [lib/theme/digigym_dashboard_theme.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_dashboard_theme.dart) — Reuses the existing light warmAccent token for the calorie flame only; restores amber #99640D.
- [lib/widgets/floating_bottom_navigation_bar.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/floating_bottom_navigation_bar.dart) — Reuses the exact dark active rendering path locally in light mode, with an independent opt-out.
- [test/stage1e_experiment_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage1e_experiment_test.dart) — Four new tests covering amber contrast/scoping, flame geometry, pixel-identical active rendering for every destination on both platforms, and independent navigation opt-out.
- [test/floating_bottom_navigation_bar_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/floating_bottom_navigation_bar_test.dart) — Updated intentional active color/glow/label expectations; retained inactive, geometry, assets and interaction checks.
- [test/light_visual_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/light_visual_refinement_test.dart) — Updated the selected navigation expectation while retaining other icon/glass/typography protections.
- [test/stage1d_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage1d_refinement_test.dart) — Updates the light calorie token expectation; retains streak, green, type and frost protections.
- [test/theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/theme_visual_test.dart) — Freezes every pre-experiment pixel outside the calorie flame and active navigation regions; retains complete dark and typography references.
- [test/goldens/dashboard_sprint3_light_stage1e_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_stage1e_android.png) — New light experiment reference; existing golden files are untouched.
- [test/goldens/dashboard_sprint3_light_stage1e_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_stage1e_iOS.png) — New light experiment reference; existing golden files are untouched.
- [test/goldens/dashboard_sprint3_light_bmi_stage1e_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_stage1e_android.png) — New light experiment reference; existing golden files are untouched.
- [test/goldens/dashboard_sprint3_light_bmi_stage1e_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_stage1e_iOS.png) — New light experiment reference; existing golden files are untouched.
- [docs/sprint-3-theme-stage-1e.md](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/sprint-3-theme-stage-1e.md) — This report and rollback notes.

## Emulator review

Compare the richer calorie amber with the separate orange streak flame, and review
the electric-green active icon/label legibility and glow against silver glass as
content scrolls beneath it. The rendering treatment is exact; its perceived
contrast differs from the dark backdrop. Widget captures use the existing iOS
system-font aliases and do not replace live emulator review.

Stopped after Stage 1E for feedback. Stage 2 has not begun.
