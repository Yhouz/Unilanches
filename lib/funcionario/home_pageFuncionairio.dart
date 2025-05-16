import 'package:flutter/material.dart';
import 'package:unilanches/Login_page.dart';

class home_pageFuncionario extends StatefulWidget {
  final String nome;
  const home_pageFuncionario({super.key, required this.nome});
  @override
  State<home_pageFuncionario> createState() => _home_pageFuncionarioState();
}

class _home_pageFuncionarioState extends State<home_pageFuncionario> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 127, 243),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ); // ação do botão voltar
          }, // ação do botão voltar
        ),
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tela Funcionário',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bem-vindo(a) ${widget.nome}'),
            OutlinedButton.icon(
              onPressed: () {
                // Ação do botão "Fazer Pedido"
              },
              icon: Icon(Icons.add),
              label: Text('Cadastrar Produto'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // Ação do botão "Ver Pedidos"
              },
              icon: Icon(Icons.list),
              label: Text('Ver Produtos'),
            ),
          ],
        ),
      ),
    );
  }
}
