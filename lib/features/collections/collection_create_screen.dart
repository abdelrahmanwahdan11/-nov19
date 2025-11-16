import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/constants/app_assets.dart';
import '../../core/localization/app_localizations.dart';

class CollectionCreateScreen extends StatefulWidget {
  const CollectionCreateScreen({super.key});

  @override
  State<CollectionCreateScreen> createState() => _CollectionCreateScreenState();
}

class _CollectionCreateScreenState extends State<CollectionCreateScreen> {
  int tabIndex = 0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final tabs = ['oneDay', 'multiDay', 'repeating'];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(localization.t('createManual'))),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.network(AppAssets.hero3d, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          ToggleButtons(
            isSelected: List.generate(tabs.length, (index) => index == tabIndex),
            onPressed: (index) => setState(() => tabIndex = index),
            borderRadius: BorderRadius.circular(30),
            children: tabs
                .map((t) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(localization.t(t)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _CreateForm(
                key: ValueKey(tabIndex),
                selectedDate: selectedDate,
                startTime: startTime,
                endTime: endTime,
                onSelectDate: (date) => setState(() => selectedDate = date),
                onSelectStart: (time) => setState(() => startTime = time),
                onSelectEnd: (time) => setState(() => endTime = time),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localization.t('save')),
        ),
      ),
    );
  }
}

class _CreateForm extends StatelessWidget {
  const _CreateForm({
    super.key,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.onSelectDate,
    required this.onSelectStart,
    required this.onSelectEnd,
  });

  final DateTime selectedDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<TimeOfDay> onSelectStart;
  final ValueChanged<TimeOfDay> onSelectEnd;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final days = List.generate(7, (index) => selectedDate.add(Duration(days: index)));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (_, index) {
                final date = days[index];
                final selected = date.day == selectedDate.day;
                return GestureDetector(
                  onTap: () => onSelectDate(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: selected ? Theme.of(context).primaryColor : Theme.of(context).cardTheme.color,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${date.day}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: selected ? Colors.white : null)),
                        Text('${date.month}', style: TextStyle(color: selected ? Colors.white70 : null)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: localization.t('description'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) onSelectStart(time);
                  },
                  icon: const Icon(IconlyLight.time_circle),
                  label: Text(startTime != null ? startTime!.format(context) : localization.t('addTime')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) onSelectEnd(time);
                  },
                  icon: const Icon(IconlyLight.time_circle),
                  label: Text(endTime != null ? endTime!.format(context) : localization.t('addTime')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            tileColor: Theme.of(context).cardTheme.color,
            leading: const Icon(IconlyLight.location),
            title: Text(localization.t('location')),
            subtitle: Text(localization.t('selectLocation')),
            trailing: IconButton(
              icon: const Icon(IconlyLight.arrow_right_2),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  builder: (_) => ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      ListTile(title: const Text('Riyadh rooftop'), onTap: () => Navigator.of(context).pop()),
                      ListTile(title: const Text('Dubai desert'), onTap: () => Navigator.of(context).pop()),
                      ListTile(title: const Text('Cairo old town'), onTap: () => Navigator.of(context).pop()),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
