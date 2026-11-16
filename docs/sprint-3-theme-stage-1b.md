# FIT-114 — Stage 1B: Expressive Silver Glassmorphism

Implemented only in the Sprint 3 worktree on `isaac/sprint-3`. No commit, merge,
push, backend change, database/configuration change, dependency change, or rollout
to additional screens was performed. Existing theme selection and persistence
code is unchanged.

## Visual refinements

- Replaced the light background's mint wash with a five-stop off-white, pearl,
  and silver linear gradient beneath a very broad diffused white highlight.
  No background stop has a green-dominant tint. The dark background is unchanged.
- Refined white card translucency, silver reflections, luminous white edges,
  and gentle neutral shadows. Card padding, corner radii, sizes, and positions
  retain their existing layout metrics.
- Increased the light glow multiplier from `.22` to `.78`. Selected navigation
  glow opacity is now `.50` with sigma `4`; light-only label shadows and small
  weekly/calendar halos use a centralized `.16` selection-glow token. The green
  foreground colors are unchanged. Dark glow behavior is unchanged.
- Targeted a 6% increase in Doto numeral size and an increase from native weight
  `840` to `880`, bounded by the font's maximum `900`. Existing unit fonts/sizes
  are retained. An invisible, non-painted reference preserves the original
  intrinsic line metrics while visible glyphs fit the available line slot.
  This keeps long values and enlarged text from resizing the dashboard cards.
- Increased the custom progress/calendar dot fill ratio from `.68` to `.74`,
  retaining a clear gap between dots and the existing digit shapes. Progress
  uses a slightly wider inner numeral area inside its unchanged ring. The
  monthly date paints at 1.06 scale within the existing calendar composition.
- Strengthened light primary-text contrast with near-black `#121418`.
- The BMI popup uses a subtle `.94` background-opacity multiplier without
  fading its content. Initial visual review showed that translucency alone made
  dashboard text distracting: the old popup had no local backdrop filter.
  A light-only, clipped sigma-14 frost layer now softens that text. Other cards
  and dialogs do not receive this filter; the dark BMI surface remains at full
  opacity with no new blur. Popup content, dimensions, actions, and navigation
  are unchanged.

## Protected values and behavior

The following light values remain exact:

| Token | Value |
| --- | --- |
| Dashboard accent / selected navigation | `#237C47` |
| Material primary / electric brand green | `#70FF45` |
| Primary container | `#E0F0E2` |
| On-primary container | `#237C47` |
| Inactive progress track | `#D4DDD5` |
| Existing branding ink | `#18211D` |

Logo assets match their Git baseline byte-for-byte. No branding widget, asset,
or wordmark filter was changed. The existing dark surface-token block is
byte-for-byte unchanged; new refinement fields default to the old dark behavior.
Both approved Android and iOS dark dashboard goldens still match pixel-for-pixel,
and neither dark golden file was updated.

New semantic values live in `DigiGymSurfaces` with `copyWith`/`lerp` support.
Material typography colors remain in `ColorScheme`. The shared widgets consume
these values without adding screen-specific color constants.

## Validation

| Check | Result |
| --- | --- |
| Dart formatting | All 13 affected Dart files formatted; final check passed |
| `flutter analyze --no-pub lib test` | No issues |
| Seven new focused refinement tests | All passed |
| Theme preference, persistence, restart, Follow System | Existing tests passed |
| Dark Android/iOS regression renders | Pixel-identical; baseline files untouched |
| Light Android/iOS dashboard and BMI renders | Passed and visually inspected |
| Responsive geometry | Exact light/dark dashboard/card/navigation/calendar bounds match at 320×640, 390×844, and 426×952, through 1×–3× text scaling |
| Long values and accessibility | Long name, large weight/calorie/BMI values, 125-minute workout, calendar/date containment, and numeral painting bounds passed |
| Full frontend suite before Stage 1B | 387 passed, 2 skipped, 1 existing failure |
| Full frontend suite after Stage 1B | 394 passed, 2 skipped, same 1 existing failure |
| Backend file checkpoint | No changes |
| `git diff --check` | Passed |

The existing failure is
`test/dashboard_theme_test.dart: narrow phones and enlarged text stack and scroll without overflow`.
It uses the live clock but searches for `month-day-2026-10-31`; in November the
lookup throws `Bad state: No element`. It was reproduced before Stage 1B and
left unchanged. No new test failures remain.

## Stage 1B files

| Files | Changes |
| --- | --- |
| `lib/theme/digigym_dashboard_theme.dart` | Silver palette, light glow/numeral/BMI tokens, interpolation |
| `lib/widgets/dashboard_number.dart` | Light Doto weight/size, unit preservation, unchanged intrinsic line slots |
| `lib/widgets/segmented_progress_ring.dart` | Light percentage scale/dot treatment inside the existing ring |
| `lib/widgets/monthly_activity_calendar.dart` | Light date weight/scale and selected-date halo |
| `lib/widgets/weekly_workout_schedule.dart` | Light-only selected-day halo |
| `lib/widgets/floating_bottom_navigation_bar.dart` | Light-only selected-label glow |
| `lib/widgets/dashboard_glass_card.dart` | Optional surface opacity and local frost; unchanged defaults |
| `lib/widgets/digigym_dialog.dart` | Opt-in BMI surface treatment |
| `lib/widgets/dashboard_information_dialogs.dart` | Enable treatment for BMI only |
| `test/light_visual_refinement_test.dart` (new) | Green/branding guards, neutral backgrounds, dark defaults, Doto metrics, percentage fitting, glow, BMI behavior |
| `test/appearance_controller_test.dart` | Updated interpolation expectations for refined values |
| `test/appearance_app_test.dart` | Approved near-black light-text expectation |
| `test/theme_visual_test.dart` | BMI renders, long-value geometry, numeral/date containment |
| `test/goldens/dashboard_sprint3_light_android.png` | Updated light dashboard render |
| `test/goldens/dashboard_sprint3_light_iOS.png` | Updated light dashboard render |
| `test/goldens/dashboard_sprint3_light_bmi_android.png` (new) | Light BMI render |
| `test/goldens/dashboard_sprint3_light_bmi_iOS.png` (new) | Light BMI render |
| `docs/sprint-3-theme-stage-1b.md` (new) | Review handoff |

## Emulator review

Review the silver lighting across scroll positions, the green glow strength at
normal display brightness, the Doto weight on the Pixel's actual pixel density,
and the BMI popup's translucency/frost balance. QA used deterministic Flutter
widget renders with bundled fonts; iOS visual fixtures retain the existing
test-only Inter substitute for native navigation fonts. No emulator application
or backend was started for this refinement.

Stage 1B stops here for feedback. Stage 2 and additional light-theme screens are
not included.
