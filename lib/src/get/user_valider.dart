import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unilanches/src/services/auth_service.dart'; // Aponta para seu AuthServiceWeb

Future<bool> verificarLogin(
  String email,
  String senha,
  String tipoUsuario,
) async {
  final url = Uri.parse('http://127.0.0.1:8000/api/login/');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'senha': senha,
        'tipo_usuario': tipoUsuario,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // ✅ 1. Obtenha AMBOS os tokens da resposta do backend
      final accessToken = data['access'];
      final refreshToken =
          data['refresh']; // Adicione esta linha para pegar o refresh token

      if (accessToken != null && refreshToken != null) {
        // 🚀 2. Chame o método CORRETO: salvarTokens (no plural)
        await AuthServiceWeb.salvarTokens(
          accessToken,
          refreshToken,
        ); // Passe os dois tokens
        print('Login bem-sucedido! Tokens (access e refresh) salvos.');
        return true;
      } else {
        print(
          'Erro no login: Tokens (access ou refresh) não recebidos na resposta.',
        );
        return false;
      }
    } else {
      print('Erro no login (${response.statusCode}): ${response.body}');
      return false;
    }
  } catch (e) {
    print('Erro inesperado na requisição de login: $e');
    return false;
  }
}
