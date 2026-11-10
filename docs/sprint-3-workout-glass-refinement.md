# FIT-114 — Workout glass translucency refinement

Worktree: `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3`. Branch: `isaac/sprint-3`. HEAD: `a65bba5`.

## Rendering diagnosis

Inspected the actual Today’s Progress card, recommendation, weekly schedule and exercise tiles, and compared the retained Android captures. They share the same renderer, but their visible composition differs. The Home reference is a smaller, denser card; the recommendation stretches the normalized reflection across a larger area. Cards occupy different locations over the silver backdrop. Large blank areas reveal a continuous pale panel more clearly than the ring and text on Home.

Regular cards previously used Home’s fill at full strength (76–88% alpha), an additional independently composited white radial reflection, and no backdrop blur. The reflection was not affected by the existing surface-opacity multiplier, so lowering that multiplier alone could leave an overly white result. No extra opaque exercise overlay was found: the Material and expansion backgrounds are transparent.

## Exact material change

One `WorkoutGlassCard` delegates to the existing Home glass renderer. It changes only three light-mode parameters. No new tint or dependency was introduced.

| Parameter | Before / unchanged Home | Light Workout after |
| --- | --- | --- |
| Fill-gradient multiplier | 1.00 | 0.80 |
| Fill-stop alpha | 224/255, 194/255, 195/255, 221/255 | 70.27%, 60.86%, 61.18%, 69.33% |
| White-reflection multiplier | 1.00 | 0.60 |
| Reflection-stop alpha | 65.88%, 12.55%, 0% | 39.53%, 7.53%, 0% |
| Backdrop Gaussian sigma X/Y | 0 / 0 | 8 / 8 logical pixels |
| Radius | 16 | 16, unchanged |
| Reflective edge | 0.8px, existing gradient | Unchanged |
| Shadow | #16545D6B, blur 24, offset (0,9) | Unchanged |

These are layered alpha values, not a single overall card opacity. Fill RGB colors, gradient stops/directions and radial-highlight placement remain Home’s existing values. The sigma-8 filter is clipped to each rounded card; text and controls are painted after filtering. Both the fill and reflection transmit more of the existing silver background.

Dark Workout cards use the original 1.0 fill, 1.0 reflection and zero blur. The default renderer path remains identical for Home and all other users. The weekly schedule exposes an optional card builder so Workout can opt in while Home retains its previous rendering.

Applied consistently to recommendation/insufficient-time panels, Weekly Schedule, exercise preview/list/expanded tiles, alternative workout cards, unconfigured-schedule content, exercise routes and walkthrough step cards. Dialog surfaces retain their existing material. All dimensions, padding, typography, icons, button styling, layouts and actions remain intact.

## Validation

- Before editing: existing focused glass and Android/iOS Workout gallery suites passed (8 tests).
- Formatting: 12 affected Dart files checked, no remaining formatting changes.
- `flutter analyze --no-pub lib test`: no issues.
- Focused material, Workout interaction and responsive suites: 13 passed.
- Home plus Android/iOS Workout visual/layout suites: 9 passed.
- Full frontend suite: **422 passed, 2 skipped, 1 pre-existing failure**.
- The existing failure is `dashboard_theme_test.dart: narrow phones and enlarged text stack and scroll without overflow`: a November live clock conflicts with the hardcoded October 31 calendar key (`Bad state: No element`). It was documented before this refinement; no unrelated fix or golden update was made.
- A rendered transmission test checks that the actual composed Workout material transmits more backdrop variation than Home, and that sigma-8 frost removes at least 75% of the fine-stripe contrast compared with the same material without blur.
- Actual recommendation/schedule/exercise/alternative card instances are checked for one consistent light treatment and original dark defaults.
- Theme switching, persistence, Follow System, all Workout views/routes, schedule actions, expansion, scrolling and Android/iOS overflow through 3x text pass.
- All 20 protected dark Workout captures and retained Home/BMI captures pass unchanged. Layout rectangles remain identical across light/dark.
- Current light Workout captures are compared against prior approved captures outside card interiors (plus one pixel for fractional clip antialiasing). Navigation and dialog blur can sample the changed cards; permitted changes there are restricted to their calculated sampling regions. Their renderer/source/material are unchanged.
- New references are confined to 20 light Workout images with the `workout_light_stage2a_glass_` prefix. Every previous golden remains byte-identical.
- Source hash audit preserves Home, shared background/palette, navigation renderer, logo/assets, orange/green values, segmented control, buttons, number glyphs, authentication/services, backend/configuration and database files. `git diff --check` passes.

