import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../services/bulk_import_service.dart';

class BulkImportDialog extends StatefulWidget {
  const BulkImportDialog({super.key});

  @override
  State<BulkImportDialog> createState() => _BulkImportDialogState();
}

class _BulkImportDialogState extends State<BulkImportDialog> {
  bool _isLoading = false;
  String? _message;

  Future<void> _loadFactorySample() async {
    setState(() {
      _isLoading = true;
      _message = 'Caricamento configurazione di fabbrica in corso...';
    });

    final provider = Provider.of<PortfolioProvider>(context, listen: false);
    await provider.loadFactorySampleData();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _message = '✓ Carte di fabbrica caricate con successo!';
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  Future<void> _pickAndImportFile() async {
    setState(() {
      _isLoading = true;
      _message = 'Selezione del file JSON...';
    });

    try {
      final cards = await BulkImportService.pickAndImportJsonFile();
      if (cards != null && cards.isNotEmpty) {
        final provider = Provider.of<PortfolioProvider>(context, listen: false);
        await provider.importJsonCards(cards, replaceExisting: false);
        if (mounted) {
          setState(() {
            _message = '✓ Importate ${cards.length} carte con successo!';
          });
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) Navigator.of(context).pop();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _message = 'Nessun file selezionato o file vuoto.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = 'Errore durante l\'importazione: formato non valido.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showExportPreview() {
    final provider = Provider.of<PortfolioProvider>(context, listen: false);
    final jsonStr = BulkImportService.exportToJsonString(provider.cards);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Export JSON Portafoglio',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 500,
          height: 350,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.file_download_outlined,
                        color: Color(0xFFFFD700), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Caricamento Bulk JSON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Scegli come popolare o aggiornare il tuo portafoglio carte:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // OPZIONE 1: FABBRICA DEMO
            _buildOptionCard(
              title: '⚡ Carica Dati di Fabbrica',
              description:
                  'Popola subito l\'app con una collezione completa di carte da Magic, Pokémon, Lorcana e One Piece normalizzate.',
              icon: Icons.inventory_2_outlined,
              accentColor: const Color(0xFFFFD700),
              onTap: _isLoading ? null : _loadFactorySample,
            ),
            const SizedBox(height: 12),

            // OPZIONE 2: IMPORT FILE JSON
            _buildOptionCard(
              title: '📁 Importa File JSON Personalizzato',
              description:
                  'Scegli un file .json memorizzato sul tuo dispositivo localmente o su cloud.',
              icon: Icons.upload_file_outlined,
              accentColor: const Color(0xFF00BCD4),
              onTap: _isLoading ? null : _pickAndImportFile,
            ),
            const SizedBox(height: 12),

            // OPZIONE 3: EXPORT JSON
            _buildOptionCard(
              title: '💾 Esporta Portafoglio Corrente (JSON)',
              description:
                  'Genera il file JSON del tuo portafoglio per backup o trasferimento.',
              icon: Icons.save_alt_rounded,
              accentColor: const Color(0xFF4CAF50),
              onTap: _isLoading ? null : _showExportPreview,
            ),

            if (_message != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message!.contains('✓')
                        ? Colors.greenAccent
                        : Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12121C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
