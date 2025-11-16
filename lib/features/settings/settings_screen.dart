import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final localization = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(localization.t('settings'))),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          controllers.settingsController,
          controllers.themeController,
        ]),
        builder: (context, _) {
          final settings = controllers.settingsController;
          final theme = controllers.themeController;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ListTile(
                leading: CircleAvatar(child: Text(localization.t('guest').characters.first)),
                title: Text(localization.t('profileName')),
                subtitle: Text(localization.t('guest')),
                trailing: IconButton(
                  icon: const Icon(IconlyLight.logout),
                  onPressed: () async {
                    await controllers.authController.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/auth/login', (route) => false);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(localization.t('language'), style: Theme.of(context).textTheme.titleMedium),
              RadioListTile(
                value: const Locale('ar'),
                groupValue: settings.locale,
                onChanged: (value) => settings.updateLocale(value!),
                title: Text(localization.t('arabic')),
              ),
              RadioListTile(
                value: const Locale('en'),
                groupValue: settings.locale,
                onChanged: (value) => settings.updateLocale(value!),
                title: Text(localization.t('english')),
              ),
              const SizedBox(height: 16),
              Text(localization.t('theme'), style: Theme.of(context).textTheme.titleMedium),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.light, label: Text(localization.t('light'))),
                  ButtonSegment(value: ThemeMode.dark, label: Text(localization.t('dark'))),
                  ButtonSegment(value: ThemeMode.system, label: Text(localization.t('system'))),
                ],
                selected: {theme.themeMode},
                onSelectionChanged: (value) => theme.updateThemeMode(value.first),
              ),
              const SizedBox(height: 16),
              Text(localization.t('primaryColor'), style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 12,
                children: DummyData.primaryChoices
                    .map((color) => GestureDetector(
                          onTap: () => theme.updatePrimaryColor(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: theme.primaryColor == color ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SwitchListTile(
                title: Text(localization.t('reduceAnimations')),
                value: settings.reduceAnimations,
                onChanged: settings.toggleReduceAnimations,
              ),
              SwitchListTile(
                title: Text(localization.t('digestTitle')),
                subtitle: Text(localization.t('digestDescription')),
                value: settings.digestEnabled,
                onChanged: settings.toggleDigest,
              ),
              const SizedBox(height: 24),
              ListTile(
                title: Text(localization.t('about')),
                subtitle: Text(localization.t('aboutDescription')),
              ),
              ElevatedButton(
                onPressed: () => settings.clearAll(),
                child: Text(localization.t('deleteData')),
              )
            ],
          );
        },
      ),
    );
  }
}
