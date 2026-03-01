import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/monthly_summary.dart';

class SummaryPieChart extends StatefulWidget {
  final MonthlySummary summary;
  const SummaryPieChart({super.key, required this.summary});

  @override
  State<SummaryPieChart> createState() => _SummaryPieChartState();
}

class _SummaryPieChartState extends State<SummaryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.summary.byCategory.isEmpty) {
      return const Center(child: Text('No data for this month'));
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (_, pieTouchResponse) {
            setState(() {
              final section =
                  pieTouchResponse?.touchedSection?.touchedSectionIndex;
              _touchedIndex = section ?? -1;
            });
          },
        ),
        sections: _buildSections(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.summary.byCategory.asMap().entries.map((entry) {
      final index = entry.key;
      final cat = entry.value;
      final isTouched = index == _touchedIndex;
      final pct = widget.summary.totalAmount > 0
          ? (cat.total / widget.summary.totalAmount * 100)
          : 0.0;

      return PieChartSectionData(
        color: Color(cat.colorValue),
        value: cat.total,
        title: '${pct.toStringAsFixed(1)}%',
        radius: isTouched ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
