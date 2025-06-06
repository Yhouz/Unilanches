import 'package:flutter/material.dart';
import 'package:unilanches/Login_page.dart';
import 'package:unilanches/funcionario/cadastro_funcionario.dart';
import 'package:unilanches/funcionario/cadastro_produto.dart';
import 'package:unilanches/funcionario/list_prod.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CadastroFuncionario(),
                      ),
                    );
                  },
                  child: Text('Cadastro Funcionario'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CadastroProduto(),
                      ),
                    );
                  },
                  child: Text('Cadastro Produto'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListProd()),
                    );
                  },
                  child: Text('Lista Produtos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
