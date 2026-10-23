import 'package:flutter/material.dart';

import '../../../domain/models/stock_alert.dart';
import '../view_models/alerts_view_model.dart';

/// The branch alerts screen.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.viewModel});

  final AlertsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        final alerts = viewModel.visibleAlerts;
        final filters = viewModel.activeFilters;

        return Scaffold(
          appBar: AppBar(title: const Text('Branch alerts')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const ValueKey('search-field'),
                    onChanged: viewModel.setQuery,
                    decoration: const InputDecoration(
                      hintText: 'Search medicines...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Filter by severity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: Severity.values.map((severity) {
                      return FilterChip(
                        key: ValueKey('filter-${severity.name}'),
                        label: Text(
                          severity.name[0].toUpperCase() +
                              severity.name.substring(1),
                        ),
                        selected: filters.contains(severity),
                        onSelected: (_) {
                          viewModel.toggleFilter(severity);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${alerts.length} '
                    '${alerts.length == 1 ? 'alert' : 'alerts'}',
                    key: const ValueKey('alerts-count'),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: viewModel.loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              key: ValueKey('alerts-loading'),
                            ),
                          )
                        : alerts.isEmpty
                        ? const Center(
                            key: ValueKey('alerts-empty'),
                            child: Text('No alerts found'),
                          )
                        : ListView.builder(
                            key: const ValueKey('alerts-list'),
                            itemCount: alerts.length,
                            itemBuilder: (context, index) {
                              final alert = alerts[index];

                              return Card(
                                key: ValueKey('alert-${alert.id}'),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              alert.medicineNameEn,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            alert.severity.name.toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      Text(alert.medicineNameAr),

                                      const SizedBox(height: 4),

                                      Text('Branch: ${alert.branchCode}'),

                                      Text(
                                        'Days of cover: '
                                        '${alert.daysOfCover}',
                                      ),

                                      if (!alert.acknowledged)
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            key: ValueKey('ack-${alert.id}'),
                                            onPressed: () {
                                              viewModel.acknowledge(alert.id);
                                            },
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                            ),
                                            label: const Text('Acknowledge'),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
