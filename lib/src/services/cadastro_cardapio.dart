import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilanches/src/models/cadastro_cardapio.dart';

class CardapioApi {
  final String baseUrl = 'http://127.0.0.1:8000/api/cardapios/cadastrar/';

  Future<http.Response> criarCardapio(CardapioModel cardapio) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
        },
        body: jsonEncode(cardapio.toJson()),
      );

      return response;
    } catch (e) {
      throw Exception('Erro ao cadastrar cardápio: $e');
    }
  }
}
