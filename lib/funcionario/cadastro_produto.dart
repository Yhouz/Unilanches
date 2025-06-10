import 'package:flutter/material.dart';
import 'package:unilanches/src/models/produto_model.dart';
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

  final List<String> unidadeList = ['KG', 'UND', 'G', 'QT'];

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

  Future<void> cadastrarProduto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
      final resultado = await produtoApi.cadastrarProduto(produto);

      if (!mounted) return;
      if (resultado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar produto.')),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto cadastrado com sucesso!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de Produto'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField(nomeController, 'Nome', 'Informe o nome'),
                  const SizedBox(height: 10),
                  _buildTextField(descricaoController, 'Descrição', null),
                  const SizedBox(height: 10),
                  _buildTextField(
                    precoController,
                    'Preço',
                    'Informe o preço',
                    isNumber: true,
                    isDouble: true,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    quantidadeController,
                    'Quantidade em estoque',
                    'Informe a quantidade',
                    isNumber: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
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
                  const SizedBox(height: 20),
                  _buildTextField(
                    custoController,
                    'Custo',
                    'Informe o Custo',
                    isNumber: true,
                  ),

                  const SizedBox(height: 20),
                  _buildTextField(
                    margemController,
                    'Margem',
                    'Informe a Margem',
                    isNumber: true,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => cadastrarProduto(),
                    child: const Text('Cadastrar Produto'),
                  ),
                ],
              ),
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
      validator: (value) {
        if (errorMessage != null && (value == null || value.trim().isEmpty)) {
          return errorMessage;
        }
        if (isNumber) {
          if (isDouble && double.tryParse(value!) == null) {
            return 'Informe um número válido';
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
