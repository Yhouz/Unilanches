import 'package:flutter/material.dart';

class CardapioPage extends StatelessWidget {
  final Map<String, double> produtos;
  const CardapioPage({super.key, required this.produtos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Cardápio')),
      body: ListView.builder(
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          String nome = produtos.keys.elementAt(index);
          double preco = produtos[nome]!;
          return ListTile(title: Text(nome), subtitle: Text('R\$ $preco'));
        },
      ),
    );
  }
}
