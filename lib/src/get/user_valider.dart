import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> verificarLogin(
  String email,
  String senha,
  String tipoUsuario,
) async {
  final url = Uri.parse('https://api-a35y.onrender.com/api/login/');

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
    return true;
  } else {
    return false;
  }
}
