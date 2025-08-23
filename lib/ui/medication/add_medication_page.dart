import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class AddMedicationPage extends StatelessWidget {
  const AddMedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How would you like to add your medication?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Scan Bottle Option
            _AddMedicationOption(
              icon: Icons.camera_alt,
              iconColor: AppTheme.primaryColor,
              title: 'Scan Bottle',
              subtitle: 'Use camera to scan medication label',
              recommended: true,
              onTap: () => context.push('/medication/scan'),
            ),

            const SizedBox(height: 12),

            // Voice Input Option
            _AddMedicationOption(
              icon: Icons.mic,
              iconColor: AppTheme.secondaryColor,
              title: 'Voice Input',
              subtitle: 'Describe your medication using voice',
              onTap: () => context.push('/medication/voice'),
            ),

            const SizedBox(height: 12),

            // Manual Entry Option
            _AddMedicationOption(
              icon: Icons.edit,
              iconColor: AppTheme.accentColor,
              title: 'Manual Entry',
              subtitle: 'Type in medication details manually',
              onTap: () => context.push('/medication/manual'),
            ),

            const Spacer(),

            // Help Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For best results, use the camera to scan your medication bottle or package.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMedicationOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool recommended;
  final VoidCallback onTap;

  const _AddMedicationOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.recommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (recommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'RECOMMENDED',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
