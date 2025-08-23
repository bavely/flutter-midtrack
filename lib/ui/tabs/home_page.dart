import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/models/medication.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/dose_card.dart';
import '../widgets/medication_card.dart';
import '../widgets/progress_circle.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationState = ref.watch(medicationProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${authState.user?.name.split(' ').first ?? 'User'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(medicationProvider.notifier).reload();
        },
        child: medicationState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Adherence Summary
                    _buildAdherenceCard(context, medicationState),
                    const SizedBox(height: 24),

                    // Upcoming Doses
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Schedule',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () => context.push('/calendar'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDoseList(context, medicationState.upcomingDoses),

                    if (medicationState.missedDoses.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Missed Doses',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildDoseList(context, medicationState.missedDoses),
                    ],

                    if (medicationState.refillAlerts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Refill Alerts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildMedicationsList(
                          context, medicationState.refillAlerts),
                    ],

                    const SizedBox(height: 24),

                    // Medications List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Medications',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/medication/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMedicationsList(context, medicationState.medications),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/medication/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAdherenceCard(BuildContext context, MedicationState state) {
    final adherencePercentage = 0.85; // Mock adherence data
    final todayTaken =
        state.upcomingDoses.where((d) => d.status == DoseStatus.taken).length;
    final todayTotal = state.upcomingDoses.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adherence Overview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This Week',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(adherencePercentage * 100).round()}%',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: adherencePercentage >= 0.8
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                ),
                      ),
                      Text(
                        'Adherence Rate',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ProgressCircle(
                    progress: adherencePercentage,
                    color: adherencePercentage >= 0.8
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    todayTaken == todayTotal
                        ? Icons.check_circle
                        : Icons.schedule,
                    color: todayTaken == todayTotal
                        ? AppTheme.successColor
                        : AppTheme.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Today: $todayTaken of $todayTotal doses taken',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseList(BuildContext context, List<Dose> doses) {
    if (doses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.celebration,
                size: 48,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 8),
              Text(
                'No doses scheduled',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'You\'re all caught up for today!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: doses
          .map((dose) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DoseCard(dose: dose),
              ))
          .toList(),
    );
  }

  Widget _buildMedicationsList(
      BuildContext context, List<Medication> medications) {
    if (medications.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.medication,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'No medications added',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Tap the + button to add your first medication',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/medication/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Medication'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: medications
          .map((medication) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MedicationCard(
                  medication: medication,
                  onTap: () => context.push('/medication/${medication.id}'),
                ),
              ))
          .toList(),
    );
  }
}
