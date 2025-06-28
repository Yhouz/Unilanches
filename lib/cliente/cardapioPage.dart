// Necessário para jsonDecode
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Importe o http
import 'package:unilanches/src/models/carrinho_model.dart';
import 'package:unilanches/src/models/produto_model.dart';
import 'package:unilanches/src/services/carrinho_service.dart';
import 'package:unilanches/cliente/carrinhoCliente.dart';

import 'package:unilanches/src/services/list_prod.dart';

class CardapioClientePage extends StatefulWidget {
  const CardapioClientePage({super.key});

  @override
  State<CardapioClientePage> createState() => _CardapioClientePageState();
}

class _CardapioClientePageState extends State<CardapioClientePage> {
  bool carregando = true;
  String? erro;
  List<ProdutoModel> produtosDisponiveis = [];

  final CarrinhoService _carrinhoService = CarrinhoService();
  final ProdutoListApi _produtoListApi = ProdutoListApi();
  CarrinhoModel? _carrinho;
  bool _isAdicionandoAoCarrinho = false;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  Future<void> _inicializarDados() async {
    if (mounted) {
      setState(() {
        carregando = true;
        erro = null;
      });
    }

    try {
      await _carregarTodosOsProdutos();
      await _carregarOuCriarCarrinho();
    } catch (e) {
      if (mounted) setState(() => erro = 'Erro ao carregar dados: $e');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _carregarTodosOsProdutos() async {
    try {
      final produtos = await _produtoListApi.listarProdutos();
      if (mounted) {
        setState(() {
          produtosDisponiveis = produtos;
        });
      }
    } catch (e) {
      throw Exception('Falha ao carregar a lista de produtos: $e');
    }
  }

  Future<void> _carregarOuCriarCarrinho() async {
    try {
      final carrinho = await _carrinhoService.getOrCreateActiveCart();
      if (mounted) setState(() => _carrinho = carrinho);
    } catch (e) {
      print('Erro ao carregar ou criar carrinho: $e');
    }
  }

  void _adicionarAoCarrinho(ProdutoModel produto) async {
    if (produto.quantidadeEstoque <= 0) {
      _mostrarSnackBar(
        'Desculpe, este produto está sem estoque.',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _isAdicionandoAoCarrinho = true;
    });

    try {
      CarrinhoModel carrinhoParaUsar =
          _carrinho ?? await _carrinhoService.getOrCreateActiveCart();

      final carrinhoAtualizado = await _carrinhoService.adicionarItemCarrinho(
        carrinhoId: carrinhoParaUsar.id,
        produtoId: produto.id!,
        quantidade: 1,
      );

      if (mounted) {
        setState(() {
          _carrinho = carrinhoAtualizado;
        });
      }

      _mostrarSnackBar(
        '${produto.nome} adicionado ao carrinho!',
        isSuccess: true,
      );
    } catch (e) {
      _mostrarSnackBar(
        'Erro ao adicionar ${produto.nome} ao carrinho: $e',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAdicionandoAoCarrinho = false;
        });
      }
    }
  }

  void _mostrarSnackBar(String message, {bool isSuccess = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor:
              isSuccess ? Colors.green.shade600 : Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define o número de colunas com base na largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1; // Padrão para telas pequenas

    if (screenWidth > 600) {
      crossAxisCount = 2; // Para tablets em modo retrato ou telas médias
    }
    if (screenWidth > 900) {
      crossAxisCount = 3; // Para tablets em modo paisagem ou telas grandes
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo de Produtos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _inicializarDados,
            tooltip: 'Recarregar produtos',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
                tooltip: 'Ir para o carrinho',
              ),
              if (_carrinho != null && _carrinho!.itens.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _carrinho!.itens.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildCorpo(crossAxisCount), // Passa o número de colunas
    );
  }

  Widget _buildCorpo(int crossAxisCount) {
    if (carregando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepOrange),
            SizedBox(height: 16),
            Text(
              'Carregando produtos...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 90,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 32),
              Text(
                'Ocorreu um erro ao carregar os produtos:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                erro!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _inicializarDados,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Tentar Novamente',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (produtosDisponiveis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 90, color: Colors.blueGrey),
              const SizedBox(height: 32),
              Text(
                'Nenhum produto disponível no momento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Por favor, tente recarregar ou verifique mais tarde.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _inicializarDados,
                icon: const Icon(Icons.refresh),
                label: const Text('Recarregar', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // GridView responsivo com o número de colunas dinâmico
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // Usa o número de colunas calculado
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7, // Proporção ajustada para os cards
      ),
      itemCount: produtosDisponiveis.length,
      itemBuilder: (context, index) {
        return _buildCartaoProduto(produtosDisponiveis[index]);
      },
    );
  }

  Widget _buildCartaoProduto(ProdutoModel produto) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _mostrarDetalhesProduto(produto),
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Hero(
                  tag: 'produto-${produto.id}',
                  child:
                      produto.imagemUrl != null && produto.imagemUrl!.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: produto.imagemUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.fastfood,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.redAccent,
                                  ),
                                ),
                          )
                          : Container(
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.fastfood,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (produto.descricao != null &&
                        produto.descricao!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          produto.descricao!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'R\$ ${produto.preco.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Estoque: ${produto.quantidadeEstoque}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isAdicionandoAoCarrinho
                                ? null
                                : (produto.quantidadeEstoque <= 0
                                    ? null
                                    : () => _adicionarAoCarrinho(produto)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              produto.quantidadeEstoque <= 0
                                  ? Colors.grey
                                  : Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 4,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        child:
                            _isAdicionandoAoCarrinho
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  produto.quantidadeEstoque <= 0
                                      ? 'Sem Estoque'
                                      : 'Comprar',
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalhesProduto(ProdutoModel produto) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              produto.nome,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (produto.imagemUrl != null &&
                      produto.imagemUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Hero(
                        tag: 'produto-${produto.id}',
                        child: CachedNetworkImage(
                          imageUrl: produto.imagemUrl!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey.shade200,
                                height: 220,
                                child: const Icon(
                                  Icons.fastfood,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                height: 220,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.redAccent,
                                ),
                              ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (produto.descricao != null &&
                      produto.descricao!.isNotEmpty) ...[
                    Text(
                      produto.descricao!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'Preço: R\$ ${produto.preco.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estoque disponível: ${produto.quantidadeEstoque}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Fechar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton.icon(
                onPressed:
                    _isAdicionandoAoCarrinho
                        ? null
                        : (produto.quantidadeEstoque <= 0
                            ? null
                            : () {
                              Navigator.pop(context);
                              _adicionarAoCarrinho(produto);
                            }),
                icon:
                    _isAdicionandoAoCarrinho
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.add_shopping_cart, size: 20),
                label: Text(
                  _isAdicionandoAoCarrinho
                      ? 'Adicionando...'
                      : (produto.quantidadeEstoque <= 0
                          ? 'Sem Estoque'
                          : 'Adicionar ao Carrinho'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      produto.quantidadeEstoque <= 0
                          ? Colors.grey
                          : Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
    );
  }
}
