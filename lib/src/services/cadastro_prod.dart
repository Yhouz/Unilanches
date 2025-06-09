import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilanches/src/models/produto_model.dart';

class ProdutoApi {
  final String baseUrl = 'http://127.0.0.1:8000/api/produtos/';

  Future<ProdutoModel?> cadastrarProduto(ProdutoModel produto) async {
    final url = Uri.parse('${baseUrl}cadastrar/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(produto.toJson()),
      );

      if (response.statusCode == 201) {
        // Sucesso no cadastro, retorna o produto criado (a partir da resposta JSON)
      } else {
        // Pode lançar um erro ou retornar null em caso de falha
        //  print('Falha no cadastro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao registrar produto: $e');
    }
    return null;
  }
}
