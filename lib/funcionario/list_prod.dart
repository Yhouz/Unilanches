import 'package:flutter/material.dart';
import 'package:unilanches/src/models/list_prod_models.dart';
import 'package:unilanches/src/services/list_prod.dart';
import 'package:unilanches/src/models/edit_prod_model.dart';

import '../src/services/edit_prod.dart';

class ListProd extends StatefulWidget {
  const ListProd({super.key});

  @override
  State<ListProd> createState() => _ListProdState();
}

class _ListProdState extends State<ListProd> {
  List<ProdutoListModel> produtosApi = [];

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    try {
      final lista = await ProdutoListApi().listarProdutos();
      setState(() {
        produtosApi = lista.toList();
      });
    } catch (e) {
      // print('Erro ao carregar produtos: $e');
    }
  }

  Future<void> _editeButtom(
    BuildContext context,
    EditProdModel produto,
    Function(EditProdModel) onSalvar,
  ) async {
    final nomeController = TextEditingController(text: produto.nome);
    final precoController = TextEditingController(
      text: produto.preco.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar Produto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: precoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Preço'),
              ),
              // TextField(
              //  controller: estoqueController,
              ////  keyboardType: TextInputType.number,
              // decoration: InputDecoration(labelText: 'Estoque'),
              //  ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  final novoProduto = EditProdModel(
                    id: produto.id,
                    nome: nomeController.text,
                    preco: double.tryParse(precoController.text) ?? 0.0,
                    // quantidadeEstoque: int.tryParse(estoqueController.text) ?? 0,
                    // categoria: produto.categoria,
                  );
                  onSalvar(novoProduto);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.save),
                label: Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body:
          produtosApi.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: produtosApi.length,
                itemBuilder: (context, index) {
                  final produto = produtosApi[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.fastfood, color: Colors.orange),
                      title: Text(
                        produto.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${produto.descricao} - R\$ ${produto.preco.toStringAsFixed(2)}',
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editeButtom(
                                context,
                                EditProdModel(
                                  id: produto.id,
                                  nome: produto.nome,
                                  preco: produto.preco,
                                ),
                                (produtoEditado) async {
                                  final resultado = await ProdutoEditApi()
                                      .editProd(produtoEditado);

                                  if (resultado != null) {
                                    await carregarProdutos(); // Recarrega a lista atualizada
                                    // setState não obrigatório aqui, pois carregarProdutos já chama setState
                                  } else {
                                    // Aqui você pode mostrar um snackbar ou alerta para o usuário
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao editar o produto',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // deletar ação
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
