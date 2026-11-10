# FIT-114 — Recommended Workout glass experiment

Worktree: `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3`  
Branch: `isaac/sprint-3`, HEAD: `a65bba5`

## Root cause, measured before implementation

The complete stack is the shared silver background and atmosphere, transparent
shell and Workout Scaffolds, a soft card shadow, rounded clip, backdrop filter,
fill gradient, reflection, then unchanged content and edge painting. There is no
opaque ancestor panel or hidden white Material covering this recommendation.
The View Plan button is intentionally opaque but covers only its own bounds.

The background contains broad, smooth gradients with almost no local detail.
At the recommendation's actual size and position, rendering the existing
material with sigma 8 versus no blur produces only **0.143/255 mean channel
difference, maximum 1**, measured in the interior. The filter is correctly
placed behind the fill and content; the existing patterned-backdrop test proves
it samples underlying detail. Increasing blur alone cannot make this smooth
backdrop reveal appreciably more texture.

The previous fill still covered 61–70% of that similarly pale backdrop, plus a
broad white radial reflection. Removing that reflection alone produced only
1.52/255 mean difference (maximum 9). The fill and backdrop are similar in color,
so small alpha changes produce weak visual separation. The large recommendation
spreads its existing broad highlight across much more blank area than the
smaller, denser Today's Progress reference. The diffuse low-alpha shadow does
not reveal an optical edge and can reinforce the perception of a pale panel.
These findings were reported in chat before adding this experiment.

## Isolated change

Only the nonempty, light-theme Recommended Workout card opts into the new
`RecommendedWorkoutGlassCard`. The empty/insufficient-time panel and every other
Workout surface retain the previous material. Dark recommendation delegates to
the prior `WorkoutGlassCard` path.

| Setting | Before | Experiment |
| --- | --- | --- |
| Fill alpha, four gradient stops | 70.27%, 60.86%, 61.18%, 69.33% | 41.96%, 18.04%, 14.12%, 27.84% |
| Fill stops | 0, .28, .72, 1 | 0, .30, .65, 1 |
| Reflection | Broad Home radial gradient, multiplier .60 | Local diagonal white reflection |
| Reflection alpha stops | 39.53%, 7.53%, 0% | 25.88%, 1.96%, 65.10%, 3.14%, 7.84% |
| Reflection stops | 0, .35, 1 | 0, .32, .48, .60, 1 |
| Reflection direction | Existing radial center (.65,-1.25) | Alignment(-1,-.65) to (1,.65) |
| Blur sigma X/Y | 8 / 8 | 12 / 12 logical pixels |
| Reflective edge | Existing diagonal Home edge | Soft continuous top edge fading vertically |
| Edge alpha stops | Existing Home gradient | 100%, 54.90%, 14.12%, 38.04%, at 0/.12/.5/1 |
| Edge width / corners | .8px / 16px | Unchanged |
| Shadow | #16545D6B, blur 24, offset (0,9) | Unchanged |

The new fill and reflection use **white with variable alpha only**. No green,
blue or opaque gray was added. Alpha values are separate composited layers,
not a single overall opacity. The stronger reflection is localized rather than
spread over the whole panel. The silver backdrop is unchanged and visibly
influences the clear portions. Text and controls paint after the clipped filter.

Card dimensions, padding, typography, duration glyphs, button styles and actions
are unchanged. A local Theme overrides only this card's three surface treatments;
ColorScheme, text styles, navigation and shared theme definitions remain intact.
The change can be reverted independently by restoring the single recommendation
call site to `WorkoutGlassCard`.

## Native Android preview and preservation

Captured actual **Pixel_10_Pro** emulator screenshots at 1280×2856 before and after.
The after screenshot visibly shows the diagonal reflection and continuous rim.
Comparing these native screenshots found **zero changed pixels outside the
recommendation bounds and the status-clock area**. Weekly Schedule, exercise
preview, navigation, header, orange label and shared backdrop match exactly.

- [Before](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/previews/recommended-workout-glass-android-before.png)
- [After](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/previews/recommended-workout-glass-android-after.png)

