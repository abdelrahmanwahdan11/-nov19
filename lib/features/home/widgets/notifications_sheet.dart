import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../../core/controllers/app_scope.dart';
import '../../../core/localization/app_localizations.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final localization = AppLocalizations.of(context);
    final reduceMotion = controllers.settingsController.reduceAnimations;
    final notificationsController = controllers.notificationsController;

    return AnimatedBuilder(
      animation: notificationsController,
      builder: (context, _) {
        final items = notificationsController.items;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  )
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(localization.t('notifications'), style: Theme.of(context).textTheme.titleLarge),
                            Text(localization.t('notificationsSubtitle'),
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed:
                            notificationsController.unreadCount == 0 ? null : notificationsController.markAllRead,
                        child: Text(localization.t('markAllRead')),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: notificationsController.filters
                          .map(
                            (filter) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(_labelForFilter(filter, localization)),
                                selected: notificationsController.filter == filter,
                                onSelected: (_) => notificationsController.filterBy(filter),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(localization.t('notificationsEmpty')),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemBuilder: (_, index) {
                          final item = items[index];
                          final icon = _iconForType(item.type);
                          return AnimatedOpacity(
                            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
                            opacity: item.read ? 0.6 : 1,
                            child: ListTile(
                              onTap: () => notificationsController.toggleRead(item.id),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                                child: Icon(icon, color: Theme.of(context).primaryColor),
                              ),
                              title: Text(item.title),
                              subtitle: Text('${item.body}\n${_formatTime(item.time, localization)}'),
                              isThreeLine: true,
                              trailing: Icon(
                                item.read ? IconlyLight.show : IconlyLight.notification,
                                color: item.read ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                        itemCount: items.length,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Tasks':
        return IconlyBold.paper;
      case 'Gallery':
        return IconlyBold.image;
      default:
        return IconlyBold.notification;
    }
  }

  String _formatTime(DateTime time, AppLocalizations localization) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return localization.t('minutesAgo').replaceFirst('%d', difference.inMinutes.toString());
    }
    if (difference.inHours < 24) {
      return localization.t('hoursAgo').replaceFirst('%d', difference.inHours.toString());
    }
    return localization.t('daysAgo').replaceFirst('%d', difference.inDays.toString());
  }
}

String _labelForFilter(String filter, AppLocalizations localization) {
  switch (filter) {
    case 'Planning':
      return localization.t('planning');
    case 'Tasks':
      return localization.t('tasks');
    case 'Gallery':
      return localization.t('gallery');
    default:
      return localization.t('galleryFilterAll');
  }
}
