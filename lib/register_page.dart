import 'package:flutter/material.dart';
import 'package:unilanches/src/models/resgister_model.dart';
import 'package:unilanches/src/services/register.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final TextEditingController nome = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController cpf = TextEditingController();
  final TextEditingController telefone = TextEditingController();
  final TextEditingController senha = TextEditingController();

  final api = RegisterApi();

  void registerUser(BuildContext context) async {
    final user = RegisterModel(
      name: nome.text,
      email: email.text,
      cpf: cpf.text,
      telefone: telefone.text,
      senha: senha.text,
    );

    final response = await api.createUser(user);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Registro bem-sucedido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário registrado com sucesso!')),
      );
      Navigator.pop(context); // Volta para a tela anterior (login, por exemplo)
    } else {
      // Erro no registro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Usuário'),
        backgroundColor: const Color.fromARGB(255, 3, 127, 243),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nome'),
                    controller: nome,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    controller: email,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'CPF'),
                    controller: cpf,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Telefone'),
                    controller: telefone,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    controller: senha,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      registerUser(context);
                      Navigator.pop(context); // Volta para a tela anterior
                    },
                    child: const Text('Registrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
