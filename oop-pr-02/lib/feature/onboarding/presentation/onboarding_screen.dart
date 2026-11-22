import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surf_mad_teacher_training/feature/onboarding/domain/entities/onboarding_step_type.dart';
import 'package:surf_mad_teacher_training/feature/onboarding/presentation/onboarding_wm.dart';
import 'package:surf_mad_teacher_training/feature/onboarding/presentation/utils/extension/onboarding_step_extension.dart';

/// Экран знакомства с тремя функциями приложения.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.wm, super.key});

  final IOnboardingWM wm;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final _pages = PageController(initialPage: widget.wm.currentStepIndex);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = OnboardingStepType.values;
    final wm = widget.wm;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Онбординг'),
        actions: [TextButton(onPressed: wm.onSkipOnboardingPressed, child: const Text('Пропустить'))],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: wm,
          builder:
              (context, _) => Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: steps.length,
                      onPageChanged: (index) => wm.onGoToStepByIndex(stepIndex: index),
                      itemBuilder: (context, index) {
                        final step = steps[index];
                        return Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                SvgPicture.asset(step.icon, width: 105, height: 105),
                                const SizedBox(height: 28),
                                Text(step.title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                Text(step.description, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Semantics(
                    label: 'Страница ${wm.currentStepIndex + 1} из ${steps.length}',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < steps.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == wm.currentStepIndex ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  i == wm.currentStepIndex
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            wm.isLastStep
                                ? wm.onFinishOnboardingPressed
                                : () =>
                                    _pages.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut),
                        child: Text(wm.isLastStep ? 'На старт' : 'Далее'),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
