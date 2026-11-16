# FIT-114 — Stage 1E reversion and calorie shadow

Completed exclusively in `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3`, branch
`isaac/sprint-3`, HEAD `a65bba5`. No Stage 2 work, commit, merge or push occurred.

## Exact reversion

Restored the actual navigation implementation saved immediately before Stage 1E.
The current navigation file is byte-identical to that checkpoint, including all
five destinations, active glyphs/assets, foreground color, glow, label styling,
callbacks, geometry and translucent glass. The experimental option was removed.

The original light active color is `#237C47`. The original light two-halo treatment,
inset highlight and label shadows return. Dark navigation remains unchanged.
Light glass remains `#6BF8F9FB`, sigma-16 frost, the same border, shadow, placement,
spacing and rounded corners. Inactive styling is unchanged.

Restored the original light calorie yellow **#FFD35B** through the original palette.
Dark calorie styling remains unchanged. The streak flame stays **#FFAA58**, and
Meals/other flames retain their existing colors and rendering.

## New shadow

Only the light dashboard calorie icon explicitly receives
`DigiGymDashboardTheme.calorieFlameLightShadow`:

- Color `#487F6A24`: a muted warm-gold tint at approximately 28% opacity.
- Blur radius **2.2 logical pixels**.
- Offset **(0, 0.75)** logical pixels.

The shared icon widget paints one transparent copy of the same Material glyph
using Flutter's native `Icon.shadows`, behind the existing icon/glow/highlight
layers. The transparent copy contributes only its shape-following shadow. It is
not included in repeated glow/highlight copies. The original yellow foreground,
shape, size and position remain intact. There is no outline, spread, large glow,
new asset or custom renderer. Existing exclusion of pointer events/semantics is
retained. The dark branch ignores this optional shadow.

`StatCard` only forwards the optional value. The dashboard calorie call site is
the sole opt-in; all other icons default to no added shadow. The three shadow
parameters can be adjusted together in one theme constant after emulator review.

## Validation

- Formatting: **10 affected Dart files checked**, no further formatting changes.
- `flutter analyze --no-pub lib test`: **no issues**.
- Focused icon/navigation/theme suite: **25 passed**.
- Android/iOS golden and responsive-layout suite: **5 passed**.
- Full frontend suite: **405 passed, 2 skipped, 1 pre-existing failure**.
- Both full dark renders match their accepted references exactly.
- Both light renders match the actual pre-Stage-1E reference exactly outside the
  calorie icon's small shadow footprint, including active navigation, streak,
  other icons, backgrounds, cards, typography and layout.
- Raster checks at 1x and 3x density confirm visible, localized shadow pixels,
  identical opaque yellow pixels, unchanged distant background and pixel-identical
  dark rendering with/without the optional shadow.
- All five active navigation states retain their original light treatment; asset,
  tap/selection, inactive-state, safe-area and enlarged-text tests pass.
- Theme switching, persistence, restart restoration and Follow System pass in
  the full frontend suite. Typography/overflow checks remain passing.
- Only new calorie-shadow goldens were generated. All previous golden files are
  byte-identical; no unrelated golden discrepancy was accepted.
- Hash audit preserves logo/assets, typography components, background/card/BMI
  rendering, streak, appearance controller/settings, app wiring, services,
  authentication and backend files. No database operation or emulator startup
  was performed. `git diff --check` passes; branch and commit are unchanged.

The sole existing failure is `dashboard_theme_test.dart: narrow phones and enlarged
text stack and scroll without overflow`. Its live November clock conflicts with a
hardcoded October 31 key, producing `Bad state: No element`. It remains unchanged;
there are no newly introduced failures.

## Modified files

- [lib/widgets/floating_bottom_navigation_bar.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/floating_bottom_navigation_bar.dart) — Exact pre-Stage-1E source restored; experiment option and dark treatment in light mode removed.
- [lib/theme/digigym_dashboard_theme.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/theme/digigym_dashboard_theme.dart) — Pre-Stage-1E palette restored, including yellow #FFD35B; adds only the narrow calorieFlameLightShadow constant.
- [lib/widgets/soft_glow_icon.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/soft_glow_icon.dart) — Optional light-only native glyph-shadow layer behind the existing illumination; default and dark paths unchanged.
- [lib/widgets/stat_card.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/widgets/stat_card.dart) — Forwards the optional lightIconShadow without changing layout or typography.
- [lib/screens/dashboard_screen.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/lib/screens/dashboard_screen.dart) — Enables the shadow only for the calorie statistic.
- [test/floating_bottom_navigation_bar_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/floating_bottom_navigation_bar_test.dart) — Actual pre-experiment tests restored for all five light/dark navigation states, assets, geometry and behavior.
- [test/light_visual_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/light_visual_refinement_test.dart) — Restored pre-experiment light navigation expectations and existing shared-widget checks.
- [test/stage1d_refinement_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage1d_refinement_test.dart) — Restored original yellow expectations; retains typography and other approved style guards.
- [test/stage1e_experiment_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/stage1e_experiment_test.dart) — Now verifies the reversion, calorie-only shadow, 1x/3x opaque-yellow preservation/locality, dark pixel identity and all five light states.
- [test/theme_visual_test.dart](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/theme_visual_test.dart) — Exact pre-experiment image comparison excludes only the small calorie-shadow area; unchanged dark and typography checks remain.
- [test/goldens/dashboard_sprint3_light_calorie_shadow_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_calorie_shadow_android.png) — New shadow-only reference. Existing Stage 1C/1D/1E and typography-correction goldens remain untouched.
- [test/goldens/dashboard_sprint3_light_calorie_shadow_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_calorie_shadow_iOS.png) — New shadow-only reference. Existing Stage 1C/1D/1E and typography-correction goldens remain untouched.
- [test/goldens/dashboard_sprint3_light_bmi_calorie_shadow_android.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_calorie_shadow_android.png) — New shadow-only reference. Existing Stage 1C/1D/1E and typography-correction goldens remain untouched.
- [test/goldens/dashboard_sprint3_light_bmi_calorie_shadow_iOS.png](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/test/goldens/dashboard_sprint3_light_bmi_calorie_shadow_iOS.png) — New shadow-only reference. Existing Stage 1C/1D/1E and typography-correction goldens remain untouched.
- [docs/sprint-3-stage-1e-reversion.md](/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3/docs/sprint-3-stage-1e-reversion.md) — This report.

## Emulator review

Review only the subtle shadow strength and warmth at the emulator's actual pixel
density. The yellow foreground is preserved; navigation is an exact reversion.
Deterministic widget renders use the existing portable iOS font aliases and do
not replace live emulator review. Stopped for feedback before Stage 2.
