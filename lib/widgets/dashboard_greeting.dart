import 'dart:async';

import 'package:flutter/material.dart';

import '../services/dashboard_personalization.dart';

class DashboardGreeting extends StatefulWidget {
  final TextStyle? style;
  final DateTime Function()? clock;

  const DashboardGreeting({super.key, this.style, this.clock});

  @override
  State<DashboardGreeting> createState() => _DashboardGreetingState();
}

class _DashboardGreetingState extends State<DashboardGreeting>
    with WidgetsBindingObserver {
  Timer? _timer;
  late String _greeting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh(notify: false);
  }

  void _refresh({bool notify = true}) {
    final now = (widget.clock ?? DateTime.now)().toLocal();
    final greeting = DashboardPersonalization.greetingFor(now);
    if (notify && greeting != _greeting) {
      setState(() => _greeting = greeting);
    } else {
      _greeting = greeting;
    }
    _timer?.cancel();
    _timer = Timer(
      DashboardPersonalization.nextGreetingChange(now).difference(now),
      _refresh,
    );
  }

  @override
  void didUpdateWidget(DashboardGreeting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clock != widget.clock) _refresh(notify: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(_greeting, style: widget.style);
}
