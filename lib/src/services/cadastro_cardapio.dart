import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:unilanches/src/models/cardapio_model.dart'; // Certifique-se de que o caminho está correto
import 'package:unilanches/src/models/produto_model.dart';

import '../models/cadastro_cardapio.dart'
    show CardapioModel; // Certifique-se de que o caminho está correto

class CardapioApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/cardapios/';
  static const String produtosBaseUrl =
      'http://127.0.0.1:8000/api/produtos/'; // Nova URL base para produtos

  // Buscar cardápio do dia
  Future<CardapioModel?> buscarCardapioDoDia() async {
    try {
      final hoje = DateTime.now().toIso8601String().split('T').first;
      final response = await http.get(
        Uri.parse(
          "$baseUrl?data=$hoje",
        ), // CORRIGIDO: Usando o endpoint de listagem com filtro de data
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assumindo que a API retorna uma lista de cardápios, mesmo que filtrada por data
        if (data is List && data.isNotEmpty) {
          return CardapioModel.fromJson(
            data[0],
          ); // Pega o primeiro cardápio encontrado para a data
        } else if (data is Map &&
            data['results'] is List &&
            data['results'].isNotEmpty) {
          // Caso a API retorne um objeto com 'results' (como em DRF com paginação)
          return CardapioModel.fromJson(data['results'][0]);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cardápio: $e');
    }
  }

  // Buscar produtos do cardápio (movido para usar produtosBaseUrl)
  Future<List<ProdutoModel>> buscarProdutosDoCardapio(
    List<int> produtoIds,
  ) async {
    try {
      final idsString = produtoIds.join(',');
      final response = await http.get(
        Uri.parse(
          '$produtosBaseUrl?ids=$idsString',
        ), // CORRIGIDO: Usando a URL base de produtos
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(response.body);
        // Assumindo que a API de produtos retorna uma lista direta de produtos
        return dados
            .map((json) => ProdutoModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erro ao carregar produtos');
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  // Criar cardápio com upload de imagem
  Future<http.Response> criarCardapioComImagem(
    CardapioModel cardapio,
    Uint8List? imagemBytes,
    String? nomeArquivo,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}cadastrar/'),
      );

      // Adicionar campos do cardápio
      request.fields['nome'] = cardapio.nome;
      request.fields['categoria'] = cardapio.categoria;
      request.fields['data'] = cardapio.data;
      request.fields['produtos'] = json.encode(cardapio.produtos);

      // Adicionar imagem se fornecida
      if (imagemBytes != null && nomeArquivo != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'imagem',
            imagemBytes,
            filename: nomeArquivo,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Erro ao criar cardápio: $e');
    }
  }
}
