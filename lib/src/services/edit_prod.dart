import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unilanches/src/models/edit_prod_model.dart'; // Certifique-se de que EditProdModel tem um toJson()

class ProdutoEditApi {
  final String baseUrl = 'http://127.0.0.1:8000/api/editar/';

  // Mude o tipo de retorno para Future<bool>
  Future<bool> editProd(EditProdModel produto) async {
    final url = Uri.parse('$baseUrl${produto.id}/');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nome': produto.nome,
          'preco': produto.preco,
          'quantidade_estoque':
              produto.quantidadeEstoque, // <-- Mude para snake_case aqui
        }),
      );

      print(
        'Status da resposta (edição): ${response.statusCode}',
      ); // Para depuração
      print('Corpo da resposta (edição): ${response.body}'); // Para depuração

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Códigos 2xx (200 OK, 204 No Content, etc.) indicam sucesso
        return true; // Retorna true em caso de sucesso
      } else {
        // Lança uma exceção para que o chamador possa tratar o erro
        throw Exception(
          'Erro ao editar produto: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      // Captura erros de rede ou outros e re-lança uma exceção mais específica
      print('Erro na requisição de edição: $e');
      throw Exception('Erro de conexão ou inesperado ao editar: $e');
    }
  }
}
