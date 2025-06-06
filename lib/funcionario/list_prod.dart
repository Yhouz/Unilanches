import 'package:flutter/material.dart';

class Produto {
  final String nome;
  final String descricao;
  final double preco;

  Produto({
    required this.nome,
    required this.descricao,
    required this.preco,
  });
}

class ListProd extends StatelessWidget {
  ListProd({super.key});

  final List<Produto> produtos = [
    Produto(
      nome: 'X-Burguer',
      descricao: 'Hambúrguer com queijo',
      preco: 12.00,
    ),
    Produto(
      nome: 'Suco de Laranja',
      descricao: '500ml de suco natural',
      preco: 7.50,
    ),
    Produto(nome: 'Batata Frita', descricao: 'Porção média', preco: 9.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final produto = produtos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      // ação de editar
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // ação de deletar
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ação de adicionar novo produto
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
