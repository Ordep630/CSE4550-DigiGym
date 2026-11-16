# FIT-114 — Stage 1C review

Completed exclusively in `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3` on
`isaac/sprint-3`, HEAD `a65bba5`. This report lists the Stage 1C increment against
the saved Stage 1B working-tree checkpoint, including prior uncommitted work.
No commit, merge, push, dependency change, backend/database operation, asset edit,
or expansion of light styling to additional screens was performed.

## Visual result

The light background keeps the existing layered implementation, with more visible
pearl-white upper lighting, cool silver through the middle, and deeper lower/edge
tones. All stops remain neutral, with a broad white atmospheric highlight rather
than green/mint lighting. Glass opacity is slightly lower, silver reflections show
through, and white edge highlights are stronger. Shadows, corner radii, padding,
card sizes and navigation geometry retain their existing values.

BMI uses an explicit preserved Stage 1B surface palette, edge, lighting and shadow.
Its opacity `.94`, local blur sigma `14`, content, actions and dimensions remain
unchanged. Whole-dashboard BMI snapshots reflect the changed background behind
the same material.

## Workout numeral inspection and shared standard

The reference “30 MIN” uses the **existing intentional `DotMatrixText` custom
painter**, not the Doto font. Numerals use a 5×7 lattice, softened digit corners,
round dots at fill ratio `.74`, and height `43.2` logical pixels (`48 × .9`) before
accessibility scaling. There is no font weight, font variation or font letter
spacing on these painted glyphs. Pitch is `height / (6 + .74)`; inter-glyph clear
spacing is `pitch × (2 - .74)`. The adjacent MIN label uses `DigiGymInter`, size
22, weight 500, height 1.2, a scaled 12px gap, and bottom alignment. The original
48sp paragraph slot remains `ceil(48 × 1.2)`.

The bundled Doto family remains `DigiGymDoto`, asset `assets/fonts/Doto-Variable.ttf`.
Its actual supported axes are `ROND` 0–100 (default 0) and `wght` 100–900 (default
900). The previous dashboard reference used weight 600 plus explicit `ROND=100`
and `wght=840` (880 for Stage 1B light). Its font glyph topology cannot exactly
reproduce the custom Workout reference through those axes alone.

`DigiGymDotTypography` and `DotMatrixText.standard` now share the existing Workout
renderer and `.74` round-dot geometry across both themes. Variants cover workout
43.2px, progress up to 44px, calendar 48px, and dashboard/other prominent numbers
at `.9 × nominal font size`, bounded by existing slots. Original Doto intrinsic
metrics preserve card layout; Inter units retain their family, weight, size and
theme color. Percent keeps the existing compact one-third-height dotted symbol.
Grouped calorie values support comma punctuation. Semantics expose the original
complete value. Width fitting and accessibility scaling remain active.

This reaches progress, calories, weight, BMI, monthly date, dashboard duration and
existing prominently dotted shared displays such as the Meals calorie target.
Workout already matches the standard and its reference appearance is retained.
Ordinary non-numeric typography and non-dotted meal values remain unchanged.
No new rendering system or font asset was introduced.

## Icon illumination and protected styling

The existing dark icon wells/rims and glyph shadows were inspected and retained.
Light illumination uses two copies of the actual icon alpha: a tight sigma `.65`
core (opacity `.75`) and a softer sigma `2.8` halo (opacity `.26`), followed by the
unchanged sharp foreground. Decorative copies cannot receive taps or duplicate
semantics. SoftGlowIcon retains its intensity control. Selected navigation keeps
its existing clipping, vertical edge fade and `.50` overall glow multiplier.
Highlighted icon badges and assigned/completed weekly icons reuse the same layers.
The light circular wash behind statistic icons is replaced by shape-following glow.

Exact existing light values are preserved: accent/selected navigation `#237C47`,
primary `#70FF45`, primary container `#E0F0E2`, on-primary-container `#237C47`,
progress track `#D4DDD5`, and branding ink `#18211D`. No logo widget or asset changed.
The dark surface-token block is byte-identical to the checkpoint.

Original Android/iOS dark golden files were retained, not rebased. A new test
compares every pixel outside the union of old/new numeric slots (1px antialiasing
margin) exactly to Stage 1B, and compares card/header/calendar/navigation bounds
exactly. Both platforms pass with **zero changed pixels outside numeric slots**.
Separate Stage 1C dark goldens record the approved current numerals.

## Validation

- Formatting: all 21 affected Dart files formatted; final check reports 0 changes.
- `flutter analyze --no-pub lib test`: no issues.
- `flutter test --no-pub`: **396 passed, 2 skipped, 1 pre-existing failure**.
- Before Stage 1C: 394 passed, 2 skipped, the same 1 pre-existing failure.
- All 5 visual tests pass: Android/iOS light and dark, light BMI snapshots, exact
  dark protection, and responsive geometry/paint containment at 320×640, 390×844,
  426×952 through 1×, 2× and 3× text scaling on both platforms, with long names,
  large weight/calorie/BMI values and a 125-minute workout.
- Theme switching, stored preference, restart restoration, default Dark and live
  Follow System behavior pass in the existing frontend tests. Preference code is
  byte-identical to the Stage 1B checkpoint.
- Existing failure: `dashboard_theme_test.dart` — “narrow phones and enlarged text
  stack and scroll without overflow”. Its live November clock conflicts with its
  hardcoded October 31 key and throws `Bad state: No element`. The same failure
  was reproduced before Stage 1C; its date defect remains unresolved. No new test
  failures remain and no unrelated golden failure was accepted.
