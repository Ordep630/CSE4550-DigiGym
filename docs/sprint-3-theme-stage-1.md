# FIT-114: Stage 1 appearance foundation

## Approved dark baseline, recorded before visual changes

Source: `a65bba58d986acb66087796740289a21a1288522`, branch
`isaac/sprint-3`. The working tree was clean before development.

The current dashboard is the Phase 3H composition: official pixel dumbbell and
wordmark, streak pill, greeting/name/message, progress and Workout cards beside
the calories/weight/BMI panel, Your Week, Monthly Activity, and floating navigation.
The older Phase 2C/2D goldens represent retired layouts and must not be rebased.

Dark values to preserve exactly:

- Page: `#0C1010`; upper-right radial `#202C30` to `#0C1010`, center
  `(1.2, -.6)`, radius `1.6`, stops `[0, .85]`. Lower-left wash:
  `#0D39FF98` to `#0039FF98`, center `(-1.1, 1.2)`, radius `1.25`.
- Glass: linear `#F23B474A`, `#EE192123`, `#F00F1618`, `#F0222D2F`,
  stops `[0, .28, .72, 1]`; reflection `#20FFFFFF`, `#06FFFFFF`,
  `#00FFFFFF`, stops `[0, .35, 1]`, center `(.85, -1.15)`, radius `1.1`.
- Glass edge: `#70D5E1DF`, `#26D5E1DF`, `#05D5E1DF`, `#12D5E1DF`,
  `#38D5E1DF`, stops `[0, .16, .48, .76, 1]`, stroke `.8`.
- Card shadow: `#38000000`, blur `18`, offset `(0, 8)`; radius `16`.
- Primary text `#F4F7F5`; secondary `#ABB5AF`; electric green `#70FF45`;
  softer dashboard accent `#67E780`; calorie amber `#FFD35B`;
  streak orange `#FFAA58`; inactive ring `#2B3530`.
- Streak: linear `#E032302B`, `#E619211F`, `#E6212723`, stops
  `[0, .55, 1]`; orange border `.30`, shadow `.11`, blur `12`, spread `-1`.
- Navigation: selected `#70FF45`, inactive `#A6AEAA`, charcoal surface at
  `.20`, white border `.15`; black outer shadow `.22`, blur `18`,
  offset `(0, 5)`; backdrop blur `14`; selected glow opacity `.85`, sigma `4`.
- Soft icon wash alphas `.16/.09/.025/0`; glow multiplier `.82`;
  shadow `.09`, glyph shadows `.22/.08`, blurs `6/12`.
- Keep Inter content, Doto numbers, existing navigation typography, all geometry,
  safe areas, scroll behavior, animation, data, and action wiring unchanged.

The Stage 1 dark golden is captured from this source before visual edits and
checked again after implementation. Stage 1 light screenshots are review artifacts.

## Implementation and scope

`DigiGymApp` now owns an `AppearanceController` and supplies separate light and
dark `ThemeData` through `MaterialApp.theme`, `darkTheme`, and `themeMode`.
`ColorScheme` owns Material surface, primary/secondary text, outline, and brand
colors. `DigiGymSurfaces`, a `ThemeExtension`, owns atmospheric decorations,
glass gradients/reflections/edges/shadows, readable accent and on-accent colors,
progress track, streak and notification surfaces, navigation, branding ink,
icon wells, and glow strength. Its `copyWith` and `lerp` support theme transitions.
The existing content helper still scopes Inter to content and preserves navigation
font metrics. Doto and the custom dotted progress display remain unchanged.

`Profile → App Appearance` offers Dark Mode, Light Mode, and Follow System with
accessible, mutually exclusive selection semantics. Dark is the default for an
unset, corrupt, or unreadable preference. The existing `KeyValueStorage`
abstraction and `FlutterSecureKeyValueStorage` implementation store `dark`,
`light`, or `system` under `digigym.appearance.v1`. Restoration completes before
session content is shown. Writes are serialized, a late read cannot overwrite a
new selection, and storage failures retain the in-memory choice, show a save
notice in settings, and retry on application resume. Preference state is local
to the device and independent of login/profile data.

Flutter handles device brightness changes when `themeMode` is `ThemeMode.system`.
The saved value remains `system`, so restoration follows the current device
setting rather than the brightness from the previous session. Explicit Dark and
Light ignore device brightness changes.

