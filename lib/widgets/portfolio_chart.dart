import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/portfolio_snapshot.dart';

class PortfolioChart extends StatefulWidget {
  final List<PortfolioSnapshot> snapshots;

  const PortfolioChart({super.key, required this.snapshots});

  @override
  State<PortfolioChart> createState() => _PortfolioChartState();
}

class _PortfolioChartState extends State<PortfolioChart> {
  int _selectedTimeRangeDays = 0; // 0 = Tutti, 30 = 1 Mese, 90 = 3 Mesi

  List<PortfolioSnapshot> get _filteredSnapshots {
    if (widget.snapshots.isEmpty) return [];
    if (_selectedTimeRangeDays == 0) return widget.snapshots;

    final cutoff =
        DateTime.now().subtract(Duration(days: _selectedTimeRangeDays));
    final filtered =
        widget.snapshots.where((s) => s.timestamp.isAfter(cutoff)).toList();
    return filtered.isNotEmpty ? filtered : widget.snapshots;
  }

  @override
  Widget build(BuildContext context) {
    final snapshots = _filteredSnapshots;

    if (snapshots.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Text(
          'Nessun dato storico ancora disponibile',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    final currencyFormat =
        NumberFormat.currency(locale: 'it_IT', symbol: '€', decimalDigits: 0);

    final spots = <FlSpot>[];
    double minY = snapshots.first.totalValue;
    double maxY = snapshots.first.totalValue;

    for (int i = 0; i < snapshots.length; i++) {
      final val = snapshots[i].totalValue;
      if (val < minY) minY = val;
      if (val > maxY) maxY = val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    // Aggiungi margine verticale per il grafico
    final paddingY = (maxY - minY) * 0.15;
    minY = (minY - paddingY).clamp(0.0, double.infinity);
    maxY = maxY + (paddingY == 0 ? 100.0 : paddingY);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded,
                      color: Color(0xFFFFD700), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ANDAMENTO PORTAFOGLIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildPeriodChip('1M', 30),
                  const SizedBox(width: 6),
                  _buildPeriodChip('3M', 90),
                  const SizedBox(width: 6),
                  _buildPeriodChip('Tutti', 0),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < snapshots.length) {
                          if (idx == 0 ||
                              idx == snapshots.length - 1 ||
                              idx == (snapshots.length / 2).floor()) {
                            final date = snapshots[idx].timestamp;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd/MM').format(date),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => const Color(0xFF2B2B40),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final snap = snapshots[idx];
                        final dateStr =
                            DateFormat('dd MMM yyyy').format(snap.timestamp);
                        return LineTooltipItem(
                          '${currencyFormat.format(spot.y)}\n$dateStr',
                          const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFFFFD700),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFFFFD700),
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF1E1E2E),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD700).withOpacity(0.28),
                          const Color(0xFFFFD700).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, int days) {
    final isSelected = _selectedTimeRangeDays == days;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTimeRangeDays = days;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
