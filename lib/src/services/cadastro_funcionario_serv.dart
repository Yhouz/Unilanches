import 'dart:convert';
import 'package:http/http.dart' as http;

class CadastroFuncAPI {
  static const String baseUrl =
      'http://127.0.0.1:8000/api/cadastro-funcionario/'; // Coloque sua URL da API

  static Future<bool> cadastroFuncionario(
    String nome,
    String email,
    String cpf,
    String telefone,
    String senha,
    String cargo,
    String tipoUsuario,
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
        'tipo_usuario': 'funcionario',
      }),
    );

    if (resposta.statusCode == 200 || resposta.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
