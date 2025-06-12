import 'package:flutter/material.dart';

class Vendas extends StatefulWidget {
  const Vendas({super.key});

  @override
  State<Vendas> createState() => _VendasState();
}

class _VendasState extends State<Vendas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema de Vendas'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Menu lateral
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {},
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.store),
                label: Text('Produtos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Relatórios'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Configurações'),
              ),
            ],
          ),
          // Conteúdo principal
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Campo de busca
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar produto...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filtros por categoria
                  Wrap(
                    spacing: 8,
                    children: const [
                      Chip(label: Text('Todos')),
                      Chip(label: Text('Bebidas')),
                      Chip(label: Text('Lanches')),
                      Chip(label: Text('Sobremesas')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Grade de produtos
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 4 / 3,
                      children: List.generate(6, (index) {
                        return Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Placeholder(), // Substitua por imagem
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Produto ${index + 1}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('R\$ ${(index + 1) * 5},00'),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Adicionar'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Carrinho
          Container(
            width: 300,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Carrinho', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Item ${index + 1}'),
                        subtitle: Text('2 x R\$ 10,00'),
                        trailing: Text('R\$ 20,00'),
                      );
                    },
                  ),
                ),
                const Divider(),
                Text(
                  'Total: R\$ 60,00',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Finalizar Venda'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
