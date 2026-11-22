import 'package:shared_preferences/shared_preferences.dart';

/// {@template onboarding_model}
/// Модель для OnboardingScreen.
/// {@endtemplate}
final class OnboardingModel implements IOnboardingModel {
  /// {@macro onboarding_model}
  const OnboardingModel();

  @override
  Future<void> saveOnboardingCompletion() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('onboarding_completed', true);
  }
}

abstract interface class IOnboardingModel {
  Future<void> saveOnboardingCompletion();
}
