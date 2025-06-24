import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilanches/src/models/carrinho_model.dart';
import 'package:unilanches/src/models/item_carrinho_model.dart';
import 'package:unilanches/src/services/auth_service.dart';

class CarrinhoService {
  final String baseUrl = 'https://api-a35y.onrender.com/api/';

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthServiceWeb.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _handleError(http.Response response, String message) {
    print('$message - Status: ${response.statusCode}, Body: ${response.body}');
    throw Exception('$message: ${response.body}');
  }

  Future<List<CarrinhoModel>> listarCarrinhos() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/carrinhos/'),
      headers: headers,
    );

    print('DEBUG - Resposta de listarCarrinhos(): ${response.body}');

    if (response.statusCode == 200) {
      List listaJson = json.decode(response.body);
      return listaJson.map((e) => CarrinhoModel.fromJson(e)).toList();
    } else {
      _handleError(response, 'Falha ao carregar carrinhos');
      return [];
    }
  }

  Future<CarrinhoModel> buscarCarrinhoPorId(int id) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/carrinhos/$id/'),
      headers: headers,
    );

    print('DEBUG - Resposta de buscarCarrinhoPorId($id): ${response.body}');

    if (response.statusCode == 200) {
      return CarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleError(response, 'Carrinho não encontrado');
      throw Exception('Carrinho não encontrado');
    }
  }

  Future<CarrinhoModel> criarCarrinho() async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/carrinhos/'),
      headers: headers,
      body: json.encode({}),
    );

    print('DEBUG - Resposta de criarCarrinho(): ${response.body}');

    if (response.statusCode == 201) {
      return CarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleError(response, 'Erro ao criar carrinho');
      throw Exception('Erro ao criar carrinho');
    }
  }

  // ✅ CORREÇÃO AQUI: Garanta que 'produto_id' é enviado no corpo da requisição
  Future<void> adicionarItemCarrinho({
    required int carrinhoId,
    required int produtoId,
    required int quantidade,
  }) async {
    final headers = await _getAuthHeaders();

    final url = Uri.parse('$baseUrl/carrinhos/$carrinhoId/itens/');

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'produto_id': produtoId, // <-- TEM QUE SER 'produto_id' AQUI!
        'quantidade': quantidade,
      }),
    );

    print(
      'DEBUG - Resposta de adicionarItemCarrinho($carrinhoId, $produtoId): ${response.body}',
    );

    if (response.statusCode != 201) {
      _handleError(response, 'Erro ao adicionar item ao carrinho');
    }
  }

  Future<void> deletarItemCarrinho(int itemId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/itens_carrinho/$itemId/'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      _handleError(response, 'Erro ao deletar item do carrinho');
    }
  }

  Future<ItemCarrinhoModel> editarItemCarrinho(
    int itemId,
    int newQuantity,
  ) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/itens_carrinho/$itemId/'),
      headers: headers,
      body: json.encode({
        'quantidade': newQuantity,
      }),
    );
    if (response.statusCode == 200) {
      return ItemCarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleError(response, 'Erro ao editar item do carrinho');
      throw Exception('Erro ao editar item do carrinho');
    }
  }

  Future<void> limparCarrinho(int carrinhoId) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse(
      '$baseUrl/carrinhos/$carrinhoId/limpar/',
    );
    final response = await http.post(url, headers: headers);
    if (response.statusCode != 200) {
      _handleError(response, 'Erro ao limpar carrinho');
    }
  }
}
