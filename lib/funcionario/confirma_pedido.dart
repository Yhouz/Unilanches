import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unilanches/src/models/pedido_models.dart'; // Importe seu PedidoModel
import 'package:unilanches/src/services/pedido_service.dart'; // Importe seu serviço de pedido

class ConfirmaPedido extends StatefulWidget {
  const ConfirmaPedido({super.key});

  @override
  State<ConfirmaPedido> createState() => _ConfirmaPedidoState();
}

class _ConfirmaPedidoState extends State<ConfirmaPedido> {
  // IMPORTANT: Set autoStart to false to manually control camera start/stop
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    autoStart: false, // <--- Key change here!
  );

  final PedidoService _pedidoService = PedidoService();

  String? codigoLido;
  bool isProcessing = false;
  bool isLoading = false;
  String? mensagemExibicao;
  Color corMensagemExibicao = Colors.white;

  @override
  void initState() {
    super.initState();
    mensagemExibicao = 'Aponte para o QR Code do pedido';
    // Start the camera when the widget initializes
    _startCamera();
  }

  // New method to handle camera start, especially useful after permissions or resets
  Future<void> _startCamera() async {
    // Only attempt to start if the controller is not already running
    if (controller.isStarting != true) {
      // Check if it's not already in a starting state
      try {
        await controller.start();
        if (mounted) {
          setState(() {
            mensagemExibicao =
                'Aponte para o QR Code do pedido'; // Reset message on successful camera start
            corMensagemExibicao = Colors.white;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            mensagemExibicao =
                'Erro ao iniciar câmera: ${e.toString().replaceAll('MobileScannerException: ', '')}';
            corMensagemExibicao = Colors.red;
            isLoading = false; // Ensure loading is off if camera fails
          });
          // You might want to delay before re-attempting or give a manual retry button
          // if camera fails to start initially.
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Reinicia o estado para permitir uma nova leitura e reativa a câmera.
  void reiniciarScanner() async {
    // Made async because it calls _startCamera()
    if (mounted) {
      setState(() {
        codigoLido = null;
        isProcessing = false;
        isLoading = false;
        mensagemExibicao = 'Aponte para o QR Code do pedido';
        corMensagemExibicao = Colors.white;
      });
      // Stop current camera session if any, then start a new one
      await controller.stop(); // Ensure it's stopped before starting again
      _startCamera();
    }
  }

  /// Exibe o pop-up com os detalhes do pedido para confirmação.
  Future<void> _exibirPopupDeConfirmacao(
    PedidoModel pedido,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Confirmar Entrega do Pedido?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Pedido ID: ${pedido.pedido_id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  'Valor Total: R\$${pedido.total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Itens do pedido:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (pedido.itens.isEmpty)
                  const Text(
                    'Nenhum item listado.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                else
                  ...pedido.itens.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '• ${item.quantidade}x ${item.produto.nome}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
              child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
                reiniciarScanner(); // Permite escanear novamente
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF037FF3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirmar Entrega',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _finalizarPedidoConfirmado(
                  pedido.pedido_id.toString(),
                ); // Chama a finalização
              },
            ),
          ],
        );
      },
    );
  }

  /// Lida com a detecção do QR Code e busca os detalhes do pedido.
  Future<void> _handleQrCodeDetection(String pedidoId) async {
    if (isProcessing) return;

    // IMPORTANT: Stop the controller right after detection to prevent further scans
    controller.stop();

    setState(() {
      isProcessing = true;
      isLoading = true;
      codigoLido = pedidoId;
      mensagemExibicao = 'Verificando pedido $pedidoId...';
      corMensagemExibicao = Colors.yellow.shade700;
    });

    try {
      final PedidoModel pedido = await _pedidoService.detalharPedidoFinalizado(
        pedidoId,
      );

      if (pedido.status_pedido.toLowerCase() == 'entregue') {
        if (!mounted) return;
        setState(() {
          mensagemExibicao = 'Pedido $pedidoId já foi entregue!';
          corMensagemExibicao = Colors.red;
          isLoading = false;
        });
        Future.delayed(const Duration(seconds: 3), () => reiniciarScanner());
        return;
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      await _exibirPopupDeConfirmacao(pedido);
    } catch (e) {
      if (mounted) {
        setState(() {
          mensagemExibicao =
              "Erro: ${e.toString().replaceAll('Exception: ', '')}";
          corMensagemExibicao = Colors.red;
          isLoading = false;
        });
        Future.delayed(const Duration(seconds: 3), () => reiniciarScanner());
      }
    }
  }

  /// Lógica de finalização que é chamada APÓS a confirmação no pop-up.
  Future<void> _finalizarPedidoConfirmado(String pedidoId) async {
    setState(() {
      isLoading = true;
      mensagemExibicao = 'Finalizando pedido $pedidoId...';
      corMensagemExibicao = Theme.of(context).primaryColor;
    });

    try {
      await _pedidoService.finalizarPedido(pedidoId);
      if (!mounted) return;
      setState(() {
        mensagemExibicao = 'Pedido $pedidoId finalizado com sucesso!';
        corMensagemExibicao = Colors.green;
        isLoading = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          reiniciarScanner();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          mensagemExibicao =
              "Falha ao finalizar: ${e.toString().replaceAll('Exception: ', '')}";
          corMensagemExibicao = Colors.red;
          isLoading = false;
        });
        Future.delayed(const Duration(seconds: 3), () => reiniciarScanner());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirmar Entrega',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF037FF3),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (isProcessing) return;
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                _handleQrCodeDetection(barcode!.rawValue!);
              }
            },
          ),
          // Scanner Overlay/Frame
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCornerLine(Alignment.topLeft),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCornerLine(Alignment.topRight),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCornerLine(Alignment.bottomLeft),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCornerLine(Alignment.bottomRight),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Information Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: corMensagemExibicao,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          mensagemExibicao!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: corMensagemExibicao,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  if (codigoLido != null &&
                      !isLoading &&
                      corMensagemExibicao != Colors.red) ...[
                    const SizedBox(height: 10),
                    Text(
                      'QR Code lido: $codigoLido',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : reiniciarScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF037FF3),
                      side: const BorderSide(color: Color(0xFF037FF3)),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Escanear Novamente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Full-screen Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Processando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

  // Helper for the corner lines in the scanner frame
  Widget _buildCornerLine(Alignment alignment) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top:
              alignment == Alignment.topLeft || alignment == Alignment.topRight
                  ? BorderSide(color: Colors.blue.shade300, width: 4)
                  : BorderSide.none,
          bottom:
              alignment == Alignment.bottomLeft ||
                      alignment == Alignment.bottomRight
                  ? BorderSide(color: Colors.blue.shade300, width: 4)
                  : BorderSide.none,
          left:
              alignment == Alignment.topLeft ||
                      alignment == Alignment.bottomLeft
                  ? BorderSide(color: Colors.blue.shade300, width: 4)
                  : BorderSide.none,
          right:
              alignment == Alignment.topRight ||
                      alignment == Alignment.bottomRight
                  ? BorderSide(color: Colors.blue.shade300, width: 4)
                  : BorderSide.none,
        ),
      ),
    );
  }
}

extension on MobileScannerController {
  get isStarting => null;
}
