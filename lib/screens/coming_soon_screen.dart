import 'package:flutter/material.dart';

import '../widgets/profile_components.dart';

/// Shared honest placeholder; the supplied artwork already contains its title.
class ComingSoonScreen extends StatelessWidget {
  static const illustrationAsset = 'assets/images/digigym_coming_soon.png';
  final String feature;

  const ComingSoonScreen({super.key, required this.feature});

  @override
  Widget build(BuildContext context) => ProfileDestinationScaffold(
    child: Semantics(
      label: '$feature. Coming soon.',
      image: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Image.asset(
              illustrationAsset,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    ),
  );
}
