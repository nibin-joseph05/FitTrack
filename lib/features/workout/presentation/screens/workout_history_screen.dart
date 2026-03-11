import 'package:fit_track/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/workout_card.dart';
import '../providers/workout_provider.dart' hide DateTimeRange;

import 'package:intl/intl.dart';
import '../providers/workout_split_provider.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  DateTimeRange? _dateRange;
  String? _splitFilter;
  String? _muscleGroupFilter;

  final _muscleGroups = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Full Body',
    'Cardio',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: workoutsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          var filteredList = list.toList();
          if (_dateRange != null) {
            filteredList = filteredList.where((w) {
              final d = w.date;
              return d.isAfter(
                      _dateRange!.start.subtract(const Duration(days: 1))) &&
                  d.isBefore(_dateRange!.end.add(const Duration(days: 1)));
            }).toList();
          }
          if (_splitFilter != null) {
            filteredList =
                filteredList.where((w) => w.title == _splitFilter).toList();
          }
          if (_muscleGroupFilter != null) {
            filteredList = filteredList
                .where((w) =>
                    w.exercises.any((e) => e.muscleGroup == _muscleGroupFilter))
                .toList();
          }

          if (filteredList.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.search_off,
              title: 'No Matches Found',
              subtitle: 'Try adjusting your filters',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final w = filteredList[index];
              return Dismissible(
                key: Key(w.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(51), 
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.cardDark,
                      title: const Text('Delete Workout?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) => ref
                    .read(workoutHistoryProvider.notifier)
                    .deleteWorkout(w.id),
                child: WorkoutCard(
                  title: w.title,
                  date: w.date,
                  exerciseCount: w.exercises.length,
                  totalSets: w.totalSets,
                  totalVolume: w.totalVolume,
                  duration: w.duration,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.workoutDetail,
                    arguments: w.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateBuilder) {
          return AlertDialog(
            title: const Text('Filter History'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date Range'),
                  OutlinedButton(
                    onPressed: () async {
                      final res = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange,
                      );
                      if (res != null) {
                        setStateBuilder(() => _dateRange = res);
                      }
                    },
                    child: Text(_dateRange == null
                        ? 'Select Dates'
                        : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'),
                  ),
                  if (_dateRange != null)
                    TextButton(
                        onPressed: () =>
                            setStateBuilder(() => _dateRange = null),
                        child: const Text('Clear Date')),
                  const SizedBox(height: 16),
                  const Text('Split Used (Matches Title)'),
                  ref.watch(workoutSplitProvider).maybeWhen(
                        data: (splits) {
                          return DropdownButton<String?>(
                            isExpanded: true,
                            value: _splitFilter,
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('Any Split')),
                              ...splits.map((s) => DropdownMenuItem(
                                  value: s.name, child: Text(s.name))),
                            ],
                            onChanged: (v) =>
                                setStateBuilder(() => _splitFilter = v),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                  const SizedBox(height: 16),
                  const Text('Muscle Group'),
                  DropdownButton<String?>(
                    isExpanded: true,
                    value: _muscleGroupFilter,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Any Muscle Group')),
                      ..._muscleGroups.map(
                          (m) => DropdownMenuItem(value: m, child: Text(m))),
                    ],
                    onChanged: (v) =>
                        setStateBuilder(() => _muscleGroupFilter = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _dateRange = null;
                    _splitFilter = null;
                    _muscleGroupFilter = null;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Reset All',
                    style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(ctx);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        });
      },
    );
  }
}
