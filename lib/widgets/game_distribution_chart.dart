import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameDistributionChart extends StatelessWidget {
  final Map<String, double> distribution;

  const GameDistributionChart({super.key, required this.distribution});

  Color _getGameColor(String game) {
    switch (game.toLowerCase()) {
      case 'magic':
        return const Color(0xFF9C27B0); // Viola Magic
      case 'pokémon':
      case 'pokemon':
        return const Color(0xFFFFC107); // Giallo Pokémon
      case 'lorcana':
        return const Color(0xFF3F51B5); // Blu/Indaco Lorcana
      case 'one piece':
      case 'onepiece':
        return const Color(0xFFE91E63); // Rosso/Cremisi One Piece
      default:
        return const Color(0xFF00BCD4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalValue = distribution.values.fold(0.0, (s, v) => s + v);

    if (totalValue == 0) {
      return const SizedBox.shrink();
    }

    final currencyFormat =
        NumberFormat.currency(locale: 'it_IT', symbol: '€', decimalDigits: 0);

    final List<PieChartSectionData> sections = [];
    distribution.forEach((game, value) {
      if (value > 0) {
        final percentage = (value / totalValue) * 100;
        sections.add(
          PieChartSectionData(
            color: _getGameColor(game),
            value: value,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 36,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });

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
          const Text(
            'DISTRIBUZIONE PER GIOCO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 28,
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: distribution.entries.map((entry) {
                    final game = entry.key;
                    final val = entry.value;
                    final color = _getGameColor(game);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              game,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            currencyFormat.format(val),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
