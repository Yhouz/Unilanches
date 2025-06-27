// lib/cliente/detalhes_pedido.dart
import 'package:flutter/material.dart';
import 'package:unilanches/src/models/pedido_models.dart';
import 'package:unilanches/src/services/pedido_service.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart'; // ✅ 1. Importe a biblioteca

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

  /// ✅ 2. Função para mostrar o Dialog com o QR Code
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
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Mapeamento de status para cores e ícones (reutilize do ListaPedidos)
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
        title: const Text('Detalhes do Pedido'),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pedido #${pedido.pedido_id}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  pedido.status_pedido,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(pedido.status_pedido),
                                    color: _getStatusColor(
                                      pedido.status_pedido,
                                    ),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    pedido.status_pedido,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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
                        const Divider(height: 25, thickness: 1.5),
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

                const SizedBox(height: 10),

                // Seção de Itens do Pedido
                Text(
                  'Itens do Pedido',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const Divider(height: 10, thickness: 1),
                pedido.itens.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
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
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
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
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.quantidade} x ${currencyFormat.format(item.valorItem)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        'Subtotal: ${currencyFormat.format(item.quantidade * item.valorItem)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
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
                const SizedBox(height: 20),

                // ✅ 3. Botão atualizado para chamar o dialog
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Usa o campo `qr_code_pedido` se existir, senão usa o `pedido_id`
                      final qrData =
                          pedido.qr_code_pedido ?? pedido.pedido_id.toString();
                      _mostrarQrCodeDialog(qrData);
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Ver QR Code do Pedido'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
