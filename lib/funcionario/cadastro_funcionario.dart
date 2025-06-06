import 'package:flutter/material.dart';

import 'package:unilanches/src/services/cadastro_funcionario_serv.dart';

class CadastroFuncionario extends StatefulWidget {
  const CadastroFuncionario({super.key});

  @override
  State<CadastroFuncionario> createState() => _CadastroFuncionarioState();
}

class _CadastroFuncionarioState extends State<CadastroFuncionario> {
  final TextEditingController nome = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController cpf = TextEditingController();
  final TextEditingController telefone = TextEditingController();
  final TextEditingController senha = TextEditingController();
  final TextEditingController cargo = TextEditingController();

  final FocusNode focoNome = FocusNode();
  final FocusNode focoEmail = FocusNode();
  final FocusNode focoCpf = FocusNode();
  final FocusNode focoTelefone = FocusNode();
  final FocusNode focoSenha = FocusNode();
  final FocusNode focoCargo = FocusNode();

  bool _isCadastroFunc = false;

  Future<void> cadastroFunc() async {
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
      return;
    }

    setState(() {
      _isCadastroFunc = true;
    });

    try {
      final sucesso = await CadastroFuncAPI.cadastroFuncionario(
        nome.text,
        email.text,
        cpf.text,
        telefone.text,
        senha.text,
        cargo.text,
        'Funcionario',
      );

      if (sucesso) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Sucesso'),
                content: Text('Funcionário cadastrado com sucesso!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Erro'),
                content: Text('Falha ao cadastrar funcionário.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Erro'),
              content: Text('Ocorreu um erro: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } finally {
      setState(() {
        _isCadastroFunc = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrar Funcionário'),
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
                    // Campos de formulário (os mesmos que você já colocou)
                    campoTexto('Nome', Icons.person, nome, focoNome, focoEmail),
                    const SizedBox(height: 20),
                    campoTexto(
                      'Email',
                      Icons.email,
                      email,
                      focoEmail,
                      focoCpf,
                      tipoTeclado: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    campoTexto(
                      'CPF',
                      Icons.credit_card,
                      cpf,
                      focoCpf,
                      focoTelefone,
                      tipoTeclado: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    campoTexto(
                      'Telefone',
                      Icons.phone,
                      telefone,
                      focoTelefone,
                      focoSenha,
                      tipoTeclado: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    campoTexto(
                      'Senha',
                      Icons.lock,
                      senha,
                      focoSenha,
                      focoCargo,
                      ocultarTexto: true,
                      tipoTeclado: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 30),
                    campoTexto(
                      'Fução',
                      Icons.add_link_sharp,
                      cargo,
                      focoCargo,
                      null,
                    ),
                    const SizedBox(height: 20),
                    // Botão de cadastro
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await cadastroFunc();
                        },
                        child:
                            _isCadastroFunc
                                ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Cadastrar'),
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

  Widget campoTexto(
    String label,
    IconData icone,
    TextEditingController controller,
    FocusNode focoAtual,
    FocusNode? focoProximo, {
    bool ocultarTexto = false,
    TextInputType tipoTeclado = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icone),
      ),
      controller: controller,
      focusNode: focoAtual,
      obscureText: ocultarTexto,
      keyboardType: tipoTeclado,
      onFieldSubmitted: (_) {
        if (focoProximo != null) {
          FocusScope.of(context).requestFocus(focoProximo);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
    );
  }
}
