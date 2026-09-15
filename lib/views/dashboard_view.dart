import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/portfolio_chart.dart';
import '../widgets/game_distribution_chart.dart';
import 'bulk_import_dialog.dart';
import 'add_edit_card_dialog.dart';
import 'card_detail_dialog.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final totalValue = provider.totalPortfolioValue;
        final totalCards = provider.totalCardCount;
        final uniqueCards = provider.uniqueCardCount;
        final snapshots = provider.snapshots;
        final dist = provider.gameValueDistribution;
        final topCards = List.from(provider.cards)
          ..sort((a, b) => b.totalValue.compareTo(a.totalValue));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INTRO HEADER
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'TCG MyCard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.5),
                              ),
                            ),
                            child: const Text(
                              'CardTrader Standard',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitoraggio portafoglio Magic, Pokémon, Lorcana & One Piece',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : () => provider.autoRefreshPricesFromCardTrader(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B2B40),
                          foregroundColor: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFFFFD700)),
                              )
                            : const Icon(Icons.sync, size: 16),
                        label: const Text('Prezzi CardTrader'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const BulkImportDialog(),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.file_download_outlined),
                        tooltip: 'Caricamento Bulk JSON',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // GRID METRICHE PRINCIPALI
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: StatCard(
                                title: 'Valore Totale Portafoglio',
                                value: currencyFormat.format(totalValue),
                                subtitle:
                                    '$totalCards carte in collezione ($uniqueCards distinte)',
                                icon: Icons.account_balance_wallet_outlined,
                                accentColor: const Color(0xFFFFD700),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatCard(
                                title: 'Top Carta',
                                value: topCards.isNotEmpty
                                    ? currencyFormat
                                        .format(topCards.first.totalValue)
                                    : '€0,00',
                                subtitle: topCards.isNotEmpty
                                    ? topCards.first.name
                                    : 'Nessuna carta',
                                icon: Icons.star_outline_rounded,
                                accentColor: const Color(0xFF00BCD4),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            StatCard(
                              title: 'Valore Totale Portafoglio',
                              value: currencyFormat.format(totalValue),
                              subtitle:
                                  '$totalCards carte in collezione ($uniqueCards distinte)',
                              icon: Icons.account_balance_wallet_outlined,
                              accentColor: const Color(0xFFFFD700),
                            ),
                            const SizedBox(height: 12),
                            StatCard(
                              title: 'Top Carta',
                              value: topCards.isNotEmpty
                                  ? currencyFormat
                                      .format(topCards.first.totalValue)
                                  : '€0,00',
                              subtitle: topCards.isNotEmpty
                                  ? topCards.first.name
                                  : 'Nessuna carta',
                              icon: Icons.star_outline_rounded,
                              accentColor: const Color(0xFF00BCD4),
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 24),

              // GRAFICO STORICO DELL'ANDAMENTO DEL PORTAFOGLIO
              PortfolioChart(snapshots: snapshots),
              const SizedBox(height: 24),

              // RIPARTIZIONE PER GIOCO E TOP CARTE
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 3,
                                child: GameDistributionChart(distribution: dist)),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 4,
                              child: _buildTopCardsList(
                                  context, topCards.take(4).toList(), provider),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            GameDistributionChart(distribution: dist),
                            const SizedBox(height: 24),
                            _buildTopCardsList(
                                context, topCards.take(4).toList(), provider),
                          ],
                        );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopCardsList(BuildContext context, List<dynamic> cards,
      PortfolioProvider provider) {
    final currencyFormat = NumberFormat.currency(locale: 'it_IT', symbol: '€');

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
            'CARTE PIÙ PREZIOSE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          if (cards.isEmpty)
            Text(
              'Nessuna carta presente.',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.06),
              ),
              itemBuilder: (context, index) {
                final card = cards[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => CardDetailDialog(
                        card: card,
                        onEdit: () => showDialog(
                          context: context,
                          builder: (ctx2) =>
                              AddEditCardDialog(cardToEdit: card),
                        ),
                        onDelete: () => provider.deleteCard(card.id),
                      ),
                    );
                  },
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: card.imageUrl.isNotEmpty
                        ? Image.network(card.imageUrl, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.style_outlined,
                                color: Colors.white38))
                        : const Icon(Icons.style_outlined,
                            color: Colors.white38),
                  ),
                  title: Text(
                    card.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${card.game} • ${card.setName}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(card.totalValue),
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'x${card.quantity}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
