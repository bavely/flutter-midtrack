import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/medication.dart';
import '../../core/theme/app_theme.dart';

class ManualEntryPage extends StatefulWidget {
  const ManualEntryPage({super.key});

  @override
  State<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _totalPillsController = TextEditingController();
  final _instructionsController = TextEditingController();

  // Form values
  String _dosageUnit = 'mg';
  MedicationForm _form = MedicationForm.tablet;
  String _frequency = 'Once daily';
  List<TimeOfDay> _scheduledTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime? _expiryDate;

  // UI state
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _brandNameController.dispose();
    _dosageController.dispose();
    _totalPillsController.dispose();
    _instructionsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            _buildBasicInfoPage(),
            _buildSchedulePage(),
            _buildAdditionalInfoPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Progress Indicator
              Expanded(
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? AppTheme.primaryColor
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(width: 16),

              // Navigation Buttons
              if (_currentPage > 0)
                TextButton(
                  onPressed: _previousPage,
                  child: const Text('Back'),
                ),

              const SizedBox(width: 8),

              ElevatedButton(
                onPressed: _currentPage == 2 ? _submitForm : _nextPage,
                child: Text(_currentPage == 2 ? 'Add Medication' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Medication Name
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Medication Name *',
              hintText: 'e.g., Lisinopril',
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

          // Brand Name (Optional)
          TextFormField(
            controller: _brandNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Brand Name (Optional)',
              hintText: 'e.g., Prinivil',
              prefixIcon: Icon(Icons.business),
            ),
          ),

          const SizedBox(height: 16),

          // Dosage Row
          Row(
            children: [
              // Dosage Amount
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _dosageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Dosage *',
                    hintText: '10',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Dosage Unit
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
                    DropdownMenuItem(value: 'units', child: Text('units')),
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

          // Medication Form
          DropdownButtonFormField<MedicationForm>(
            initialValue: _form,
            decoration: const InputDecoration(
              labelText: 'Form',
              prefixIcon: Icon(Icons.category),
            ),
            items: MedicationForm.values.map((form) {
              return DropdownMenuItem(
                value: form,
                child: Text(_formatFormName(form)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _form = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Total Pills (Optional)
          TextFormField(
            controller: _totalPillsController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Total Pills/Doses (Optional)',
              hintText: '30',
              prefixIcon: Icon(Icons.inventory),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Frequency
          DropdownButtonFormField<String>(
            initialValue: _frequency,
            decoration: const InputDecoration(
              labelText: 'Frequency',
              prefixIcon: Icon(Icons.schedule),
            ),
            items: const [
              DropdownMenuItem(value: 'Once daily', child: Text('Once daily')),
              DropdownMenuItem(
                  value: 'Twice daily', child: Text('Twice daily')),
              DropdownMenuItem(
                  value: 'Three times daily', child: Text('Three times daily')),
              DropdownMenuItem(
                  value: 'Four times daily', child: Text('Four times daily')),
              DropdownMenuItem(
                  value: 'Every other day', child: Text('Every other day')),
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'As needed', child: Text('As needed')),
            ],
            onChanged: (value) {
              setState(() {
                _frequency = value!;
                _updateScheduledTimes();
              });
            },
          ),

          const SizedBox(height: 24),

          // Scheduled Times
          Text(
            'Times',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          ..._scheduledTimes.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('Dose ${index + 1}'),
                subtitle: Text(time.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTime(index),
                ),
              ),
            );
          }),

          if (_scheduledTimes.length < 4)
            OutlinedButton.icon(
              onPressed: _addTime,
              icon: const Icon(Icons.add),
              label: const Text('Add Time'),
            ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Expiry Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Expiry Date (Optional)'),
            subtitle: Text(_expiryDate != null
                ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                : 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectExpiryDate,
          ),

          const SizedBox(height: 16),

          // Instructions
          TextFormField(
            controller: _instructionsController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Instructions (Optional)',
              hintText: 'e.g., Take with food, avoid alcohol',
              prefixIcon: Icon(Icons.note),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 32),

          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                      'Name',
                      _nameController.text.isEmpty
                          ? 'Not specified'
                          : _nameController.text),
                  if (_brandNameController.text.isNotEmpty)
                    _buildSummaryRow('Brand', _brandNameController.text),
                  _buildSummaryRow('Dosage',
                      '${_dosageController.text.isEmpty ? '0' : _dosageController.text} $_dosageUnit'),
                  _buildSummaryRow('Form', _formatFormName(_form)),
                  _buildSummaryRow('Frequency', _frequency),
                  if (_totalPillsController.text.isNotEmpty)
                    _buildSummaryRow(
                        'Total', '${_totalPillsController.text} pills'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  String _formatFormName(MedicationForm form) {
    return form.name[0].toUpperCase() + form.name.substring(1);
  }

  void _updateScheduledTimes() {
    switch (_frequency) {
      case 'Once daily':
        _scheduledTimes = [const TimeOfDay(hour: 8, minute: 0)];
        break;
      case 'Twice daily':
        _scheduledTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case 'Three times daily':
        _scheduledTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case 'Four times daily':
        _scheduledTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 16, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      default:
        _scheduledTimes = [const TimeOfDay(hour: 8, minute: 0)];
    }
  }

  Future<void> _editTime(int index) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _scheduledTimes[index],
    );

    if (time != null) {
      setState(() {
        _scheduledTimes[index] = time;
      });
    }
  }

  void _addTime() {
    setState(() {
      _scheduledTimes.add(const TimeOfDay(hour: 8, minute: 0));
    });
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  void _nextPage() {
    if (_currentPage == 0 && !_validateBasicInfo()) {
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateBasicInfo() {
    return _nameController.text.isNotEmpty &&
        _dosageController.text.isNotEmpty &&
        double.tryParse(_dosageController.text) != null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _validateBasicInfo()) {
      final medicationData = {
        'name': _nameController.text,
        'brandName': _brandNameController.text.isEmpty
            ? null
            : _brandNameController.text,
        'dosage': double.parse(_dosageController.text),
        'unit': _dosageUnit,
        'form': _form.name,
        'frequency': _frequency,
        'scheduledTimes': _scheduledTimes
            .map((t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
            .toList(),
        'totalPills': _totalPillsController.text.isEmpty
            ? null
            : int.tryParse(_totalPillsController.text),
        'expiryDate': _expiryDate,
        'instructions': _instructionsController.text.isEmpty
            ? null
            : _instructionsController.text,
        'manualEntry': true,
      };

      context.go('/medication/confirm', extra: medicationData);
    }
  }
}
