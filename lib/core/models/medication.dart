enum MedicationForm {
  tablet,
  capsule,
  liquid,
  injection,
  cream,
  patch,
  inhaler,
  drops,
  other,
}

enum DoseStatus {
  scheduled,
  taken,
  skipped,
  missed,
}

class Medication {
  final String id;
  final String name;
  final String? brandName;
  final double dosage;
  final String dosageUnit;
  final MedicationForm form;
  final String frequency;
  final List<String> scheduledTimes;
  final int? totalPills;
  final int? remainingPills;
  final DateTime? expiryDate;
  final String? instructions;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medication({
    required this.id,
    required this.name,
    this.brandName,
    required this.dosage,
    required this.dosageUnit,
    required this.form,
    required this.frequency,
    required this.scheduledTimes,
    this.totalPills,
    this.remainingPills,
    this.expiryDate,
    this.instructions,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      brandName: json['brandName'],
      dosage: json['dosage'].toDouble(),
      dosageUnit: json['dosageUnit'],
      form: MedicationForm.values.firstWhere(
        (e) => e.name == json['form'],
        orElse: () => MedicationForm.other,
      ),
      frequency: json['frequency'],
      scheduledTimes: List<String>.from(json['scheduledTimes']),
      totalPills: json['totalPills'],
      remainingPills: json['remainingPills'],
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      instructions: json['instructions'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brandName': brandName,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'form': form.name,
      'frequency': frequency,
      'scheduledTimes': scheduledTimes,
      'totalPills': totalPills,
      'remainingPills': remainingPills,
      'expiryDate': expiryDate?.toIso8601String(),
      'instructions': instructions,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get remainingPercentage {
    if (totalPills == null || remainingPills == null) return 0;
    return remainingPills! / totalPills!;
  }

  bool get isLowStock {
    if (totalPills == null || remainingPills == null) return false;
    return remainingPercentage < 0.2; // Less than 20%
  }

  String get displayName {
    return brandName?.isNotEmpty == true ? '$brandName ($name)' : name;
  }

  String get dosageDisplay {
    return '$dosage $dosageUnit';
  }
}

class Dose {
  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledTime;
  final DoseStatus status;
  final DateTime? takenTime;
  final double dosage;
  final String dosageUnit;

  const Dose({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledTime,
    required this.status,
    this.takenTime,
    required this.dosage,
    required this.dosageUnit,
  });

  factory Dose.fromJson(Map<String, dynamic> json) {
    return Dose(
      id: json['id'],
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      status: DoseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DoseStatus.scheduled,
      ),
      takenTime: json['takenTime'] != null 
          ? DateTime.parse(json['takenTime']) 
          : null,
      dosage: json['dosage'].toDouble(),
      dosageUnit: json['dosageUnit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status.name,
      'takenTime': takenTime?.toIso8601String(),
      'dosage': dosage,
      'dosageUnit': dosageUnit,
    };
  }

  bool get isOverdue {
    return status == DoseStatus.scheduled && 
           DateTime.now().isAfter(scheduledTime.add(const Duration(minutes: 30)));
  }

  String get timeDisplay {
    final hour = scheduledTime.hour;
    final minute = scheduledTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String get dosageDisplay {
    return '$dosage $dosageUnit';
  }
}