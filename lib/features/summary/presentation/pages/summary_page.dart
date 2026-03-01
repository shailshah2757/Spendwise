import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/summary_provider.dart';
import '../widgets/summary_pie_chart.dart';

class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.monthlySummary),
      ),
      body: Column(
        children: [
          _MonthSelector(selected: selectedMonth),
          Expanded(
            child: summaryAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (summary) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TotalCard(total: summary.totalAmount),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: SummaryPieChart(summary: summary),
                    ),
                    const SizedBox(height: 16),
                    _CategoryBreakdown(summary: summary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends ConsumerWidget {
  final DateTime selected;
  const _MonthSelector({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).state = DateTime(
                selected.year,
                selected.month - 1,
              );
            },
          ),
          Text(
            DateFormatter.formatMonthYear(selected),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: selected.year == DateTime.now().year &&
                    selected.month == DateTime.now().month
                ? null
                : () {
                    ref.read(selectedMonthProvider.notifier).state = DateTime(
                      selected.year,
                      selected.month + 1,
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.totalSpent,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              DateFormatter.formatCurrency(total),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF44336),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final dynamic summary;
  const _CategoryBreakdown({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.byCategory,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...summary.byCategory.map<Widget>((cat) {
              final pct = summary.totalAmount > 0
                  ? cat.total / summary.totalAmount
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(cat.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(cat.categoryName)),
                    Text(DateFormatter.formatCurrency(cat.total)),
                    const SizedBox(width: 8),
                    Text(
                      '(${(pct * 100).toStringAsFixed(1)}%)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
