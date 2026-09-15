import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_item.dart';
import '../providers/portfolio_provider.dart';

class AddEditCardDialog extends StatefulWidget {
  final CardItem? cardToEdit;

  const AddEditCardDialog({super.key, this.cardToEdit});

  @override
  State<AddEditCardDialog> createState() => _AddEditCardDialogState();
}

class _AddEditCardDialogState extends State<AddEditCardDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _setController;
  late TextEditingController _numberController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;
  late TextEditingController _rarityController;

  String _selectedGame = 'Magic';
  bool _isSearching = false;
  String? _searchStatus;

  final List<String> _games = [
    'Magic',
    'Pokémon',
    'Lorcana',
    'One Piece',
    'Altro'
  ];

  @override
  void initState() {
    super.initState();
    final card = widget.cardToEdit;
    _nameController = TextEditingController(text: card?.name ?? '');
    _setController = TextEditingController(text: card?.setName ?? '');
    _numberController = TextEditingController(text: card?.cardNumber ?? '');
    _priceController =
        TextEditingController(text: card != null ? card.currentPrice.toString() : '');
    _quantityController =
        TextEditingController(text: card != null ? card.quantity.toString() : '1');
    _imageUrlController = TextEditingController(text: card?.imageUrl ?? '');
    _rarityController = TextEditingController(text: card?.rarity ?? '');

    if (card != null && _games.contains(card.game)) {
      _selectedGame = card.game;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setController.dispose();
    _numberController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    _rarityController.dispose();
    super.dispose();
  }

  Future<void> _autoSearchCardTrader() async {
    final name = _nameController.text.trim();
    final number = _numberController.text.trim();
    final setStr = _setController.text.trim();

    final query = [name, number, setStr].where((s) => s.isNotEmpty).join(' ');

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Inserisci il nome o il numero della carta (es. Loki, OP17-119) prima di cercare'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _searchStatus = 'Ricerca in corso su CardTrader...';
    });

    final provider = Provider.of<PortfolioProvider>(context, listen: false);
    if (provider.cardTraderService.apiToken == null ||
        provider.cardTraderService.apiToken!.isEmpty) {
      provider.cardTraderService.apiToken = provider.cardTraderToken;
    }

    final result = await provider.cardTraderService.searchCard(
      name,
      _selectedGame,
      cardNumber: number,
      setName: setStr,
    );

    if (result != null) {
      setState(() {
        _nameController.text = result.name;
        if (result.setName.isNotEmpty) _setController.text = result.setName;
        if (result.cardNumber.isNotEmpty) {
          _numberController.text = result.cardNumber;
        }
        if (result.imageUrl.isNotEmpty) {
          _imageUrlController.text = result.imageUrl;
        }
        _priceController.text = result.price.toStringAsFixed(2);
        if (result.rarity.isNotEmpty) _rarityController.text = result.rarity;
        _searchStatus = '✓ Trovato su CardTrader!';
      });
    } else {
      setState(() {
        _searchStatus = 'Nessun risultato trovato. Compila manualmente.';
      });
    }

    setState(() {
      _isSearching = false;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final setName = _setController.text.trim();
      final number = _numberController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
      final imageUrl = _imageUrlController.text.trim();
      final rarity = _rarityController.text.trim();

      final provider = Provider.of<PortfolioProvider>(context, listen: false);

      if (widget.cardToEdit != null) {
        final updated = widget.cardToEdit!.copyWith(
          name: name,
          game: _selectedGame,
          setName: setName,
          cardNumber: number,
          currentPrice: price,
          quantity: quantity,
          imageUrl: imageUrl,
          rarity: rarity,
        );
        provider.updateCard(updated);
      } else {
        final newCard = CardItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          game: _selectedGame,
          setName: setName,
          cardNumber: number,
          currentPrice: price,
          quantity: quantity,
          imageUrl: imageUrl,
          rarity: rarity,
        );
        provider.addCard(newCard);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardToEdit != null;

    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // INTESTAZIONE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Modifica Carta' : 'Aggiungi Nuova Carta',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // SELEZIONE GIOCO
                const Text(
                  'Gioco TCG',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGame,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E2E),
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      items: _games
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGame = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // NOME CARTA + BOTTONE AUTO-RICERCA
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          'Nome della Carta *',
                          hint: 'es. Black Lotus, Charizard, Elsa',
                          prefixIcon: Icons.style,
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Campo obbligatorio'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // PULSANTE RICERCA AUTOMATICA CARDTRADER
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _autoSearchCardTrader,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B2B40),
                      foregroundColor: const Color(0xFFFFD700),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFFD700),
                            ),
                          )
                        : const Icon(Icons.search, size: 18),
                    label: Text(
                      _isSearching
                          ? 'Ricerca in corso...'
                          : '🔍 Auto-cerca Foto & Prezzo (CardTrader)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (_searchStatus != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _searchStatus!,
                    style: TextStyle(
                      color: _searchStatus!.contains('✓')
                          ? Colors.greenAccent
                          : Colors.amberAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // SET & NUMERO CARTA
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _setController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Espansione / Set',
                            hint: 'es. Base Set, OP-01'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _numberController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Numero #', hint: 'es. 4/102'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // PREZZO MEDIO & QUANTITÀ
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Prezzo Medio (€)',
                            prefixIcon: Icons.euro),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Obbligatorio';
                          if (double.tryParse(val) == null) return 'Non valido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Quantità',
                            prefixIcon: Icons.numbers),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Obbligatorio';
                          if (int.tryParse(val) == null) return 'Non valido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // URL FOTO IMMAGINE
                TextFormField(
                  controller: _imageUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    'URL Immagine / Foto Carta',
                    hint: 'https://...',
                    prefixIcon: Icons.image,
                  ),
                ),
                const SizedBox(height: 24),

                // PULSANTE SALVA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Salva Modifiche' : 'Aggiungi al Portafoglio',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label,
      {String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFFFFD700), size: 18)
          : null,
      filled: true,
      fillColor: const Color(0xFF12121C),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700)),
      ),
    );
  }
}
