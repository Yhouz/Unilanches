import 'package:flutter/material.dart';
import 'package:unilanches/src/services/cadastro_fornecedor.dart';
import 'package:unilanches/src/models/cadastro_fornecedor_model.dart';

class UF {
  String sigla;
  UF({required this.sigla});
}

class CadastroFornecedor extends StatefulWidget {
  const CadastroFornecedor({super.key});

  @override
  State<CadastroFornecedor> createState() => _CadastroFornecedorState();
}

class _CadastroFornecedorState extends State<CadastroFornecedor> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController contatoController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();

  bool ativo = true;

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

  Future<void> _cadastroFornecedor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fornecedor = CadastrarFornecedorModel(
      nome: nomeController.text,
      cnpj: cnpjController.text,
      email: emailController.text,
      telefone: telefoneController.text,
      celular: celularController.text,
      endereco: enderecoController.text,
      cidade: cidadeController.text,
      estado: ufSelecionada?.sigla ?? '',
      cep: cepController.text,
      contato: contatoController.text,
      ativo: ativo,
      dataCadastro: DateTime.now(),
      observacoes: observacoesController.text,
    );

    try {
      final api = FornecedorApi();
      final fornecedorCriado = await api.cadastrarFornecedor(fornecedor);

      if (fornecedorCriado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fornecedor cadastrado com sucesso!')),
        );
        // Opcional: limpar campos ou navegar para outra tela
        _formKey.currentState!.reset();
        setState(() {
          ufSelecionada = null;
          ativo = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao cadastrar fornecedor')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar fornecedor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Fornecedor'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 127, 243),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Navigator.push(
              //    context,
              //   MaterialPageRoute(builder: (context) => ListProd()),
              //  );
            },
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            label: Text(
              'Consutar Fornecedor',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nomeController, 'Nome', Icons.business, true),
              _buildTextField(cnpjController, 'CNPJ', Icons.badge, true),
              _buildTextField(
                emailController,
                'Email',
                Icons.email,
                true,
                inputType: TextInputType.emailAddress,
              ),
              _buildTextField(
                telefoneController,
                'Telefone',
                Icons.phone,
                false,
              ),
              _buildTextField(
                celularController,
                'Celular',
                Icons.phone_android,
                false,
              ),
              _buildTextField(
                enderecoController,
                'Endereço',
                Icons.location_on,
                false,
              ),
              _buildTextField(
                cidadeController,
                'Cidade',
                Icons.location_city,
                false,
              ),
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
                validator: (valor) => valor == null ? 'Selecione uma UF' : null,
              ),
              _buildTextField(
                cepController,
                'CEP',
                Icons.markunread_mailbox,
                false,
              ),
              _buildTextField(
                contatoController,
                'Pessoa de Contato',
                Icons.person_outline,
                false,
              ),
              _buildMultilineField(
                observacoesController,
                'Observações',
                Icons.notes,
              ),
              SwitchListTile(
                title: const Text('Ativo'),
                value: ativo,
                onChanged: (value) {
                  setState(() {
                    ativo = value;
                  });
                },
                secondary: const Icon(Icons.check_circle),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _cadastroFornecedor();
                    // Aqui você pode salvar ou enviar os dados
                  }
                },

                label: const Text('Cadastar'),
                style: ElevatedButton.styleFrom(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool required, {
    TextInputType inputType = TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator:
            required
                ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Preencha o campo $label';
                  }
                  return null;
                }
                : null,
      ),
    );
  }

  Widget _buildMultilineField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
