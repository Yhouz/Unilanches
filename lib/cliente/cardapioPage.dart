import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilanches/src/models/carrinho_model.dart';
import 'package:unilanches/src/models/cadastro_cardapio.dart';
import 'package:unilanches/src/models/produto_model.dart';
import 'package:unilanches/src/services/cadastro_cardapio.dart';
import 'package:unilanches/src/services/carrinho_service.dart';
import 'package:unilanches/cliente/carrinhoCliente.dart';

class CardapioClientePage extends StatefulWidget {
  const CardapioClientePage({super.key});

  @override
  State<CardapioClientePage> createState() => _CardapioClientePageState();
}

class _CardapioClientePageState extends State<CardapioClientePage> {
  CardapioModel? cardapioAtual;
  bool carregando = true;
  String? erro;
  List<ProdutoModel> produtosSelecionados = [];

  final CarrinhoService _carrinhoService = CarrinhoService();
  CarrinhoModel? _carrinho;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (mounted)
      setState(() {
        carregando = true;
        erro = null;
      });

    try {
      await Future.wait([
        _carregarCardapioDoDia(),
        // _loadOrCreateCarrinho(),
      ]);
    } catch (e) {
      if (mounted) setState(() => erro = 'Erro ao carregar dados: $e');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _loadOrCreateCarrinho() async {
    try {
      final carrinho = await _carrinhoService.getOrCreateActiveCart();
      if (mounted) setState(() => _carrinho = carrinho);
    } catch (e) {
      throw Exception('Falha ao obter o carrinho: $e');
    }
  }

  Future<void> _carregarCardapioDoDia() async {
    try {
      final apiService = CardapioApiService();
      final cardapio = await apiService.buscarCardapioDoDia();

      if (cardapio != null) {
        // ✅ ESTE É O PONTO CRÍTICO: CHAMA buscarProdutosDoCardapio
        final produtosCardapio = await apiService.buscarProdutosDoCardapio(
          cardapio.produtos, // cardapio.produtos deve ser uma List<int> de IDs
        );
        if (mounted) {
          setState(() {
            cardapioAtual = cardapio;
            produtosSelecionados =
                produtosCardapio; // Esta lista deve conter APENAS os produtos do cardápio
          });
        }
      } else {
        if (mounted)
          setState(() => erro = 'Nenhum cardápio disponível para hoje');
      }
    } catch (e) {
      throw Exception('Falha ao carregar o cardápio: $e');
    }
  }

  void _adicionarAoCarrinho(ProdutoModel produto) async {
    // Validação de estoque continua sendo a primeira coisa. Ótimo.
    if (produto.quantidadeEstoque <= 0) {
      _showSnackBar('Desculpe, este produto está sem estoque.');
      return;
    }

    // Mantenha isso para o feedback visual de carregamento
    setState(() {
      _isAddingToCart = true;
    });

    try {
      // ✅ ESTA É A NOVA LÓGICA
      // 1. Verificamos se já temos um carrinho no estado da página.
      // Se não tiver (_carrinho for nulo), nós o buscamos ou criamos AGORA.
      // O operador '??' significa: use o valor da esquerda se não for nulo, senão, use o da direita.
      CarrinhoModel carrinhoParaUsar =
          _carrinho ?? await _carrinhoService.getOrCreateActiveCart();

      // 2. Com o carrinho garantido, agora sim adicionamos o item.
      // Esta chamada de serviço retorna o carrinho mais recente, com o item já adicionado.
      final carrinhoAtualizado = await _carrinhoService.adicionarItemCarrinho(
        carrinhoId: carrinhoParaUsar.id,
        produtoId: produto.id!,
        quantidade: 1,
      );

      // 3. Atualizamos o estado da página com a versão final e mais recente do carrinho.
      // Isso garante que, na próxima vez que o botão for clicado, _carrinho não será mais nulo.
      if (mounted) {
        setState(() {
          _carrinho = carrinhoAtualizado;
        });
      }

      _showSnackBar('${produto.nome} adicionado ao carrinho!');
    } catch (e) {
      _showSnackBar('Erro: $e');
    } finally {
      // Garante que o indicador de carregamento sempre será desativado.
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String _formatarData(String data) {
    try {
      final date = DateTime.parse(data);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return data; // Retorna a data original se houver erro no parsing
    }
  }

  // --- O resto do seu código (build, buildBody, buildProdutoCard, etc.) ---
  // --- pode permanecer exatamente o mesmo. Nenhuma alteração é necessária lá. ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardápio do Dia'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeData, // Recarrega tudo
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text(
              'Ir ao Carrinho',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(erro!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeData,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardapioHeader(),
          const SizedBox(height: 24),
          _buildProdutosList(),
        ],
      ),
    );
  }

  Widget _buildCardapioHeader() {
    if (cardapioAtual == null) return const SizedBox.shrink();
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cardapioAtual!.nome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Categoria: ${cardapioAtual!.categoria}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Data: ${_formatarData(cardapioAtual!.data)}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProdutosList() {
    if (produtosSelecionados.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum produto disponível',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produtos Disponíveis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: produtosSelecionados.length,
          itemBuilder: (context, index) {
            return _buildProdutoCard(produtosSelecionados[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProdutoCard(ProdutoModel produto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _mostrarDetalhesProduto(produto),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    produto.imagemUrl != null
                        ? CachedNetworkImage(
                          imageUrl: produto.imagemUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              ),
                        )
                        : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.fastfood),
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (produto.descricao != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        produto.descricao!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${produto.preco.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Estoque: ${produto.quantidadeEstoque}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _adicionarAoCarrinho(produto),
                icon: const Icon(Icons.add_shopping_cart),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhesProduto(ProdutoModel produto) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(produto.nome),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (produto.imagemUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: produto.imagemUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                if (produto.descricao != null) ...[
                  Text(
                    produto.descricao!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Preço: R\$ ${produto.preco.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _adicionarAoCarrinho(produto);
                },
                child: const Text('Adicionar ao Carrinho'),
              ),
            ],
          ),
    );
  }
}
