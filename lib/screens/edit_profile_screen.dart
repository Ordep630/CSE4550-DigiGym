import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/digigym_api.dart';
import '../widgets/digigym_form_components.dart';
import '../widgets/imperial_height_input.dart';
import '../utils/measurement_units.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;
  final DigiGymApi api;

  const EditProfileScreen({
    super.key,
    required this.user,
    this.api = digiGymApi,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController feetController;
  late TextEditingController inchesController;
  late TextEditingController weightController;
  late TextEditingController workoutTimeController;

  late String fitnessLevel;
  late String fitnessGoal;
  late String dietaryPreference;
  late String bodyType;
  bool isSaving = false;
  late final ({int feet, double inches}) _initialHeight;
  late final double _initialPounds;
  late final double _originalHeight;
  late final double _originalWeight;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user.name);
    ageController = TextEditingController(text: widget.user.age.toString());
    _originalHeight = widget.user.height;
    _originalWeight = widget.user.weight;
    _initialHeight = MeasurementUnits.centimetersToFeetInches(
      widget.user.height,
      fractionDigits: 1,
    );
    _initialPounds = double.parse(
      MeasurementUnits.kilogramsToPounds(widget.user.weight).toStringAsFixed(1),
    );
    feetController = TextEditingController(text: '${_initialHeight.feet}');
    inchesController = TextEditingController(text: '${_initialHeight.inches}');
    weightController = TextEditingController(
      text: _initialPounds.toStringAsFixed(1),
    );
    workoutTimeController = TextEditingController(
      text: widget.user.workoutTime.toString(),
    );

    fitnessLevel = widget.user.fitnessLevel;
    fitnessGoal = widget.user.fitnessGoal;
    dietaryPreference = widget.user.dietaryPreference;
    bodyType = widget.user.bodyType;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    feetController.dispose();
    inchesController.dispose();
    weightController.dispose();
    workoutTimeController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (isSaving) return;
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final parsedHeight = MeasurementUnits.parseHeight(
      feetController.text,
      inchesController.text,
    );
    final parsedWeight = MeasurementUnits.parseWeight(weightController.text);
    // Display rounding must not change a stored measurement on an unchanged save.
    final height =
        parsedHeight != null &&
            int.tryParse(feetController.text.trim()) == _initialHeight.feet &&
            double.tryParse(inchesController.text.trim()) ==
                _initialHeight.inches
        ? _originalHeight
        : parsedHeight;
    final weight =
        parsedWeight != null &&
            double.tryParse(weightController.text.trim()) == _initialPounds
        ? _originalWeight
        : parsedWeight;
    final workoutTime = int.tryParse(workoutTimeController.text.trim());

    if (name.isEmpty ||
        age == null ||
        age <= 0 ||
        height == null ||
        height <= 0 ||
        weight == null ||
        weight <= 0 ||
        workoutTime == null ||
        workoutTime <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid profile values.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      var updatedUser = UserProfile(
        name: name,
        email: widget.user.email,
        age: age,
        height: height,
        weight: weight,
        fitnessLevel: fitnessLevel,
        fitnessGoal: fitnessGoal,
        workoutTime: workoutTime,
        dietaryPreference: dietaryPreference,
        bodyType: bodyType,
        isDemo: widget.user.isDemo,
      );

      // The demo account is intentionally local-only.
      if (!widget.user.isDemo) {
        updatedUser = await widget.api.updateProfile(updatedUser);
      }

      if (!mounted) return;
      Navigator.pop(context, updatedUser);
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
            'Unable to save your profile. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DigiGymFormPage(
      title: 'Edit Profile',
      child: Column(
        children: [
          DigiGymGlassField(
            child: TextField(
              controller: nameController,
              decoration: digiGymFormDecoration('Name', icon: Icons.person),
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: digiGymFormDecoration('Age', icon: Icons.cake),
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
              decoration: digiGymFormDecoration(
                'Weight (lb)',
                icon: Icons.monitor_weight,
              ),
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: fitnessLevel,
              decoration: digiGymFormDecoration('Fitness Level'),
              items: const [
                DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                DropdownMenuItem(
                  value: 'Intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => fitnessLevel = value);
                }
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: fitnessGoal,
              decoration: digiGymFormDecoration('Fitness Goal'),
              items: const [
                DropdownMenuItem(
                  value: 'Lose Weight',
                  child: Text('Lose Weight'),
                ),
                DropdownMenuItem(
                  value: 'Build Muscle',
                  child: Text('Build Muscle'),
                ),
                DropdownMenuItem(
                  value: 'Gain Weight',
                  child: Text('Gain Weight'),
                ),
                DropdownMenuItem(
                  value: 'Maintain Weight',
                  child: Text('Maintain Weight'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => fitnessGoal = value);
                }
              },
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: TextField(
              controller: workoutTimeController,
              keyboardType: TextInputType.number,
              decoration: digiGymFormDecoration(
                'Available Workout Time (minutes)',
                icon: Icons.timer,
              ),
            ),
          ),
          const SizedBox(height: 15),
          DigiGymGlassField(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: dietaryPreference,
              decoration: digiGymFormDecoration('Dietary Preference'),
              items: const [
                DropdownMenuItem(
                  value: 'No Preference',
                  child: Text('No Preference'),
                ),
                DropdownMenuItem(
                  value: 'Vegetarian',
                  child: Text('Vegetarian'),
                ),
                DropdownMenuItem(value: 'Vegan', child: Text('Vegan')),
                DropdownMenuItem(
                  value: 'High Protein',
                  child: Text('High Protein'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => dietaryPreference = value);
                }
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
              items: const [
                DropdownMenuItem(value: 'Slim', child: Text('Slim')),
                DropdownMenuItem(value: 'Average', child: Text('Average')),
                DropdownMenuItem(value: 'Athletic', child: Text('Athletic')),
                DropdownMenuItem(value: 'Heavy', child: Text('Heavy')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => bodyType = value);
                }
              },
            ),
          ),
          const SizedBox(height: 25),
          DigiGymPrimaryButton(
            label: isSaving ? 'SAVING...' : 'SAVE CHANGES',
            loading: isSaving,
            onPressed: saveProfile,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }
}
