import 'dart:async';

import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../models/session.dart';
import '../models/user_profile.dart';
import '../services/grocery_list_controller.dart';
import '../services/meal_recommendation_service.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/digigym_dialog.dart';
import '../widgets/workout_app_bar.dart';

class GroceryScreen extends StatefulWidget {
  final GroceryListController? controller;
  final UserProfile? user;
  const GroceryScreen({super.key, this.controller, this.user});
  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  GroceryListController? _owned;
  Timer? _snackBarTimer;
  @override
  void dispose() {
    _snackBarTimer?.cancel();
    _owned?.dispose();
    super.dispose();
  }

  GroceryListController _controller() {
    if (widget.controller case final controller?) return controller;
    final profile = widget.user ?? DigiGymSession.currentUser;
    final account = profile?.email.trim().toLowerCase() ?? '';
    if (_owned?.accountKey != account) {
      _owned?.dispose();
      _owned = GroceryListController(accountKey: account);
    }
    _owned!.reconcile(
      profile == null
          ? []
          : const MealRecommendationService().recommend(profile),
      notify: false,
    );
    return _owned!;
  }

  Future<void> _addItem(GroceryListController controller) => showDialog<void>(
    context: context,
    builder: (_) => _CustomGroceryDialog(controller: controller),
  );

  @override
  Widget build(BuildContext context) {
    final controller = _controller();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: workoutAppBar(context, title: 'Groceries', large: true),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final items = controller.items;
            final purchased = controller.purchasedCount;
            return ListView(
              key: PageStorageKey(('groceries', controller.accountKey)),
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                DashboardGlassCard(
                  key: const ValueKey('grocery-summary'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR GROCERY LIST',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$purchased / ${items.length} items purchased',
                        style: theme.textTheme.titleLarge,
                        key: const ValueKey('grocery-purchased-count'),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: items.isEmpty ? 0 : purchased / items.length,
                        semanticsLabel:
                            'Grocery purchases: $purchased of ${items.length} items',
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 5,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your shopping list is based on your recommended meals.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Changes are saved for this session only.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const ValueKey('grocery-add'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DigiGymDarkColors.softGreen,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () => _addItem(controller),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add item'),
                ),
                if (items.isEmpty) ...[
                  const SizedBox(height: 20),
                  const DashboardGlassCard(
                    key: ValueKey('groceries-empty'),
                    child: Text(
                      'Your grocery list is empty. Add an item, or review your meal preferences.',
                    ),
                  ),
                ],
                for (final category in GroceryCategory.values)
                  if (items.any((item) => item.category == category)) ...[
                    const SizedBox(height: 24),
                    Text(
                      category.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DashboardGlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          for (final item in items.where(
                            (item) => item.category == category,
                          ))
                            Row(
                              key: ValueKey('grocery-row-${item.id}'),
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    key: ValueKey('grocery-check-${item.id}'),
                                    // Normal two-line rows: 72px -> 62px (~14%).
                                    // Wrapped/accessibility text can grow freely.
                                    dense: true,
                                    visualDensity: const VisualDensity(
                                      vertical: -.5,
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                    value: item.purchased,
                                    onChanged: (value) => controller
                                        .setPurchased(item.id, value ?? false),
                                    title: Text(
                                      item.name,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            decoration: item.purchased
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: item.purchased
                                                ? theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                : theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    subtitle: Text(
                                      item.quantityLabel.isEmpty
                                          ? 'Custom item'
                                          : item.quantityLabel,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove ${item.name}',
                                  onPressed: () {
                                    controller.remove(item.id);
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );

                                    final snackBarController = messenger
                                        .showSnackBar(
                                          SnackBar(
                                            duration: const Duration(
                                              seconds: 5,
                                            ),
                                            content: const Text(
                                              'Grocery item removed',
                                            ),
                                            action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () =>
                                                  controller.restore(item),
                                            ),
                                          ),
                                        );
                                    _snackBarTimer?.cancel();

                                    _snackBarTimer = Timer(
                                      const Duration(seconds: 5),
                                      () {
                                        if (mounted) {
                                          snackBarController.close();
                                        }
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: DigiGymDarkColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CustomGroceryDialog extends StatefulWidget {
  final GroceryListController controller;
  const _CustomGroceryDialog({required this.controller});
  @override
  State<_CustomGroceryDialog> createState() => _CustomGroceryDialogState();
}

class _CustomGroceryDialogState extends State<_CustomGroceryDialog> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _form = GlobalKey<FormState>();
  IngredientUnit _unit = IngredientUnit.item;
  GroceryCategory _category = GroceryCategory.pantry;
  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DigiGymDialog(
    title: 'Add grocery item',
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const ValueKey('grocery-custom-name'),
            controller: _name,
            autofocus: true,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Item name'),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Enter an item name.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const ValueKey('grocery-custom-quantity'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Quantity (optional)'),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return null;
              final parsed = double.tryParse(value!.trim());
              return parsed == null ||
                      !parsed.isFinite ||
                      parsed <= 0 ||
                      !IngredientQuantity(parsed, _unit).baseAmount.isFinite
                  ? 'Enter a positive quantity.'
                  : null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<IngredientUnit>(
            initialValue: _unit,
            isExpanded: true,
            itemHeight: null,
            decoration: const InputDecoration(labelText: 'Unit'),
            items: const [
              DropdownMenuItem(
                value: IngredientUnit.item,
                child: Text('Items'),
              ),
              DropdownMenuItem(
                value: IngredientUnit.ounce,
                child: Text('Ounces (oz)'),
              ),
              DropdownMenuItem(
                value: IngredientUnit.fluidOunce,
                child: Text('Fluid ounces (fl oz)'),
              ),
            ],
            onChanged: (value) => setState(() => _unit = value!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<GroceryCategory>(
            initialValue: _category,
            isExpanded: true,
            itemHeight: null,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final value in GroceryCategory.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
            onChanged: (value) => setState(() => _category = value!),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          final quantity = double.tryParse(_amount.text.trim());
          widget.controller.addCustom(
            _name.text,
            quantity: quantity == null
                ? null
                : IngredientQuantity(quantity, _unit),
            category: _category,
          );
          Navigator.pop(context);
        },
        child: const Text('Add item'),
      ),
    ],
  );
}