- Initial expected golden differences were retained under ignored
  `build/stage1c-baseline/initial-diffs`; only intentional Stage 1C captures were
  updated. Original dark goldens remain unchanged.
- File hash audit: backend/configuration, assets, authentication/services, main
  application, appearance controller and appearance-settings code unchanged from
  Stage 1B. `git diff --check` passes; branch and HEAD unchanged.

## Modified files

- [lib/theme/digigym_dashboard_theme.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_dashboard_theme.dart) — Stronger neutral silver background and translucent light glass; centralized glyph-glow values; frozen Stage 1B BMI material.
- [lib/theme/digigym_dot_typography.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_dot_typography.dart) — New shared Workout-reference dot geometry and size variants.
- [lib/screens/dashboard_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/dashboard_screen.dart) — Use the shared numeric treatment for the dashboard workout duration.
- [lib/widgets/dashboard_number.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/dashboard_number.dart) — Reuse the existing dot painter, retain reference line metrics, Inter units, semantics, and width fitting.
- [lib/widgets/dot_matrix_text.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/dot_matrix_text.dart) — Shared standard constructor and grouped-number comma support; original constructor remains available.
- [lib/widgets/workout_overview.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_overview.dart) — Consume the shared standard; existing Workout numeral appearance retained.
- [lib/widgets/segmented_progress_ring.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/segmented_progress_ring.dart) — Shared round dots within the existing ring and label layout.
- [lib/widgets/monthly_activity_calendar.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/monthly_activity_calendar.dart) — Shared round-dot date styling within existing geometry.
- [lib/widgets/soft_glow_icon.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/soft_glow_icon.dart) — Light-only tight glyph core and secondary halo; unchanged dark rendering path.
- [lib/widgets/dashboard_glass_card.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/dashboard_glass_card.dart) — Apply light-only illumination to icon badges.
- [lib/widgets/floating_bottom_navigation_bar.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/floating_bottom_navigation_bar.dart) — Two light glyph-glow layers inside the existing clipped/faded selected-icon slot.
- [lib/widgets/weekly_workout_schedule.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/weekly_workout_schedule.dart) — Illuminate completed/assigned light icons; retain neutral and dark icons.
- [lib/widgets/digigym_dialog.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/digigym_dialog.dart) — Resolve BMI through its preserved Stage 1B surface material.
- [test/appearance_app_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/appearance_app_test.dart) — Verify painted numeric data alongside existing switching, persistence, restart and system-brightness coverage.
- [test/dashboard_appearance_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/dashboard_appearance_test.dart) — Shared numeral/unit metrics and unchanged Pixel geometry.
- [test/dashboard_theme_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/dashboard_theme_test.dart) — Assert original numeric component values after the rendering change; retain existing calendar failure.
- [test/floating_bottom_navigation_bar_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/floating_bottom_navigation_bar_test.dart) — Verify two light glow layers, unchanged dark layer and sharp foreground, selection and hit targets.
- [test/meals_groceries_screen_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/meals_groceries_screen_test.dart) — Verify the shared prominent dotted calorie target; ordinary meal typography stays unchanged.
- [test/segmented_progress_ring_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/segmented_progress_ring_test.dart) — Assert the unchanged imperial weight value through its numeric component.
- [test/light_visual_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/light_visual_refinement_test.dart) — Shared Workout geometry, grouped values, green guards, frozen BMI material, glow and disabled intensity.
- [test/theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/theme_visual_test.dart) — Current Android/iOS goldens, exact dark pixel protection outside numerals, and responsive bounds through 3x scaling.
- [test/fixtures/dashboard_stage1b_visual_regions.json](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/fixtures/dashboard_stage1b_visual_regions.json) — Saved pre-change dark numeric/layout regions for exact regression checks.
- [test/goldens/dashboard_sprint3_dark_stage1c_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_dark_stage1c_android.png) — New current dark numeral snapshot.
- [test/goldens/dashboard_sprint3_dark_stage1c_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_dark_stage1c_iOS.png) — New current dark numeral snapshot.
- [test/goldens/dashboard_sprint3_light_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_android.png) — Updated approved light snapshot; BMI material remains frozen while its backdrop changes.
- [test/goldens/dashboard_sprint3_light_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_iOS.png) — Updated approved light snapshot; BMI material remains frozen while its backdrop changes.
- [test/goldens/dashboard_sprint3_light_bmi_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_android.png) — Updated approved light snapshot; BMI material remains frozen while its backdrop changes.
- [test/goldens/dashboard_sprint3_light_bmi_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_iOS.png) — Updated approved light snapshot; BMI material remains frozen while its backdrop changes.
- [docs/sprint-3-theme-stage-1c.md](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/sprint-3-theme-stage-1c.md) — This review handoff.

## Emulator review and stopping point

Review the strengthened silver transitions while scrolling, dot sharpness at the
Pixel’s actual device-pixel ratio, icon illumination at ordinary display brightness,
and compositing performance of the small blur layers. Widget goldens use real
bundled fonts; portable iOS captures retain the existing test-only Inter alias for
native system navigation fonts. These are deterministic Flutter widget captures,
not screenshots from a running emulator. No Flutter application or backend was
launched for this stage.

Stage 1C is complete and stops here for feedback. Further screen styling is deferred.
