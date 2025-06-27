import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:unilanches/src/models/produto_model.dart'; // Mantenha essa importação
import '../models/cadastro_cardapio.dart'
    show CardapioModel; // Mantenha essa importação

class CardapioApiService {
  static const String baseUrl = 'https://api-a35y.onrender.com/api/cardapios/';
  static const String produtosBaseUrl =
      'https://api-a35y.onrender.com/api/produtos/';

  // Buscar cardápio do dia
  Future<CardapioModel?> buscarCardapioDoDia() async {
    try {
      final hoje = DateTime.now().toIso8601String().split('T').first;

      // ✅ CORREÇÃO AQUI: Remova o '/cardapios/' duplicado
      // A URL final deve ser '$baseUrl$hoje/dia/' ou usar Uri.resolve
      final response = await http.get(
        Uri.parse(
          '$baseUrl$hoje/dia/',
        ), // Isso gerará: https://api-a35y.onrender.com/api/cardapios/2025-06-27/dia/
        headers: {'Content-Type': 'application/json'},
      );

      print('Chamando API de cardápios com URL: ${response.request?.url}');
      print(
        'Resposta do Cardápio (Status ${response.statusCode}): ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          return CardapioModel.fromJson(data);
        }

        print(
          'DEBUG: Formato de resposta do cardápio inesperado: $data',
        );
        return null;
      } else if (response.statusCode == 404) {
        print('Nenhum cardápio encontrado para hoje: ${response.body}');
        return null;
      } else {
        throw Exception(
          'Erro ao buscar cardápio do dia: Status ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erro de rede/comunicação ao buscar cardápio: $e');
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
      if (produtoIds.isEmpty) {
        return []; // Retorna uma lista vazia se não houver IDs para buscar
      }

      final idsString = produtoIds.join(','); // Ex: "8,9"

      // A CORREÇÃO ESTÁ AQUI: Incluindo '/listar/' na URL
      // Agora a URL será: 'https://api-a35y.onrender.com/api/produtos/listar/?ids=8,9'
      final uri = Uri.parse(
        produtosBaseUrl,
      ).resolve('listar/').replace(queryParameters: {'ids': idsString});

      print('Chamando API de produtos com URL: $uri'); // Útil para depuração!

      final response = await http.get(
        uri, // Usando a Uri construída corretamente
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(response.body);
        return dados
            .map((json) => ProdutoModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        print("Erro do backend (400): ${errorData['message']}");
        throw Exception('Erro de requisição: ${errorData['message']}');
      } else if (response.statusCode == 404) {
        print("Nenhum produto encontrado para os IDs fornecidos (404).");
        return [];
      } else {
        throw Exception(
          'Erro ao carregar produtos: Status ${response.statusCode}, Body: ${response.body}',
        );
      }
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
