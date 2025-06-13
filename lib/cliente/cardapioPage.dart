import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../src/models/cadastro_cardapio.dart' show CardapioModel;
import '../src/models/produto_model.dart' show ProdutoModel;
import '../src/services/cadastro_cardapio.dart' show CardapioApiService;
import 'carrinhoCliente.dart' show CarrinhoPage, CartScreenState, CartScreen;

class CardapioClientePage extends StatefulWidget {
  const CardapioClientePage({super.key});

  @override
  State<CardapioClientePage> createState() => _CardapioClientePageState();
}

class _CardapioClientePageState extends State<CardapioClientePage> {
  CardapioModel? cardapioAtual;
  // List<ProdutoModel> produtos = [];
  bool carregando = true;
  String? erro;
  List<ProdutoModel> produtosSelecionados = [];

  @override
  void initState() {
    super.initState();
    _carregarCardapioDoDia();
  }

  Future<void> _carregarCardapioDoDia() async {
    try {
      setState(() {
        carregando = true;
        erro = null;
      });

      final apiService = CardapioApiService();
      final cardapio = await apiService.buscarCardapioDoDia();

      if (cardapio != null) {
        final produtosCardapio = await apiService.buscarProdutosDoCardapio(
          cardapio.produtos,
        );

        setState(() {
          cardapioAtual = cardapio;
          produtosSelecionados = produtosCardapio;
          carregando = false;
        });
      } else {
        setState(() {
          erro = 'Nenhum cardápio disponível para hoje';
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        erro = 'Erro ao carregar cardápio: $e';
        carregando = false;
      });
    }
  }

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
            onPressed: _carregarCardapioDoDia,
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            label: Text(
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando cardápio...'),
          ],
        ),
      );
    }

    if (erro != null) {
      return Center(
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
              erro!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarCardapioDoDia,
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
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Data: ${_formatarData(cardapioAtual!.data)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
              // Imagem do produto
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
              // Informações do produto
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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
                    // Verifica se o campo existe no modelo
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
              // Botão de ação
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

  void _adicionarAoCarrinho(ProdutoModel produto) {
    // Implementar lógica do carrinho
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Produto Adicionado!'),
          content: Text('${produto.nome} foi adicionado ao seu carrinho.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }

  String _formatarData(String data) {
    try {
      final date = DateTime.parse(data);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return data;
    }
  }
}

extension on ProdutoModel {
  get imagemUrl => null;
}
