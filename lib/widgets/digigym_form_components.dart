import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/digigym_dashboard_theme.dart';
import 'digigym_page_shell.dart';

/// Shared authentication/profile presentation. Login keeps its approved layout.
class DigiGymFormPage extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;

  const DigiGymFormPage({
    super.key,
    required this.title,
    required this.child,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) => DigiGymPageShell(
    child: Builder(
      // The title scrolls with the form so 3x text plus an open keyboard
      // cannot consume the entire viewport with a fixed-height header.
      builder: (context) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
              child: Row(
                children: [
                  if (showBack && Navigator.canPop(context))
                    const BackButton(color: DigiGymDarkColors.electricGreen)
                  else
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class DigiGymFormBranding extends StatelessWidget {
  const DigiGymFormBranding({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'DigiGym',
    image: true,
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [
          Image.asset(
            'assets/images/digigym_workout_icon.png',
            width: 96,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/digigym_wordmark.png',
            width: 152,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
        ],
      ),
    ),
  );
}

/// Blur is confined to each input, while inline errors can grow without clips.
class DigiGymGlassField extends StatelessWidget {
  final Widget child;
  const DigiGymGlassField({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x801F2925), Color(0x40101815)],
                ),
              ),
            ),
          ),
        ),
      ),
      child,
    ],
  );
}

InputDecoration digiGymFormDecoration(String label, {IconData? icon}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    borderSide: BorderSide(color: color),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: DigiGymDarkColors.secondaryText),
    prefixIcon: icon == null ? null : Icon(icon, size: 24),
    prefixIconColor: DigiGymDarkColors.secondaryText,
    suffixIconColor: DigiGymDarkColors.secondaryText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    constraints: const BoxConstraints(minHeight: 60),
    filled: false,
    border: border(const Color(0x25D9E7DE)),
    enabledBorder: border(const Color(0x25D9E7DE)),
    focusedBorder: border(
      DigiGymDarkColors.electricGreen.withValues(alpha: .55),
    ),
    errorBorder: border(const Color(0xFFFFB4AB)),
    focusedErrorBorder: border(const Color(0xFFFFB4AB)),
    errorMaxLines: 10,
  );
}

class DigiGymPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const DigiGymPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF3CBF5F).withValues(alpha: loading ? .40 : 1),
          const Color(0xFF67E780).withValues(alpha: loading ? .40 : 1),
        ],
      ),
      boxShadow: loading
          ? null
          : [
              BoxShadow(
                color: DigiGymDarkColors.electricGreen.withValues(alpha: .15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
    ),
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        foregroundColor: DigiGymDarkColors.graphite,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        minimumSize: const Size(double.infinity, 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: loading
          ? SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DigiGymDarkColors.graphite,
                semanticsLabel: label,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 22),
                  const SizedBox(width: 8),
                ],
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            ),
    ),
  );
}
