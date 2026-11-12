import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/digigym_api.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/digigym_dialog.dart';
import '../widgets/profile_components.dart';
import '../widgets/workout_app_bar.dart';
import 'app_appearance_screen.dart';
import 'change_password_screen.dart';
import 'coming_soon_screen.dart';
import 'profile_details_screen.dart';
import 'edit_profile_screen.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile user;
  final Future<void> Function() onLogout;
  final Function(UserProfile) onUpdateProfile;
  final DigiGymApi api;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onUpdateProfile,
    this.api = digiGymApi,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => DigiGymDialog(
        title: 'Log Out',
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
            style: TextButton.styleFrom(
              foregroundColor: DigiGymDarkColors.destructive,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                shadows: [
                  Shadow(
                    color: DigiGymDarkColors.destructive.withValues(alpha: .45),
                    blurRadius: 6,
                  ),
                  Shadow(
                    color: DigiGymDarkColors.destructive.withValues(alpha: .18),
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

  @override
  Widget build(BuildContext context) {
    final theme = DigiGymDashboardTheme.content(
      DigiGymDashboardTheme.dark(Theme.of(context)),
    );
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
        body: SizedBox.expand(
          child: SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileUpperLighting(
                        child: DashboardGlassCard(
                          key: const ValueKey('profile-user-card'),
                          padding: EdgeInsets.zero,
                          child: ProfileGlassLighting(
                            child: Semantics(
                              button: true,
                              enabled: !isLoggingOut,
                              onTap: isLoggingOut ? null : openDetails,
                              label:
                                  'View profile details for ${widget.user.name}, ${widget.user.email}',
                              excludeSemantics: true,
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  excludeFromSemantics: true,
                                  onTap: isLoggingOut ? null : openDetails,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 21,
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final identity = Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.user.name,
                                              style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.user.email,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: DigiGymDarkColors
                                                    .secondaryText,
                                              ),
                                            ),
                                          ],
                                        );
                                        const chevron = Icon(
                                          Icons.chevron_right_rounded,
                                          size: 20,
                                          color:
                                              DigiGymDarkColors.secondaryText,
                                        );
                                        // Give account text the full width at accessible
                                        // scales instead of squeezing it beside an avatar.
                                        if (MediaQuery.textScalerOf(context)
                                                    .scale(19) >
                                                28 &&
                                            constraints.maxWidth < 400) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                children: [
                                                  ProfileAvatar(
                                                    name: widget.user.name,
                                                    size: 74,
                                                  ),
                                                  Spacer(),
                                                  chevron,
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              identity,
                                            ],
                                          );
                                        }
                                        return Row(
                                          children: [
                                            ProfileAvatar(
                                              name: widget.user.name,
                                              size: 74,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(child: identity),
                                            const SizedBox(width: 8),
                                            chevron,
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DashboardGlassCard(
                    key: const ValueKey('profile-settings-menu'),
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ProfileMenuRow(
                          label: 'Edit Profile',
                          icon: Icons.edit_outlined,
                          onTap: isLoggingOut
                              ? null
                              : () => editProfile(context),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ProfileMenuRow(
                          label: 'Preferences',
                          icon: Icons.tune_rounded,
                          onTap: isLoggingOut
                              ? null
                              : () => openComingSoon('Preferences'),
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
                              : () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AppAppearanceScreen(),
                                    ),
                                  );
                                },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ProfileMenuRow(
                          label: 'Change Password',
                          icon: Icons.lock_outline_rounded,
                          onTap: isLoggingOut
                              ? null
                              : () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChangePasswordScreen(api: widget.api),
                                    ),
                                  );
                                },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
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
                  const SizedBox(height: 16),
                  DashboardGlassCard(
                    padding: EdgeInsets.zero,
                    child: ProfileMenuRow(
                      key: const ValueKey('profile-logout'),
                      label: 'Log Out',
                      icon: Icons.logout_rounded,
                      color: DigiGymDarkColors.destructive,
                      glow: true,
                      loading: isLoggingOut,
                      onTap: isLoggingOut ? null : logout,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
