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
        senha.text.isEmpty ||
        cargoSelecionado == null ||
        dtAdmissao.text.isEmpty ||
        dtNascimento.text.isEmpty ||
        salario.text.isEmpty ||
        endereco.text.isEmpty ||
        numero.text.isEmpty ||
        ufSelecionada == null ||
        cidade.text.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Erro no Cadastro'),
              content: const Text('Preencha todos os campos obrigatórios!'),
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
        'Funcionario', // Assuming this is a fixed role
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
      helpText: 'Selecione a Data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(255, 3, 127, 243),
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 3, 127, 243),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Funcionário'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 127, 243),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            label: const Text(
              'Consultar Funcionário',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ), // Max width for larger screens
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Personal Information Section
                  const Text(
                    'Dados Pessoais',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 127, 243),
                    ),
                  ),
                  const Divider(color: Color.fromARGB(255, 3, 127, 243)),
                  const SizedBox(height: 16),
                  campoTexto(
                    'Nome Completo',
                    Icons.person,
                    nome,
                    focoNome,
                    focoEmail,
                  ),
                  const SizedBox(height: 16),
                  campoTexto(
                    'Email',
                    Icons.email,
                    email,
                    focoEmail,
                    focoCpf,
                    tipoTeclado: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: campoTexto(
                          'CPF',
                          Icons.credit_card,
                          cpf,
                          focoCpf,
                          focoTelefone,
                          tipoTeclado: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: campoTexto(
                          'Telefone',
                          Icons.phone,
                          telefone,
                          focoTelefone,
                          focoSenha,
                          tipoTeclado: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  campoTexto(
                    'Senha',
                    Icons.lock,
                    senha,
                    focoSenha,
                    focoCargo,
                    ocultarTexto: true,
                    tipoTeclado: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 32),

                  /// Job Information Section
                  const Text(
                    'Dados Profissionais',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 127, 243),
                    ),
                  ),
                  const Divider(color: Color.fromARGB(255, 3, 127, 243)),
                  const SizedBox(height: 16),
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
                        (valor) => valor == null ? 'Selecione um cargo' : null,
                  ),
                  const SizedBox(height: 16),
                  campoTexto(
                    'Salário (R\$)',
                    Icons.attach_money,
                    salario,
                    focoSalario,
                    focoEndereco,
                    tipoTeclado: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 32),

                  /// Address Information Section
                  const Text(
                    'Endereço',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 3, 127, 243),
                    ),
                  ),
                  const Divider(color: Color.fromARGB(255, 3, 127, 243)),
                  const SizedBox(height: 16),
                  campoTexto(
                    'Endereço',
                    Icons.home,
                    endereco,
                    focoEndereco,
                    focoNumero,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: campoTexto(
                          'Número',
                          Icons.pin,
                          numero,
                          focoNumero,
                          focoCidade,
                          tipoTeclado: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: campoTexto(
                          'Cidade',
                          Icons.location_city,
                          cidade,
                          focoCidade,
                          focoUF,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UF>(
                    decoration: const InputDecoration(
                      labelText: 'Estado (UF)',
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
                        (valor) => valor == null ? 'Selecione um estado' : null,
                  ),
                  const SizedBox(height: 32),

                  /// Registration Button
                  ElevatedButton(
                    onPressed:
                        _isCadastroFunc
                            ? null
                            : () async {
                              // You might want to add form validation here before calling cadastroFunc
                              await cadastroFunc(ufSelecionada);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 127, 243),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isCadastroFunc
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Cadastrar Funcionário',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ],
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
        floatingLabelBehavior:
            FloatingLabelBehavior.auto, // Ensures label moves when focused
      ),
      controller: controller,
      focusNode: focoAtual,
      obscureText: ocultarTexto,
      keyboardType: tipoTeclado,
      onFieldSubmitted: (_) {
        if (focoProximo != null) {
          FocusScope.of(context).requestFocus(focoProximo);
        } else {
          focoAtual.unfocus(); // Unfocus the current field
        }
      },
      // Basic validation: checks if the field is empty
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
    );
  }
}
