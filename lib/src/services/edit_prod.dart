import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:unilanches/src/models/edit_prod_model.dart';

class ProdutoEditApi {
  final String baseUrl = 'http://127.0.0.1:8000/api/produtos/editar/';

  Future<EditProdModel?> editProd(EditProdModel produto) async {
    final url = Uri.parse('$baseUrl${produto.id}'); // <<-- Ajuste importante

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(produto.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EditProdModel.fromJson(data);
      } else {
        print('Falha ao editar: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao editar produto: $e');
    }
  }
}
