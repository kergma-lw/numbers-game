import 'package:shared_preferences/shared_preferences.dart';

abstract interface class TutorialProgressStore {
  Future<bool> hasCompletedOrDismissed();
  Future<void> markCompletedOrDismissed();
}

class SharedPreferencesTutorialProgressStore implements TutorialProgressStore {
  static const _key = 'tutorial_completed_or_dismissed';

  @override
  Future<bool> hasCompletedOrDismissed() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_key) ?? false;
  }

  @override
  Future<void> markCompletedOrDismissed() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_key, true);
  }
}
