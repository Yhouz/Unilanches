class ItemPedidoModel {
  final String? pedido_id;
  final String produto_id;
  final int quantidade;
  final double valor_item;

  ItemPedidoModel({
    required this.pedido_id,
    required this.produto_id,
    required this.quantidade,
    required this.valor_item,
  });

  factory ItemPedidoModel.fromJson(Map<String, dynamic> json) {
    return ItemPedidoModel(
      pedido_id: json['pedido_id'],
      produto_id: json['produto_id'],
      quantidade: json['quantidade'],
      valor_item: json['valor_item'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pedido_id': pedido_id,
      'produto_id': produto_id,
      'quantidade': quantidade,
      'valor_item': valor_item,
    };
  }
}