The first rebuild used the source's localhost default and could not restore its
session. Relaunching with the existing Android runtime address
`--dart-define=SERVER_URL=http://10.0.2.2:8080/` restored the saved session.
No API configuration, authentication code or backend files were changed. Light
Mode was selected through the existing Appearance UI, and the emulator is left
on the light Workout screen. Flutter was detached without stopping the app.

## Validation

- Before changes: focused material and Android/iOS Workout gallery tests passed (8).
- Formatting: six affected Dart files, zero outstanding changes.
- `flutter analyze --no-pub lib test`: **no issues**.
- Focused recommendation/scope/interaction/responsive tests: **13 passed**.
- Full frontend suite: **423 passed, 2 skipped, 1 pre-existing failure**.
- The prior `dashboard_theme_test.dart` calendar test still uses a hardcoded
  October 31 key against the live November clock and throws `Bad state: No element`.
  It was not changed, and no unrelated golden failures were accepted.
- The new rendered test requires meaningful differences over at least 25% of the
  exposed recommendation surface and a mean change exceeding 4/255 per channel.
  It also verifies **pixel-identical View Plan button core, icon and label**.
  Full-card interior mean change in the Android fixture is 6.84/255; 43.6% of
  channel samples differ by at least 8. This is a visible material/reflection
  change rather than another negligible global-opacity adjustment.
- Every light gallery frame is compared to the immediately preceding captures
  outside the recommendation. Other cards, header, controls and background must
  remain identical. Existing popup frost may naturally sample the changed card;
  that allowance is confined to the computed sampling region. Popup styling
  itself is unchanged.
- All retained Home and 20 dark Workout captures pass. Android/iOS geometry,
  exercise expansion, routes, scrolling, appearance switching/restoration and
  overflow checks through 3x text pass.
- Only ten new light recommendation goldens were added (five states on Android
  and iOS). Every existing golden remains byte-identical.

## Emulator review

The reflection is intentionally more apparent for this experiment. Review its
strength and the perceived softness against the retained before screenshot.
Near-black primary text remains strongly separated (roughly 13–15:1 on sampled
blank background areas). Smaller muted/green copy is visually readable but some
sampled backgrounds produce around 3.8–4.3:1; this is not a blanket 4.5:1 contrast
claim. Text colors were preserved as requested. Review that tradeoff and scrolling
before approving the new material.

## Files changed in this experiment

- [docs/previews/recommended-workout-glass-android-after.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/previews/recommended-workout-glass-android-after.png)
- [docs/previews/recommended-workout-glass-android-before.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/previews/recommended-workout-glass-android-before.png)
- [lib/widgets/recommended_workout_glass_card.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/recommended_workout_glass_card.dart)
- [lib/widgets/workout_overview.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/workout_overview.dart)
- [test/goldens/workout_light_recommended_glass_day_dialog_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_day_dialog_android.png)
- [test/goldens/workout_light_recommended_glass_day_dialog_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_day_dialog_iOS.png)
- [test/goldens/workout_light_recommended_glass_my_plan_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_my_plan_android.png)
- [test/goldens/workout_light_recommended_glass_my_plan_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_my_plan_iOS.png)
- [test/goldens/workout_light_recommended_glass_schedule_editor_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_schedule_editor_android.png)
- [test/goldens/workout_light_recommended_glass_schedule_editor_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_schedule_editor_iOS.png)
- [test/goldens/workout_light_recommended_glass_unconfigured_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_unconfigured_android.png)
- [test/goldens/workout_light_recommended_glass_unconfigured_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_unconfigured_iOS.png)
- [test/goldens/workout_light_recommended_glass_weekly_preview_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_weekly_preview_android.png)
- [test/goldens/workout_light_recommended_glass_weekly_preview_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/workout_light_recommended_glass_weekly_preview_iOS.png)
- [test/recommended_workout_glass_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/recommended_workout_glass_test.dart)
- [test/stage2a_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage2a_refinement_test.dart)
- [test/workout_appearance_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workout_appearance_test.dart)
- [test/workout_theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/workout_theme_visual_test.dart)
- [docs/sprint-3-recommended-glass-experiment.md](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/sprint-3-recommended-glass-experiment.md)

No commit, merge or push. No backend/database/configuration files, Home implementation, shared glass renderer, standard Workout glass tokens, navigation or typography implementation was changed. Stopped for emulator feedback.