Reference APIs: [MaterialApp.themeMode](https://api.flutter.dev/flutter/material/MaterialApp/themeMode.html)
and [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html).

Stage 1 applies light appearance to Home, its floating navigation, dashboard
information dialogs, and App Appearance. Other tabs and legacy/authentication
routes retain their existing scoped dark presentation. No backend, dependency,
calculation, scheduling, or authentication behavior was changed.

## Light dashboard design

- Soft `#F1F3EF` background with upper-right neutral gray lighting and a quiet
  lower-left green wash; no flat white page or inverted dark colors.
- Frosted translucent white cards, subtle gray reflections, delicate edge
  gradients, and softer shadows in the existing card shapes.
- Near-black `#18211D` primary text and muted `#606C65` secondary text. The
  official wordmark's neutral lettering is re-inked for light backgrounds while
  retaining the original asset and green identity.
- The existing electric brand green remains available for fills. `#237C47`
  supplies readable small text/icons on pale glass; amber and streak accents
  receive quieter light treatments. Decorative glow is reduced to `.22` of its
  dark strength, and navigation glow is similarly restrained.
- Identical header, progress/Workout composition, calories/weight/BMI panel,
  Your Week, Monthly Activity, spacing, safe areas, scrolling, and actions.
  The current source has a daily-calorie statistic and Workout summary rather
  than the retired featured-plan cards; Stage 1 preserves this approved layout.

Review renders: [Android](../test/goldens/dashboard_sprint3_light_android.png)
and [iOS](../test/goldens/dashboard_sprint3_light_iOS.png).

## Dark protection and visual verification

Both dark goldens pass pixel-for-pixel after centralization. Initial captures
were produced before visual changes. For readable iOS test labels, the golden
fixture loads bundled Inter under the otherwise unavailable native system font
aliases. The iOS dark baseline was also rendered from an untouched `git archive`
of `a65bba5` under the ignored `build/theme-baseline` directory with that same
font fixture. Android's original and archive captures have identical hashes.
This changes only test rendering; production iOS navigation typography is untouched.

Dark baseline SHA-256:

- Android: `2baf98c4ed4ecad960b3a6c93218a7b299bcae180e036feff3ce5dd6f4892286`
- iOS: `26c4db171084791dc9f74cb27d8510e3432355fb532ef48d97450b298d2f4c81`

The visual suite also compares light/dark geometry at 320×640, 390×844, and
426×952 with 1×, 2×, and 3× text scaling, including a long name and scrolling
through the calendar. All comparisons pass. Native device/simulator review of
the new light design and real platform storage is still recommended before the
next rollout stage; this session used widget renders and injected storage tests.

## Validation results

| Check | Before implementation | Final |
| --- | --- | --- |
| `flutter analyze --no-pub lib test` | No issues | No issues |
| `flutter analyze --no-pub` | 383 diagnostics | Exactly the same 383 diagnostics |
| `flutter test --no-pub --reporter expanded` | 369 passed, 2 skipped, 1 failed | 387 passed, 2 skipped, 1 failed |
| New controller/app/visual tests | — | 18 passed |
| Dark original-source golden comparisons | Baselines captured | Android and iOS pass |
| Light renders and responsive geometry | — | Pass |
| `git diff --check` | Clean | Clean |

The existing full-suite failure is
`test/dashboard_theme_test.dart: narrow phones and enlarged text stack and scroll without overflow`.
It uses a live clock but looks for `month-day-2026-10-31` at line 464; in November,
`ensureVisible` throws `Bad state: No element`. It was reproduced before any
implementation changes and is left unchanged. No newly introduced test failures
remain.

The root analysis diagnostics originate in the independently configured nested
backend projects (including unresolved server packages and `flutter_driver`) and
the existing backend package-name lint. Their diagnostic set is identical before
and after Stage 1. Frontend analysis is clean. Existing dependencies were resolved
with `flutter pub get`; neither manifest nor lockfile changed.

## Modified files

| Files | Purpose |
| --- | --- |
| `lib/main.dart` | App-level appearance ownership, restoration, themes, persistence retry |
| `lib/theme/appearance_controller.dart` (new) | Device preference, storage serialization/recovery, inherited scope |
| `lib/theme/digigym_dashboard_theme.dart` | Light ThemeData and centralized semantic surface extension; original dark values retained |
| `lib/screens/home_screen.dart` | Stage 1 dashboard theme scope; other tabs remain dark |
| `lib/screens/dashboard_screen.dart` | Semantic accents, readable wordmark, system overlay brightness |
| `lib/screens/app_appearance_screen.dart` | Three working appearance choices and save-failure notice |
| `lib/widgets/digigym_atmospheric_background.dart` | Central background and atmospheric lighting |
| `lib/widgets/dashboard_glass_card.dart` | Central glass, edge, shadow, icon well treatments; theme-aware repainting |
| `lib/widgets/floating_bottom_navigation_bar.dart` | Central navigation surface, colors, shadows, glow |
| `lib/widgets/daily_streak_indicator.dart` | Central streak surface/accent and semantic text colors |
| `lib/widgets/dashboard_notification_button.dart` | Central notification surface |
| `lib/widgets/soft_glow_icon.dart` | Central glow multiplier |
| `lib/widgets/segmented_progress_ring.dart` | Semantic inactive track |
| `lib/widgets/weekly_workout_schedule.dart` | Semantic current-day accent and glow |
| `lib/widgets/digigym_dialog.dart` | Follow dashboard appearance and semantic action colors |
| `lib/widgets/dashboard_information_dialogs.dart` | Semantic BMI highlights |
| `lib/widgets/profile_components.dart` | Opt-in appearance-aware settings scaffold |
| `lib/widgets/workout_app_bar.dart` | Semantic back-button accent, retaining dark appearance |
| `test/appearance_controller_test.dart` (new) | Defaults, persistence/restoration, races, failures/retry, interpolation |
| `test/appearance_app_test.dart` (new) | Settings interaction, full-app restart, system brightness, dialogs, lifecycle retry |
| `test/theme_visual_test.dart` (new) | Dark regression, light renders, responsive geometry |
| `test/dashboard_appearance_test.dart` | Optional theme argument for the existing visual fixture |
| `test/floating_bottom_navigation_bar_test.dart` | Approved centralized light palette expectations |
| `test/profile_navigation_test.dart` | Replace obsolete unavailable-light expectation with the three-option route |
| `test/goldens/dashboard_sprint3_{dark,light}_{android,iOS}.png` (four new files) | Dark baselines and light review renders |
| `docs/sprint-3-theme-stage-1.md` (new) | Baseline specification and implementation/validation handoff |

All project changes are confined to `/Users/isaac/Desktop/CSE4550-DigiGym-sprint-3`
on `isaac/sprint-3`. The original project directory was not modified. No commit,
push, merge, or rollout to remaining screens was performed. Stage 1 stops here
for dashboard design review.
