import 'dart:typed_data'; // Para Uint8List
import 'package:http/http.dart'
    as http; // Para requisições HTTP, incluindo MultipartRequest
// Para codificação/decodificação JSON
import 'package:unilanches/src/models/produto_model.dart'; // Verifique se este caminho está correto

class ProdutoApi {
  // Use 10.0.2.2 para Emulador Android, localhost para web, ou o IP da sua máquina para dispositivo físico
  // final String baseUrl = 'http://10.0.2.2:8000/api/produtos/'; // Para Emulador Android
  final String baseUrl =
      'http://127.0.0.1:8000/api/produtos/'; // Para Web ou máquina local

  Future<String?> cadastrarProduto(
    ProdutoModel produto,
    Uint8List
    imagemBytes, // Agora é um argumento posicional obrigatório para os dados da imagem
    String
    nomeArquivo, // Agora é um argumento posicional obrigatório para o nome do arquivo da imagem
  ) async {
    final url = Uri.parse('${baseUrl}cadastrar/');

    // Use MultipartRequest para enviar arquivos junto com outros dados de formulário
    var request = http.MultipartRequest('POST', url);

    // Adicione os campos de texto do ProdutoModel
    request.fields['nome'] = produto.nome;
    request.fields['descricao'] = produto.descricao!;
    request.fields['preco'] =
        produto.preco.toString(); // Converta double para string
    request.fields['quantidade_estoque'] =
        produto.quantidadeEstoque.toString(); // Converta int para string
    request.fields['categoria'] = produto.categoria!;
    request.fields['custo'] =
        produto.custo ?? ''; // Lida com possíveis valores nulos
    request.fields['margem'] =
        produto.margem ?? ''; // Lida com possíveis valores nulos
    request.fields['unidade'] = produto.unidade!;

    // Adicione o arquivo da imagem como um MultipartFile
    request.files.add(
      http.MultipartFile.fromBytes(
        'imagem', // Esta chave 'imagem' DEVE corresponder ao nome que seu backend Django espera para o arquivo de imagem (ex: request.FILES['imagem'])
        imagemBytes,
        filename: nomeArquivo,
      ),
    );

    try {
      // Envie a requisição
      final streamedResponse = await request.send();
      // Leia a resposta
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Sucesso! Produto criado. Você pode querer analisar o corpo da resposta
        // se seu backend retornar os dados do produto criado.

        return null; // Retorna null para indicar sucesso, conforme sua lógica atual
      } else {
        // Lida com erros baseados no código de status

        // Você pode querer retornar o corpo do erro ou uma mensagem de erro específica
        return response.body; // Retorna a mensagem de erro do backend
      }
    } catch (e) {
      // Captura erros de rede ou outros erros inesperados

      throw Exception('Erro ao registrar produto: $e');
    }
  }
}
