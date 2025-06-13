import 'package:flutter/material.dart';
import 'package:unilanches/funcionario/list_prod.dart';
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

  final List<String> unidadeList = [
    'KG',
    'UND',
    'G',
    'L',
  ]; // Adicionado 'L' para Litro, comum em bebidas.

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

  Future<void> cadastrarProduto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Certifique-se de que os valores dos Dropdowns são atribuídos aos controllers
    categoriaController.text = categoriaSelecionada ?? '';
    unidadeController.text = unidadeSelecionada ?? '';

    final produto = ProdutoModel(
      nome: nomeController.text.trim(),
      descricao: descricaoController.text.trim(),
      preco: double.tryParse(precoController.text.trim()) ?? 0,
      quantidadeEstoque: int.tryParse(quantidadeController.text.trim()) ?? 0,
      categoria: categoriaController.text.trim(),
      id: null,
      custo:
          custoController.text
              .trim(), // Considerar converter para double no model ou antes de enviar
      margem:
          margemController.text
              .trim(), // Considerar converter para double no model ou antes de enviar
      unidade: unidadeController.text.trim(),
    );

    try {
      final resultado = await produtoApi.cadastrarProduto(produto);

      if (!mounted) return;
      // Ajuste na lógica: se resultado for null, significa sucesso na API (retorna void ou null em caso de sucesso)
      if (resultado == null) {
        // Supondo que null significa sucesso na API
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto cadastrado com sucesso!')),
        );
        _formKey.currentState!.reset();
        // Limpar controllers e seleções de dropdown após o sucesso
        nomeController.clear();
        descricaoController.clear();
        precoController.clear();
        quantidadeController.clear();
        custoController.clear();
        margemController.clear();
        setState(() {
          categoriaSelecionada = null;
          unidadeSelecionada = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar produto.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
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
        backgroundColor: Colors.blue.shade700, // Tom de azul mais escuro
        foregroundColor: Colors.white, // Texto branco no AppBar
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListProd()),
              );
            },
            icon: const Icon(
              Icons.list_alt, // Ícone mais adequado para "consultar lista"
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
                            helperText: 'Ex: KG, UND, G', // Ajuda visual
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
                          'Informe a Margem (ex: 0.20 para 20%)', // Adicionado helper text
                          isNumber: true,
                          isDouble: true,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity, // Ocupa a largura total
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
                          enabled: false, // Para não permitir edição direta
                          isNumber: true,
                          isDouble: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Espaçamento antes do botão final
                SizedBox(
                  width: double.infinity, // Ocupa a largura total
                  child: ElevatedButton(
                    onPressed: () => cadastrarProduto(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors
                              .green
                              .shade700, // Cor de destaque para o botão principal
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
                const SizedBox(height: 16), // Espaçamento no final
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
