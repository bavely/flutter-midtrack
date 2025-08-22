import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/providers/providers.dart';
import '../../core/models/medication.dart';
import '../widgets/dose_card.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Dose> _selectedDayDoses = [];
  bool _isLoadingDoses = false;

  @override
  void initState() {
    super.initState();
    _loadDosesForDay(_selectedDay);
  }

  Future<void> _loadDosesForDay(DateTime day) async {
    setState(() {
      _isLoadingDoses = true;
    });

    try {
      final doses = await ref
          .read(medicationServiceProvider)
          .getDosesForDate(day);
      setState(() {
        _selectedDayDoses = doses;
        _isLoadingDoses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDoses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
              _loadDosesForDay(_selectedDay);
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Widget
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<Dose>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left),
                rightChevronIcon: Icon(Icons.chevron_right),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadDosesForDay(selectedDay);
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                // Return mock events for demo
                if (day.isBefore(DateTime.now()) || isSameDay(day, DateTime.now())) {
                  return []; // Would load actual doses here
                }
                return [];
              },
            ),
          ),
          
          // Selected Day Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatSelectedDate(_selectedDay),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                if (!_isLoadingDoses && _selectedDayDoses.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedDayDoses.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Doses List
          Expanded(
            child: _isLoadingDoses
                ? const Center(child: CircularProgressIndicator())
                : _selectedDayDoses.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _selectedDayDoses.length,
                        itemBuilder: (context, index) {
                          final dose = _selectedDayDoses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: DoseCard(dose: dose),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    if (isSameDay(date, DateTime.now())) {
      return 'Today, ${DateFormat('MMMM d').format(date)}';
    } else if (isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Yesterday, ${DateFormat('MMMM d').format(date)}';
    } else if (isSameDay(date, DateTime.now().add(const Duration(days: 1)))) {
      return 'Tomorrow, ${DateFormat('MMMM d').format(date)}';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  Widget _buildEmptyState() {
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final isPast = _selectedDay.isBefore(DateTime.now());
    final isFuture = _selectedDay.isAfter(DateTime.now());

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isToday 
                  ? Icons.check_circle_outline
                  : isPast
                      ? Icons.history
                      : Icons.schedule,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isToday
                  ? 'No doses scheduled today'
                  : isPast
                      ? 'No doses recorded'
                      : 'No doses scheduled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isToday
                  ? 'You\'re all caught up!'
                  : isPast
                      ? 'This day has no dose history'
                      : 'No medications scheduled for this day',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}