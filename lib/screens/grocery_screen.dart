import 'package:flutter/material.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final Map<String, bool> items = {
    'Chicken breast': false,
    'Rice': false,
    'Broccoli': false,
    'Olive oil': false,
    'Oats': false,
    'Bananas': false,
    'Peanut butter': false,
    'Milk': false,
    'Greek yogurt': false,
    'Blueberries': false,
    'Strawberries': false,
    'Granola': false,
    'Lettuce': false,
    'Tomatoes': false,
    'Cucumber': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grocery List')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Weekly Grocery List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items.entries.map(
            (item) => CheckboxListTile(
              title: Text(item.key),
              value: item.value,
              onChanged: (value) {
                setState(() {
                  items[item.key] = value ?? false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}