class EditProdModel {
  int id;
  String nome;
  String? descricao;
  double preco;

  EditProdModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
  });

  factory EditProdModel.fromJson(Map<String, dynamic> json) {
    return EditProdModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: (json['preco'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
    };
  }
}
