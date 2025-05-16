import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilanches/cliente/home_pageClient.dart';
import 'package:unilanches/funcionario/home_pageFuncionairio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class Funcao {
  String nome;

  Funcao({required this.nome});
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nome = TextEditingController();
  final TextEditingController senha = TextEditingController();
  final List<Funcao> listFuncao = [
    Funcao(nome: 'Cliente'),
    Funcao(nome: 'Funcionario'),
  ];
  Funcao? selectedFuncao;
  final FocusNode focoNome = FocusNode();
  final FocusNode focoSenha = FocusNode();

  @override
  void dispose() {
    nome.dispose();
    senha.dispose();
    focoNome.dispose();
    focoSenha.dispose();
    super.dispose();
  }

  void loginUser() {
    if (formKey.currentState!.validate()) {
      log('Nome: ${nome.text}');
      log('Senha: ${senha.text}');
      log('Função: ${selectedFuncao?.nome ?? "Nenhuma selecionada"}');

      if (selectedFuncao != null) {
        if (selectedFuncao!.nome == 'Cliente') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => HomePageclient(nome: nome.text, saldo: 0.00),
            ),
          );
        } else if (selectedFuncao!.nome == 'Funcionario') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => home_pageFuncionario(nome: nome.text),
            ),
          );
        } else {
          log('Nenhuma Função selecionada');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset('assets/images/image.png'),
                ),
                SizedBox(height: 100),
                Text(
                  'Faça seu Login',
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: nome,
                  focusNode: focoNome,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.name,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(focoSenha);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira um nome, por favor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: senha,
                  focusNode: focoSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  onFieldSubmitted: (value) {
                    loginUser();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira um senha, por favor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<Funcao>(
                  value: selectedFuncao,
                  hint: Text(
                    'Selecione...',
                    style: TextStyle(
                      fontSize: 20,
                      color: const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                  items:
                      listFuncao.map<DropdownMenuItem<Funcao>>((Funcao funcao) {
                        return DropdownMenuItem<Funcao>(
                          value: funcao,
                          child: Text(
                            funcao.nome,
                            style: TextStyle(
                              color: CupertinoColors.activeGreen,
                              fontSize: 20,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (Funcao? newValue) {
                    setState(() {
                      selectedFuncao = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Escolha um alternativa';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    loginUser();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        50,
                      ), // Borda arredondada
                    ),
                  ),
                  child: const Text('Entrar', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
