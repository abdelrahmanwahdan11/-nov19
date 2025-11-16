import 'package:shared_preferences/shared_preferences.dart';

import 'auth_controller.dart';
import 'catalog_controller.dart';
import 'collections_controller.dart';
import 'gallery_controller.dart';
import 'onboarding_controller.dart';
import 'settings_controller.dart';
import 'theme_controller.dart';

class AppControllers {
  AppControllers(this.prefs)
      : themeController = ThemeController(prefs),
        authController = AuthController(prefs),
        onboardingController = OnboardingController(prefs),
        collectionsController = CollectionsController(),
        galleryController = GalleryController(),
        catalogController = CatalogController(),
        settingsController = SettingsController(prefs);

  final SharedPreferences prefs;
  final ThemeController themeController;
  final AuthController authController;
  final OnboardingController onboardingController;
  final CollectionsController collectionsController;
  final GalleryController galleryController;
  final CatalogController catalogController;
  final SettingsController settingsController;
}
