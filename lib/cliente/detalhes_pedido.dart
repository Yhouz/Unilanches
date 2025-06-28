import 'package:flutter/material.dart';
import 'package:unilanches/src/models/pedido_models.dart';
import 'package:unilanches/src/services/pedido_service.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importe a biblioteca

class DetalhesPedido extends StatefulWidget {
  final String pedidoid;

  const DetalhesPedido({super.key, required this.pedidoid});

  @override
  State<DetalhesPedido> createState() => _DetalhesPedidoState();
}

class _DetalhesPedidoState extends State<DetalhesPedido> {
  Future<PedidoModel>? _pedidoDetalhesFuture;
  final PedidoService _pedidoService = PedidoService();

  @override
  void initState() {
    super.initState();
    _carregarDetalhesPedido();
  }

  Future<void> _carregarDetalhesPedido() async {
    setState(() {
      _pedidoDetalhesFuture = _pedidoService.detalharPedido(widget.pedidoid);
    });
  }

  /// Função para mostrar o Dialog com o QR Code
  void _mostrarQrCodeDialog(String qrData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'QR Code para Finalização',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SizedBox(
            width: 250,
            height: 250,
            child: Center(
              child: QrImageView(
                data: qrData, // O ID do pedido vai aqui
                version: QrVersions.auto,
                size: 220.0,
                gapless: false,
                // Você pode adicionar um logo no meio se quiser
                // embeddedImage: AssetImage('assets/images/logo.png'),
                // embeddedImageStyle: QrEmbeddedImageStyle(
                //   size: Size(40, 40),
                // ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Mapeamento de status para cores e ícones
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'confirmado':
        return Colors.blue;
      case 'em preparacao':
        return Colors.purple;
      case 'a caminho':
        return Colors.lightBlue;
      case 'entregue':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Icons.hourglass_empty;
      case 'confirmado':
        return Icons.check_circle_outline;
      case 'em preparacao':
        return Icons.kitchen;
      case 'a caminho':
        return Icons.delivery_dining;
      case 'entregue':
        return Icons.done_all;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes do Pedido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<PedidoModel>(
        future: _pedidoDetalhesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar os detalhes do pedido: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _carregarDetalhesPedido,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Nenhum detalhe de pedido encontrado.'),
            );
          }

          final pedido = snapshot.data!;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
          final currencyFormat = NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$',
          );

          // Determine if the QR code should be active
          final bool isPedidoEntregue =
              pedido.status_pedido.toLowerCase() == 'entregue';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de Resumo do Pedido
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Pedido #${pedido.pedido_id}',
                                style: const TextStyle(
                                  fontSize: 24, // Larger font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  pedido.status_pedido,
                                ).withOpacity(0.15), // Slightly less opacity
                                borderRadius: BorderRadius.circular(
                                  15,
                                ), // More rounded
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(pedido.status_pedido),
                                    color: _getStatusColor(
                                      pedido.status_pedido,
                                    ),
                                    size: 20, // Slightly larger icon
                                  ),
                                  const SizedBox(width: 8), // More spacing
                                  Text(
                                    pedido.status_pedido,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16, // Slightly larger text
                                      color: _getStatusColor(
                                        pedido.status_pedido,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 30,
                          thickness: 1.5,
                          color: Colors.grey,
                        ), // Thicker divider
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Data do Pedido:',
                          dateFormat.format(pedido.data_pedido),
                        ),
                        _buildDetailRow(
                          Icons.attach_money,
                          'Total do Pedido:',
                          currencyFormat.format(pedido.total),
                          isBold: true,
                          valueColor: Colors.green[700],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seção de Itens do Pedido
                Text(
                  'Itens do Pedido',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    // Changed to headlineMedium
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const Divider(
                  height: 15,
                  thickness: 1.5,
                  color: Colors.grey,
                ), // Consistent divider
                pedido.itens.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 30.0,
                      ), // More padding
                      child: Center(
                        child: Text(
                          'Nenhum item encontrado para este pedido.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pedido.itens.length,
                      itemBuilder: (context, index) {
                        final item = pedido.itens[index];
                        return Card(
                          elevation: 3, // Slightly higher elevation
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ), // More vertical margin
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // More rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), // More padding
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.produto.nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18, // Larger font size
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6), // More spacing
                                      Text(
                                        '${item.quantidade} x ${currencyFormat.format(item.valorItem)}',
                                        style: TextStyle(
                                          fontSize: 15, // Slightly larger
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Subtotal: ${currencyFormat.format(item.quantidade * item.valorItem)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16, // Slightly larger
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                const SizedBox(height: 30), // More space before the button
                // Botão para ver o QR Code
                Center(
                  child: ElevatedButton.icon(
                    // ✅ Lógica para desabilitar o botão se o pedido estiver 'Entregue'
                    onPressed:
                        isPedidoEntregue
                            ? null // Botão desabilitado se o status for 'Entregue'
                            : () {
                              final qrData =
                                  pedido.qr_code_pedido ??
                                  pedido.pedido_id
                                      .toString(); // Usa qr_code_pedido se existir
                              _mostrarQrCodeDialog(qrData);
                            },
                    icon: const Icon(Icons.qr_code, size: 24), // Larger icon
                    label: Text(
                      isPedidoEntregue
                          ? 'QR Code Indisponível (Entregue)' // Texto quando desabilitado
                          : 'Ver QR Code do Pedido',
                      style: const TextStyle(
                        fontSize: 18,
                      ), // Consistent font size
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30, // More horizontal padding
                        vertical: 18, // More vertical padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      // Define a cor de fundo com base no status (cinza se desabilitado)
                      backgroundColor:
                          isPedidoEntregue
                              ? Colors.grey[400] // Lighter grey for disabled
                              : Theme.of(
                                context,
                              ).primaryColor, // Primary color for enabled
                      foregroundColor:
                          isPedidoEntregue
                              ? Colors.grey[700] // Darker text for disabled
                              : Colors.white, // White text for enabled
                      elevation:
                          isPedidoEntregue
                              ? 0
                              : 5, // No elevation when disabled
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Método auxiliar para construir linhas de detalhes
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // More vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Aligned to center
        children: [
          Icon(
            icon,
            size: 22,
            color: Colors.deepPurple,
          ), // Larger icon and distinct color
          const SizedBox(width: 12), // More spacing
          Text(
            label,
            style: const TextStyle(
              fontSize: 17, // Slightly larger font
              fontWeight: FontWeight.w600, // Medium bold
              color: Colors.blueGrey,
            ),
          ),
          const Spacer(), // Use Spacer to push the value to the end
          Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 17, // Consistent font size
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
