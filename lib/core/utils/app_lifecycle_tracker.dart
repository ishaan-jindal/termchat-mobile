import 'package:flutter/material.dart';

class AppLifecycleTracker with WidgetsBindingObserver {
  static final AppLifecycleTracker instance = AppLifecycleTracker._();
  AppLifecycleTracker._();

  AppLifecycleState state = AppLifecycleState.resumed;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
  }

  bool get isBackground =>
      state == AppLifecycleState.paused || state == AppLifecycleState.inactive;
}
