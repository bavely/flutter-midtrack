import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/medication.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';

class DoseCard extends ConsumerWidget {
  final Dose dose;

  const DoseCard({required this.dose, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = dose.isOverdue;
    final isTaken = dose.status == DoseStatus.taken;
    final isSkipped = dose.status == DoseStatus.skipped;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status Indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(dose.status, isOverdue),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            
            // Medication Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dose.medicationName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dose.dosageDisplay} • ${dose.timeDisplay}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (isTaken && dose.takenTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Taken at ${_formatTime(dose.takenTime!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                  if (isOverdue) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Overdue',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Action Buttons
            if (!isTaken && !isSkipped) ...[
              IconButton(
                onPressed: () => _markAsSkipped(ref),
                icon: const Icon(Icons.close),
                tooltip: 'Skip dose',
                style: IconButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _markAsTaken(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('Take'),
              ),
            ],
            
            // Status Icon
            if (isTaken)
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 24,
              ),
            if (isSkipped)
              Icon(
                Icons.cancel,
                color: AppTheme.errorColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DoseStatus status, bool isOverdue) {
    switch (status) {
      case DoseStatus.taken:
        return AppTheme.successColor;
      case DoseStatus.skipped:
        return AppTheme.errorColor;
      case DoseStatus.missed:
        return AppTheme.errorColor;
      case DoseStatus.scheduled:
        return isOverdue ? AppTheme.warningColor : AppTheme.primaryColor;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _markAsTaken(WidgetRef ref) {
    ref.read(medicationProvider.notifier).markDoseTaken(dose.id);
  }

  void _markAsSkipped(WidgetRef ref) {
    ref.read(medicationProvider.notifier).markDoseSkipped(dose.id);
  }
}