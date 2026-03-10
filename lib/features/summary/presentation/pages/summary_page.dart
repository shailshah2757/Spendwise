import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/monthly_summary.dart';
import '../providers/summary_provider.dart';
import '../widgets/summary_pie_chart.dart';

class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.analytics)),
      body: Column(
        children: [
          _MonthSelector(selected: selectedMonth),
          Expanded(
            child: summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (summary) => summary.byCategory.isEmpty
                  ? const _EmptyAnalytics()
                  : _AnalyticsContent(
                      summary: summary,
                      currencySymbol: currencySymbol,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Month Selector ---

class _MonthSelector extends ConsumerWidget {
  final DateTime selected;
  const _MonthSelector({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isCurrentMonth =
        selected.year == now.year && selected.month == now.month;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _MonthNavButton(
            icon: Icons.chevron_left_rounded,
            onTap: () {
              ref.read(selectedMonthProvider.notifier).state = DateTime(
                selected.year,
                selected.month - 1,
              );
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                DateFormatter.formatMonthYear(selected),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          _MonthNavButton(
            icon: Icons.chevron_right_rounded,
            enabled: !isCurrentMonth,
            onTap: isCurrentMonth
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

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _MonthNavButton({
    required this.icon,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// --- Empty State ---

class _EmptyAnalytics extends StatelessWidget {
  const _EmptyAnalytics();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 40,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No spending data',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some expenses to see your\nspending breakdown here',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Analytics Content ---

class _AnalyticsContent extends StatelessWidget {
  final MonthlySummary summary;
  final String currencySymbol;

  const _AnalyticsContent({
    required this.summary,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Spent Hero
          Center(
            child: Column(
              children: [
                Text(
                  'Total Spent',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatCurrency(summary.totalAmount,
                      symbol: currencySymbol),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pie Chart + Legends
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: cs.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: SummaryPieChart(summary: summary),
                  ),
                  const SizedBox(height: 20),
                  // Legends
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: summary.byCategory.map((cat) {
                      final pct = summary.totalAmount > 0
                          ? (cat.total / summary.totalAmount * 100)
                          : 0.0;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(cat.colorValue),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${cat.categoryName} ${pct.toStringAsFixed(0)}%',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Top Categories
          Text(
            'Top Categories',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...summary.byCategory.map((cat) {
            final pct = summary.totalAmount > 0
                ? cat.total / summary.totalAmount
                : 0.0;
            return _CategoryRow(
              name: cat.categoryName,
              amount: DateFormatter.formatCurrency(cat.total,
                  symbol: currencySymbol),
              percentage: pct,
              color: Color(cat.colorValue),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final String amount;
  final double percentage;
  final Color color;

  const _CategoryRow({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: tt.titleSmall),
                        Text(amount, style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 6,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${(percentage * 100).toStringAsFixed(0)}%',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
