import 'package:flutter/material.dart';
import 'package:unilanches/src/models/list_prod_models.dart';
import 'package:unilanches/src/services/list_prod.dart';

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
      print('Erro ao carregar produtos: $e');
    }
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
                              // editar ação
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
