import 'item_carrinho_model.dart';
// Certifique-se que este import está correto para onde ProdutoModel está

class CarrinhoModel {
  final int id;
  final int usuarioId;
  final String criadoEm;
  final String atualizadoEm;
  final bool finalizado;
  final List<ItemCarrinhoModel> itens;
  final int totalItens;
  final double totalValor;

  CarrinhoModel({
    required this.id,
    required this.usuarioId,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.finalizado,
    required this.itens,
    required this.totalItens,
    required this.totalValor,
  });

  factory CarrinhoModel.fromJson(Map<String, dynamic> json) {
    // Torna a leitura de 'itens' mais robusta:
    // Se 'itens' não existir ou não for uma lista, ele assume uma lista vazia.
    var itensList =
        (json['itens'] is List)
            ? (json['itens'] as List)
                .map((item) => ItemCarrinhoModel.fromJson(item))
                .toList()
            : <
              ItemCarrinhoModel
            >[]; // Garante que seja uma lista vazia se for nulo ou não for uma lista

    // Garante que 'total_itens' e 'total_valor' são lidos corretamente,
    // com valores padrão de 0 caso não existam ou sejam nulos.
    // O '?? 0' fornece um fallback.
    final int parsedTotalItens = json['total_itens'] ?? 0;
    final double parsedTotalValor =
        (json['total_valor'] as num?)?.toDouble() ?? 0.0;

    return CarrinhoModel(
      id: json['id'],
      usuarioId:
          json['usuario'], // O backend envia 'usuario' para o ID do usuário
      criadoEm: json['criado_em'],
      atualizadoEm: json['atualizado_em'],
      finalizado: json['finalizado'],
      itens: itensList,
      totalItens: parsedTotalItens,
      totalValor: parsedTotalValor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuarioId,
      'finalizado': finalizado,
      // Obs: Normalmente no POST você não precisa enviar itens, eles são adicionados separadamente
      // 'criado_em': criadoEm, // Não precisa enviar em toJson para criar/atualizar
      // 'atualizado_em': atualizadoEm, // Não precisa enviar em toJson para criar/atualizar
      // 'total_itens': totalItens, // Calculado no backend
      // 'total_valor': totalValor, // Calculado no backend
    };
  }
}
