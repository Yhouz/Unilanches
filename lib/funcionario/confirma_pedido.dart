import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:unilanches/src/models/pedido_models.dart'; // IMPORTANTE: Importe seu PedidoModel
import 'package:unilanches/src/services/pedido_service.dart'; // Importe seu serviço de pedido

class ConfirmaPedido extends StatefulWidget {
  const ConfirmaPedido({super.key});

  @override
  State<ConfirmaPedido> createState() => _ConfirmaPedidoState();
}

class _ConfirmaPedidoState extends State<ConfirmaPedido> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
  );

  // Instância do seu serviço de Pedidos
  final PedidoService _pedidoService = PedidoService();

  String? codigoLido;
  bool isProcessing = false; // Trava o scanner após a primeira leitura
  bool isLoading = false; // Controla a exibição do loading
  String? errorMessage; // Armazena mensagens de erro da API

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Reinicia o estado para permitir uma nova leitura
  void reiniciarScanner() {
    if (mounted) {
      setState(() {
        codigoLido = null;
        isProcessing = false;
        isLoading = false;
        errorMessage = null;
      });
    }
  }

  /// Exibe o pop-up com os detalhes do pedido para confirmação.
  Future<void> _exibirPopupDeConfirmacao(
    String pedidoId,
    List<String> itensDoPedido,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve escolher uma ação
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Entrega do Pedido'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Pedido: $pedidoId',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Itens do pedido:'),
                const SizedBox(height: 8),
                // Exibe a lista de itens formatada
                ...itensDoPedido.map((item) => Text('• $item')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                reiniciarScanner(); // Permite escanear novamente
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF037FF3),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _finalizarPedidoConfirmado(pedidoId); // Chama a finalização
              },
            ),
          ],
        );
      },
    );
  }

  /// **CORRIGIDO**: Função chamada quando um QR Code é detectado.
  Future<void> _handleQrCodeDetection(String pedidoId) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      isLoading = true;
      errorMessage = null;
      codigoLido = pedidoId;
    });

    try {
      final PedidoModel pedido = await _pedidoService.detalharPedidoFinalizado(
        pedidoId,
      );

      // --- PONTO DA CORREÇÃO ---
      // O erro acontecia porque estávamos tentando usar `pedido.carrinho.itens`.
      // Como vimos no seu `PedidoModel`, `pedido.carrinho` é um `int` (ID),
      // e a lista de itens está diretamente em `pedido.itens`.
      //
      // ✅ CORREÇÃO: Acessamos a lista de itens diretamente de `pedido.itens`.
      final List<String> itensDoPedido =
          pedido.itens.map((item) {
            // Presumindo que seu ItemCarrinhoModel tenha os campos `quantidade`
            // e um objeto `produto` com um campo `nome`.
            final int quantidade = item.quantidade;
            final String nomeProduto = item.produto.nome;
            // ✅ CORREÇÃO DE SINTAXE: O 'x' foi movido para dentro da string.
            return '${quantidade}x $nomeProduto'; // Formata como "2x Nome do Produto"
          }).toList();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      await _exibirPopupDeConfirmacao(pedidoId, itensDoPedido);
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Erro: ${e.toString().replaceAll('Exception: ', '')}";
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
      errorMessage = null;
    });

    try {
      await _pedidoService.finalizarPedido(pedidoId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido finalizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
        centerTitle: true,
        backgroundColor: const Color(0xFF037FF3),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
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
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 6,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    codigoLido != null
                        ? 'Processando pedido: $codigoLido'
                        : 'Aponte para o QR Code',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : reiniciarScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF037FF3)),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text(
                      'Escanear Novamente',
                      style: TextStyle(color: Color(0xFF037FF3)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
