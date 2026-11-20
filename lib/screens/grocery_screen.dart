import 'dart:async';

import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../models/session.dart';
import '../models/user_profile.dart';
import '../services/grocery_list_controller.dart';
import '../services/meal_recommendation_service.dart';
import '../theme/digigym_dashboard_theme.dart';
import '../theme/digigym_screen_theme.dart';
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
    final light = DigiGymScreenTheme.isLight(context);
    final accent = DigiGymSurfaces.of(context).accent;
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
                12,
                20,
                112 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Text(
                  'YOUR SHOPPING LIST',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Everything you need.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check items off as you shop.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  key: const ValueKey('grocery-summary'),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF193D2C), Color(0xFF0C1D17)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFF426A50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'SHOPPING PROGRESS',
                              style: TextStyle(
                                color: Color(0xFFB3D3BE),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF315C41),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.shopping_basket_outlined,
                              color: Color(0xFF65ECA0),
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$purchased of ${items.length} items',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                        key: const ValueKey('grocery-purchased-count'),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: items.isEmpty ? 0 : purchased / items.length,
                        backgroundColor: const Color(0xFF355543),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF65ECA0),
                        ),
                        semanticsLabel:
                            'Grocery purchases: $purchased of ${items.length} items',
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your shopping list is based on your recommended meals.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB3D3BE),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Changes are saved for this session only.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB3D3BE),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const ValueKey('grocery-add'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _addItem(controller),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add grocery item'),
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
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.label,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${items.where((item) => item.category == category).length} items',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DashboardGlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          for (final item in items.where(
                            (item) => item.category == category,
                          ))
                            Container(
                              key: ValueKey('grocery-row-${item.id}'),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(
                                  alpha: light ? .065 : .09,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
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
                                      onChanged: (value) =>
                                          controller.setPurchased(
                                            item.id,
                                            value ?? false,
                                          ),
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
                                    icon: Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
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
    translucentSurface: DigiGymScreenTheme.isLight(context),
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
