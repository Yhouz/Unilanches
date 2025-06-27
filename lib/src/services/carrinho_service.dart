import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unilanches/src/models/carrinho_model.dart';
import 'package:unilanches/src/models/item_carrinho_model.dart';
import 'package:unilanches/src/services/auth_service.dart';

class CarrinhoService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<http.Response> _apiCall(
    Future<http.Response> Function(Map<String, String> headers) apiRequest,
  ) async {
    // ... seu método _apiCall (está perfeito, não mude nada) ...
    String? token = await AuthServiceWeb.getAccessToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await apiRequest(headers);

    if (response.statusCode == 401 || response.statusCode == 403) {
      try {
        await AuthServiceWeb.refreshToken();
        token = await AuthServiceWeb.getAccessToken();
        headers['Authorization'] = 'Bearer $token';
        response = await apiRequest(headers);
      } catch (e) {
        await AuthServiceWeb.logout();
        throw Exception('Sessão expirada. Por favor, faça login novamente.');
      }
    }
    return response;
  }

  void _handleGenericError(http.Response response, String message) {
    // ... seu método _handleGenericError (está perfeito) ...
    print('$message - Status: ${response.statusCode}, Body: ${response.body}');
    throw Exception(
      '$message (Status: ${response.statusCode}): ${response.body}',
    );
  }

  Future<CarrinhoModel> getOrCreateActiveCart() async {
    // ... seu método getOrCreateActiveCart (está perfeito) ...
    try {
      return await _fetchMyOpenCart();
    } on Exception catch (e) {
      if (e.toString().contains('Status: 404')) {
        return await _createCart();
      } else {
        rethrow;
      }
    }
  }

  // ✅ A CORREÇÃO ESTÁ AQUI ✅
  Future<CarrinhoModel> adicionarItemCarrinho({
    required int carrinhoId,
    required int produtoId,
    required int quantidade,
  }) async {
    final response = await _apiCall(
      (headers) => http.post(
        // A URL está correta e corresponde à sua urls.py
        Uri.parse('$baseUrl/carrinhos/$carrinhoId/itens/'),
        headers: headers,
        // O corpo da requisição agora envia apenas o que a view precisa
        body: json.encode({
          'produto_id': produtoId,
          'quantidade': quantidade,
        }),
      ),
    );

    // O status esperado aqui deve ser 200, pois a view que corrigimos
    // retorna o carrinho completo com status 200 OK.
    if (response.statusCode == 200) {
      return CarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Erro ao adicionar item');
      throw Exception('Unreachable');
    }
  }

  // ... O resto dos seus métodos (deletar, editar, etc.) estão corretos e não precisam de mudança.

  Future<CarrinhoModel> deletarItemCarrinho(int itemId, int carrinhoId) async {
    final response = await _apiCall(
      (headers) => http.delete(
        Uri.parse('$baseUrl/itens_carrinho/$itemId/'),
        headers: headers,
      ),
    );
    if (response.statusCode == 204) {
      return _fetchCartById(carrinhoId);
    } else {
      _handleGenericError(response, 'Erro ao deletar item');
      throw Exception('Unreachable');
    }
  }

  Future<ItemCarrinhoModel> editarItemCarrinho(
    int itemId,
    int newQuantity,
  ) async {
    final response = await _apiCall(
      (headers) => http.patch(
        Uri.parse('$baseUrl/itens_carrinho/$itemId/'),
        headers: headers,
        body: json.encode({'quantidade': newQuantity}),
      ),
    );
    if (response.statusCode == 200) {
      return ItemCarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Erro ao editar item');
      throw Exception('Unreachable');
    }
  }

  Future<CarrinhoModel> _fetchMyOpenCart() async {
    final response = await _apiCall(
      (headers) => http.get(
        Uri.parse('$baseUrl/carrinhos/meu-carrinho/'),
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      return CarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Falha ao buscar carrinho do usuário');
      throw Exception('Unreachable');
    }
  }

  Future<CarrinhoModel> _fetchCartById(int carrinhoId) async {
    final response = await _apiCall(
      (headers) => http.get(
        Uri.parse('$baseUrl/carrinhos/$carrinhoId/'),
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      return CarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Falha ao buscar carrinho por ID');
      throw Exception('Unreachable');
    }
  }

  Future<CarrinhoModel> _createCart() async {
    final response = await _apiCall(
      (headers) => http.post(
        Uri.parse('$baseUrl/carrinhos/'),
        headers: headers,
        body: json.encode({}),
      ),
    );
    if (response.statusCode == 201) {
      return CarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Erro ao criar carrinho');
      throw Exception('Unreachable');
    }
  }

  Future<void> finalizarCarrinho(int carrinhoId) async {
    final response = await _apiCall(
      (headers) => http.post(
        Uri.parse('$baseUrl/carrinhos/$carrinhoId/finalizar/'),
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      return;
    } else {
      _handleGenericError(response, 'Erro ao finalizar carrinho');
      throw Exception('Unreachable');
    }
  }
}
