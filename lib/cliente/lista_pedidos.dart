import 'package:flutter/material.dart';
import 'package:unilanches/cliente/detalhes_pedido.dart';
import 'package:unilanches/src/models/pedido_models.dart';
import 'package:unilanches/src/services/pedido_service.dart';
import 'package:unilanches/src/services/auth_service.dart';
import 'package:intl/intl.dart'; // For date and currency formatting

class ListaPedidos extends StatefulWidget {
  const ListaPedidos({super.key});

  @override
  State<ListaPedidos> createState() => _ListaPedidosState();
}

class _ListaPedidosState extends State<ListaPedidos> {
  Future<List<PedidoModel>>? _pedidosFuture;
  final PedidoService _pedidoService = PedidoService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosIniciais();
    });
  }

  Future<void> _carregarDadosIniciais() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await AuthServiceWeb.getAccessToken();

      if (token != null && token.isNotEmpty) {
        final future = _carregarPedidosDoUsuarioLogado().timeout(
          const Duration(seconds: 15),
          onTimeout:
              () => Future.error('Tempo limite excedido ao carregar pedidos.'),
        );

        setState(() {
          _pedidosFuture = future;
        });
      } else {
        setState(() {
          _pedidosFuture = Future.error(
            'Usuário não autenticado. Faça login novamente.',
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pedidosFuture = Future.error(
            'Erro ao verificar autenticação: ${e.toString()}',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<PedidoModel>> _carregarPedidosDoUsuarioLogado() async {
    try {
      // Assuming `listarPedidosDoUsuarioLogado` already handles authentication
      // and fetches orders associated with the token.
      return await _pedidoService.listarPedidosDoUsuarioLogado();
    } catch (e) {
      rethrow;
    }
  }

  // Helper to map status to icon
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

  // Helper to map status to color
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Pedidos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ), // Bold title, white color
        ),
        backgroundColor:
            Theme.of(context).primaryColor, // Use primary color for app bar
        elevation: 0, // No shadow for a flat design
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        actions: [
          IconButton(
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ), // White loading indicator
                      ),
                    )
                    : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _carregarDadosIniciais,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_pedidosFuture == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ), // Primary color for loading
            const SizedBox(height: 16),
            Text(
              'Carregando seus pedidos...',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<PedidoModel>>(
      future: _pedidosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ), // Primary color for loading
                const SizedBox(height: 16),
                Text(
                  'Carregando pedidos...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Increased padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons
                        .sentiment_dissatisfied_outlined, // More empathetic icon
                    color: Colors.redAccent, // Softer red
                    size: 60, // Larger icon
                  ),
                  const SizedBox(height: 20), // More spacing
                  const Text(
                    'Poxa, algo deu errado!', // Friendlier error message
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${snapshot.error}', // Display the actual error
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700], fontSize: 15),
                  ),
                  const SizedBox(height: 24), // More spacing
                  ElevatedButton.icon(
                    onPressed: _carregarDadosIniciais,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text(
                      'Tentar novamente',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      await AuthServiceWeb.logout();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    icon: Icon(
                      Icons.login_outlined,
                      color: Colors.blueGrey[600],
                    ), // Logout icon
                    label: Text(
                      'Fazer login novamente',
                      style: TextStyle(
                        color: Colors.blueGrey[600],
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Increased padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .shopping_bag_outlined, // More relevant empty state icon
                    color: Colors.grey[400], // Softer grey
                    size: 80, // Even larger icon
                  ),
                  const SizedBox(height: 30), // More spacing
                  const Text(
                    'Você ainda não fez nenhum pedido!',
                    style: TextStyle(
                      fontSize: 22, // Larger font
                      color: Colors.black54, // Softer black
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Que tal explorar nossos produtos e fazer seu primeiro pedido agora?', // More engaging text
                    style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30), // More spacing
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement navigation to product/home screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navegar para a tela de produtos/home'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.storefront_outlined,
                      size: 24,
                    ), // New icon
                    label: const Text(
                      'Explorar cardápio!',
                      style: TextStyle(fontSize: 18),
                    ), // More inviting text
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).primaryColor, // Use primary color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ), // More rounded
                      elevation: 5, // Add a slight shadow
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final pedidos = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _carregarDadosIniciais,
          color: Theme.of(context).primaryColor, // Refresh indicator color
          child: ListView.builder(
            padding: const EdgeInsets.all(
              12.0,
            ), // Increased padding around the list
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return _buildPedidoCard(
                pedido,
              ); // Method to build each order card
            },
          ),
        );
      },
    );
  }

  // --- IMPROVED METHOD: BUILD ORDER CARD ---
  Widget _buildPedidoCard(PedidoModel pedido) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    String dataPedido = '';
    try {
      dataPedido = dateFormat.format(pedido.data_pedido);
    } catch (e) {
      dataPedido = 'Data inválida';
    }

    final statusColor = _getStatusColor(pedido.status_pedido);
    final statusIcon = _getStatusIcon(pedido.status_pedido);
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Card(
      elevation: 6, // Higher elevation for a more prominent card
      margin: const EdgeInsets.symmetric(
        vertical: 10.0, // More vertical space between cards
        horizontal: 8.0, // Slight horizontal margin
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // More rounded corners
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DetalhesPedido(pedidoid: '${pedido.pedido_id}'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(
          15,
        ), // Match card border radius for InkWell
        child: Padding(
          padding: const EdgeInsets.all(
            18.0,
          ), // Increased padding inside the card
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
                        fontWeight: FontWeight.bold,
                        fontSize: 20, // Larger font size for order ID
                        color: Colors.deepPurple, // Distinct color
                      ),
                      overflow:
                          TextOverflow
                              .ellipsis, // Prevents overflow for long IDs
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(
                        0.18,
                      ), // Slightly more opaque background
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pedido.status_pedido,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 20,
                thickness: 1.2,
                color: Colors.grey,
              ), // Thicker, slightly darker divider
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Data: $dataPedido',
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Spacing before total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600, // Medium bold
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    currencyFormat.format(pedido.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19, // Slightly larger for total
                      color: Colors.green, // Prominent green for total
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
