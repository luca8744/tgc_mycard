import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/tcg_card_tile.dart';
import 'add_edit_card_dialog.dart';
import 'card_detail_dialog.dart';
import 'bulk_import_dialog.dart';

class CollectionView extends StatelessWidget {
  const CollectionView({super.key});

  final List<String> _gameFilters = const [
    'Tutti',
    'Magic',
    'Pokémon',
    'Lorcana',
    'One Piece',
    'Altro'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PortfolioProvider>(context);
    final cards = provider.filteredCards;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // INTESTAZIONE E BARRA RICERCA
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  onChanged: (val) => provider.setSearchQuery(val),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cerca nome, espansione o #...',
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFFFFD700), size: 18),
                    filled: true,
                    fillColor: const Color(0xFF1E1E2E),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFFFD700)),
                    ),
                  ),
                ),
              ),

              // ORDINAMENTO DROPDOWN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.sortBy,
                    dropdownColor: const Color(0xFF1E1E2E),
                    icon: const Icon(Icons.sort, color: Color(0xFFFFD700)),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(
                        value: 'valore_desc',
                        child: Text('Valore ↓'),
                      ),
                      DropdownMenuItem(
                        value: 'valore_asc',
                        child: Text('Valore ↑'),
                      ),
                      DropdownMenuItem(
                        value: 'nome_asc',
                        child: Text('Nome A-Z'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.setSortBy(val);
                    },
                  ),
                ),
              ),

              // TASTO NUOVA CARTA
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AddEditCardDialog(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Nuova Carta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // TAB FILTRI PER GIOCO (TUTTI, MAGIC, POKÉMON, LORCANA, ONE PIECE)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _gameFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final game = _gameFilters[index];
                final isSelected = provider.selectedGameFilter == game;
                return ChoiceChip(
                  label: Text(game),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) provider.setGameFilter(game);
                  },
                  selectedColor: const Color(0xFFFFD700),
                  backgroundColor: const Color(0xFF1E1E2E),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : Colors.white.withOpacity(0.08),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // GRIGLIA CARTE
          Expanded(
            child: cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 60,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nessuna carta trovata',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Aggiungi una carta a mano o carica il file di fabbrica.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => const BulkImportDialog(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B2B40),
                            foregroundColor: const Color(0xFFFFD700),
                          ),
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('Carica Dati di Fabbrica'),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 5;
                      } else if (constraints.maxWidth > 900) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 3;
                      }

                      return GridView.builder(
                        itemCount: cards.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return TcgCardTile(
                            card: card,
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
                            onIncrement: () =>
                                provider.updateQuantity(card.id, 1),
                            onDecrement: () =>
                                provider.updateQuantity(card.id, -1),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
