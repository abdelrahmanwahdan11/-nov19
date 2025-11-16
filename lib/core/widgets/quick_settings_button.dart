import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../controllers/app_scope.dart';
import '../localization/app_localizations.dart';

class QuickSettingsButton extends StatelessWidget {
  const QuickSettingsButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return IconButton(
      icon: Icon(IconlyLight.setting, color: iconColor),
      tooltip: localization.t('quickSettings'),
      onPressed: () => _openSheet(context),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _QuickSettingsSheet(),
    );
  }
}

class _QuickSettingsSheet extends StatelessWidget {
  const _QuickSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    final listenable = Listenable.merge([
      controllers.themeController,
      controllers.settingsController,
      controllers.authController,
    ]);

    final colorOptions = <Color>[
      const Color(0xFFB4DC3A),
      const Color(0xFFFFA45B),
      const Color(0xFF7DD3FC),
      const Color(0xFFE879F9),
      const Color(0xFF4ADE80),
    ];

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final theme = Theme.of(context);
        final isLoggedIn = controllers.authController.isLoggedIn;
        final isGuest = controllers.authController.isGuest;
        final accountLabel = isLoggedIn
            ? localization.t('accountLoggedIn')
            : isGuest
                ? localization.t('accountGuest')
                : localization.t('accountLoggedOut');

        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Text(
                      localization.t('quickSettings'),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localization.t('quickSettingsDescription'),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 24),
                    Text(localization.t('language'), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: AppLocalizations.supportedLocales.map((locale) {
                        final selected = controllers.settingsController.locale.languageCode == locale.languageCode;
                        final label = locale.languageCode == 'ar'
                            ? localization.t('arabic')
                            : localization.t('english');
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) => controllers.settingsController.updateLocale(locale),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(localization.t('theme'), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: ThemeMode.values.map((mode) {
                        final labels = {
                          ThemeMode.system: localization.t('themeSystem'),
                          ThemeMode.light: localization.t('themeLight'),
                          ThemeMode.dark: localization.t('themeDark'),
                        };
                        return ChoiceChip(
                          label: Text(labels[mode] ?? mode.name),
                          selected: controllers.themeController.themeMode == mode,
                          onSelected: (_) => controllers.themeController.updateThemeMode(mode),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(localization.t('primaryColor'), style: theme.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: colorOptions.map((color) {
                        final isSelected = controllers.themeController.primaryColor.value == color.value;
                        return GestureDetector(
                          onTap: () => controllers.themeController.updatePrimaryColor(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(localization.t('account'), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                        child: Icon(IconlyLight.profile, color: theme.colorScheme.primary),
                      ),
                      title: Text(accountLabel),
                      subtitle: Text(isLoggedIn
                          ? localization.t('manageAccount')
                          : localization.t('accountQuickActionsHint')),
                      trailing: FilledButton(
                        onPressed: () {
                          if (isLoggedIn) {
                            controllers.authController.logout();
                          } else {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed('/auth/login');
                          }
                        },
                        child: Text(isLoggedIn ? localization.t('logout') : localization.t('login')),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/settings');
                            },
                            child: Text(localization.t('openFullSettings')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(localization.t('close')),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
