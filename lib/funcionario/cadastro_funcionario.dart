// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:unilanches/src/services/cadastro_funcionario_serv.dart';

class UF {
  String sigla;

  UF({
    required this.sigla,
  });
}

class Cargo {
  String nome;
  Cargo({required this.nome});
}

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
  //final TextEditingController cargo = TextEditingController();
  final TextEditingController dtAdmissao = TextEditingController();
  final TextEditingController dtNascimento = TextEditingController();
  final TextEditingController salario = TextEditingController();
  final TextEditingController endereco = TextEditingController();
  final TextEditingController numero = TextEditingController();
  //final TextEditingController uf = TextEditingController();
  final TextEditingController cidade = TextEditingController();

  final List<Cargo> cargo = [
    Cargo(nome: 'Gerente'),
    Cargo(nome: 'Caixa'),
    Cargo(nome: 'Atendente'),
    Cargo(nome: 'Cozinheiro'),
    Cargo(nome: 'Estoquista'),
    Cargo(nome: 'Administrador'),
    Cargo(nome: 'Faxineiro'),
  ];

  //Variavel para guarda o que foi selecionado CARGO
  Cargo? cargoSelecionado;

  final List<UF> uf = [
    UF(sigla: 'AC'),
    UF(sigla: 'AL'),
    UF(sigla: 'AP'),
    UF(sigla: 'AM'),
    UF(sigla: 'BA'),
    UF(sigla: 'CE'),
    UF(sigla: 'DF'),
    UF(sigla: 'ES'),
    UF(sigla: 'GO'),
    UF(sigla: 'MA'),
    UF(sigla: 'MT'),
    UF(sigla: 'MS'),
    UF(sigla: 'MG'),
    UF(sigla: 'PA'),
    UF(sigla: 'PB'),
    UF(sigla: 'PR'),
    UF(sigla: 'PE'),
    UF(sigla: 'PI'),
    UF(sigla: 'RJ'),
    UF(sigla: 'RN'),
    UF(sigla: 'RS'),
    UF(sigla: 'RO'),
    UF(sigla: 'RR'),
    UF(sigla: 'SC'),
    UF(sigla: 'SP'),
    UF(sigla: 'SE'),
    UF(sigla: 'TO'),
  ];

  // Focar o campo ao aperta o enter
  final FocusNode focoNome = FocusNode();
  final FocusNode focoEmail = FocusNode();
  final FocusNode focoCpf = FocusNode();
  final FocusNode focoTelefone = FocusNode();
  final FocusNode focoSenha = FocusNode();
  final FocusNode focoCargo = FocusNode();

  bool _isCadastroFunc = false;

  Future<void> cadastroFunc(dynamic uf) async {
    if (nome.text.isEmpty ||
        email.text.isEmpty ||
        cpf.text.isEmpty ||
        telefone.text.isEmpty ||
        senha.text.isEmpty ||
        uf == null) {
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
        Cargo as String,
        'Funcionario',
        dtAdmissao.text,
        dtNascimento.text,
        salario.text,
        endereco.text,
        numero.text,
        uf!,
        cidade.text,
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

  Future<void> _selecionarData(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        controller.text =
            "${dataSelecionada.day.toString().padLeft(2, '0')}/"
            "${dataSelecionada.month.toString().padLeft(2, '0')}/"
            "${dataSelecionada.year}";
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: 20),
                    DropdownButtonFormField<Cargo>(
                      decoration: InputDecoration(
                        labelText: 'Cargo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      value: cargoSelecionado,
                      items:
                          cargo.map((cargo) {
                            return DropdownMenuItem<Cargo>(
                              value: cargo,
                              child: Text(cargo.nome),
                            );
                          }).toList(),
                      onChanged: (novoCargo) {
                        setState(() {
                          cargoSelecionado = novoCargo;
                        });
                      },
                      validator:
                          (valor) =>
                              valor == null ? 'Selecione um cargo' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: dtAdmissao,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Data de Admissão',
                              border: const OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selecionarData(context, dtAdmissao),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: dtNascimento,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Data de Nascimento',
                              border: const OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_month),
                            ),
                            onTap: () => _selecionarData(context, dtNascimento),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Botão de cadastro
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await cadastroFunc(uf);
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
