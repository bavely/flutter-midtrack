import 'package:flutter/material.dart';

import '../../core/models/medication.dart';
import '../../core/theme/app_theme.dart';
import 'progress_circle.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTap;

  const MedicationCard({
    required this.medication,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Medication Icon/Image
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMedicationIcon(medication.form),
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Medication Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${medication.dosageDisplay} • ${medication.frequency}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  // Stock Progress Circle
                  if (medication.totalPills != null && medication.remainingPills != null)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ProgressCircle(
                        progress: medication.remainingPercentage,
                        color: medication.isLowStock 
                            ? AppTheme.errorColor 
                            : AppTheme.successColor,
                        strokeWidth: 3,
                        showPercentage: false,
                        child: Text(
                          medication.remainingPills.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Additional Info
              const SizedBox(height: 12),
              Row(
                children: [
                  // Next Dose
                  if (medication.scheduledTimes.isNotEmpty) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Next: ${medication.scheduledTimes.first}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Stock Warning
                  if (medication.isLowStock) ...[
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Low stock',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMedicationIcon(MedicationForm form) {
    switch (form) {
      case MedicationForm.tablet:
        return Icons.medication;
      case MedicationForm.capsule:
        return Icons.medication;
      case MedicationForm.liquid:
        return Icons.local_drink;
      case MedicationForm.injection:
        return Icons.vaccines;
      case MedicationForm.cream:
        return Icons.healing;
      case MedicationForm.patch:
        return Icons.healing;
      case MedicationForm.inhaler:
        return Icons.air;
      case MedicationForm.drops:
        return Icons.water_drop;
      case MedicationForm.other:
        return Icons.medication;
    }
  }
}