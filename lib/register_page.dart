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
  final List<Funcao> selectedFuncao = [];

  final FocusNode focoNome = FocusNode();
  final FocusNode focoEmail = FocusNode();
  final FocusNode focoCpf = FocusNode();
  final FocusNode focoTelefone = FocusNode();
  final FocusNode focoSenha = FocusNode();

  final api = RegisterApi();
  bool _isLoading = false;

  /// Função para registrar o usuário
  Future<bool> registerUser(BuildContext context) async {
    if (nome.text.isEmpty ||
        email.text.isEmpty ||
        cpf.text.isEmpty ||
        telefone.text.isEmpty ||
        senha.text.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Erro no Cadastro'),
              content: Text('Preencha todos os campos!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Ok'),
                ),
              ],
            ),
      );
      return false;
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
      tipoUsuario: 'Cliente',
    );

    try {
      final response = await api.createUser(user);

      if (!context.mounted) return false;

      if (response.statusCode == 400) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Erro no Cadastro'),
                content: Text(
                  'Use um e-mail institucional (@unifucamp.edu.br)',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Ok'),
                  ),
                ],
              ),
        );
        return false;
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Erro no Login'),
                content: Text('Usuário registrado com sucesso!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Ok'),
                  ),
                ],
              ),
        );
        return true;
      } else {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Erro ao registrar'),
                content: Text('Erro ao registrar: ${response.body}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Ok'),
                  ),
                ],
              ),
        );
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Erro no Cadastro'),
              content: Text('Erro inesperado: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Ok'),
                ),
              ],
            ),
      );
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Registrar Usuário',
          ),
          centerTitle: true,
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
                    // Campo Nome
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
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

                    // Campo Email
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
                          (value) =>
                              FocusScope.of(context).requestFocus(focoCpf),
                    ),
                    const SizedBox(height: 20),

                    // Campo CPF
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

                    // Campo Telefone
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

                    // Campo Senha
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
                          (value) => FocusScope.of(context).unfocus(),
                    ),
                    const SizedBox(height: 30),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: () async {
                            bool sucesso = await registerUser(context);
                            if (sucesso) {
                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                50,
                              ), // Borda arredondada
                            ),
                          ),
                          child: Text(
                            'Registrar',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
