import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/medication.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';

class ConfirmPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? medicationData;

  const ConfirmPage({this.medicationData, super.key});

  @override
  ConsumerState<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends ConsumerState<ConfirmPage> {
  final _formKey = GlobalKey<FormState>();

  // Editable fields
  late TextEditingController _nameController;
  late TextEditingController _brandNameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;

  late String _dosageUnit;
  late String _form;
  late String _frequency;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final data = widget.medicationData ?? {};

    _nameController = TextEditingController(text: data['name'] ?? '');
    _brandNameController = TextEditingController(text: data['brandName'] ?? '');
    _dosageController =
        TextEditingController(text: data['dosage']?.toString() ?? '');
    _instructionsController =
        TextEditingController(text: data['instructions'] ?? '');

    _dosageUnit = data['unit'] ?? 'mg';
    _form = data['form'] ?? 'tablet';
    _frequency = data['frequency'] ?? 'Once daily';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandNameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.medicationData ?? {};
    final confidence = data['confidence'] as double?;
    final isScanned = data.containsKey('confidence');
    final isVoiceInput = data.containsKey('voiceInput');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Medication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source Information
              if (isScanned || isVoiceInput) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isScanned ? Icons.camera_alt : Icons.mic,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isScanned ? 'Scanned Information' : 'Voice Input',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                      if (confidence != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              confidence >= 0.8
                                  ? Icons.check_circle
                                  : Icons.warning,
                              size: 16,
                              color: confidence >= 0.8
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Confidence: ${(confidence * 100).round()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ],
                      if (isVoiceInput && data['voiceInput'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'You said: "${data['voiceInput']}"',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Medication Information Form
              Text(
                'Please review and confirm the information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Medication Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Medication Name *',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Brand Name
              TextFormField(
                controller: _brandNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Brand Name (Optional)',
                  prefixIcon: Icon(Icons.business),
                ),
              ),

              const SizedBox(height: 16),

              // Dosage Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _dosageController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Dosage *',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _dosageUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'mg', child: Text('mg')),
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'mcg', child: Text('mcg')),
                        DropdownMenuItem(value: 'IU', child: Text('IU')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _dosageUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Form
              DropdownButtonFormField<String>(
                initialValue: _form,
                decoration: const InputDecoration(
                  labelText: 'Form',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'tablet', child: Text('Tablet')),
                  DropdownMenuItem(value: 'capsule', child: Text('Capsule')),
                  DropdownMenuItem(value: 'liquid', child: Text('Liquid')),
                  DropdownMenuItem(
                      value: 'injection', child: Text('Injection')),
                  DropdownMenuItem(value: 'cream', child: Text('Cream')),
                  DropdownMenuItem(value: 'patch', child: Text('Patch')),
                  DropdownMenuItem(value: 'inhaler', child: Text('Inhaler')),
                  DropdownMenuItem(value: 'drops', child: Text('Drops')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _form = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Frequency
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Once daily', child: Text('Once daily')),
                  DropdownMenuItem(
                      value: 'Twice daily', child: Text('Twice daily')),
                  DropdownMenuItem(
                      value: 'Three times daily',
                      child: Text('Three times daily')),
                  DropdownMenuItem(
                      value: 'As needed', child: Text('As needed')),
                ],
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Instructions
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Instructions (Optional)',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: const Text('Edit More'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMedication,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Add Medication'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create medication object
      final medication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        brandName: _brandNameController.text.trim().isEmpty
            ? null
            : _brandNameController.text.trim(),
        dosage: double.parse(_dosageController.text),
        dosageUnit: _dosageUnit,
        form: MedicationForm.values.firstWhere(
          (e) => e.name == _form,
          orElse: () => MedicationForm.tablet,
        ),
        frequency: _frequency,
        scheduledTimes: _getDefaultScheduledTimes(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add medication via provider
      final success =
          await ref.read(medicationProvider.notifier).addMedication(medication);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medication.name} added successfully!'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to home
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding medication: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _getDefaultScheduledTimes() {
    switch (_frequency) {
      case 'Once daily':
        return ['08:00'];
      case 'Twice daily':
        return ['08:00', '20:00'];
      case 'Three times daily':
        return ['08:00', '14:00', '20:00'];
      default:
        return ['08:00'];
    }
  }
}
