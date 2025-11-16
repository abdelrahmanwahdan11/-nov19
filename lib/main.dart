import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/controllers/app_controllers.dart';
import 'core/controllers/app_scope.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/gradient_background.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/collections/collection_create_screen.dart';
import 'features/collections/collection_details_screen.dart';
import 'features/collections/collection_guests_screen.dart';
import 'features/collections/collection_itinerary_screen.dart';
import 'features/collections/collection_journal_screen.dart';
import 'features/collections/collection_roadmap_screen.dart';
import 'features/collections/collection_logistics_screen.dart';
import 'features/collections/collection_budget_screen.dart';
import 'features/collections/collection_vendors_screen.dart';
import 'features/collections/collection_documents_screen.dart';
import 'features/collections/collections_screen.dart';
import 'features/collections/task_schedule_screen.dart';
import 'features/compare/compare_screen.dart';
import 'features/gallery/gallery_screen.dart';
import 'features/home/home_shell.dart';
import 'features/home/insights_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final controllers = AppControllers(prefs);
  runApp(NuviqApp(controllers: controllers));
}

class NuviqApp extends StatefulWidget {
  const NuviqApp({super.key, required this.controllers});

  final AppControllers controllers;

  @override
  State<NuviqApp> createState() => _NuviqAppState();
}

class _NuviqAppState extends State<NuviqApp> {
  @override
  Widget build(BuildContext context) {
    final listenable = Listenable.merge([
      widget.controllers.themeController,
      widget.controllers.settingsController,
      widget.controllers.authController,
      widget.controllers.onboardingController,
    ]);

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final themeController = widget.controllers.themeController;
        final settingsController = widget.controllers.settingsController;
        final locale = settingsController.locale;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nuviq Event Collections',
          theme: AppTheme.light(themeController.primaryColor),
          darkTheme: AppTheme.dark(themeController.primaryColor),
          themeMode: themeController.themeMode,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AppScope(
              controllers: widget.controllers,
              child: Directionality(
                textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child: GradientBackground(
                  dark: isDark,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const RootDecider());
              case '/onboarding':
                return MaterialPageRoute(builder: (_) => const OnboardingScreen());
              case '/auth/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/auth/register':
                return MaterialPageRoute(builder: (_) => const RegisterScreen());
              case '/auth/forgot_password':
                return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
              case '/home':
                return MaterialPageRoute(builder: (_) => const HomeShell());
              case '/insights':
                return MaterialPageRoute(builder: (_) => const InsightsScreen());
              case '/collections':
                return MaterialPageRoute(builder: (_) => const CollectionsScreen());
              case '/collection_details':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionDetailsScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_create':
                return MaterialPageRoute(builder: (_) => const CollectionCreateScreen());
              case '/collection_tasks':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => TaskScheduleScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_journal':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionJournalScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_guests':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionGuestsScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_itinerary':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionItineraryScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_logistics':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionLogisticsScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_budget':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionBudgetScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_documents':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionDocumentsScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_vendors':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionVendorsScreen(collectionId: id ?? 'c1'),
                );
              case '/collection_roadmap':
                final id = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => CollectionRoadmapScreen(collectionId: id ?? 'c1'),
                );
              case '/gallery':
                return MaterialPageRoute(builder: (_) => const GalleryScreen());
              case '/catalog':
                return MaterialPageRoute(builder: (_) => const CatalogScreen());
              case '/compare':
                return MaterialPageRoute(builder: (_) => const CompareScreen());
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsScreen());
              default:
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Center(
                      child: Text('Route not found ${settings.name}'),
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final onboardingDone = controllers.onboardingController.completed;
    if (!onboardingDone) {
      return const OnboardingScreen();
    }
    if (!controllers.authController.isLoggedIn && !controllers.authController.isGuest) {
      return const LoginScreen();
    }
    return const HomeShell();
  }
}
