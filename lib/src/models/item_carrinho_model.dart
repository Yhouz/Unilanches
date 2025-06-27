// lib/src/models/item_carrinho_model.dart

import 'package:unilanches/src/models/produto_model.dart' show ProdutoModel;

class ItemCarrinhoModel {
  final int
  id; // Este ID deve ser o ID do item do pedido no banco de dados, se for persistido.
  final ProdutoModel produto;
  final int quantidade;
  final double valorItem; // Este é o subtotal do item no pedido

  ItemCarrinhoModel({
    required this.id,
    required this.produto,
    required this.quantidade,
    required this.valorItem,
  });

  factory ItemCarrinhoModel.fromJson(Map<String, dynamic> json) {
    return ItemCarrinhoModel(
      id: json['id'] as int, // ✅ Garante que o ID do item é um int
      produto: ProdutoModel.fromJson(
        json['produto'],
      ), // ✅ Mapeia o produto aninhado
      quantidade:
          json['quantidade'] as int, // ✅ Garante que a quantidade é um int
      valorItem:
          (json['subtotal'] as num)
              .toDouble(), // ✅ Converte para double de forma segura
    );
  }

  // Este método toJson é para quando você CRIA um pedido (envia para o backend).
  // Ele não precisa ser alterado para a tela de detalhes.
  Map<String, dynamic> toJson() {
    return {
      'produto_id': produto.id,
      'quantidade': quantidade,
    };
  }
}
