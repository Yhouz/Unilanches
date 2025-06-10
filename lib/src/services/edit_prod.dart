import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unilanches/src/models/edit_prod_model.dart';

class ProdutoEditApi {
  final String baseUrl = 'http://127.0.0.1:8000/api/produtos/editar/';

  Future<EditProdModel?> editProd(EditProdModel produto) async {
    final url = Uri.parse('$baseUrl${produto.id}/'); // Inclui o id na URL

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nome': produto.nome,
          'preco': produto.preco,
        }),
      );

      if (response.statusCode == 200) {
        // Se o backend retornar os dados atualizados, use fromJson
        final data = jsonDecode(response.body);
        return EditProdModel.fromJson(data, idAntigo: produto.id);
      } else {
        throw Exception('Erro ao editar produto: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
