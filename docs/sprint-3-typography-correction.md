# FIT-114 — Targeted typography correction

Completed on `isaac/sprint-3`, HEAD `a65bba5`, exclusively in the Sprint 3 worktree.

- Restored Stage 1C shared defaults: fill `.74`, original sizes/spacing/colors.
  Progress, monthly calendar and Workout renderers now match their Stage 1C source
  exactly. Monthly numerals are green again; progress uses its original ink.
- Audited all dot-painter and DashboardNumber call sites: progress, calendar,
  Workout duration, dashboard cards, Meals target/cards and meal details.
- Only Daily calorie target, Weight and BMI explicitly opt into
  `statisticTypography`. They retain Stage 1D fill `.88` and its black light ink /
  existing dark ink. A `.95` paint transform anchored bottom-left reduces each
  numeral exactly 5% within the unchanged Stage 1D fitting/line slot. Units keep
  their exact Stage 1D rectangles and alignment; card/icon positions are unchanged.
- The existing painter, glyph topology, dot counts and font assets are retained.
  No duplicated numeral renderer or screen-specific color constants were added.

## Validation

- Formatting: 13 affected Dart files checked; no further formatting changes.
- `flutter analyze --no-pub lib test`: no issues.
- Full frontend: **401 passed, 2 skipped, 1 pre-existing failure**.
- Final targeted suite: **23 passed**, including unchanged-golden verification,
  scoped typography, illumination, translucency and appearance persistence tests.
- Android/iOS references compare the restored typography against Stage 1C and
  frozen decorations against Stage 1D. Both pass. Every dark pixel outside the
  three statistic slots matches Stage 1C.
- Actual rendered statistic width/height ratios are `.95` versus Stage 1D on
  both platforms; unit rectangles and number slots are identical to Stage 1D.
- Android/iOS overflow/geometry tests pass at 320×640, 390×844, 426×952 and 1×–3×
  text scale; Workout and Meals tests confirm the restored standard treatment.
- An initial 49-pixel iOS difference was traced to the restored green date
  showing through the unchanged navbar frost (x28–143, y847–853). The reference
  check permits only the date's computed three-sigma backdrop contribution within
  the existing glass. Navigation code/style is byte-identical to Stage 1D.
- All existing Stage 1C/1D goldens remain untouched. Corrected dashboard/BMI
  captures use separate names. No unrelated golden discrepancy was accepted.

The existing failure remains `dashboard_theme_test.dart: narrow phones and enlarged
text stack and scroll without overflow`: the live November clock conflicts with
the hardcoded October 31 key, throwing `Bad state: No element`. No new failures remain.

## Protected Stage 1D work

Hash checks confirm the theme definition, silver/card materials, icon illumination,
flame colors, navbar, BMI popup, logo/assets, preferences, app wiring, services and
backend files are unchanged. No database operation, emulator startup, commit,
merge, push, branch change or history change was performed.

## Files

- [lib/theme/digigym_dot_typography.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_dot_typography.dart)
- [lib/widgets/dot_matrix_text.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/dot_matrix_text.dart)
- [lib/widgets/dashboard_number.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/dashboard_number.dart)
- [lib/widgets/stat_card.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/stat_card.dart)
- [lib/screens/dashboard_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/dashboard_screen.dart)
- [lib/widgets/segmented_progress_ring.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/segmented_progress_ring.dart)
- [lib/widgets/monthly_activity_calendar.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/monthly_activity_calendar.dart)
- [lib/widgets/workout_overview.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_overview.dart)

Updated validation/reference files:

- [test/dashboard_appearance_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/dashboard_appearance_test.dart)
- [test/light_visual_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/light_visual_refinement_test.dart)
- [test/stage1d_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage1d_refinement_test.dart)
- [test/theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/theme_visual_test.dart)
- [test/workouts_screen_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workouts_screen_test.dart)
- [test/fixtures/dashboard_stage1d_numeral_regions.json](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/fixtures/dashboard_stage1d_numeral_regions.json)
- [test/goldens/dashboard_sprint3_dark_typography_correction_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_dark_typography_correction_android.png)
- [test/goldens/dashboard_sprint3_dark_typography_correction_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_dark_typography_correction_iOS.png)
- [test/goldens/dashboard_sprint3_light_typography_correction_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_typography_correction_android.png)
- [test/goldens/dashboard_sprint3_light_typography_correction_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_typography_correction_iOS.png)
- [test/goldens/dashboard_sprint3_light_bmi_typography_correction_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_typography_correction_android.png)
- [test/goldens/dashboard_sprint3_light_bmi_typography_correction_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_typography_correction_iOS.png)

Stopped for emulator review; no further visual changes are included.
