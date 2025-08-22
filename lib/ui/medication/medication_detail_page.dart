import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/medication.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/progress_circle.dart';

class MedicationDetailPage extends ConsumerWidget {
  final String medicationId;

  const MedicationDetailPage({required this.medicationId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationState = ref.watch(medicationProvider);
    final medication = medicationState.medications
        .where((m) => m.id == medicationId)
        .firstOrNull;

    if (medication == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medication')),
        body: const Center(
          child: Text('Medication not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(medication.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMedication(context, medication),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, ref, medication),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Header Card
            _buildHeaderCard(context, medication),
            
            const SizedBox(height: 16),
            
            // Schedule Card
            _buildScheduleCard(context, medication),
            
            const SizedBox(height: 16),
            
            // Stock Information
            if (medication.totalPills != null && medication.remainingPills != null)
              _buildStockCard(context, medication),
            
            if (medication.totalPills != null && medication.remainingPills != null)
              const SizedBox(height: 16),
            
            // Instructions Card
            if (medication.instructions != null)
              _buildInstructionsCard(context, medication),
            
            if (medication.instructions != null)
              const SizedBox(height: 16),
            
            // Additional Info Card
            _buildAdditionalInfoCard(context, medication),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Medication medication) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Medication Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getMedicationIcon(medication.form),
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Medication Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (medication.brandName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Brand: ${medication.brandName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${medication.dosageDisplay} • ${_formatFormName(medication.form)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Status Chips
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(medication.frequency),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                if (medication.isLowStock)
                  Chip(
                    label: const Text('Low Stock'),
                    backgroundColor: AppTheme.warningColor.withOpacity(0.2),
                    labelStyle: const TextStyle(color: AppTheme.warningColor),
                  ),
                if (medication.expiryDate != null && 
                    medication.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30))))
                  Chip(
                    label: const Text('Expires Soon'),
                    backgroundColor: AppTheme.errorColor.withOpacity(0.2),
                    labelStyle: const TextStyle(color: AppTheme.errorColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, Medication medication) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Frequency: ${medication.frequency}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 12),
            
            // Scheduled Times
            Text(
              'Times:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            ...medication.scheduledTimes.map((time) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(time),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, Medication medication) {
    final remaining = medication.remainingPills!;
    final total = medication.totalPills!;
    final percentage = medication.remainingPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock Level',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$remaining of $total pills remaining',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(percentage * 100).round()}% remaining',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      if (medication.isLowStock)
                        Text(
                          'Time to reorder!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ProgressCircle(
                    progress: percentage,
                    color: medication.isLowStock 
                        ? AppTheme.warningColor 
                        : AppTheme.successColor,
                    strokeWidth: 8,
                    child: Text(
                      remaining.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context, Medication medication) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              medication.instructions!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context, Medication medication) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(context, 'Form', _formatFormName(medication.form)),
            _buildInfoRow(context, 'Dosage', medication.dosageDisplay),
            if (medication.expiryDate != null)
              _buildInfoRow(context, 'Expires', _formatExpiryDate(medication.expiryDate!)),
            _buildInfoRow(context, 'Added', _formatDate(medication.createdAt)),
            if (medication.updatedAt != medication.createdAt)
              _buildInfoRow(context, 'Updated', _formatDate(medication.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
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

  String _formatFormName(MedicationForm form) {
    return form.name[0].toUpperCase() + form.name.substring(1);
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return time;
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatExpiryDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays <= 0) {
      return 'Expired';
    } else if (difference.inDays <= 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays <= 365) {
      return '${(difference.inDays / 30).round()} months';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _editMedication(BuildContext context, Medication medication) {
    // Navigate to edit page (would implement similar to manual entry)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Medication medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${medication.displayName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}