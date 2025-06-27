import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilanches/src/models/cadastro_fornecedor_model.dart';

class FornecedorApi {
  // Ajuste a URL conforme seu ambiente de teste!
  final String baseUrl = 'https://api-a35y.onrender.com/api/criar/';

  Future<CadastrarFornecedorModel?> cadastrarFornecedor(
    CadastrarFornecedorModel fornecedor,
  ) async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(fornecedor.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Verifique se a chave 'fornecedor' existe no responseData
        if (responseData.containsKey('fornecedor')) {
          return CadastrarFornecedorModel.fromJson(responseData['fornecedor']);
        } else {
          print('Resposta inesperada: $responseData');
          return null;
        }
      } else {
        print('Falha no cadastro: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      // É importante capturar e relançar ou lidar com a exceção
      print('Erro ao registrar fornecedor: $e');
      throw Exception('Erro ao registrar fornecedor: $e');
    }
  }
}
