// lib/src/models/pedido_models.dart

// ignore_for_file: non_constant_identifier_names

import 'package:unilanches/src/models/item_carrinho_model.dart'; // Importa para usar na lista de itens

class PedidoModel {
  // ✅ CORREÇÃO: Campos de ID alterados de 'String' para 'int'.
  final int pedido_id;
  final int usuario;
  final int carrinho;

  final DateTime data_pedido;
  final String status_pedido;
  final double total;
  final String? qr_code_pedido;
  final List<ItemCarrinhoModel> itens;
  final int total_itens;
  final double total_valor;

  PedidoModel({
    required this.pedido_id,
    required this.usuario,
    required this.carrinho,
    required this.data_pedido,
    required this.status_pedido,
    required this.total,
    this.qr_code_pedido,
    required this.itens,
    required this.total_itens,
    required this.total_valor,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    // Mapeia a lista de itens do JSON para uma lista de objetos ItemCarrinhoModel
    var itensFromJson = json['itens'] as List? ?? [];
    List<ItemCarrinhoModel> itensList =
        itensFromJson.map((i) => ItemCarrinhoModel.fromJson(i)).toList();

    return PedidoModel(
      // ✅ CORREÇÃO: Garante que os valores sejam lidos como os tipos corretos.
      pedido_id: json['pedido_id'] as int,
      usuario: json['usuario'] as int,
      carrinho: json['carrinho'] as int,

      // Converte a string de data do JSON para um objeto DateTime do Dart
      data_pedido: DateTime.parse(json['data_pedido']),

      status_pedido: json['status_pedido'] as String,

      // Converte o total, que pode vir como String, para double.
      total: double.parse(json['total'].toString()),

      qr_code_pedido: json['qr_code_pedido'] as String?,

      itens: itensList,
      total_itens: json['total_itens'] as int,

      // Converte o total_valor, que pode vir como String ou int, para double.
      total_valor: double.parse(json['total_valor'].toString()),
    );
  }

  int get id => pedido_id;
}
