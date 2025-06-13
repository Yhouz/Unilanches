import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../src/models/cadastro_cardapio.dart' show CardapioModel;
import '../src/models/produto_model.dart' show ProdutoModel;
import '../src/services/cadastro_cardapio.dart' show CardapioApiService;
import '../src/services/list_prod.dart' show ProdutoListApi;

class CadastroCardapioAprimoradoPage extends StatefulWidget {
  const CadastroCardapioAprimoradoPage({super.key});

  @override
  State<CadastroCardapioAprimoradoPage> createState() =>
      _CadastroCardapioAprimoradoPageState();
}

class _CadastroCardapioAprimoradoPageState
    extends State<CadastroCardapioAprimoradoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  DateTime? _dataSelecionada;

  List<ProdutoModel> _produtos = [];
  List<int> produtosSelecionados = [];
  Uint8List? _imagemCardapio;
  String? _nomeImagemCardapio;
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    try {
      setState(() => _carregando = true);
      print("Tentando carregar produtos...");
      final produtosApi = await ProdutoListApi().listarProdutos();

      print("Verificando IDs dos produtos carregados:");
      Set<int?> uniqueIds = {};
      for (var produto in produtosApi) {
        print("  Produto: ${produto.nome} (ID: ${produto.id})");
        if (produto.id != null) {
          if (!uniqueIds.add(produto.id!)) {
            print("  *** ALERTA: ID DUPLICADO ENCONTRADO: ${produto.id} ***");
          }
        } else {
          print("  *** ALERTA: PRODUTO COM ID NULO: ${produto.nome} ***");
        }
      }
      print(
        "Total de produtos carregados: ${produtosApi.length}, Total de IDs únicos: ${uniqueIds.length}",
      );

      setState(() {
        _produtos = produtosApi;
        _carregando = false;
      });
    } catch (e) {
      // ...
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() => _dataSelecionada = picked);
    }
  }

  Future<void> _selecionarImagemCardapio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;

        // Validar tamanho do arquivo (máximo 5MB)
        if (file.size > 5 * 1024 * 1024) {
          _mostrarErro('A imagem deve ter no máximo 5MB');
          return;
        }

        setState(() {
          _imagemCardapio = file.bytes;
          _nomeImagemCardapio = file.name;
        });
      }
    } catch (e) {
      _mostrarErro('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _salvarCardapio() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataSelecionada == null) {
      _mostrarErro('Selecione uma data para o cardápio');
      return;
    }
    if (produtosSelecionados.isEmpty) {
      _mostrarErro('Selecione ao menos um produto');
      return;
    }

    setState(() => _salvando = true);

    try {
      final cardapio = CardapioModel(
        nome: _nomeController.text.trim(),
        categoria: _categoriaController.text.trim(),
        data: _dataSelecionada!.toIso8601String().split('T').first,
        produtos: produtosSelecionados,
      );

      final apiService = CardapioApiService();
      final response = await apiService.criarCardapioComImagem(
        cardapio,
        _imagemCardapio,
        _nomeImagemCardapio,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarSucesso('Cardápio salvo com sucesso!');
        _limparFormulario();
      } else {
        _mostrarErro('Erro ao salvar cardápio: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarErro('Erro ao salvar cardápio: $e');
    } finally {
      setState(() => _salvando = false);
    }
  }

  void _limparFormulario() {
    _nomeController.clear();
    _categoriaController.clear();
    setState(() {
      _dataSelecionada = null;
      produtosSelecionados.clear();
      _imagemCardapio = null;
      _nomeImagemCardapio = null;
    });
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Cardápio'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _carregando ? _buildCarregando() : _buildFormulario(),
    );
  }

  Widget _buildCarregando() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando produtos...'),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInformacoesBasicas(),
            const SizedBox(height: 24),
            _buildImagemCardapio(),
            const SizedBox(height: 24),
            _buildSelecaoProdutos(),
            const SizedBox(height: 32),
            _buildBotoes(),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacoesBasicas() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Básicas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Cardápio',
                hintText: 'Ex: Cardápio Especial de Sexta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome do cardápio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoriaController,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                hintText: 'Ex: Almoço, Lanche, Jantar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a categoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selecionarData,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      _dataSelecionada == null
                          ? 'Selecionar Data'
                          : 'Data: ${_formatarData(_dataSelecionada!)}',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _dataSelecionada == null
                                ? Colors.grey[600]
                                : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagemCardapio() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Imagem do Cardápio (Opcional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selecionarImagemCardapio,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child:
                    _imagemCardapio != null
                        ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _imagemCardapio!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _imagemCardapio = null;
                                    _nomeImagemCardapio = null;
                                  });
                                },
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                        : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Toque para adicionar uma imagem',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Máximo 5MB',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
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

  Widget _buildSelecaoProdutos() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Produtos do Cardápio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${produtosSelecionados.length} selecionados'),
                  backgroundColor: Colors.orange[100],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_produtos.isEmpty)
              const Center(
                child: Text('Nenhum produto encontrado'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _produtos.length,
                itemBuilder: (context, index) {
                  final produto = _produtos[index];
                  final selecionado = produtosSelecionados.contains(
                    produto.id,
                  );
                  if (produto.id == null) {
                    return const SizedBox.shrink(); // Ou um Text('Produto sem ID válido')
                  }

                  return Card(
                    key: ValueKey(produto.id),
                    margin: const EdgeInsets.only(bottom: 8),
                    color: selecionado ? Colors.orange[50] : null,
                    child: CheckboxListTile(
                      value: selecionado,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            if (produto.id != null) {
                              // Adiciona verificação de nulo
                              produtosSelecionados.add(
                                produto.id!,
                              ); // Usa ! para afirmar que não é nulo
                            } else {
                              _mostrarErro(
                                "Produto sem ID não pode ser selecionado.",
                              );
                            }
                          } else {
                            produtosSelecionados.remove(produto.id);
                          }
                        });
                      },
                      title: Text(
                        produto.nome,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        "R\$ ${produto.preco.toStringAsFixed(2)} | Estoque: ${produto.quantidadeEstoque}",
                      ),
                      secondary:
                          produto.imagemUrl != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  produto.imagemUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image),
                                ),
                              )
                              : const Icon(Icons.fastfood),
                      activeColor: Colors.orange,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotoes() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _salvando ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _salvando ? null : _salvarCardapio,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child:
                _salvando
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text('Salvar Cardápio'),
          ),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }
}

extension on ProdutoModel {
  get imagemUrl => null;
}
