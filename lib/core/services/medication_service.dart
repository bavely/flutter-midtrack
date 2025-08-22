import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/medication.dart';

class MedicationService {
  final String baseUrl;

  MedicationService({required this.baseUrl});

  Future<List<Medication>> getMedications() async {
    // Mock data for now
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Medication(
        id: '1',
        name: 'Lisinopril',
        brandName: 'Prinivil',
        dosage: 10,
        dosageUnit: 'mg',
        form: MedicationForm.tablet,
        frequency: 'Once daily',
        scheduledTimes: ['08:00'],
        totalPills: 30,
        remainingPills: 22,
        expiryDate: DateTime.now().add(const Duration(days: 300)),
        instructions: 'Take with water, preferably in the morning',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      Medication(
        id: '2',
        name: 'Metformin',
        dosage: 500,
        dosageUnit: 'mg',
        form: MedicationForm.tablet,
        frequency: 'Twice daily',
        scheduledTimes: ['08:00', '20:00'],
        totalPills: 60,
        remainingPills: 8,
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        instructions: 'Take with meals to reduce stomach upset',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<List<Dose>> getUpcomingDoses() async {
    // Mock data for now
    await Future.delayed(const Duration(milliseconds: 300));
    
    final now = DateTime.now();
    return [
      Dose(
        id: '1',
        medicationId: '1',
        medicationName: 'Lisinopril',
        scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
        status: DoseStatus.scheduled,
        dosage: 10,
        dosageUnit: 'mg',
      ),
      Dose(
        id: '2',
        medicationId: '2',
        medicationName: 'Metformin',
        scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
        status: DoseStatus.taken,
        takenTime: DateTime(now.year, now.month, now.day, 8, 15),
        dosage: 500,
        dosageUnit: 'mg',
      ),
      Dose(
        id: '3',
        medicationId: '2',
        medicationName: 'Metformin',
        scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
        status: DoseStatus.scheduled,
        dosage: 500,
        dosageUnit: 'mg',
      ),
    ];
  }

  Future<List<Dose>> getDosesForDate(DateTime date) async {
    // Mock data for specific date
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      Dose(
        id: '1',
        medicationId: '1',
        medicationName: 'Lisinopril',
        scheduledTime: DateTime(date.year, date.month, date.day, 8, 0),
        status: DoseStatus.taken,
        takenTime: DateTime(date.year, date.month, date.day, 8, 10),
        dosage: 10,
        dosageUnit: 'mg',
      ),
      Dose(
        id: '2',
        medicationId: '2',
        medicationName: 'Metformin',
        scheduledTime: DateTime(date.year, date.month, date.day, 8, 0),
        status: DoseStatus.taken,
        takenTime: DateTime(date.year, date.month, date.day, 8, 15),
        dosage: 500,
        dosageUnit: 'mg',
      ),
    ];
  }

  Future<Medication> addMedication(Medication medication) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(medication.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return medication.copyWith(id: data['id']?.toString());
      }
    } catch (_) {
      // If the API call fails, fall back to generating a local ID
    }

    // Generate a UUID if the server doesn't provide one
    return medication.copyWith(id: const Uuid().v4());
  }

  Future<void> markDoseTaken(String doseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // API call to mark dose as taken
  }

  Future<void> markDoseSkipped(String doseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // API call to mark dose as skipped
  }

  Future<void> deleteMedication(String medicationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // API call to delete medication
  }

  Future<Map<String, dynamic>> parseLabel(String imagePath) async {
    // Mock OCR results
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'name': 'Lisinopril',
      'brandName': 'Prinivil',
      'dosage': 10.0,
      'dosageUnit': 'mg',
      'form': 'tablet',
      'instructions': 'Take once daily with water',
      'confidence': 0.85,
    };
  }

  Future<String> uploadImage(String imagePath) async {
    // Mock image upload
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/medication-images/uploaded-image.jpg';
  }
}

extension MedicationCopy on Medication {
  Medication copyWith({
    String? id,
    String? name,
    String? brandName,
    double? dosage,
    String? dosageUnit,
    MedicationForm? form,
    String? frequency,
    List<String>? scheduledTimes,
    int? totalPills,
    int? remainingPills,
    DateTime? expiryDate,
    String? instructions,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      brandName: brandName ?? this.brandName,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      totalPills: totalPills ?? this.totalPills,
      remainingPills: remainingPills ?? this.remainingPills,
      expiryDate: expiryDate ?? this.expiryDate,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}