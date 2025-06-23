import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:unilanches/src/models/carrinho_model.dart' show CarrinhoModel;
import 'package:unilanches/src/models/item_carrinho_model.dart'
    show ItemCarrinhoModel;
import 'package:unilanches/src/models/produto_model.dart'; // Certifique-se que ProdutoModel está no lugar certo

class CarrinhoService {
  final String baseUrl =
      'https://api-a35y.onrender.com/api'; // <- Sua URL da API

  // Função auxiliar para tratamento de erro padronizado
  void _handleError(http.Response response, String errorMessage) {
    String detailedMessage = errorMessage;
    try {
      final errorBody = json.decode(response.body);
      if (errorBody is Map && errorBody.containsKey('erro')) {
        detailedMessage += ': ${errorBody['erro']}';
      } else if (errorBody is Map && errorBody.containsKey('detail')) {
        detailedMessage += ': ${errorBody['detail']}';
      } else {
        detailedMessage += ': Status ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      detailedMessage +=
          ': Status ${response.statusCode} - Erro ao decodificar resposta de erro.';
    }
    throw Exception(detailedMessage);
  }

  // ----------------------------------------
  // LISTAR TODOS OS CARRINHOS
  // (Geralmente não usado em tela de carrinho do usuário, mas mantido)
  // ----------------------------------------
  Future<List<CarrinhoModel>> listarCarrinhos() async {
    final response = await http.get(Uri.parse('$baseUrl/carrinhos/'));
    if (response.statusCode == 200) {
      List listaJson = json.decode(response.body);
      return listaJson.map((e) => CarrinhoModel.fromJson(e)).toList();
    } else {
      _handleError(response, 'Falha ao carregar carrinhos');
      return []; // Retorno inalcançável devido ao throw
    }
  }

  // ----------------------------------------
  // BUSCAR UM CARRINHO ESPECÍFICO PELO ID DO CARRINHO
  // ----------------------------------------
  Future<CarrinhoModel> buscarCarrinhoPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/carrinhos/$id/'));
    if (response.statusCode == 200) {
      print(
        'JSON retornado por buscarCarrinhoPorId: ${response.body}',
      ); // Diagnóstico
      return CarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleError(response, 'Carrinho não encontrado');
      throw Exception(
        'Carrinho não encontrado',
      ); // Garante que uma exceção é lançada
    }
  }

  // ----------------------------------------
  // CRIAR UM NOVO CARRINHO
  // ----------------------------------------
  Future<CarrinhoModel> criarCarrinho(int usuarioId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/carrinhos/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'usuario': usuarioId}),
    );
    if (response.statusCode == 201) {
      print(
        'JSON retornado por criarCarrinho: ${response.body}',
      ); // Diagnóstico
      return CarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleError(response, 'Erro ao criar carrinho');
      throw Exception(
        'Erro ao criar carrinho',
      ); // Garante que uma exceção é lançada
    }
  }

  // ----------------------------------------
  // ADICIONAR ITEM NO CARRINHO
  // ----------------------------------------
  Future<ItemCarrinhoModel> adicionarItemCarrinho({
    required int carrinhoId,
    required int produtoId,
    required int quantidade,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/itens_carrinho/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'carrinho': carrinhoId,
        'produto_id':
            produtoId, // <-- CORREÇÃO AQUI: De volta para 'produto_id'
        'quantidade': quantidade,
      }),
    );
    if (response.statusCode == 201) {
      return ItemCarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleError(response, 'Erro ao adicionar item no carrinho');
      throw Exception(
        'Erro ao adicionar item no carrinho',
      ); // Garante que uma exceção é lançada
    }
  }

  // ----------------------------------------
  // DELETAR ITEM DO CARRINHO
  // ----------------------------------------
  Future<void> deletarItemCarrinho(int itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/itens_carrinho/$itemId/'),
    );
    if (response.statusCode != 204) {
      // 204 No Content para DELETE bem sucedido
      _handleError(response, 'Erro ao deletar item do carrinho');
    }
  }

  // ----------------------------------------
  // EDITAR ITEM DO CARRINHO (ATUALIZAR QUANTIDADE)
  // Implementação baseada no backend PUT /itens_carrinho/{pk}/
  // ----------------------------------------
  Future<ItemCarrinhoModel> editarItemCarrinho(
    int itemId,
    int newQuantity,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/itens_carrinho/$itemId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'quantidade': newQuantity,
      }),
    );
    if (response.statusCode == 200) {
      // PUT/PATCH geralmente retorna 200 OK com o objeto atualizado
      return ItemCarrinhoModel.fromJson(json.decode(response.body));
    } else {
      _handleError(response, 'Erro ao editar item do carrinho');
      throw Exception(
        'Erro ao editar item do carrinho',
      ); // Garante que uma exceção é lançada
    }
  }

  // ----------------------------------------
  // LIMPAR TODOS OS ITENS DE UM CARRINHO
  // (Esta função assume que você criou um endpoint no backend para isso,
  // ex: POST /carrinhos/{id}/limpar_itens/)
  // ----------------------------------------
  Future<void> limparCarrinho(int carrinhoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/carrinhos/$carrinhoId/limpar_itens/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      // 204 No Content, ou 200 OK com mensagem de sucesso
      // Sucesso
    } else {
      _handleError(response, 'Erro ao limpar carrinho');
    }
  }

  // Método auxiliar para adicionar um item ao carrinho (chamado de outras telas)
  Future<ItemCarrinhoModel> adicionarItemAoCarrinho(
    int carrinhoId,
    ProdutoModel produto,
    int quantidade,
  ) async {
    return await adicionarItemCarrinho(
      carrinhoId: carrinhoId,
      produtoId: produto.id!, // Assumindo que produto.id não é nulo
      quantidade: quantidade,
    );
  }
}
