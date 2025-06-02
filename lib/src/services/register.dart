import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilanches/src/models/resgister_model.dart';

class RegisterApi {
  final String baseUrl = 'https://api-unilanches.onrender.com/usuarios/';

  Future<http.Response> createUser(RegisterModel user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    return response;
  }
}