## Readability and emulator review

Reviewed recommendation, expanded exercise and schedule-editor captures. Main near-black text remains strongly separated (sampled card backgrounds yield roughly 14–16:1), and green icons remain above 3:1 on those samples. No text, icon or accent color was changed.

Small muted and accent copy has less contrast as more silver shows through. Some sampled areas are about 4.3–4.5:1 for muted gray; the prior material also had locations below 4.5:1. This is not a blanket WCAG AA claim. Review small copy, green text and scrolling smoothness on the Pixel emulator before approving this glass treatment. Per-card blur is new in light Workout, so native rendering/performance still needs device review; widget goldens do not replace it.

The already-approved orange label, navigation translucency, green accents and silver backdrop remain intact. Navigation/popup pixels can naturally reflect the altered material beneath them without any styling change to those components.

## Files changed in this refinement

- [lib/screens/workout_exercises_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/workout_exercises_screen.dart)
- [lib/screens/workouts_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/workouts_screen.dart)
- [lib/theme/digigym_workout_theme.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_workout_theme.dart)
- [lib/widgets/dashboard_glass_card.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/dashboard_glass_card.dart)
- [lib/widgets/weekly_workout_schedule.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/weekly_workout_schedule.dart)
- [lib/widgets/workout_exercise_list.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_exercise_list.dart)
- [lib/widgets/workout_glass_card.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_glass_card.dart)
- [lib/widgets/workout_overview.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_overview.dart)
- [lib/widgets/workout_week_view.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_week_view.dart)
- [test/goldens/workout_light_stage2a_glass_day_dialog_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_day_dialog_android.png)
- [test/goldens/workout_light_stage2a_glass_day_dialog_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_day_dialog_iOS.png)
- [test/goldens/workout_light_stage2a_glass_exercise_route_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_exercise_route_android.png)
- [test/goldens/workout_light_stage2a_glass_exercise_route_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_exercise_route_iOS.png)
- [test/goldens/workout_light_stage2a_glass_exercises_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_exercises_android.png)
- [test/goldens/workout_light_stage2a_glass_exercises_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_exercises_iOS.png)
- [test/goldens/workout_light_stage2a_glass_expanded_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_expanded_android.png)
- [test/goldens/workout_light_stage2a_glass_expanded_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_expanded_iOS.png)
- [test/goldens/workout_light_stage2a_glass_more_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_more_android.png)
- [test/goldens/workout_light_stage2a_glass_more_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_more_iOS.png)
- [test/goldens/workout_light_stage2a_glass_my_plan_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_my_plan_android.png)
- [test/goldens/workout_light_stage2a_glass_my_plan_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_my_plan_iOS.png)
- [test/goldens/workout_light_stage2a_glass_schedule_editor_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_schedule_editor_android.png)
- [test/goldens/workout_light_stage2a_glass_schedule_editor_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_schedule_editor_iOS.png)
- [test/goldens/workout_light_stage2a_glass_unconfigured_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_unconfigured_android.png)
- [test/goldens/workout_light_stage2a_glass_unconfigured_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_unconfigured_iOS.png)
- [test/goldens/workout_light_stage2a_glass_walkthrough_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_walkthrough_android.png)
- [test/goldens/workout_light_stage2a_glass_walkthrough_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_walkthrough_iOS.png)
- [test/goldens/workout_light_stage2a_glass_weekly_preview_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_weekly_preview_android.png)
- [test/goldens/workout_light_stage2a_glass_weekly_preview_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_glass_weekly_preview_iOS.png)
- [test/stage2a_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage2a_refinement_test.dart)
- [test/workout_glass_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workout_glass_test.dart)
- [test/workout_theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workout_theme_visual_test.dart)
- [docs/sprint-3-workout-glass-refinement.md](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/sprint-3-workout-glass-refinement.md)

No commit, merge or push was performed. No Flutter emulator app or backend was started. Stopped after this refinement for emulator feedback.
