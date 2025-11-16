import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/controllers/onboarding_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  OnboardingController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= AppScope.of(context).onboardingController..startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final onboardingController = controllers.onboardingController;
    final localization = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization.t('appName'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await onboardingController.complete();
                      if (!mounted) return;
                      Navigator.of(context).pushReplacementNamed('/auth/login');
                    },
                    child: Text(localization.t('skip')),
                  )
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: onboardingController.pageController,
                  onPageChanged: onboardingController.updateIndex,
                  itemCount: DummyData.onboarding.length,
                  itemBuilder: (_, index) {
                    final page = DummyData.onboarding[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(36),
                              child: Image.network(page['image']!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
              AnimatedBuilder(
                animation: onboardingController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(DummyData.onboarding.length, (index) {
                      final active = onboardingController.index == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.all(4),
                        height: 10,
                        width: active ? 28 : 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(active ? 0.9 : 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: () => onboardingController.pageController.nextPage(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeInOut,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(localization.t('next'), style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(IconlyLight.arrow_right_2, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      label: localization.t('getStarted'),
                      onPressed: () async {
                        await onboardingController.complete();
                        if (!mounted) return;
                        Navigator.of(context).pushReplacementNamed('/auth/login');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
