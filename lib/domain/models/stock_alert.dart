/// How urgent a stock alert is. The order of the values is the display order:
/// critical first, low last.
enum Severity { critical, high, medium, low }

/// One stock alert for one branch, as sent by Nour head office.
///
/// Immutable: a change creates a new object through [copyWith].
/// Do not change the constructor, the fields or the method signatures.
final class StockAlert {
  const StockAlert({
    required this.id,
    required this.medicineNameEn,
    required this.medicineNameAr,
    required this.severity,
    required this.daysOfCover,
    required this.branchCode,
    this.acknowledged = false,
  });

  final String id;
  final String medicineNameEn;
  final String medicineNameAr;
  final Severity severity;
  final double daysOfCover;
  final String branchCode;
  final bool acknowledged;

  /// Reads one alert from the head-office JSON feed.
  ///
  /// TODO(W2): validate every field as the README says. Any invalid input
  /// throws a FormatException, never a TypeError.

  /// Reads one alert from the head-office JSON feed.
  factory StockAlert.fromJson(Map<String, Object?> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Invalid field: $key');
      }
      return value;
    }

    final id = requiredString('id');
    final medicineNameEn = requiredString('medicineNameEn');
    final medicineNameAr = requiredString('medicineNameAr');
    final branchCode = requiredString('branchCode');

    final severityValue = json['severity'];
    if (severityValue is! String) {
      throw const FormatException('Invalid severity');
    }

    final severityName = severityValue.toLowerCase();
    final matchingSeverities = Severity.values
        .where((value) => value.name == severityName)
        .toList();

    if (matchingSeverities.isEmpty) {
      throw FormatException('Unknown severity: $severityValue');
    }

    final daysValue = json['daysOfCover'];
    if (daysValue is! num || !daysValue.isFinite || daysValue < 0) {
      throw const FormatException('Invalid daysOfCover');
    }

    final acknowledgedValue = json['acknowledged'];
    if (acknowledgedValue != null && acknowledgedValue is! bool) {
      throw const FormatException('Invalid acknowledged');
    }

    return StockAlert(
      id: id,
      medicineNameEn: medicineNameEn,
      medicineNameAr: medicineNameAr,
      severity: matchingSeverities.first,
      daysOfCover: daysValue.toDouble(),
      branchCode: branchCode,
      acknowledged: acknowledgedValue as bool? ?? false,
    );
  }

  /// Returns a new alert with the given fields replaced.
  StockAlert copyWith({
    String? id,
    String? medicineNameEn,
    String? medicineNameAr,
    Severity? severity,
    double? daysOfCover,
    String? branchCode,
    bool? acknowledged,
  }) {
    return StockAlert(
      id: id ?? this.id,
      medicineNameEn: medicineNameEn ?? this.medicineNameEn,
      medicineNameAr: medicineNameAr ?? this.medicineNameAr,
      severity: severity ?? this.severity,
      daysOfCover: daysOfCover ?? this.daysOfCover,
      branchCode: branchCode ?? this.branchCode,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  /// Value equality over all seven fields.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StockAlert &&
            id == other.id &&
            medicineNameEn == other.medicineNameEn &&
            medicineNameAr == other.medicineNameAr &&
            severity == other.severity &&
            daysOfCover == other.daysOfCover &&
            branchCode == other.branchCode &&
            acknowledged == other.acknowledged;
  }

  /// Consistent with ==.
  @override
  int get hashCode => Object.hash(
    id,
    medicineNameEn,
    medicineNameAr,
    severity,
    daysOfCover,
    branchCode,
    acknowledged,
  );
}
