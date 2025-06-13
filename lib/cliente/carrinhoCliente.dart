import 'package:flutter/material.dart';

// --- Cart Item Model (You'll likely have this in your actual app) ---
class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
}

// --- Cart Screen Widget ---
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  // Dummy Cart Data - Replace with your actual cart management
  List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'Product A',
      imageUrl: 'https://via.placeholder.com/150',
      price: 29.99,
      quantity: 1,
    ),
    CartItem(
      id: '2',
      name: 'Product B',
      imageUrl: 'https://via.placeholder.com/150',
      price: 49.99,
      quantity: 2,
    ),
    CartItem(
      id: '3',
      name: 'Product C',
      imageUrl: 'https://via.placeholder.com/150',
      price: 19.99,
      quantity: 1,
    ),
  ];

  // Function to calculate total price
  double _getTotalPrice() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // Function to remove an item
  void _removeItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });
  }

  // Function to increase item quantity
  void _increaseQuantity(String id) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _cartItems[index].quantity++;
      }
    });
  }

  // Function to decrease item quantity
  void _decreaseQuantity(String id) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index != -1 && _cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else if (index != -1 && _cartItems[index].quantity == 1) {
        // Optionally remove item if quantity becomes 0
        _removeItem(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Carrinho'),
        centerTitle: true,
      ),
      body:
          _cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Seu carrinho está vazio!',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Product Image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(item.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'R\$ ${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Quantity Controls
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove_circle),
                                            onPressed:
                                                () =>
                                                    _decreaseQuantity(item.id),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add_circle),
                                            onPressed:
                                                () =>
                                                    _increaseQuantity(item.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Remove Button
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeItem(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // --- Cart Summary at the bottom ---
                  Divider(height: 1, color: Colors.grey),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'R\$ ${_getTotalPrice().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement checkout logic here
                              print('Proceed to Checkout!');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor:
                                  Colors.blueAccent, // Button color
                            ),
                            child: Text(
                              'Finalizar Pedido',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

// --- How to use this in your main.dart or other file ---
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CartScreen(), // Set CartScreen as the home screen
    );
  }
}
