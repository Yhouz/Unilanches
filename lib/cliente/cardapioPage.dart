import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar shared_preferences
import 'package:unilanches/src/models/carrinho_model.dart';
import 'package:unilanches/src/models/cadastro_cardapio.dart'; // Importa seu CardapioModel
import 'package:unilanches/src/models/produto_model.dart'; // Importa seu ProdutoModel
import 'package:unilanches/src/services/cadastro_cardapio.dart'; // Importa seu CardapioApiService
import 'package:unilanches/src/services/carrinho_service.dart'; // Importa seu CarrinhoService
import 'package:unilanches/cliente/carrinhoCliente.dart'; // Importa sua CartScreen (verifique o caminho exato)

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

  // Instância do CarrinhoService
  final CarrinhoService _carrinhoService = CarrinhoService();

  // Variável para armazenar o ID do carrinho ativo
  int? _currentCarrinhoId;

  @override
  void initState() {
    super.initState();
    _initializeData(); // Nova função para carregar dados e o ID do carrinho
  }

  // Inicializa o ID do carrinho e carrega o cardápio
  Future<void> _initializeData() async {
    await _loadCarrinhoId(); // Primeiro, carregue o ID do carrinho
    await _carregarCardapioDoDia(); // Em seguida, carregue o cardápio
  }

  // Função para carregar o ID do carrinho salvo ou criar um novo
  Future<void> _loadCarrinhoId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentCarrinhoId = prefs.getInt('carrinhoId'); // Tenta obter o ID salvo

      // Para fins de teste local, você pode mudar este ID ou obtê-lo de outra fonte.
      // Em uma aplicação real, este ID viria do usuário logado.
      int testUserId = 1; // ID de usuário temporário para teste

      CarrinhoModel? fetchedCarrinho;

      if (_currentCarrinhoId != null) {
        try {
          fetchedCarrinho = await _carrinhoService.buscarCarrinhoPorId(
            _currentCarrinhoId!,
          );
        } catch (e) {
          print(
            'Carrinho salvo ($_currentCarrinhoId) não encontrado. Tentando criar um novo...',
          );
          fetchedCarrinho = await _carrinhoService.criarCarrinho(
            testUserId,
          ); // Usa o ID de teste
        }
      } else {
        print('Nenhum carrinhoId salvo. Tentando criar um novo carrinho...');
        fetchedCarrinho = await _carrinhoService.criarCarrinho(
          testUserId,
        ); // Usa o ID de teste
      }

      // ignore: unnecessary_null_comparison
      if (fetchedCarrinho != null) {
        _currentCarrinhoId = fetchedCarrinho.id;
        await prefs.setInt(
          'carrinhoId',
          _currentCarrinhoId!,
        ); // Salva o ID recém-obtido/criado
        // Opcional: _showSnackBar('Carrinho (ID: $_currentCarrinhoId) pronto para uso.');
      } else {
        // Trate a falha crítica aqui se não conseguir obter/criar um carrinho
        print('Falha crítica: Não foi possível obter ou criar um carrinho.');
        // Pode ser útil mostrar um erro persistente ou redirecionar o usuário
        setState(() {
          erro = 'Erro crítico ao inicializar o carrinho. Tente novamente.';
        });
      }
    } catch (e) {
      setState(() {
        erro = 'Erro ao inicializar o carrinho: $e';
      });
      print('Erro detalhado em _loadCarrinhoId: $e');
    }
  }

  Future<void> _carregarCardapioDoDia() async {
    setState(() {
      carregando = true;
      erro = null; // Limpa o erro ao tentar carregar novamente
    });

    try {
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
      print('Erro detalhado em _carregarCardapioDoDia: $e');
    }
  }

  // Função auxiliar para exibir SnackBar de forma segura
  void _showSnackBar(String message) {
    if (mounted) {
      // Verifica se o widget ainda está montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
            onPressed: _initializeData, // Recarrega cardápio e ID do carrinho
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
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
              onPressed: _initializeData, // Tentar novamente (recarrega tudo)
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

  void _adicionarAoCarrinho(ProdutoModel produto) async {
    // Verifica se temos um ID de carrinho válido
    if (_currentCarrinhoId == null) {
      _showSnackBar(
        'Erro: Carrinho não inicializado. Tente recarregar a página.',
      );
      return;
    }

    try {
      // Usa o ID do carrinho obtido dinamicamente
      await _carrinhoService.adicionarItemCarrinho(
        carrinhoId: _currentCarrinhoId!, // Usando o ID dinâmico
        produtoId: produto.id!, // Assumindo que produto.id não é nulo
        quantidade: 1, // Adiciona 1 unidade por padrão
      );
      _showSnackBar('${produto.nome} adicionado ao carrinho!');
    } catch (e) {
      _showSnackBar('Erro ao adicionar ${produto.nome}: $e');
    }
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

// REMOVIDA A EXTENSÃO PROBLEMÁTICA QUE ESTAVA ANULANDO A IMAGEM URL.
// CERTIFIQUE-SE DE QUE SEU 'ProdutoModel' TEM UM CAMPO 'imagemUrl' (String?)
// e que ele está sendo corretamente desserializado no 'ProdutoModel.fromJson'.
