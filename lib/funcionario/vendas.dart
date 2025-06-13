import 'package:flutter/material.dart';

// A simple model for a Product
class Product {
  final String name;
  final double price;
  final String category; // Added category for filtering
  int quantity; // Quantity in the cart

  Product({
    required this.name,
    required this.price,
    required this.category,
    this.quantity = 1,
  });
}

class Vendas extends StatefulWidget {
  const Vendas({super.key});

  @override
  State<Vendas> createState() => _VendasState();
}

class _VendasState extends State<Vendas> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  // Dummy product data
  final List<Product> _allProducts = [
    Product(name: 'Refrigerante Cola', price: 5.00, category: 'Bebidas'),
    Product(name: 'Hamburger Clássico', price: 15.00, category: 'Lanches'),
    Product(name: 'Bolo de Chocolate', price: 10.00, category: 'Sobremesas'),
    Product(name: 'Suco de Laranja', price: 7.50, category: 'Bebidas'),
    Product(name: 'Sanduíche Natural', price: 12.00, category: 'Lanches'),
    Product(name: 'Pudim de Leite', price: 8.00, category: 'Sobremesas'),
    Product(name: 'Água Mineral', price: 3.00, category: 'Bebidas'),
    Product(name: 'Batata Frita', price: 7.00, category: 'Lanches'),
  ];

  // Cart items
  final List<Product> _cartItems = [];

  // Get filtered products based on search query and category
  List<Product> get _filteredProducts {
    List<Product> products = _allProducts;

    if (_searchQuery.isNotEmpty) {
      products =
          products.where((product) {
            return product.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();
    }

    if (_selectedCategory != 'Todos') {
      products =
          products.where((product) {
            return product.category == _selectedCategory;
          }).toList();
    }
    return products;
  }

  // Calculate total price in the cart
  double get _cartTotal {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, you would navigate to different screens here
    // based on the selected index.
  }

  void _addToCart(Product product) {
    setState(() {
      final existingProductIndex = _cartItems.indexWhere(
        (item) => item.name == product.name,
      );

      if (existingProductIndex != -1) {
        _cartItems[existingProductIndex].quantity++;
      } else {
        _cartItems.add(
          Product(
            name: product.name,
            price: product.price,
            category: product.category,
            quantity: 1,
          ),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho!'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _removeFromCart(Product product) {
    setState(() {
      final existingProductIndex = _cartItems.indexWhere(
        (item) => item.name == product.name,
      );
      if (existingProductIndex != -1) {
        if (_cartItems[existingProductIndex].quantity > 1) {
          _cartItems[existingProductIndex].quantity--;
        } else {
          _cartItems.removeAt(existingProductIndex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Vendas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile Layout
            return _buildMobileLayout();
          } else {
            // Tablet/Desktop Layout
            return _buildTabletDesktopLayout();
          }
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onDestinationSelected,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Produtos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Relatórios',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Configurações',
                ),
              ],
            );
          } else {
            return const SizedBox.shrink(); // Hide bottom nav for larger screens
          }
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(context).size.width > 1200
                  ? 4
                  : MediaQuery.of(context).size.width > 800
                  ? 3
                  : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8, // Adjusted for better card fit
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Placeholder(
                      // Replace with actual product image
                      fallbackHeight: 80,
                      fallbackWidth: 80,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addToCart(product),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Adicionar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        35,
                      ), // Full width button
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductListAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar produto...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip('Todos'),
                _buildCategoryChip('Bebidas'),
                _buildCategoryChip('Lanches'),
                _buildCategoryChip('Sobremesas'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildProductGrid(),
      ],
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? label : 'Todos';
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color:
            isSelected ? Theme.of(context).colorScheme.primary : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCartSection() {
    return Container(
      width: 300,
      color: Colors.grey[50], // Lighter background for the cart
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Carrinho de Compras',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child:
                _cartItems.isEmpty
                    ? Center(
                      child: Text(
                        'Seu carrinho está vazio.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${item.price.toStringAsFixed(2)} p/unidade',
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => _removeFromCart(item),
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () => _addToCart(item),
                                    ),
                                  ],
                                ),
                                Text(
                                  'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'R\$ ${_cartTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                _cartItems.isEmpty
                    ? null
                    : () {
                      // Implement checkout logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Venda finalizada com sucesso!'),
                        ),
                      );
                      setState(() {
                        _cartItems.clear(); // Clear cart after sale
                      });
                    },
            icon: const Icon(Icons.check),
            label: const Text('Finalizar Venda'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    // For mobile, you might only show products or a different view based on _selectedIndex
    return _selectedIndex == 0
        ? _buildProductListAndFilters()
        : _selectedIndex == 1
        ? const Center(child: Text('Relatórios'))
        : const Center(child: Text('Configurações'));
  }

  Widget _buildTabletDesktopLayout() {
    return Row(
      children: [
        // Menu lateral
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
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
        const VerticalDivider(thickness: 1, width: 1),
        // Conteúdo principal
        Expanded(
          flex: 3,
          child:
              _selectedIndex == 0
                  ? _buildProductListAndFilters()
                  : _selectedIndex == 1
                  ? const Center(child: Text('Relatórios'))
                  : const Center(child: Text('Configurações')),
        ),
        // Carrinho
        _buildCartSection(),
      ],
    );
  }
}
