import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/card_item.dart';

class CardDetailDialog extends StatelessWidget {
  final CardItem card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardDetailDialog({
    super.key,
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CON TASTO CHIUDI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      card.game.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // IMMAGINE CARTA IN ALTA RISOLUZIONE
              Center(
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: card.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: card.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFFFD700)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 180,
                              color: const Color(0xFF12121C),
                              child: const Icon(Icons.style_outlined,
                                  size: 60, color: Colors.white38),
                            ),
                          )
                        : Container(
                            width: 180,
                            color: const Color(0xFF12121C),
                            child: const Icon(Icons.style_outlined,
                                size: 60, color: Colors.white38),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // TITOLO E SET
              Text(
                card.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Espansione: ${card.setName} ${card.cardNumber.isNotEmpty ? '#${card.cardNumber}' : ''}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              if (card.rarity.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Rarità: ${card.rarity}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // GRIGLIA VALORI E QUANTITÀ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Prezzo Medio (CardTrader)',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(card.currentPrice),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    Column(
                      children: [
                        Text(
                          'Quantità Posseduta',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'x${card.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    Column(
                      children: [
                        Text(
                          'Valore Totale',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(card.totalValue),
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PULSANTI AZIONE
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDelete();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Elimina'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onEdit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                        'Modifica',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
