import 'package:flutter/material.dart';

class fazerReserva extends StatelessWidget {
  final double saldo;
  final List<String> items;

  const fazerReserva({super.key, required this.items, required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Fazer Reserva - R\$ ${saldo.toStringAsFixed(2)}'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(items[index]));
        },
      ),
    );
  }
}
