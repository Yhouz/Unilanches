// lib/src/services/RecuperarSenha.dart
import 'dart:convert'; // Para usar jsonEncode e jsonDecode
import 'package:http/http.dart' as http; // Para fazer requisições HTTP

class RecuperarSenhaApi {
  // A URL do seu endpoint de recuperação de senha.
  // Certifique-se de que esta URL está correta e acessível.
  final String baseUrl = 'http://127.0.0.1:8000/api/recuperar-senha/';

  /// Envia uma requisição POST para a API para recuperar/alterar a senha de um usuário.
  ///
  /// Recebe o [email] do usuário e a [novaSenha] que será definida.
  /// Retorna um [http.Response] contendo a resposta completa do servidor.
  /// Lança uma [Exception] se houver um erro de conexão (ex: sem internet).
  Future<http.Response> recuperarSenha(String email, String novaSenha) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl), // Converte a String URL para um objeto Uri
        headers: {
          // Informa ao servidor que estamos enviando JSON
          'Content-Type': 'application/json; charset=UTF-8',
          // Informa ao servidor que esperamos JSON de volta
          'accept': 'application/json',
        },
        body: jsonEncode({
          // Converte o mapa Dart em uma string JSON para o corpo da requisição
          'email': email,
          'nova_senha': novaSenha,
        }),
      );
      return response; // Retorna o objeto de resposta completo (statusCode, body, etc.)
    } catch (e) {
      // Captura qualquer erro que ocorra durante a comunicação HTTP (ex: falha de rede)
      print("Erro na API de recuperar senha: $e"); // Loga o erro para depuração
      throw Exception(
        'Falha ao conectar com o servidor. Verifique sua conexão ou tente novamente mais tarde.',
      );
    }
  }
}
