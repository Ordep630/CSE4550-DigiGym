# FIT-114 — Stage 2A refinement

Completed exclusively in `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3`, branch
`isaac/sprint-3`, HEAD `a65bba5`. Production edits are confined to three files.
No commit, merge, push, backend/database/authentication operation, dependency
change or extension of light styling to unrelated tabs was performed.

## Home-versus-Workout glass comparison

**The regular cards already match exactly. No card styling was changed.**
Recommended Workout, weekly schedule, exercise preview/list/expanded cards,
More Workouts and the unconfigured schedule panel all use `DashboardGlassCard`
with the same `DigiGymSurfaces.light` material as Home. Expanded exercise tiles
also retain transparent Material/background layers rather than an opaque overlay.

| Treatment | Home and regular Workout cards |
| --- | --- |
| Surface-opacity multiplier | 1.0 in both; this does not mean opaque white |
| Glass tint/alpha | `#E0FFFFFF`, `#C2F8F9FC`, `#C3E4E9F0`, `#DDFFFFFF` — about 76–88% alpha |
| Fill gradient | Same top-left/bottom-right alignment and stops 0/.28/.72/1 |
| Per-card backdrop blur | 0 in both regular card sets |
| Lighting overlay | Same radial white highlight, center (.65,-1.25), radius 1.5 and stops 0/.35/1 |
| Reflective border | Same five-stop white/silver edge, painted at 0.8px |
| Shadow | Same `#16545D6B`, blur 24, offset (0,9) |
| Corners | Existing 16px radius; dimensions/padding/margins unchanged |

A real-font raster test renders a Home card and Workout card at identical size,
position and background and verifies **pixel-identical output**. Tests also inspect
actual card instances across Workout views, including expanded/unconfigured states.

The apparent opacity difference comes from the larger recommended/exercise card
areas, the normalized white reflection spreading over larger physical areas, and
different positions over the silver background. Smooth static gradients also
provide little fine detail to see through. Adding blur would not resolve a material
difference, because there is none.

If a perceptual adjustment is still desired, the narrowest follow-up is a small
Workout-only `surfaceOpacity` multiplier using the existing card API. It was not
applied here because it would deliberately depart from the exact Home material.
Home card appearance and dark cards remain unchanged. Workout dialogs retain the
previously approved Home-derived local frosting; that is separate from regular cards.

## Workout level accent

The original dark orange is **#F2A34A**. Measured background samples around the
small label are `#F9FAFC`, `#F2F4F6` and `#EEF0F3`; the original orange produces
only **1.82–1.99:1** contrast there. This was reported before changing the label.

The user explicitly approved the proposed light-only darker orange **#99570E**.
It produces **4.94–5.40:1** against those same silver samples. Only the light
“Intermediate Plan” label uses it. Dark Intermediate remains #F2A34A; other level
labels and other Workout text colors are unchanged. Inter, 14px size, weight 400,
position and line metrics are preserved.

## Shared navigation translucency

Light fill changes **#6BF8F9FB → #4DF8F9FB**, approximately **42.0% → 30.2% opacity**.
RGB remains the same. This shared token applies consistently to light floating
navigation without changing its renderer.

Blur remains sigma **16**. Border #EBFFFFFF, shape/radius, dimensions, position,
shadow, active green #237C47, inactive #626C66, icon illumination, label styles and
tap behavior are unchanged. Dark navigation remains unchanged.

The Workout segmented control previously reused the navigation surface token.
Its existing 42% value is now named separately so it does not inadvertently become
more transparent with the navbar. Its pixels remain identical to the prior reference.
A rendered transmission test now requires **more than 60%** of underlying contrast
to survive the navbar, including its shadow. All active/inactive styling and
navigation-state tests remain passing. Scroll/More Workouts captures were reviewed
with content passing beneath the unchanged frost.

## Validation and preservation

- Formatting: **10 affected Dart files checked**, no outstanding changes.
- `flutter analyze --no-pub lib test`: **no issues**.
- Focused refinement/Workout suite: **17 passed**.
- Android/iOS visual/layout suites: **9 passed**.
- Full frontend suite: **421 passed, 2 skipped, 1 pre-existing failure**.
- The four new refinement tests pass, including identical glass rendering and
  approved-orange contrast across the sampled background range.
- All 20 dark Workout captures remain exact matches. Existing Home/dark reference
  files were not modified or rebased; new light references use separate names.
- Exact comparisons protect Home cards/background/icons/flame/typography and BMI
  outside navigation. Workout pixels outside the approved label/navigation edits
  remain unchanged, including all cards and segmented-control styling.
