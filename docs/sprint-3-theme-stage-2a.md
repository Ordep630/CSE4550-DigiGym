# FIT-114 — Stage 2A: Workout light appearance

Completed only in `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3`, branch
`isaac/sprint-3`, HEAD `a65bba5`. No commit, merge, push, backend/database operation,
authentication change, dependency change or extension to other light-theme tabs
was performed. Existing uncommitted Sprint 3 work is preserved.

## Light Workout implementation

Home and Workout now follow the saved appearance. Meals, Groceries and Profile
keep their existing dark scope. The Workout body and its exercise/walkthrough
routes share one small interaction-theme adapter; no new palette was introduced.

The background is the **same `DigiGymAtmosphericBackground` implementation using
exactly `DigiGymSurfaces.light.background` and `.atmosphere`**. Colors, stops,
alignment, lighting and painting bounds are reused, not recreated. The shell
already extends this background behind the transparent scrolling Workout scaffold
and the floating navigation bar. Full-screen exercise routes reuse the same
background component.

The existing `DashboardGlassCard` supplies the same silver-white fill, reflections,
white edge and soft shadow as Home. Recommended Workout, weekly schedule,
exercise preview/list/detail cards and More Workouts use this shared renderer
without changing its dimensions, padding, margins, corner radii or layout.

| Role | Existing Home value reused |
| --- | --- |
| Buttons, selected segments/exercises, weekly indicators, text actions | Surface accent `#237C47` |
| Foreground on green-filled controls | Surface on-accent `#F8F9F6` |
| Primary text | ColorScheme on-surface `#121418` |
| Secondary text | ColorScheme on-surface-variant `#606C65` |
| Primary container | Existing Home `#E0F0E2` |
| Segmented control container / border | Navigation surface `#6BF8F9FB` / border `#EBFFFFFF` |

The segmented control retains its radius, padding, spacing, minimum sizes and
selection behavior. Recommended duration keeps the existing approved 5×7 dot
renderer, height, fill and Inter units. The shared numeral renderer and fonts were
not modified.

View Plan and Guided walkthrough use the scoped Home green. Expansion tiles use
that green for selected titles/chevrons, near-black collapsed titles and neutral
gray inactive chevrons. Weekly indicators use the existing Home schedule widget
and its green/gray treatments. No new green shade was added.

Workout schedule editor/day dialogs reuse **Home's existing frosted dialog
material and local sigma-14 blur** so text behind them cannot compete with their
content. The optional day-dialog flag defaults to false, preserving the Home day
dialog. Dark dialogs do not opt into frosting. No new dialog surface, menu system
or overlay architecture was introduced.

The floating navigation component is unchanged, including its selected Workout
asset/rendering, green tint, inactive icons, translucent fill, blur, border,
shadow, placement and dimensions. Home styling is unchanged.

## Dark and functional protection

Before any production change, 20 dark Workout references were captured: 10 states
on Android and iOS. All still match **pixel-for-pixel**. The original dark
interaction overrides are retained exactly in the scoped adapter; no dark palette,
background, typography, button, icon, card, navigation or dialog change remains.

The captured states are My Plan, weekly/preview scroll position, Exercises,
expanded exercise, More Workouts, expanded exercise route, walkthrough, schedule
editor, day details and unconfigured schedule. Matching light references cover
all the same states. Card, segment, dialog and navigation bounds also match
exactly between themes.

Recommendation generation, schedule persistence/controller/API calls, expansion,
subview storage and walkthrough behavior are unchanged. Tests exercise real
widgets with fake APIs and synthetic profile data; no live account/database data
was read or written.

## Validation

- Formatting: **9 affected Dart files checked**, no outstanding formatting changes.
- `flutter analyze --no-pub lib test`: **no issues**.
- **8 new appearance/behavior/accessibility tests pass**.
- Workout and Home visual suites: **9 tests pass**, including all 40 new Workout
  captures and every existing Home reference used by its visual suite.
- Full frontend suite: **417 passed, 2 skipped, 1 pre-existing failure**.
- Previous accepted baseline: 405 passed, 2 skipped, the same existing failure.
- All three Workout tabs, inline expand/collapse, exercise routes, walkthrough,
  schedule checkbox/save actions, day-details navigation and no-time states pass.
- Live Dark/Light/System switching preserves the active Workout subview;
  appearance preference restores after application restart, and Follow System
  reacts to brightness changes.
- Android/iOS layouts pass at 320×640, 390×844 and 426×952, with 1×, 2× and 3× text
  scaling. Tests include visible scrolling/expansion above the floating navbar,
  last-content clearance, dialogs and exercise routes.
