import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart'; // ✅ Importação para firstWhereOrNull

import 'package:unilanches/src/services/carrinho_service.dart';
import 'package:unilanches/src/models/carrinho_model.dart';

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
  int? _currentCarrinhoId; // Para armazenar o ID do carrinho ativo

  @override
  void initState() {
    super.initState();
    _loadAndFetchCarrinho();
  }

  Future<void> _loadAndFetchCarrinho() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentCarrinhoId = prefs.getInt(
        'carrinhoId',
      ); // Tenta carregar um ID salvo

      CarrinhoModel?
      foundCarrinho; // Variável para armazenar o carrinho encontrado/criado

      // 1. Tentar buscar o carrinho pelo ID salvo (se existir)
      if (_currentCarrinhoId != null) {
        try {
          final fetchedByIdCarrinho = await _service.buscarCarrinhoPorId(
            _currentCarrinhoId!,
          );
          // Verificar se o carrinho retornado pelo ID está 'em aberto'
          if (!fetchedByIdCarrinho.finalizado) {
            foundCarrinho = fetchedByIdCarrinho;
            print(
              'DEBUG: Carrinho (ID: $_currentCarrinhoId) salvo encontrado e está em aberto.',
            );
          } else {
            print(
              'DEBUG: Carrinho (ID: $_currentCarrinhoId) salvo está finalizado. Desconsiderando.',
            );
            await prefs.remove(
              'carrinhoId',
            ); // Remove o ID do carrinho finalizado
            _currentCarrinhoId = null; // Limpa a variável local também
          }
        } catch (e) {
          // Se a busca pelo ID salvo falhar (404 Not Found, 403 Forbidden, etc.)
          print(
            'DEBUG: Carrinho (ID: $_currentCarrinhoId) salvo não encontrado ou inacessível. Removendo ID salvo.',
          );
          await prefs.remove('carrinhoId'); // Limpa o ID que deu erro
          _currentCarrinhoId = null; // Zera a variável local também
        }
      }

      // 2. Se nenhum carrinho válido foi encontrado pelo ID salvo, tentar listar carrinhos abertos
      if (foundCarrinho == null) {
        print('DEBUG: Buscando por carrinhos abertos na API...');
        final allCarrinhos = await _service.listarCarrinhos();
        // Filtra para encontrar o primeiro carrinho que não está finalizado
        final openCarrinho = allCarrinhos.firstWhereOrNull(
          (c) => !c.finalizado,
        );

        if (openCarrinho != null) {
          foundCarrinho = openCarrinho;
          print(
            'DEBUG: Carrinho em aberto encontrado na API (ID: ${foundCarrinho.id}).',
          );
        } else {
          print('DEBUG: Nenhum carrinho em aberto encontrado na API.');
        }
      }

      // 3. Se ainda nenhum carrinho foi encontrado, criar um novo
      if (foundCarrinho == null) {
        print(
          'DEBUG: Nenhum carrinho em aberto encontrado ou salvo. Criando novo...',
        );
        foundCarrinho = await _service.criarCarrinho();
        print('DEBUG: Novo carrinho criado (ID: ${foundCarrinho.id}).');
      }

      // Salvar o ID do carrinho encontrado/criado para uso futuro
      _carrinho = foundCarrinho;
      _currentCarrinhoId = _carrinho!.id;
      await prefs.setInt('carrinhoId', _currentCarrinhoId!);
      print(
        'DEBUG: ID do carrinho ativo salvo para a sessão: $_currentCarrinhoId',
      );

      if (!mounted) return;
      _showSnackBar('Carrinho carregado/criado com sucesso!');
    } catch (e) {
      _error = 'Erro ao carregar carrinho: $e';
      print('ERRO: $_error');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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
        // Busca o carrinho pelo ID
        _carrinho = await _service.buscarCarrinhoPorId(_currentCarrinhoId!);
        // Se o carrinho foi finalizado por fora (ex: outro dispositivo), vamos tratá-lo como "não encontrado"
        if (_carrinho!.finalizado) {
          print(
            'DEBUG: Carrinho ID $_currentCarrinhoId foi finalizado. Buscando/Criando novo.',
          );
          await _loadAndFetchCarrinho(); // Tentar novamente desde o início
        } else {
          print('DEBUG: Carrinho ID $_currentCarrinhoId recarregado.');
        }
      } else {
        // Se não tem ID, tenta criar/carregar de novo (chama a lógica completa)
        print(
          'DEBUG: _currentCarrinhoId é nulo em _fetchCarrinho. Chamando _loadAndFetchCarrinho.',
        );
        await _loadAndFetchCarrinho();
      }
    } catch (e) {
      _error = 'Erro ao recarregar carrinho: $e';
      print('ERRO detalhado em _fetchCarrinho: $_error');
      // Se houver um erro ao buscar o carrinho específico, força uma nova busca/criação
      await _loadAndFetchCarrinho();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  double _getTotalPrice() {
    return _carrinho?.totalValor ?? 0;
  }

  void _removeItem(int itemId) async {
    if (_currentCarrinhoId == null) {
      _showSnackBar('Nenhum carrinho ativo.');
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      await _service.deletarItemCarrinho(itemId);
      _showSnackBar('Item removido do carrinho.');
      await _fetchCarrinho();
    } catch (e) {
      _showSnackBar('Erro ao remover item: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _updateItemQuantity(int itemId, int currentQuantity, int change) async {
    if (_currentCarrinhoId == null) {
      _showSnackBar('Nenhum carrinho ativo.');
      return;
    }

    final newQuantity = currentQuantity + change;
    if (newQuantity < 0) {
      _showSnackBar('A quantidade não pode ser negativa.');
      return;
    }
    if (newQuantity == 0) {
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
        _removeItem(itemId);
      }
      return;
    }

    setState(() {
      _loading = true;
    });
    try {
      await _service.editarItemCarrinho(itemId, newQuantity);
      _showSnackBar('Quantidade atualizada para $newQuantity.');
      await _fetchCarrinho();
    } catch (e) {
      _showSnackBar('Erro ao atualizar quantidade: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _clearCart() async {
    if (_currentCarrinhoId == null) {
      _showSnackBar('Nenhum carrinho ativo para limpar.');
      return;
    }

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
        _loading = true;
      });
      try {
        await _service.limparCarrinho(_currentCarrinhoId!);
        _showSnackBar('Carrinho limpo com sucesso!');
        await _fetchCarrinho();
      } catch (e) {
        _showSnackBar('Erro ao limpar carrinho: $e');
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
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
            onPressed: _fetchCarrinho,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCart,
          ),
        ],
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : _error != null
              ? Center(
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
                      onPressed: _loadAndFetchCarrinho,
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              )
              : _carrinho == null || _carrinho!.itens.isEmpty
              ? Center(
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
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        item.produto.imagemUrl ??
                                            'https://via.placeholder.com/150',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
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
