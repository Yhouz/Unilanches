import 'package:flutter/material.dart';
import 'package:unilanches/cliente/detalhes_pedido.dart';
import 'package:unilanches/src/models/pedido_models.dart';
import 'package:unilanches/src/services/pedido_service.dart';
import 'package:unilanches/src/services/auth_service.dart';
import 'package:intl/intl.dart'; // Para formatação de data e moeda

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
      // Supondo que `listarPedidosDoUsuarioLogado` já faz a autenticação
      // e busca os pedidos associados ao token.
      return await _pedidoService.listarPedidosDoUsuarioLogado();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        actions: [
          IconButton(
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando seus pedidos...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return FutureBuilder<List<PedidoModel>>(
      future: _pedidosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando pedidos...', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
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
                  const Text(
                    'Ops! Ocorreu um erro:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _carregarDadosIniciais,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      await AuthServiceWeb.logout();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Fazer login novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.grey,
                    size: 64, // Ícone maior para vazio
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Você ainda não fez nenhum pedido!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Que tal explorar nossos produtos e fazer seu primeiro pedido?',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navegar para a tela de produtos/home'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Fazer um pedido agora!'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return _buildPedidoCard(
                pedido,
              ); // Novo método para construir o card
            },
          ),
        );
      },
    );
  }

  // --- NOVO MÉTODO: CONSTRUIR CARD DE PEDIDO ---
  Widget _buildPedidoCard(PedidoModel pedido) {
    // Formatação da data
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    String dataPedido = '';
    try {
      dataPedido = dateFormat.format(pedido.data_pedido);
    } catch (e) {
      dataPedido = 'Data inválida';
    }

    // Mapeamento de status para cores (exemplo)
    Color statusColor;
    switch (pedido.status_pedido.toLowerCase()) {
      case 'pendente':
        statusColor = Colors.orange;
        break;
      case 'confirmado':
        statusColor = Colors.blue;
        break;
      case 'em Preparacao':
        statusColor = Colors.purple;
        break;
      case 'a Caminho':
        statusColor = Colors.lightBlue;
        break;
      case 'entregue':
        statusColor = Colors.green;
        break;
      case 'cancelado':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 4, // Maior elevação para destaque
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 12.0,
      ), // Mais espaço nas laterais
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Cantos arredondados
      child: InkWell(
        // Adiciona um efeito de clique
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DetalhesPedido(pedidoid: '${pedido.pedido_id}'),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${pedido.pedido_id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepPurple, // Cor de destaque para o ID
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(
                        0.2,
                      ), // Fundo suave com a cor do status
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pedido.status_pedido,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16, thickness: 1), // Divisor visual
              Text(
                'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(pedido.total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Data: $dataPedido',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
