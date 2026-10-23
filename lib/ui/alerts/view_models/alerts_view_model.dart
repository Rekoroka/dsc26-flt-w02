import 'package:flutter/foundation.dart';

import '../../../data/repositories/alert_repository.dart';
import '../../../domain/models/stock_alert.dart';

/// Turns the alerts from [AlertRepository] into what the alerts screen shows.
///
/// Keep these public signatures exactly: the hidden tests call them.
/// Add private fields and helpers as you need.
class AlertsViewModel extends ChangeNotifier {
  AlertsViewModel({required this._repository});

  // ignore: unused_field
  final AlertRepository _repository;

  bool _loading = false;
  List<StockAlert> _alerts = [];
  final Set<Severity> _activeFilters = {};
  String _query = '';

  String _normalize(String value) {
    var result = value.trim().toLowerCase();

    result = result
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ـ', '')
        .replaceAll(RegExp('[\u064B-\u0652]'), '');

    return result;
  }

  /// True while [load] is in progress.
  bool get loading => _loading;

  Set<Severity> get activeFilters => Set.unmodifiable(_activeFilters);

  /// Fetches the alerts from the repository.
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _alerts = List<StockAlert>.of(await _repository.fetchAlerts());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Unmodifiable; filtered by severity and search query, then sorted
  List<StockAlert> get visibleAlerts {
    var result = List<StockAlert>.of(_alerts);
    if (_activeFilters.isNotEmpty) {
      result = result.where((alert) {
        return _activeFilters.contains(alert.severity);
      }).toList();
    }
    if (_query.isNotEmpty) {
      result = result.where((alert) {
        return _normalize(alert.medicineNameEn).contains(_query) ||
            _normalize(alert.medicineNameAr).contains(_query);
      }).toList();
    }
    result.sort((a, b) {
      if (a.acknowledged != b.acknowledged) {
        return a.acknowledged ? 1 : -1;
      }

      final severityCompare = a.severity.index.compareTo(b.severity.index);
      if (severityCompare != 0) {
        return severityCompare;
      }

      final daysCompare = a.daysOfCover.compareTo(b.daysOfCover);
      if (daysCompare != 0) {
        return daysCompare;
      }

      return a.medicineNameEn.toLowerCase().compareTo(
        b.medicineNameEn.toLowerCase(),
      );
    });
    return List.unmodifiable(result);
  }

  /// The severities currently shown. Empty means "show all".

  void toggleFilter(Severity severity) {
    if (_activeFilters.contains(severity)) {
      _activeFilters.remove(severity);
    } else {
      _activeFilters.add(severity);
    }
    notifyListeners();
  }

  void setQuery(String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery == _query) return;
    _query = normalizedQuery;
    notifyListeners();
  }

  Future<void> acknowledge(String id) async {
    final index = _alerts.indexWhere((alert) => alert.id == id);

    if (index == -1) return;

    await _repository.acknowledge(id);

    _alerts[index] = _alerts[index].copyWith(acknowledged: true);

    notifyListeners();
  }

  /// Unacknowledged critical alerts among ALL loaded alerts, whatever the
  /// current filters and search query.
  int get unacknowledgedCriticalCount {
    return _alerts.where((alert) {
      return alert.severity == Severity.critical && !alert.acknowledged;
    }).length;
  }
}