- All 20 pre-change dark Workout PNGs and every older golden remain byte-identical.
  No unrelated golden failure was accepted or silently rebased.
- File hash audit preserves Home's palette/background/card/numeral/nav components,
  logo/assets, appearance storage/app wiring, unrelated screen sources, services,
  models, backend configuration and migrations. The only shared shell change is
  Workout's appearance opt-in; the shared day-dialog flag is false by default.
- `git diff --check` passes. Branch/commit remain unchanged.

The existing failure is `dashboard_theme_test.dart: narrow phones and enlarged text
stack and scroll without overflow`: its live November clock conflicts with the
hardcoded October 31 key and throws `Bad state: No element`. It remains unchanged.
There are no newly introduced failures.

## Modified files

- [lib/theme/digigym_workout_theme.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_workout_theme.dart) — New Workout-only interaction adapter over the unchanged Home palette; retains the exact existing dark overrides.
- [lib/screens/home_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/home_screen.dart) — Opts Workout into the saved light appearance; Home behavior and legacy tab dark scopes remain unchanged.
- [lib/screens/workouts_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/workouts_screen.dart) — Applies the scoped theme; light segmented surface/border and supporting subtitle consume Home tokens.
- [lib/screens/workout_exercises_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/workout_exercises_screen.dart) — Exercise and walkthrough routes resolve the selected appearance and reuse the shared atmospheric background.
- [lib/widgets/workout_week_view.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_week_view.dart) — Light weekly accents reuse Home green; Workout day details explicitly opt into existing Home dialog frosting.
- [lib/widgets/workout_schedule_editor.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_schedule_editor.dart) — Light checkboxes use Home accent/on-accent and the existing frosted dialog surface; saving/cancel behavior unchanged.
- [lib/widgets/workout_schedule_details.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_schedule_details.dart) — Adds a false-by-default frosting option so Workout dialogs can opt in without changing Home day dialogs.
- [test/workout_appearance_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workout_appearance_test.dart) — Eight new tests for exact token reuse, all tabs/expansion, routes/walkthrough, schedule editing, rollout scope, appearance switching/restoration/system brightness, empty states and accessible Android/iOS layouts.
- [test/workout_theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workout_theme_visual_test.dart) — Real-font Android/iOS dark/light state captures and exact cross-theme card/control geometry checks.
- [test/goldens/workout_dark_stage2a_baseline_day_dialog_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_day_dialog_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_day_dialog_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_day_dialog_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_exercise_route_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_exercise_route_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_exercise_route_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_exercise_route_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_exercises_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_exercises_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_exercises_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_exercises_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_expanded_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_expanded_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_expanded_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_expanded_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_more_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_more_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_more_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_more_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_my_plan_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_my_plan_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_my_plan_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_my_plan_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_schedule_editor_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_schedule_editor_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_schedule_editor_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_schedule_editor_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_unconfigured_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_unconfigured_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_unconfigured_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_unconfigured_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_walkthrough_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_walkthrough_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_walkthrough_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_walkthrough_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_weekly_preview_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_weekly_preview_android.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_dark_stage2a_baseline_weekly_preview_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_dark_stage2a_baseline_weekly_preview_iOS.png) — Protected dark reference captured before implementation.
- [test/goldens/workout_light_stage2a_day_dialog_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_day_dialog_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_day_dialog_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_day_dialog_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_exercise_route_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_exercise_route_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_exercise_route_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_exercise_route_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_exercises_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_exercises_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_exercises_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_exercises_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_expanded_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_expanded_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_expanded_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_expanded_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_more_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_more_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_more_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_more_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_my_plan_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_my_plan_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_my_plan_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_my_plan_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_schedule_editor_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_schedule_editor_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_schedule_editor_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_schedule_editor_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_unconfigured_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_unconfigured_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_unconfigured_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_unconfigured_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_walkthrough_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_walkthrough_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_walkthrough_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_walkthrough_iOS.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_weekly_preview_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_weekly_preview_android.png) — New light Workout reference.
- [test/goldens/workout_light_stage2a_weekly_preview_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_weekly_preview_iOS.png) — New light Workout reference.
- [docs/sprint-3-theme-stage-2a.md](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/sprint-3-theme-stage-2a.md) — This report.

## Emulator review

Review the main card/weekly composition, glass during scrolling, selected segment
and exercise contrast, and the frosted schedule editor/day dialogs. Check long
content at the device's large text settings. Widget captures use actual bundled
fonts and the existing test-only Inter aliases for iOS system fonts; real iOS font
metrics and device compositing/performance still warrant normal emulator review.
No emulator application or backend was started for this stage.

Stopped after Stage 2A for feedback. Meals, Groceries and Profile light styling
have not begun.
