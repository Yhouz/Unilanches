import 'package:flutter/material.dart';
import 'package:unilanches/src/models/list_prod_models.dart';
import 'package:unilanches/src/services/list_prod.dart';
import 'package:unilanches/src/models/edit_prod_model.dart';
import '../src/services/delete_prod.dart';
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

  Future<bool?> _editeButtom(
    BuildContext context,
    EditProdModel produto,
    Function(EditProdModel) onSalvar,
  ) {
    final nomeController = TextEditingController(text: produto.nome);
    final precoController = TextEditingController(
      text: produto.preco.toString(),
    );

    return showModalBottomSheet<bool>(
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final novoProduto = EditProdModel(
                    id: produto.id,
                    nome: nomeController.text,
                    preco: double.parse(precoController.text),
                  );

                  try {
                    final resultado = await ProdutoEditApi().editProd(
                      novoProduto,
                    );

                    if (resultado != null) {
                      await carregarProdutos();

                      Navigator.of(
                        context,
                      ).pop(true); // Retorna true indicando sucesso
                    } else {
                      throw Exception('Resposta nula da API ao editar produto');
                    }
                  } catch (e, stackTrace) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Erro'),
                          content: Text('Erro ao salvar: ${e.toString()}'),
                          actions: [
                            TextButton(
                              child: const Text('Fechar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
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
          produtosApi == null
              ? const Center(child: CircularProgressIndicator())
              : produtosApi.isEmpty
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
                            onPressed: () async {
                              final mudou = await _editeButtom(
                                context,
                                EditProdModel(
                                  id: produto.id,
                                  nome: produto.nome,
                                  preco: produto.preco,
                                ),
                                (produtoEditado) async {},
                              );
                              if (mudou == true) {
                                await carregarProdutos();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text('Confirmar exclusão'),
                                      content: Text(
                                        'Deseja excluir o produto "${produto.nome}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.of(ctx).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(ctx).pop(true),
                                          child: const Text(
                                            'Excluir',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                try {
                                  await ProdDeletAPI().deletarProduto(
                                    produto.id,
                                  );
                                  await carregarProdutos(); // Atualiza a lista
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text('Erro'),
                                          content: Text(
                                            'Erro ao excluir o produto: ${e.toString()}',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(ctx).pop(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                              }
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
