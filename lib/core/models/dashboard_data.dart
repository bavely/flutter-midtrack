import 'medication.dart';

class DashboardData {
  final List<Medication> medications;
  final List<Dose> upcomingDoses;
  final List<Dose> missedDoses;
  final List<Medication> refillAlerts;

  DashboardData({
    this.medications = const [],
    this.upcomingDoses = const [],
    this.missedDoses = const [],
    this.refillAlerts = const [],
  });
}
