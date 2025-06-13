import 'package:flutter/material.dart';
import 'package:unilanches/src/services/cadastro_fornecedor.dart';
import 'package:unilanches/src/models/cadastro_fornecedor_model.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

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
  final TextEditingController cepController = TextEditingController();
  final TextEditingController contatoController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();

  bool ativo = true;
  bool _isLoading = false; // To manage loading state for the button

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

  @override
  void dispose() {
    nomeController.dispose();
    cnpjController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    celularController.dispose();
    enderecoController.dispose();
    cidadeController.dispose();
    cepController.dispose();
    contatoController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  Future<void> _cadastroFornecedor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

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
        if (mounted) {
          // Check if the widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fornecedor cadastrado com sucesso!')),
          );
          _formKey.currentState!.reset();
          setState(() {
            ufSelecionada = null;
            ativo = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha ao cadastrar fornecedor')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar fornecedor: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Fornecedor',
          style: TextStyle(color: Colors.white),
        ), // Text color for contrast
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 127, 243),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Icon color for back button
        actions: [
          TextButton.icon(
            onPressed: () {
              // Navigator.push(
              //    context,
              //   MaterialPageRoute(builder: (context) => ListProd()),
              //  );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white, // Changed to white for better contrast
            ),
            label: const Text(
              'Consultar Fornecedor',
              style: TextStyle(
                color: Colors.white,
              ), // Changed to white for better contrast
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
              _buildTextField(
                cnpjController,
                'CNPJ',
                Icons.badge,
                true,
                inputType: TextInputType.number,
                inputFormatters: [_cnpjFormatter], // Apply CNPJ formatter
                maxLength: 18, // Max length for formatted CNPJ
              ),
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
                inputType: TextInputType.phone,
                inputFormatters: [
                  _phoneFormatter,
                ], // Optional: Apply phone formatter
                maxLength: 15, // Max length for formatted phone
              ),
              _buildTextField(
                celularController,
                'Celular',
                Icons.phone_android,
                false,
                inputType: TextInputType.phone,
                inputFormatters: [
                  _cellPhoneFormatter,
                ], // Optional: Apply cellphone formatter
                maxLength: 16, // Max length for formatted cellphone
              ),
              const SizedBox(height: 16), // Add some space before address group
              const Divider(), // Visual separator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Endereço',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DropdownButtonFormField<UF>(
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
              ),
              _buildTextField(
                cepController,
                'CEP',
                Icons.markunread_mailbox,
                false,
                inputType: TextInputType.number,
                inputFormatters: [_cepFormatter], // Apply CEP formatter
                maxLength: 9, // Max length for formatted CEP
              ),
              const SizedBox(height: 16), // Add some space
              const Divider(), // Visual separator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Dados Adicionais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                onPressed:
                    _isLoading
                        ? null // Disable button when loading
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            await _cadastroFornecedor();
                          }
                        },
                label:
                    _isLoading
                        ? const CircularProgressIndicator(
                          color: Colors.white,
                        ) // Show loading indicator
                        : const Text('Cadastrar'),
                icon: const Icon(Icons.save), // Icon for save
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    3,
                    127,
                    243,
                  ), // Primary color for button
                  foregroundColor: Colors.white, // Text color for button
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          counterText: "", // Hide the default character counter
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

  // Input Formatters
  final FilteringTextInputFormatter _cnpjFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\-/]'));
  final FilteringTextInputFormatter _cepFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]'));
  final FilteringTextInputFormatter _phoneFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\(\)\- ]'));
  final FilteringTextInputFormatter _cellPhoneFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\(\)\- ]'));

  // You might want to implement more sophisticated formatters if needed
  // For example, to automatically add dots/dashes as the user types
  // using custom TextInputFormatter extending TextInputFormatter.
}
