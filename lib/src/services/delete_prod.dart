import 'package:http/http.dart' as http;

class ProdDeletAPI {
  final String baseUrl = 'https://api-a35y.onrender.com/api/produtos/deletar/';

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
