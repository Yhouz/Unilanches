import 'package:unilanches/src/models/produto_model.dart' show ProdutoModel;

class ItemCarrinhoModel {
  final int id;
  final ProdutoModel produto;
  final int quantidade;
  final double subtotal;

  ItemCarrinhoModel({
    required this.id,
    required this.produto,
    required this.quantidade,
    required this.subtotal,
  });

  factory ItemCarrinhoModel.fromJson(Map<String, dynamic> json) {
    return ItemCarrinhoModel(
      id: json['id'],
      produto: ProdutoModel.fromJson(json['produto']),
      quantidade: json['quantidade'],
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  // Apenas para serializar para envio ao backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produto_id': produto.id,
      'quantidade': quantidade,
    };
  }
}
