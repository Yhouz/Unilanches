import 'package:flutter/material.dart';
import 'package:unilanches/Login_page.dart';
import 'package:unilanches/src/models/resgister_model.dart';
import 'package:unilanches/src/services/register.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nome = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController cpf = TextEditingController();
  final TextEditingController telefone = TextEditingController();
  final TextEditingController senha = TextEditingController();
  final List<Funcao> listFuncao = [
    Funcao(nome: 'Cliente'),
    Funcao(nome: 'Funcionario'),
  ];
  final FocusNode focoNome = FocusNode();
  final FocusNode focoEmail = FocusNode();
  final FocusNode focoCpf = FocusNode();
  final FocusNode focoTelefone = FocusNode();
  final FocusNode focoSenha = FocusNode();
  final List<Funcao> selectedFuncao = [];
  final api = RegisterApi();

  bool _isLoading = false;

  void registerUser(BuildContext context) async {
    if (nome.text.isEmpty ||
        email.text.isEmpty ||
        cpf.text.isEmpty ||
        telefone.text.isEmpty ||
        senha.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = RegisterModel(
      nome: nome.text,
      email: email.text,
      cpf: cpf.text,
      telefone: telefone.text,
      senha: senha.text,
      tipoUsuario: 'cliente',
    );

    try {
      final response = await api.createUser(user);

      if (!context.mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário registrado com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar: ${response.body}')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    controller: nome,
                    focusNode: focoNome,
                    onFieldSubmitted:
                        (value) =>
                            FocusScope.of(context).requestFocus(focoEmail),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    controller: email,
                    focusNode: focoEmail,
                    keyboardType: TextInputType.emailAddress,

                    onFieldSubmitted:
                        (value) => FocusScope.of(context).requestFocus(focoCpf),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'CPF',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                    controller: cpf,
                    focusNode: focoCpf,
                    keyboardType: TextInputType.number,

                    onFieldSubmitted:
                        (value) =>
                            FocusScope.of(context).requestFocus(focoTelefone),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    controller: telefone,
                    focusNode: focoTelefone,
                    keyboardType: TextInputType.phone,
                    onFieldSubmitted:
                        (value) =>
                            FocusScope.of(context).requestFocus(focoSenha),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    controller: senha,
                    focusNode: focoSenha,
                    keyboardType: TextInputType.visiblePassword,
                    onFieldSubmitted:
                        (value) => FocusScope.of(context).requestFocus(
                          selectedFuncao.isEmpty ? focoNome : null,
                        ),
                  ),
                  const SizedBox(height: 30),
                  DropdownButton(
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items:
                        listFuncao.map((funcao) {
                          return DropdownMenuItem(
                            value: funcao.nome,
                            child: Text(funcao.nome),
                          );
                        }).toList(),
                    value:
                        selectedFuncao.isNotEmpty
                            ? selectedFuncao.first.nome
                            : null,
                    hint: const Text(
                      'Selecione uma função',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedFuncao.clear();
                        if (value != null) {
                          selectedFuncao.add(
                            Funcao(nome: value.toString()),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: () {
                          registerUser(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
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
