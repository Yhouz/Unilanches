import 'package:flutter/material.dart';
import 'dart:typed_data'; // Para Uint8List
import 'package:image_picker/image_picker.dart'; // Importar image_picker

import 'package:unilanches/funcionario/list_prod.dart';
import 'package:unilanches/src/models/produto_model.dart'; // Verifique o nome real do seu arquivo model, se é .1 ou não
import 'package:unilanches/src/services/cadastro_prod.dart';

class CadastroProduto extends StatefulWidget {
  const CadastroProduto({super.key});

  @override
  State<CadastroProduto> createState() => _CadastroProdutoState();
}

class _CadastroProdutoState extends State<CadastroProduto> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final precoController = TextEditingController();
  final quantidadeController = TextEditingController();
  final categoriaController = TextEditingController();
  final custoController = TextEditingController();
  final margemController = TextEditingController();
  final unidadeController = TextEditingController();

  // Variáveis para a imagem
  Uint8List? imagemSelecionada; // Garanta que esta é a única declaração
  String? nomeArquivoImagem; // Para guardar o nome original do arquivo

  final ImagePicker _picker = ImagePicker(); // Instância do ImagePicker

  final List<String> unidadeList = [
    'KG',
    'UND',
    'G',
    'L',
  ];

  final List<String> listaCategorias = [
    'Bebidas',
    'Lanches',
    'Doces',
    'Salgados',
    'Sanduíches',
    'Refrigerantes',
    'Sucos',
    'Cafés',
    'Sobremesas',
    'Pães',
  ];

  String? unidadeSelecionada;
  String? categoriaSelecionada;

  final ProdutoApi produtoApi = ProdutoApi();

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    precoController.dispose();
    quantidadeController.dispose();
    categoriaController.dispose();
    custoController.dispose();
    margemController.dispose();
    unidadeController.dispose();
    super.dispose();
  }

  // Função para selecionar a imagem (web-friendly)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // Lê como Uint8List
      setState(() {
        imagemSelecionada = bytes; // Atribui Uint8List
        nomeArquivoImagem = pickedFile.name; // Pega o nome do arquivo
      });
    }
  }

  Future<void> cadastrarProduto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Valida se a imagem foi selecionada
    if (imagemSelecionada == null || nomeArquivoImagem == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma imagem.')),
        );
      }
      return;
    }

    // Atribua os valores dos Dropdowns aos controllers
    categoriaController.text = categoriaSelecionada ?? '';
    unidadeController.text = unidadeSelecionada ?? '';

    // Crie o ProdutoModel com os dados do formulário
    final produto = ProdutoModel(
      nome: nomeController.text.trim(),
      descricao: descricaoController.text.trim(),
      preco: double.tryParse(precoController.text.trim()) ?? 0,
      quantidadeEstoque: int.tryParse(quantidadeController.text.trim()) ?? 0,
      categoria: categoriaController.text.trim(),
      id: null,
      custo: custoController.text.trim(),
      margem: margemController.text.trim(),
      unidade: unidadeController.text.trim(),
    );

    try {
      // Chame o método cadastrarProduto do seu serviço ProdutoApi,
      // passando o ProdutoModel e os dados da imagem
      final resultado = await produtoApi.cadastrarProduto(
        produto,
        imagemSelecionada!,
        nomeArquivoImagem!,
      );

      if (!mounted) return;

      if (resultado == null) {
        // Sucesso: a API retornou null ou indicou sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto cadastrado com sucesso!')),
        );
        _formKey.currentState!.reset(); // Limpa o formulário
        // Limpa os controllers e seleções após o sucesso
        nomeController.clear();
        descricaoController.clear();
        precoController.clear();
        quantidadeController.clear();
        custoController.clear();
        margemController.clear();
        setState(() {
          categoriaSelecionada = null;
          unidadeSelecionada = null;
          imagemSelecionada = null; // Limpa a prévia da imagem
          nomeArquivoImagem = null;
        });
      } else {
        // Erro: a API retornou uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar produto: $resultado')),
        );
        print('Erro no cadastro: $resultado');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
      print('Erro inesperado ao enviar produto: $e');
    }
  }

  void _valorProd() {
    try {
      double custo = double.parse(custoController.text);
      double margem = double.parse(margemController.text);

      double precoVenda = custo * (1 + margem);

      precoController.text = precoVenda.toStringAsFixed(2);
    } catch (e) {
      print("Erro ao calcular: $e");
      precoController.text = "Erro!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Produto'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListProd()),
              );
            },
            icon: const Icon(
              Icons.list_alt,
              color: Colors.white,
            ),
            label: const Text(
              'Consultar Produto',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // --- Seção de Informações Básicas ---
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações Básicas',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          nomeController,
                          'Nome',
                          'Informe o nome',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          descricaoController,
                          'Descrição',
                          null,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        // Botão para selecionar a imagem
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Selecionar Imagem do Produto'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Prévia da imagem
                        if (imagemSelecionada != null)
                          Image.memory(
                            // **** AQUI ESTÁ A CORREÇÃO CRÍTICA ****
                            imagemSelecionada!, // Usa a variável Uint8List
                            height: 200,
                            width: double.infinity,
                            fit:
                                BoxFit
                                    .contain, // Ajusta a imagem dentro do espaço
                          )
                        else
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Nenhuma imagem selecionada',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // --- Seção de Estoque e Categoria ---
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estoque e Categoria',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          quantidadeController,
                          'Quantidade em estoque',
                          'Informe a quantidade',
                          isNumber: true,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Unidade',
                            border: OutlineInputBorder(),
                            helperText: 'Ex: KG, UND, G',
                          ),
                          value: unidadeSelecionada,
                          items:
                              unidadeList.map((unidade) {
                                return DropdownMenuItem<String>(
                                  value: unidade,
                                  child: Text(unidade),
                                );
                              }).toList(),
                          onChanged: (valor) {
                            setState(() {
                              unidadeSelecionada = valor;
                              unidadeController.text = valor ?? '';
                            });
                          },
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'Informe a unidade';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                          ),
                          value: categoriaSelecionada,
                          items:
                              listaCategorias.map((categoria) {
                                return DropdownMenuItem<String>(
                                  value: categoria,
                                  child: Text(categoria),
                                );
                              }).toList(),
                          onChanged: (valor) {
                            setState(() {
                              categoriaSelecionada = valor;
                              categoriaController.text = valor ?? '';
                            });
                          },
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'Informe a categoria';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Seção de Precificação ---
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precificação',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          custoController,
                          'Custo (R\$)',
                          'Informe o Custo',
                          isNumber: true,
                          isDouble: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          margemController,
                          'Margem (%)',
                          'Informe a Margem (ex: 0.20 para 20%)',
                          isNumber: true,
                          isDouble: true,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _valorProd,
                            icon: const Icon(Icons.calculate),
                            label: const Text('Calcular Preço de Venda'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          precoController,
                          'Preço de Venda (R\$)',
                          null,
                          enabled: false,
                          isNumber: true,
                          isDouble: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => cadastrarProduto(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('CADASTRAR PRODUTO'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? errorMessage, {
    bool isNumber = false,
    bool isDouble = false,
    bool enabled = true,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      enabled: enabled,
      maxLines: maxLines,
      validator: (value) {
        if (errorMessage != null && (value == null || value.trim().isEmpty)) {
          return errorMessage;
        }
        if (isNumber) {
          if (isDouble && double.tryParse(value!) == null) {
            return 'Informe um número decimal válido (Ex: 10.50)';
          }
          if (!isDouble && int.tryParse(value!) == null) {
            return 'Informe um número inteiro válido';
          }
        }
        return null;
      },
    );
  }
}
