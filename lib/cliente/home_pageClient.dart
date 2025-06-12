import 'package:flutter/material.dart';
import 'package:unilanches/cliente/cardapioPage.dart';
import 'package:unilanches/cliente/carteira.dart';

class HomePageclient extends StatefulWidget {
  final String nome;
  final double saldo;

  const HomePageclient({super.key, required this.nome, required this.saldo});

  @override
  State<HomePageclient> createState() => _HomePageclientState();
}

class _HomePageclientState extends State<HomePageclient> {
  final Map<String, double> produtos = {};
  final List<String> items = [
    'Produto 1',
    'Produto 2',
    'Produto 3',
    'Produto 4',
  ];
  bool mostrarCardapio = false;
  bool reservar = false;

  @override
  void initState() {
    super.initState();
    carregarCardapioDoDia();
  }

  void carregarCardapioDoDia() {
    setState(() {
      produtos.clear();
      produtos.addAll({
        'Jantinha Especial': 15.99,
        'Salgado de Frango': 4.50,
        'Refrigerante': 3.00,
        'Suco Natural': 5.00,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo com overlay
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/image_fundo.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
              ],
            ),
          ),

          // Conteúdo central
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bem vindo - ${widget.nome}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Delícias inesquecíveis esperando por você!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              mostrarCardapio = !mostrarCardapio;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            mostrarCardapio
                                ? 'Ocultar Cardápio'
                                : 'Ver Cardápio',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              reservar = !reservar;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text(
                            'Fazer Reserva',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Carteira(saldo: widget.saldo),
                            ),
                          );
                        },
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text(
                          'Ver Carteira',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (mostrarCardapio)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CardapioClientePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Ver Cardápio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (reservar)
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 600, // largura máxima
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  ' Reserva',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'R\$ ${widget.saldo.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      reservar = !reservar;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Escolha o produto:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return ListTile(title: Text(items[index]));
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
