import 'dart:convert';
import 'package:http/http.dart' as http;

class CadastroFuncAPI {
  static const String baseUrl =
      'https://api-a35y.onrender.com/api/cadastro-funcionario/'; // Coloque sua URL da API

  static Future<bool> cadastroFuncionario(
    String nome,
    String email,
    String cpf,
    String telefone,
    String senha,
    String cargo,
    String tipoUsuario,
    String dtAdmissao,
    String dtNascimento,
    String salario,
    String endereco,
    String numero,
    String uf,
    String cidade,
  ) async {
    final url = Uri.parse(baseUrl);

    final resposta = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'senha': senha,
        'email': email,
        'telefone': telefone,
        'cpf': cpf,
        'cargo': cargo,
        'tipoUsuario': tipoUsuario,
        'dt_admissao': dtAdmissao,
        'dt_nascimento': dtNascimento,
        'salario': salario,
        'endereco': endereco,
        'numero': numero,
        'uf': uf,
        'cidade': cidade,
      }),
    );

    if (resposta.statusCode == 200 || resposta.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
