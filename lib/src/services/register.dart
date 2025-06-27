import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilanches/src/models/resgister_model.dart';

class RegisterApi {
  final String baseUrl = 'https://api-a35y.onrender.com/api/cadastro/';

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
