import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:unilanches/cliente/finalizar_carrinho.dart';
import 'package:unilanches/src/services/carrinho_service.dart';
import 'package:unilanches/src/models/carrinho_model.dart';
import 'package:unilanches/src/models/item_carrinho_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final CarrinhoService _service = CarrinhoService();
  CarrinhoModel? _carrinho;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final carrinho = await _service.getOrCreateActiveCart();
      if (mounted) setState(() => _carrinho = carrinho);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erro ao carregar o carrinho: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updateItemQuantity(ItemCarrinhoModel item, int change) async {
    final newQuantity = item.quantidade + change;

    if (change > 0 && newQuantity > item.produto.quantidadeEstoque) {
      _showSnackBar('Não há estoque suficiente para este produto.');
      return;
    }

    if (newQuantity <= 0) {
      _removeItem(item.id);
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.editarItemCarrinho(item.id, newQuantity);
      await _loadCart();
    } catch (e) {
      _handleApiError(e, defaultMessage: 'Erro ao atualizar a quantidade.');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _removeItem(int itemId) async {
    setState(() => _loading = true);
    try {
      await _service.deletarItemCarrinho(itemId, _carrinho!.id);
      _showSnackBar('Item removido com sucesso.');
      await _loadCart();
    } catch (e) {
      _handleApiError(e, defaultMessage: 'Erro ao remover o item.');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : null,
        ),
      );
    }
  }

  void _handleApiError(Object e, {String defaultMessage = 'Ocorreu um erro.'}) {
    String errorMessage = defaultMessage;
    final errorString = e.toString();

    final jsonStartIndex = errorString.indexOf('{');
    if (jsonStartIndex != -1) {
      try {
        final jsonString = errorString.substring(jsonStartIndex);
        final decodedBody = jsonDecode(jsonString) as Map<String, dynamic>;

        if (decodedBody.values.isNotEmpty) {
          final firstErrorValue = decodedBody.values.first;
          if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
            errorMessage = firstErrorValue.first;
          } else {
            errorMessage = firstErrorValue.toString();
          }
        }
      } catch (_) {
        // Usa a mensagem padrão se o parsing falhar.
      }
    }
    _showSnackBar(errorMessage, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadCart,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCart,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_carrinho == null || _carrinho!.itens.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Seu carrinho está vazio!', style: TextStyle(fontSize: 20)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _carrinho!.itens.length,
            itemBuilder: (context, index) {
              final item = _carrinho!.itens[index];
              return _buildCartItemCard(item);
            },
          ),
        ),
        _buildCheckoutSection(),
      ],
    );
  }

  Widget _buildCartItemCard(ItemCarrinhoModel item) {
    // ... (nenhuma mudança aqui, o card continua o mesmo)
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.produto.imagemUrl ?? 'https://via.placeholder.com/150',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.produto.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${item.produto.preco.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _updateItemQuantity(item, -1),
                      ),
                      Text(
                        item.quantidade.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _updateItemQuantity(item, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _removeItem(item.id),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ BOTÃO ATUALIZADO: Apenas navega para a próxima tela.
  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'R\$ ${(_carrinho?.totalValor ?? 0.0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // A única responsabilidade agora é navegar.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FinalizarCarrinho(
                          carrinhoId: _carrinho!.id,
                          total: _carrinho!.totalValor,
                          itens: _carrinho!.itens,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.payment),
              label: const Text(
                'Ir para Pagamento',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
