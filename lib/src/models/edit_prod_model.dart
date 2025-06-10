class EditProdModel {
  final int id;
  final String nome;
  final double preco;

  EditProdModel({
    required this.id,
    required this.nome,
    required this.preco,
  });

  factory EditProdModel.fromJson(
    Map<String, dynamic> json, {
    required int idAntigo,
  }) {
    return EditProdModel(
      id: json['id'] ?? idAntigo,
      nome: json['nome'] ?? '',
      preco: double.tryParse(json['preco'].toString()) ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
    };
  }
}
