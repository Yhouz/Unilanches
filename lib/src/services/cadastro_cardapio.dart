import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:unilanches/src/models/produto_model.dart'; // Mantenha essa importação
import '../models/cadastro_cardapio.dart'
    show CardapioModel; // Mantenha essa importação

class CardapioApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/cardapios/';
  static const String produtosBaseUrl =
      'http://127.0.0.1:8000/api/produtos/';

  // Buscar cardápio do dia
  Future<CardapioModel?> buscarCardapioDoDia() async {
    try {
      final hoje = DateTime.now().toIso8601String().split('T').first;
      final response = await http.get(
        Uri.parse(
          "$baseUrl?data=$hoje",
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          return CardapioModel.fromJson(data[0]);
        } else if (data is Map &&
            data['results'] is List &&
            data['results'].isNotEmpty) {
          return CardapioModel.fromJson(data['results'][0]);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cardápio: $e');
    }
  }

  // --- NOVO MÉTODO A SER INSERIDO AQUI ---
  // Buscar cardápios por uma lista de IDs (para filtrar no frontend)
  Future<List<CardapioModel>> buscarCardapiosPorIds(
    List<int> cardapioIds,
  ) async {
    try {
      if (cardapioIds.isEmpty) {
        return []; // Retorna lista vazia se nenhum ID for fornecido
      }
      final idsString = cardapioIds.join(','); // Transforma [20, 19] em "20,19"
      final response = await http.get(
        Uri.parse(
          '$baseUrl?ids=$idsString',
        ), // Chama a API com o parâmetro de IDs
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(response.body);
        // Mapeia os dados JSON para uma lista de CardapioModel
        return dados
            .map((json) => CardapioModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
        'Erro ao carregar cardápios por IDs: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Erro ao buscar cardápios por IDs: $e');
    }
  }
  // --- FIM DO NOVO MÉTODO ---

  // Buscar produtos do cardápio (movido para usar produtosBaseUrl)
  Future<List<ProdutoModel>> buscarProdutosDoCardapio(
    List<int> produtoIds,
  ) async {
    try {
      final idsString = produtoIds.join(',');
      final response = await http.get(
        Uri.parse(
          '$produtosBaseUrl?ids=$idsString',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(response.body);
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
