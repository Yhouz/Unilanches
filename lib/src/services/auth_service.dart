// lib/src/services/auth_service_web.dart
import 'dart:convert' show jsonEncode, json;
import 'dart:html' as html;

import 'package:http/http.dart' as http show post;
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Importar SharedPreferences

class AuthServiceWeb {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // Salva ambos os tokens após um login bem-sucedido
  static Future<void> salvarTokens(
    String accessToken,
    String refreshToken,
  ) async {
    html.window.localStorage[_accessTokenKey] = accessToken;
    html.window.localStorage[_refreshTokenKey] = refreshToken;
    print('Tokens salvos no localStorage.');
  }

  // Recupera o Access Token para uso em requisições protegidas
  static Future<String?> getAccessToken() async {
    final token = html.window.localStorage[_accessTokenKey];
    return token;
  }

  // Recupera o Refresh Token para renovação ou logout
  static Future<String?> getRefreshToken() async {
    final token = html.window.localStorage[_refreshTokenKey];
    return token;
  }

  // Limpa ambos os tokens (access/refresh) E o carrinhoId
  static Future<void> limparTokens() async {
    html.window.localStorage.remove(_accessTokenKey);
    html.window.localStorage.remove(_refreshTokenKey);
    print('Tokens de autenticação removidos do localStorage.');

    // ✅ NOVO: Remover o ID do carrinho do SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('carrinhoId');
    print('ID do carrinho removido do SharedPreferences.');
  }

  // --- Funções para renovação de token (opcional, mas recomendado) ---
  static Future<bool> renovarAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      print('Não há Refresh Token para renovar.');
      return false;
    }

    final url = Uri.parse(
      'http://127.0.0.1:8000/api/token/refresh/',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access'];
        final newRefreshToken =
            data.containsKey('refresh') ? data['refresh'] : refreshToken;

        await salvarTokens(newAccessToken, newRefreshToken);
        print('Access Token renovado com sucesso!');
        return true;
      } else {
        print(
          'Falha ao renovar token (${response.statusCode}): ${response.body}',
        );
        await limparTokens(); // Limpar tudo se o refresh token falhar
        return false;
      }
    } catch (e) {
      print('Erro na requisição de renovação de token: $e');
      await limparTokens(); // Limpar tudo em caso de erro de rede
      return false;
    }
  }
}
