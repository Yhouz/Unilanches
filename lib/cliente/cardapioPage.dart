import 'package:flutter/material.dart';

class CardapioPage extends StatelessWidget {
  final Map<String, double> produtos;
  const CardapioPage({super.key, required this.produtos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cardápio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            produtos.isEmpty
                ? const Center(
                  child: Text(
                    'Nenhum produto disponível',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                : ListView.builder(
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    String nome = produtos.keys.elementAt(index);
                    double preco = produtos[nome]!;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('R\$ ${preco.toStringAsFixed(2)}'),
                        leading: const Icon(Icons.fastfood),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
