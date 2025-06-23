import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar shared_preferences

import 'package:unilanches/src/services/carrinho_service.dart';
import 'package:unilanches/src/models/carrinho_model.dart';

// Importar ItemCarrinhoModel

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final CarrinhoService _service = CarrinhoService();
  CarrinhoModel? _carrinho; // Removido 'late', inicializado como null
  bool _loading = true;
  String? _error;
  int? _currentCarrinhoId; // Para armazenar o ID do carrinho ativo

  @override
  void initState() {
    super.initState();
    _loadAndFetchCarrinho(); // Chamada inicial para carregar ID e buscar/criar carrinho
  }

  // Esta função é responsável por carregar o ID do carrinho salvo,
  // buscar o carrinho na API, ou criar um novo se não houver um.
  Future<void> _loadAndFetchCarrinho() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentCarrinhoId = prefs.getInt('carrinhoId');

      const int testUserId = 1;

      CarrinhoModel fetchedCarrinho;

      if (_currentCarrinhoId != null) {
        try {
          fetchedCarrinho = await _service.buscarCarrinhoPorId(
            _currentCarrinhoId!,
          );
        } catch (e) {
          print(
            'Carrinho salvo ($_currentCarrinhoId) não encontrado. Criando novo...',
          );
          fetchedCarrinho = await _service.criarCarrinho(testUserId);
        }
      } else {
        print('Nenhum carrinhoId salvo. Criando novo...');
        fetchedCarrinho = await _service.criarCarrinho(testUserId);
      }

      _carrinho = fetchedCarrinho;
      _currentCarrinhoId = _carrinho!.id;
      await prefs.setInt('carrinhoId', _currentCarrinhoId!);
      _showSnackBar('Carrinho carregado/criado com sucesso!');
    } catch (e) {
      _error = 'Erro ao carregar carrinho: $e';
      print('Erro: $_error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Recarrega os dados do carrinho usando o ID atualmente armazenado (_currentCarrinhoId)
  Future<void> _fetchCarrinho() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_currentCarrinhoId != null) {
        // Usa o ID dinâmico do carrinho
        // Reintroduzindo o cast explícito para CarrinhoModel?
        _carrinho =
            (await _service.buscarCarrinhoPorId(_currentCarrinhoId!))
                as CarrinhoModel?;
      } else {
        // Se por algum motivo _currentCarrinhoId estiver nulo aqui (não deveria após _loadAndFetchCarrinho),
        // chame a lógica de carregamento inicial novamente para garantir que um ID seja obtido.
        await _loadAndFetchCarrinho();
      }
    } catch (e) {
      _error = 'Erro ao recarregar carrinho: $e';
      print('Erro detalhado em _fetchCarrinho: $_error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  double _getTotalPrice() {
    return _carrinho?.totalValor ?? 0;
  }

  // Remove um item do carrinho
  void _removeItem(int itemId) async {
    if (_currentCarrinhoId == null) {
      _showSnackBar('Nenhum carrinho ativo.');
      return;
    }
    setState(() {
      _loading = true; // Mostra indicador de carregamento
    });
    try {
      await _service.deletarItemCarrinho(itemId);
      _showSnackBar('Item removido do carrinho.');
      await _fetchCarrinho(); // Recarrega o carrinho para atualizar a UI e o total
    } catch (e) {
      _showSnackBar('Erro ao remover item: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Atualiza a quantidade de um item no carrinho
  void _updateItemQuantity(int itemId, int currentQuantity, int change) async {
    if (_currentCarrinhoId == null) {
      _showSnackBar('Nenhum carrinho ativo.');
      return;
    }

    final newQuantity = currentQuantity + change;
    if (newQuantity < 0) {
      // Não permite quantidade negativa
      _showSnackBar('A quantidade não pode ser negativa.');
      return;
    }
    if (newQuantity == 0) {
      // Se a nova quantidade for zero, pergunta ao usuário se deseja remover o item
      bool? confirmRemove = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Remover item?'),
            content: const Text('Deseja remover este item do carrinho?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
              ),
              TextButton(
                child: const Text('Remover'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (confirmRemove == true) {
        _removeItem(itemId); // Chama a função de remover item
      }
      return; // Sai da função após o tratamento de quantidade zero
    }

    setState(() {
      _loading = true; // Mostra indicador de carregamento
    });
    try {
      await _service.editarItemCarrinho(itemId, newQuantity);
      _showSnackBar('Quantidade atualizada para $newQuantity.');
      await _fetchCarrinho(); // Recarrega o carrinho para atualizar a UI e o total
    } catch (e) {
      _showSnackBar('Erro ao atualizar quantidade: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Limpa todos os itens do carrinho ativo
  void _clearCart() async {
    if (_currentCarrinhoId == null) {
      _showSnackBar('Nenhum carrinho ativo para limpar.');
      return;
    }
    // Adiciona uma confirmação antes de limpar o carrinho completamente
    bool? confirmClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Limpar Carrinho?'),
          content: const Text(
            'Tem certeza que deseja remover todos os itens do carrinho?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmClear == true) {
      setState(() {
        _loading = true; // Mostra indicador de carregamento
      });
      try {
        // Usa o ID dinâmico do carrinho
        await _service.limparCarrinho(_currentCarrinhoId!);
        _showSnackBar('Carrinho limpo com sucesso!');
        await _fetchCarrinho(); // Recarrega o carrinho para atualizar a UI
      } catch (e) {
        _showSnackBar('Erro ao limpar carrinho: $e');
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Função auxiliar para exibir SnackBar de forma segura
  void _showSnackBar(String message) {
    // Garante que o widget ainda está montado antes de mostrar o SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
            onPressed:
                _fetchCarrinho, // Botão de refresh para recarregar o carrinho
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCart, // Botão para limpar o carrinho
          ),
        ],
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Indicador de carregamento
              : _error != null
              ? Center(
                // Exibe mensagem de erro se houver
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          _loadAndFetchCarrinho, // Tentar novamente (carrega/cria)
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              )
              : _carrinho == null || _carrinho!.itens.isEmpty
              ? Center(
                // Exibe mensagem de carrinho vazio
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Seu carrinho está vazio!',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Column(
                // Exibe os itens do carrinho se houver
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _carrinho!.itens.length,
                      itemBuilder: (context, index) {
                        final item = _carrinho!.itens[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Imagem do produto
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        // Usa 'item.produto.imagemUrl' que deve vir do ProdutoModel
                                        // Se for nulo, usa um placeholder
                                        item.produto.imagemUrl ??
                                            'https://via.placeholder.com/150',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Detalhes e Controles de Quantidade
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.produto.nome,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${item.produto.preco.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed:
                                                () => _updateItemQuantity(
                                                  item.id,
                                                  item.quantidade,
                                                  -1,
                                                ),
                                          ),
                                          Text(
                                            item.quantidade.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            onPressed:
                                                () => _updateItemQuantity(
                                                  item.id,
                                                  item.quantidade,
                                                  1,
                                                ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Total Item: R\$ ${(item.produto.preco * item.quantidade).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeItem(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total do Pedido:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'R\$ ${_getTotalPrice().toStringAsFixed(2)}',
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
                              _showSnackBar(
                                'Finalizar Pedido (Lógica a ser implementada)!',
                              );
                              // ADICIONE A LÓGICA PARA FINALIZAR O PEDIDO AQUI
                              // Ex: Navegar para uma tela de pagamento, enviar pedido para a API, etc.
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.payment),
                            label: const Text(
                              'Finalizar Pedido',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

// REMOVIDA A EXTENSÃO PROBLEMÁTICA QUE ESTAVA ANULANDO A IMAGEM URL.
// CERTIFIQUE-SE DE QUE SEU 'ProdutoModel' TEM UM CAMPO 'imagemUrl' (String?)
// e que ele está sendo corretamente desserializado no 'ProdutoModel.fromJson'.
