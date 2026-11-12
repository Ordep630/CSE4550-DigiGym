import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/session.dart';
import '../services/digigym_api.dart';
import '../widgets/digigym_form_components.dart';
import '../widgets/imperial_height_input.dart';
import '../utils/measurement_units.dart';

class AssessmentScreen extends StatefulWidget {
  final DigiGymApi api;
  final VoidCallback? onComplete;

  const AssessmentScreen({super.key, this.api = digiGymApi, this.onComplete});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late final TextEditingController nameController;
  final ageController = TextEditingController();
  final feetController = TextEditingController();
  final inchesController = TextEditingController();
  final weightController = TextEditingController();

  String fitnessLevel = 'Beginner';
  String goal = 'Lose Weight';
  String diet = 'No Restrictions';
  String bodyType = 'Average';
  int workoutTime = 30;

  bool isCreatingPlan = false;
  late final UserProfile? _assessmentUser;
  String? _initialFeet;
  String? _initialInches;
  String? _initialWeight;
  double? _originalHeight;
  double? _originalWeight;

  @override
  void initState() {
    super.initState();
    _assessmentUser = DigiGymSession.pendingUser;
    nameController = TextEditingController(text: _assessmentUser?.name ?? '');
    // Only a recovered server draft has an auth UUID. Fresh registration keeps
    // its existing blank inputs. Never replace recovered values with defaults.
    final draft = _assessmentUser;
    if (draft != null && draft.accountId != null) {
      ageController.text = draft.age > 0 ? '${draft.age}' : '';
      if (draft.height.isFinite && draft.height > 0) {
        final height = MeasurementUnits.centimetersToFeetInches(
          draft.height,
          fractionDigits: 1,
        );
        _originalHeight = draft.height;
        feetController.text = _initialFeet = '${height.feet}';
        inchesController.text = _initialInches = '${height.inches}';
      }
      if (draft.weight.isFinite && draft.weight > 0) {
        _originalWeight = draft.weight;
        weightController.text = _initialWeight =
            MeasurementUnits.kilogramsToPounds(draft.weight).toStringAsFixed(1);
      }
      fitnessLevel = draft.fitnessLevel;
      goal = draft.fitnessGoal;
      diet = draft.dietaryPreference == 'No Preference'
          ? 'No Restrictions'
          : draft.dietaryPreference;
      bodyType = draft.bodyType;
      workoutTime = draft.workoutTime;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    feetController.dispose();
    inchesController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> createPlan() async {
    if (isCreatingPlan) return;
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final parsedHeight = MeasurementUnits.parseHeight(
      feetController.text,
      inchesController.text,
    );
    final parsedWeight = MeasurementUnits.parseWeight(weightController.text);
    // Imperial display rounding must not rewrite a recovered metric value.
    final height =
        parsedHeight != null &&
            feetController.text.trim() == _initialFeet &&
            inchesController.text.trim() == _initialInches
        ? _originalHeight
        : parsedHeight;
    final weight =
        parsedWeight != null && weightController.text.trim() == _initialWeight
        ? _originalWeight
        : parsedWeight;
    final user = _assessmentUser;

    if (user == null ||
        !identical(user, DigiGymSession.pendingUser) ||
        name.isEmpty ||
        age == null ||
        age <= 0 ||
        height == null ||
        height <= 0 ||
        weight == null ||
        weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a name and valid age, height, and weight.'),
        ),
      );
      return;
    }

    setState(() {
      isCreatingPlan = true;
    });

    try {
      final dietaryPreference = diet == 'No Restrictions'
          ? 'No Preference'
          : diet;

      final savedUser = await widget.api.updateProfile(
        UserProfile(
          accountId: user.accountId,
          name: name,
          email: user.email,
          age: age,
          height: height,
          weight: weight,
          fitnessLevel: fitnessLevel,
          fitnessGoal: goal,
          workoutTime: workoutTime,
          dietaryPreference: dietaryPreference,
          bodyType: bodyType,
        ),
      );

      if (!savedUser.hasCompletedAssessment ||
          (user.accountId != null && savedUser.accountId != user.accountId)) {
        throw StateError('The assessment save was not confirmed.');
      }

      // Registration signs the user in. Sign out after the assessment because
      // this flow intentionally returns to the login screen.
      await widget.api.signOut();

      if (!mounted) return;

      DigiGymSession.registeredUser = savedUser;
      DigiGymSession.clearPendingRegistration();

      if (widget.onComplete != null) {
        widget.onComplete!();
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please log in.')),
      );
    } on ArgumentError {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a supported fitness level and goal.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save your assessment. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCreatingPlan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DigiGymFormPage(
      title: 'Fitness Assessment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DigiGymFormBranding(),
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DigiGymGlassField(
            child: TextField(
              controller: nameController,
              decoration: digiGymFormDecoration('Name'),
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: digiGymFormDecoration('Age'),
            ),
          ),
          const SizedBox(height: 15),
          ImperialHeightInput(
            feetController: feetController,
            inchesController: inchesController,
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: TextField(
              key: const ValueKey('weight-lb'),
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: digiGymFormDecoration('Weight (lb)'),
            ),
          ),
          const SizedBox(height: 20),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: fitnessLevel,
              decoration: digiGymFormDecoration('Fitness Level'),
              items: ['Beginner', 'Intermediate', 'Advanced']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  fitnessLevel = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: goal,
              decoration: digiGymFormDecoration('Fitness Goal'),
              items:
                  [
                        'Lose Weight',
                        'Build Muscle',
                        'Gain Weight',
                        'Maintain Weight',
                      ]
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  goal = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: diet,
              decoration: digiGymFormDecoration('Diet'),
              items:
                  {
                        'No Restrictions',
                        'Vegetarian',
                        'Vegan',
                        'High Protein',
                        diet,
                      }
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  diet = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: bodyType,
              decoration: digiGymFormDecoration('Body Type'),
              items: {'Slim', 'Average', 'Athletic', 'Heavy', bodyType}
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  bodyType = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              itemHeight: null,
              initialValue: workoutTime,
              decoration: digiGymFormDecoration('Available Workout Time'),
              items: {15, 30, 45, 60, workoutTime}
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('$value minutes'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  workoutTime = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 30),
          DigiGymPrimaryButton(
            label: 'Create My Plan',
            loading: isCreatingPlan,
            onPressed: createPlan,
          ),
        ],
      ),
    );
  }
}
