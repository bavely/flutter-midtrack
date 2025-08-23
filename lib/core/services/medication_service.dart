import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/medication.dart';
import '../models/dashboard_data.dart';

const String ADD_MEDICATION = r'''
mutation AddMedication($input: MedicationInput!) {
  addMedication(input: $input) {
    medication {
      id
      name
      brandName
      dosage
      dosageUnit
      form
      frequency
      scheduledTimes
      totalPills
      remainingPills
      expiryDate
      instructions
      createdAt
      updatedAt
    }
    errors { field message }
  }
}
''';

const String GET_DASHBOARD = r'''
query GetDashboard {
  getDashboard {
    medications {
      id
      name
      brandName
      dosage
      dosageUnit
      form
      frequency
      scheduledTimes
      totalPills
      remainingPills
      expiryDate
      instructions
      createdAt
      updatedAt
    }
    upcomingDoses {
      id
      medicationId
      medicationName
      scheduledTime
      status
      takenTime
      dosage
      dosageUnit
    }
    missedDoses {
      id
      medicationId
      medicationName
      scheduledTime
      status
      takenTime
      dosage
      dosageUnit
    }
    refillAlerts {
      id
      name
      brandName
      dosage
      dosageUnit
      form
      frequency
      scheduledTimes
      totalPills
      remainingPills
      expiryDate
      instructions
      createdAt
      updatedAt
    }
    errors { field message }
  }
}
''';

const String PARSE_MED_LABEL = r'''
mutation ParseMedLabel($imageUrl: String!) {
  parseMedLabel(imageUrl: $imageUrl) {
    medication {
      name
      brandName
      dosage
      dosageUnit
      form
      frequency
      scheduledTimes
      totalPills
      remainingPills
      expiryDate
      instructions
    }
    errors { field message }
  }
}
''';

class MedicationService {
  MedicationService({required GraphQLClient client}) : _client = client;

  final GraphQLClient _client;

  Future<DashboardData> getDashboard() async {
    final result = await _client.query(
      QueryOptions(document: gql(GET_DASHBOARD)),
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data?['getDashboard'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('No dashboard data');
    }

    final errors = data['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final message = errors
          .map((e) => '${e['field']}: ${e['message']}')
          .join(', ');
      throw Exception(message);
    }

    final medications = (data['medications'] as List<dynamic>? ?? [])
        .map((e) => Medication.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final upcomingDoses = (data['upcomingDoses'] as List<dynamic>? ?? [])
        .map((e) => Dose.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final missedDoses = (data['missedDoses'] as List<dynamic>? ?? [])
        .map((e) => Dose.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final refillAlerts = (data['refillAlerts'] as List<dynamic>? ?? [])
        .map((e) => Medication.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return DashboardData(
      medications: medications,
      upcomingDoses: upcomingDoses,
      missedDoses: missedDoses,
      refillAlerts: refillAlerts,
    );
  }

  Future<Medication> addMedication(Medication medication) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(ADD_MEDICATION),
        variables: {
          'input': medication.toJson()..remove('id'),
        },
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data?['addMedication'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('No data');
    }
    final errors = data['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final message = errors
          .map((e) => '${e['field']}: ${e['message']}')
          .join(', ');
      throw Exception(message);
    }
    final medData = data['medication'] as Map<String, dynamic>?;
    if (medData == null) {
      throw Exception('Medication not returned');
    }
    return Medication.fromJson(Map<String, dynamic>.from(medData));
  }

  Future<Map<String, dynamic>> parseLabel(String imagePath) async {
    final imageUrl = await uploadImage(imagePath);
    final result = await _client.mutate(
      MutationOptions(
        document: gql(PARSE_MED_LABEL),
        variables: {'imageUrl': imageUrl},
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data?['parseMedLabel'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('No data');
    }
    final errors = data['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final message = errors
          .map((e) => '${e['field']}: ${e['message']}')
          .join(', ');
      throw Exception(message);
    }
    final medData = data['medication'] as Map<String, dynamic>? ?? {};
    return Map<String, dynamic>.from(medData);
  }

  Future<List<Dose>> getDosesForDate(DateTime date) async {
    final dashboard = await getDashboard();
    final all = [...dashboard.upcomingDoses, ...dashboard.missedDoses];
    return all
        .where((d) =>
            d.scheduledTime.year == date.year &&
            d.scheduledTime.month == date.month &&
            d.scheduledTime.day == date.day)
        .toList();
  }

  Future<void> markDoseTaken(String doseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> markDoseSkipped(String doseId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> deleteMedication(String medicationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<String> uploadImage(String imagePath) async {
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