- Initial schedule-editor differences were traced to its existing sigma-14 frost
  sampling the changed navbar. Outside navigation, the differences are at most
  **one step out of 255 per channel**, confined to the computed three-sigma blur
  footprint intersected with the popup. The test permits only that tiny compositing
  contribution, rather than masking the popup or accepting an unrelated failure.
- Three-tab, expand/collapse, routes, schedule actions, navigation, appearance
  switching/restoration, Follow System, scrolling and Android/iOS overflow checks
  through 3x text remain passing.
- File hash checks preserve the card/background/nav/icon renderers, calorie flame,
  dot typography, Home source, BMI, assets/logo, preferences, services/models,
  backend files, configuration and migrations. Only the three stated production
  files differ. No emulator app/backend was started.
- `git diff --check` passes; branch and commit remain unchanged.

The existing failure remains `dashboard_theme_test.dart: narrow phones and enlarged
text stack and scroll without overflow`: a live November clock conflicts with its
hardcoded October 31 key and throws `Bad state: No element`. No new failures remain.

## Modified files

- [lib/theme/digigym_dashboard_theme.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_dashboard_theme.dart) — Changes only the shared light navigation fill alpha from 0x6B to 0x4D; RGB and every other palette value remain intact.
- [lib/theme/digigym_workout_theme.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_workout_theme.dart) — Names the existing 42% segmented-control surface separately, and defines the user-approved light-only Intermediate Plan orange.
- [lib/screens/workouts_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/workouts_screen.dart) — Applies that orange only to the light Intermediate Plan label and retains the existing segmented-control appearance independently of navigation.
- [test/stage2a_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage2a_refinement_test.dart) — Four new tests for equal glass pixels, actual Workout card defaults, scoped orange/contrast/font metrics and unchanged navigation styling at 30% fill.
- [test/support/golden_region_checks.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/support/golden_region_checks.dart) — Shared exact regional reference comparison; tightly bounds the existing popup-frost contribution to one channel step.
- [test/theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/theme_visual_test.dart) — Protects Home and BMI pixels outside navigation while retaining dark and typography references.
- [test/workout_theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workout_theme_visual_test.dart) — Protects every Workout pixel outside the label/navigation and the computed frost contribution.
- [test/stage1d_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage1d_refinement_test.dart) — Checks 30% fill and requires over 60% backdrop-contrast transmission.
- [test/stage1e_experiment_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage1e_experiment_test.dart) — Updates only the shared navigation-fill expectation; icon/shadow checks remain.
- [test/workout_appearance_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workout_appearance_test.dart) — Updates only the shared navigation-fill expectation; all behavior/accessibility checks remain.
- [test/goldens/workout_light_stage2a_refined_day_dialog_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_day_dialog_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_day_dialog_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_day_dialog_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_exercise_route_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_exercise_route_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_exercise_route_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_exercise_route_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_exercises_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_exercises_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_exercises_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_exercises_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_expanded_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_expanded_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_expanded_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_expanded_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_more_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_more_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_more_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_more_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_my_plan_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_my_plan_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_my_plan_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_my_plan_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_schedule_editor_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_schedule_editor_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_schedule_editor_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_schedule_editor_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_unconfigured_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_unconfigured_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_unconfigured_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_unconfigured_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_walkthrough_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_walkthrough_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_walkthrough_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_walkthrough_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_weekly_preview_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_weekly_preview_android.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/workout_light_stage2a_refined_weekly_preview_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_stage2a_refined_weekly_preview_iOS.png) — New approved light label/navigation reference; old references retained.
- [test/goldens/dashboard_sprint3_light_nav30_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_nav30_android.png) — New shared-navigation-only Home reference; prior Home/BMI references retained.
- [test/goldens/dashboard_sprint3_light_nav30_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_nav30_iOS.png) — New shared-navigation-only Home reference; prior Home/BMI references retained.
- [test/goldens/dashboard_sprint3_light_bmi_nav30_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_nav30_android.png) — New shared-navigation-only Home reference; prior Home/BMI references retained.
- [test/goldens/dashboard_sprint3_light_bmi_nav30_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_nav30_iOS.png) — New shared-navigation-only Home reference; prior Home/BMI references retained.
- [docs/sprint-3-theme-stage-2a-refinement.md](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/sprint-3-theme-stage-2a-refinement.md) — This comparison/report.

## Emulator review

Review the darker orange's appearance and the 30% navbar over moving/dense content,
particularly inactive-label legibility. The blur and foreground styling remain
unchanged; increased translucency intentionally lets more underlying content through.
Cards remain the approved Home material; any further perceptual opacity experiment
would be a separate scoped adjustment. Widget captures use existing portable iOS
font aliases and do not replace native device review.

Stopped after this refinement for feedback. No further screens were styled.
