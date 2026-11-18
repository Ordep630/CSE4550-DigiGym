import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/digigym_api.dart';
import '../services/workout_start_preference.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_screen_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/digigym_dialog.dart';
import '../widgets/profile_components.dart';
import '../widgets/workout_app_bar.dart';
import 'app_appearance_screen.dart';
import 'change_password_screen.dart';
import 'coming_soon_screen.dart';
import 'profile_details_screen.dart';
import 'edit_profile_screen.dart';
import 'workout_preferences_screen.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile user;
  final Future<void> Function() onLogout;
  final Function(UserProfile) onUpdateProfile;
  final DigiGymApi api;
  final WorkoutStartPreference? workoutStartPreference;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
    this.api = digiGymApi,
    this.workoutStartPreference,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggingOut = false;

  Future<void> editProfile(BuildContext context) async {
    final updatedUser = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: widget.user, api: widget.api),
      ),
    );

    if (updatedUser != null) {
      widget.onUpdateProfile(updatedUser);
    }
  }

  Future<void> logout() async {
    final light = DigiGymScreenTheme.isLight(context);
    final destructive = light
        ? Theme.of(context).colorScheme.error
        : DigiGymDarkColors.destructive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DigiGymDialog(
        title: 'Log Out',
        translucentSurface: light,
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),

          TextButton(
            key: const ValueKey('confirm-logout'),
            style: TextButton.styleFrom(foregroundColor: destructive),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                shadows: light
                    ? null
                    : [
                        Shadow(
                          color: DigiGymDarkColors.destructive.withValues(
                            alpha: .45,
                          ),
                          blurRadius: 6,
                        ),
                        Shadow(
                          color: DigiGymDarkColors.destructive.withValues(
                            alpha: .18,
                          ),
                          blurRadius: 12,
                        ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await widget.onLogout();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to log out. Check your connection and retry.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  void openDetails() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileDetailsScreen(user: widget.user),
      ),
    );
  }

  void openComingSoon(String feature) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: '/profile/${feature.toLowerCase()}'),
        builder: (_) => ComingSoonScreen(feature: feature),
      ),
    );
  }

  void openPreferences() {
    final preference = widget.workoutStartPreference;
    if (preference == null) {
      openComingSoon('Preferences');
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutPreferencesScreen(preference: preference),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DigiGymScreenTheme.route(context);
    final light = theme.brightness == Brightness.light;
    final accent = DigiGymSurfaces.of(context).accent;
    final heroText = light ? theme.colorScheme.onSurface : Colors.white;
    final heroMuted = light
        ? theme.colorScheme.onSurfaceVariant
        : const Color(0xFFB8D4C5);

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: workoutAppBar(
          context,
          title: 'Profile',
          large: true,
          theme: theme,
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            key: PageStorageKey(('profile-scroll', widget.user.email)),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              120 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              // A prominent, tappable identity card. All values come from the
              // current UserProfile; there are no placeholder achievements.
              ProfileUpperLighting(
                child: DashboardGlassCard(
                  key: const ValueKey('profile-user-card'),
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: light
                              ? [
                                  const Color(0xFFE7F6ED),
                                  const Color(0xFFF7FCF8),
                                ]
                              : [
                                  const Color(0xFF1C4734),
                                  const Color(0xFF10231C),
                                ],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoggingOut ? null : openDetails,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      color: light
                                          ? accent
                                          : const Color(0xFF6DF3A2),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'MY ACCOUNT',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: heroMuted,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final identity = Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.user.name.trim().isEmpty
                                              ? 'Your profile'
                                              : widget.user.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                color: heroText,
                                                fontWeight: FontWeight.w800,
                                                height: 1.12,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          widget.user.email,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(color: heroMuted),
                                        ),
                                      ],
                                    );
                                    final avatar = ProfileAvatar(
                                      name: widget.user.name,
                                      size: 74,
                                    );
                                    if (constraints.maxWidth < 260 ||
                                        MediaQuery.textScalerOf(context)
                                                .scale(16) >
                                            23) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          avatar,
                                          const SizedBox(height: 14),
                                          identity,
                                        ],
                                      );
                                    }
                                    return Row(
                                      children: [
                                        avatar,
                                        const SizedBox(width: 16),
                                        Expanded(child: identity),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                Container(
                                  height: 1,
                                  color: light
                                      ? const Color(0x1A17452E)
                                      : const Color(0x33FFFFFF),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Text(
                                      'View personal details',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: heroText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: light
                                          ? accent
                                          : const Color(0xFF6DF3A2),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: isLoggingOut ? null : () => editProfile(context),
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Edit Profile'),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(54),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _ProfileSectionHeading(
                title: 'Your fitness profile',
                subtitle: 'Your current goals and preferences',
                theme: theme,
              ),
              const SizedBox(height: 12),
              DashboardGlassCard(
                key: const ValueKey('profile-fitness-summary'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                child: Column(
                  children: [
                    _ProfileSummaryRow(
                      icon: Icons.flag_outlined,
                      label: 'Fitness goal',
                      value: widget.user.fitnessGoal,
                      accent: accent,
                    ),
                    const Divider(height: 1),
                    _ProfileSummaryRow(
                      icon: Icons.fitness_center_outlined,
                      label: 'Fitness level',
                      value: widget.user.fitnessLevel,
                      accent: accent,
                    ),
                    const Divider(height: 1),
                    _ProfileSummaryRow(
                      icon: Icons.restaurant_menu_outlined,
                      label: 'Diet preference',
                      value: widget.user.dietaryPreference,
                      accent: accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _ProfileSectionHeading(
                title: 'Settings',
                subtitle: 'Customize your DigiGym experience',
                theme: theme,
              ),
              const SizedBox(height: 12),
              DashboardGlassCard(
                key: const ValueKey('profile-settings-menu'),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ProfileMenuRow(
                      label: 'Preferences',
                      icon: Icons.tune_rounded,
                      onTap: isLoggingOut ? null : openPreferences,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ProfileMenuRow(
                      label: 'Notifications',
                      icon: Icons.notifications_none_rounded,
                      onTap: isLoggingOut
                          ? null
                          : () => openComingSoon('Notifications'),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ProfileMenuRow(
                      label: 'App Appearance',
                      icon: Icons.dark_mode_outlined,
                      onTap: isLoggingOut
                          ? null
                          : () => Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AppAppearanceScreen(),
                              ),
                            ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    if (widget.user.accountId != null &&
                        !widget.user.isDemo &&
                        widget.api.authenticatedAccountId ==
                            widget.user.accountId) ...[
                      ProfileMenuRow(
                        key: const ValueKey('profile-change-password'),
                        label: 'Change Password',
                        icon: Icons.lock_outline_rounded,
                        onTap: isLoggingOut
                            ? null
                            : () => Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChangePasswordScreen(api: widget.api),
                                ),
                              ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                    ProfileMenuRow(
                      label: 'Help & Support',
                      icon: Icons.help_outline_rounded,
                      onTap: isLoggingOut
                          ? null
                          : () => openComingSoon('Help & Support'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DashboardGlassCard(
                padding: EdgeInsets.zero,
                child: ProfileMenuRow(
                  key: const ValueKey('profile-logout'),
                  label: 'Log Out',
                  icon: Icons.logout_rounded,
                  color: light
                      ? theme.colorScheme.error
                      : DigiGymDarkColors.destructive,
                  glow: !light,
                  loading: isLoggingOut,
                  onTap: isLoggingOut ? null : logout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final ThemeData theme;

  const _ProfileSectionHeading({
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _ProfileSummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _ProfileSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value.trim().isEmpty ? 'Not set' : value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
