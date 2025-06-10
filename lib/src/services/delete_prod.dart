import 'package:http/http.dart' as http;

class ProdDeletAPI {
  final String baseUrl = 'http://127.0.0.1:8000/api/produtos/deletar/';

  Future<void> deletarProduto(int id) async {
    final url = Uri.parse('$baseUrl$id/');

    final response = await http.delete(url);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Erro ao deletar produto: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
