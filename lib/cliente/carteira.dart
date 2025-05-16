// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Carteira extends StatefulWidget {
  const Carteira({super.key, required saldo});

  @override
  State<Carteira> createState() => _CarteiraState();
}

class _CarteiraState extends State<Carteira> {
  double saldo = 0.00;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarSaldo();
  }

  Future<void> _salvarSaldo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saldo', saldo);
  }

  Future<void> _carregarSaldo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      saldo = prefs.getDouble('saldo') ?? 0.00;
    });
  }

  void addSaldo(double valor) {
    if (valor < 0) return;
    setState(() {
      saldo += valor;
    });
    _salvarSaldo();
  }

  void removeSaldo(double valor) {
    if (valor < 0) return;
    setState(() {
      saldo -= valor;
    });
    _salvarSaldo();
  }

  double getSaldo() {
    return saldo;
  }

  void _mostrarDialogoValor(String metodo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar com $metodo'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Digite o valor'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.clear();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final valor =
                    double.tryParse(_controller.text.replaceAll(',', '.')) ??
                    0.0;
                addSaldo(valor);
                Navigator.of(context).pop();
                _controller.clear();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Carteira')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Saldo:', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text(
              'R\$ ${getSaldo().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Escolha a forma de pagamento:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.qr_code),
                            title: const Text('PIX'),
                            onTap: () {
                              Navigator.pop(context);
                              _mostrarDialogoValor('PIX');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.credit_card),
                            title: const Text('Cartão'),
                            onTap: () {
                              Navigator.pop(context);
                              _mostrarDialogoValor('Cartão');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.money),
                            title: const Text('Dinheiro'),
                            onTap: () {
                              Navigator.pop(context);
                              _mostrarDialogoValor('Dinheiro');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Saldo'),
            ),
          ],
        ),
      ),
    );
  }
}
