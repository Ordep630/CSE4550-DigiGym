import 'package:digigym/widgets/dashboard_glass_card.dart';
import 'package:digigym_backend_client/digigym_backend_client.dart';
import 'package:flutter/material.dart';

import '../widgets/dashboard_card_action.dart';
import '../widgets/digigym_dialog.dart';
import '../widgets/digigym_page_shell.dart';

import '../client.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  List<FoodEntry> _entries = [];
  bool _loading = true;
  Object? _error;

  int get dailyCalories =>
      _entries.fold(0, (total, entry) => total + entry.calories);

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await client.foodEntry.findFoodEntries(DateTime.now());

      if (!mounted) return;

      setState(() {
        _entries = entries;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  Future<(String, int)?> _showFoodDialog({FoodEntry? entry}) async {
    final name = TextEditingController(text: entry?.name ?? '');
    final calories = TextEditingController(
      text: entry?.calories.toString() ?? '',
    );

    return showDialog<(String, int)>(
      context: context,
      builder: (context) => DigiGymDialog(
        title: entry == null ? 'Add Food' : 'Edit Food',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Food name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: calories,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories'),
            ),
          ],
        ),
        actions: [
          if (entry != null)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteFoodEntry(entry);
              },

              child: const Text('Delete'),
            ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          FilledButton(
            onPressed: () {
              final calorieValue = int.tryParse(calories.text);

              if (name.text.trim().isEmpty ||
                  calorieValue == null ||
                  calorieValue < 0) {
                return;
              }

              Navigator.pop(context, (name.text.trim(), calorieValue));
            },
            child: Text(entry == null ? 'Add Food' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFood() async {
    final food = await _showFoodDialog();

    if (food == null) return;

    await client.foodEntry.addFoodEntry(food.$1, food.$2, DateTime.now());

    await _loadEntries();
  }

  Future<void> _editFood(FoodEntry entry) async {
    final food = await _showFoodDialog(entry: entry);

    if (food == null) return;

    await client.foodEntry.updateFoodEntry(
      entry.id!,
      food.$1,
      food.$2,
      entry.consumedAt,
    );

    await _loadEntries();
  }

  Future<void> _deleteFoodEntry(FoodEntry entry) async {
    await client.foodEntry.deleteFoodEntry(entry.id!);
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DigiGymPageShell(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Calorie Tracker'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DashboardGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dailyCalories Cal',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text("Today's Food", style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Tap a food item to edit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              const Text('Unable to load food entries.')
            else if (_entries.isEmpty)
              const Text('No food entries yet.')
            else
              for (final entry in _entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.name),
                  trailing: Text('${entry.calories} Cal'),
                  onTap: () => _editFood(entry),
                ),

            const SizedBox(height: 20),
            DashboardCardAction(
              label: 'Add Food',
              onTap: () => _addFood(),
              child: DashboardGlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Add Food'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
