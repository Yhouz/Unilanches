import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:unilanches/src/models/pedido_models.dart' show PedidoModel;
import 'package:unilanches/src/services/auth_service.dart';

class PedidoService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<http.Response> _apiCall(
    Future<http.Response> Function(Map<String, String> headers) apiRequest,
  ) async {
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
    print('$message - Status: ${response.statusCode}, Body: ${response.body}');
    throw Exception(
      '$message (Status: ${response.statusCode}): ${response.body}',
    );
  }

  /// Cria um novo pedido no backend.
  Future<PedidoModel> criarPedido({
    required int carrinhoId,
    required double total,
  }) async {
    final response = await _apiCall(
      (headers) => http.post(
        Uri.parse('$baseUrl/pedidos/criar/'),
        headers: headers,
        body: json.encode({
          'carrinho_id': carrinhoId,
          'total': total,
        }),
      ),
    );

    if (response.statusCode == 201) {
      return PedidoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Falha ao criar pedido');
      throw Exception('Unreachable');
    }
  }

  /// ✅ MÉTODO PARA LISTAR PEDIDOS DO USUÁRIO LOGADO
  /// Tenta diferentes endpoints até encontrar o correto
  Future<List<PedidoModel>> listarPedidosDoUsuarioLogado() async {
    final List<String> possiveisEndpoints = [
      '$baseUrl/pedidos/',
    ];

    Exception? ultimoErro;

    for (String endpoint in possiveisEndpoints) {
      try {
        final response = await _apiCall(
          (headers) => http.get(
            Uri.parse(endpoint),
            headers: headers,
          ),
        );

        if (response.statusCode == 200) {
          final responseBody = utf8.decode(response.bodyBytes);
          final dynamic decodedResponse = json.decode(responseBody);

          List<dynamic> pedidosJson;
          if (decodedResponse is List) {
            pedidosJson = decodedResponse;
          } else if (decodedResponse is Map &&
              decodedResponse.containsKey('results')) {
            pedidosJson = decodedResponse['results'];
          } else if (decodedResponse is Map &&
              decodedResponse.containsKey('data')) {
            pedidosJson = decodedResponse['data'];
          } else {
            continue;
          }

          return pedidosJson.map((json) => PedidoModel.fromJson(json)).toList();
        } else if (response.statusCode == 404) {
          continue;
        } else {
          ultimoErro = Exception(
            'Erro ${response.statusCode}: ${response.body}',
          );
        }
      } catch (e) {
        ultimoErro = e is Exception ? e : Exception(e.toString());
        continue;
      }
    }

    throw ultimoErro ?? Exception('Erro desconhecido ao buscar pedidos.');
  }

  /// Método original que ainda funciona se você tiver o usuarioId
  Future<List<PedidoModel>> listarPedidos(String usuarioId) async {
    final response = await _apiCall(
      (headers) => http.get(
        Uri.parse('$baseUrl/pedidos/usuario/$usuarioId/'),
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> pedidosJson = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return pedidosJson.map((json) => PedidoModel.fromJson(json)).toList();
    } else {
      _handleGenericError(response, 'Falha ao listar pedidos');
      throw Exception('Unreachable');
    }
  }

  // Atualiza o status de um pedido
  Future<PedidoModel> atualizarStatusPedido(
    String pedidoId,
    String status,
  ) async {
    final response = await _apiCall(
      (headers) => http.patch(
        Uri.parse('$baseUrl/pedidos/$pedidoId/'),
        headers: headers,
        body: json.encode({'status_pedido': status}),
      ),
    );

    if (response.statusCode == 200) {
      return PedidoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Falha ao atualizar pedido');
      throw Exception('Unreachable');
    }
  }

  // Detalhes de um pedido específico
  Future<PedidoModel> detalharPedido(String pedidoId) async {
    final response = await _apiCall(
      (headers) => http.get(
        Uri.parse('$baseUrl/pedidos/$pedidoId/'),
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      return PedidoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Falha ao detalhar pedido');
      throw Exception('Unreachable');
    }
  }

  // Deleta um pedido
  Future<void> deletarPedido(String pedidoId) async {
    final response = await _apiCall(
      (headers) => http.delete(
        Uri.parse('$baseUrl/pedidos/$pedidoId/deletar/'),
        headers: headers,
      ),
    );

    if (response.statusCode != 204) {
      _handleGenericError(response, 'Falha ao deletar pedido');
    }
  }

  // Finalizar pedido
  Future<PedidoModel> finalizarPedido(String pedidoId) async {
    // A lógica de autenticação agora está diretamente aqui.

    // 1. Obter o token de acesso.
    final String? token = await AuthServiceWeb.getAccessToken();

    // Validação para garantir que o token existe.
    if (token == null) {
      throw Exception('Utilizador não autenticado. Por favor, faça login.');
    }

    // 2. Preparar os cabeçalhos da requisição.
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Fazer a chamada HTTP POST diretamente.
    final response = await http.post(
      Uri.parse('$baseUrl/pedidos/$pedidoId/finalizar/'),
      headers: headers,
    );

    // 4. Verificar a resposta.
    if (response.statusCode == 200) {
      // Se a resposta for 200 OK, decodifica o JSON e cria o modelo do Pedido.
      return PedidoModel.fromJson(json.decode(response.body));
    } else {
      // Se houver qualquer outro status, lança um erro com os detalhes.
      print(
        'Falha ao finalizar pedido - Status: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception(
        'Falha ao finalizar pedido (Status: ${response.statusCode}): ${response.body}',
      );
    }
  }

  // Detalhes de um pedido específico
  Future<PedidoModel> detalharPedidoFinalizado(String pedidoId) async {
    final response = await _apiCall(
      (headers) => http.get(
        Uri.parse('$baseUrl/pedidos/$pedidoId/detalhar/'),
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      return PedidoModel.fromJson(json.decode(response.body));
    } else {
      _handleGenericError(response, 'Falha ao detalhar pedido');
      throw Exception('Unreachable');
    }
  }
}
