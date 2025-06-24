import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unilanches/src/models/produto_model.dart'; // Importe o ProdutoModel completo

class ProdutoListApi {
  final String baseUrl = 'https://api-a35y.onrender.com/api/produtos/';

  Future<List<ProdutoModel>> listarProdutos() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);
      // Mapeia cada item da lista dinâmica para um ProdutoModel
      return dados
          .map((json) => ProdutoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erro ao carregar produtos: ${response.statusCode}');
    }
  }
}
