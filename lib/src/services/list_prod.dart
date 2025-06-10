import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unilanches/src/models/edit_prod_model.dart';
import 'package:unilanches/src/models/list_prod_models.dart';

class ProdutoListApi {
  final String baseUrl = 'http://127.0.0.1:8000/api/produtos/';

  Future<List<ProdutoListModel>> listarProdutos() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);

      // CORREÇÃO AQUI: convertendo cada item do JSON
      return dados.map((json) => ProdutoListModel.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar produtos');
    }
  }

  Future<void> editarProduto(EditProdModel produtoEditado) async {}
}
