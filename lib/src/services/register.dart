import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilanches/src/models/resgister_model.dart';

class RegisterApi {
  final String baseUrl = 'http://127.0.0.1:8000/api/cadastro/';

  Future<http.Response> createUser(RegisterModel user) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      return response;
    } catch (e) {
      throw Exception('Erro ao registrar usuário: $e');
    }
  }
}
