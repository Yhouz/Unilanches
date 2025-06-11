// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:unilanches/src/services/cadastro_funcionario_serv.dart';

class UF {
  String sigla;
  UF({required this.sigla});
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
  final TextEditingController dtAdmissao = TextEditingController();
  final TextEditingController dtNascimento = TextEditingController();
  final TextEditingController salario = TextEditingController();
  final TextEditingController endereco = TextEditingController();
  final TextEditingController numero = TextEditingController();
  final TextEditingController cidade = TextEditingController();

  final List<Cargo> cargos = [
    Cargo(nome: 'Gerente'),
    Cargo(nome: 'Caixa'),
    Cargo(nome: 'Atendente'),
    Cargo(nome: 'Cozinheiro'),
    Cargo(nome: 'Estoquista'),
    Cargo(nome: 'Administrador'),
    Cargo(nome: 'Faxineiro'),
  ];

  Cargo? cargoSelecionado;

  final List<UF> ufs = [
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

  UF? ufSelecionada;

  final FocusNode focoNome = FocusNode();
  final FocusNode focoEmail = FocusNode();
  final FocusNode focoCpf = FocusNode();
  final FocusNode focoTelefone = FocusNode();
  final FocusNode focoSenha = FocusNode();
  final FocusNode focoCargo = FocusNode();
  final FocusNode focoDtadmissao = FocusNode();
  final FocusNode focusDtnascimento = FocusNode();
  final FocusNode focoSalario = FocusNode();
  final FocusNode focoEndereco = FocusNode();
  final FocusNode focoNumero = FocusNode();
  final FocusNode focoCidade = FocusNode();
  final FocusNode focoUF = FocusNode();

  bool _isCadastroFunc = false;

  Future<void> cadastroFunc(UF? uf) async {
    if (nome.text.isEmpty ||
        email.text.isEmpty ||
        cpf.text.isEmpty ||
        telefone.text.isEmpty ||
        senha.text.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Erro no Cadastro'),
              content: const Text('Preencha todos os campos!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ok'),
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
        cargoSelecionado!.nome,
        'Funcionario',
        dtAdmissao.text,
        dtNascimento.text,
        salario.text,
        endereco.text,
        numero.text,
        uf!.sigla,
        cidade.text,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(sucesso ? 'Sucesso' : 'Erro'),
              content: Text(
                sucesso
                    ? 'Funcionário cadastrado com sucesso!'
                    : 'Falha ao cadastrar funcionário.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Erro'),
              content: Text('Ocorreu um erro: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
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
      controller.text =
          "${dataSelecionada.year.toString().padLeft(4, '0')}-"
          "${dataSelecionada.month.toString().padLeft(2, '0')}-"
          "${dataSelecionada.day.toString().padLeft(2, '0')}";
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
          actions: [
            TextButton.icon(
              onPressed: () {
                // Navigator.push(
                // context,
                // MaterialPageRoute(builder: (context) => ()),
                //);
              },
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              label: Text(
                'Consutar Funcionario',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              // width: 400,
              padding: const EdgeInsets.all(16),
              child: Form(
                child: Column(
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
                      decoration: const InputDecoration(
                        labelText: 'Cargo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      value: cargoSelecionado,
                      items:
                          cargos.map((cargo) {
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

                    campoTexto(
                      'Salário (Reais)',
                      Icons.attach_money,
                      salario,
                      focoSalario,
                      focoEndereco,
                      tipoTeclado: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    campoTexto(
                      'Endereço',
                      Icons.home,
                      endereco,
                      focoEndereco,
                      focoNumero,
                    ),
                    const SizedBox(height: 20),

                    campoTexto(
                      'Número',
                      Icons.pin,
                      numero,
                      focoNumero,
                      focoCidade,
                      tipoTeclado: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    campoTexto(
                      'Cidade',
                      Icons.location_city,
                      cidade,
                      focoCidade,
                      focoUF,
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<UF>(
                      decoration: const InputDecoration(
                        labelText: 'UF',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      value: ufSelecionada,
                      items:
                          ufs.map((estado) {
                            return DropdownMenuItem<UF>(
                              value: estado,
                              child: Text(estado.sigla),
                            );
                          }).toList(),
                      onChanged: (novaUF) {
                        setState(() {
                          ufSelecionada = novaUF;
                        });
                      },
                      validator:
                          (valor) => valor == null ? 'Selecione uma UF' : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: dtAdmissao,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Data de Admissão',
                              border: OutlineInputBorder(),
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
                            decoration: const InputDecoration(
                              labelText: 'Data de Nascimento',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_month),
                            ),
                            onTap: () => _selecionarData(context, dtNascimento),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        await cadastroFunc(ufSelecionada);
                      },
                      child:
                          _isCadastroFunc
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Cadastrar'),
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
