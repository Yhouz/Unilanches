import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeScreen extends StatelessWidget {
  final String qrCodeData;

  const QrCodeScreen({
    super.key,
    required this.qrCodeData,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtém as dimensões da tela para cálculos responsivos
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 2. Calcula o tamanho do QR Code com base na menor dimensão da tela
    //    Isso garante que ele fique bom tanto no modo retrato quanto paisagem.
    //    Adicionamos um limite máximo para telas grandes como tablets.
    final qrSize =
        (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.6;
    const maxQrSize = 350.0;
    final finalQrSize = qrSize > maxQrSize ? maxQrSize : qrSize;

    // 3. Calcula os tamanhos de fonte responsivos
    final titleFontSize = screenWidth * 0.06;
    final subtitleFontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirada do Pedido'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove o botão de voltar
      ),
      // 4. Usa um SingleChildScrollView para evitar overflow em telas pequenas
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size:
                      finalQrSize *
                      0.25, // Tamanho do ícone relativo ao QR Code
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  'Seu Pedido está Pronto!',
                  style: TextStyle(
                    // Limita o tamanho máximo da fonte
                    fontSize: titleFontSize > 28.0 ? 28.0 : titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apresente este QR Code no balcão para retirar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subtitleFontSize > 18.0 ? 18.0 : subtitleFontSize,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 32),
                // Widget que renderiza o QR Code
                QrImageView(
                  data: qrCodeData,
                  version: QrVersions.auto,
                  size: finalQrSize, // Tamanho do QR Code agora é responsivo
                  gapless: false,
                ),
                const SizedBox(height: 32),
                // Botão para copiar o código (opcional)
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar Código'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: TextStyle(
                      fontSize:
                          subtitleFontSize > 16.0 ? 16.0 : subtitleFontSize,
                    ),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: qrCodeData));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Código do pedido copiado!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // Botão para voltar para a tela inicial
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Text(
            'Voltar para o Início',
            style: TextStyle(
              fontSize: subtitleFontSize > 16.0 ? 16.0 : subtitleFontSize,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}
