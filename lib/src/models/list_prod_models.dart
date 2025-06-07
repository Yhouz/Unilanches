class ProdutoListModel {
  final String nome;
  final String descricao;
  final double preco;

  ProdutoListModel({
    required this.nome,
    required this.descricao,
    required this.preco,
  });

  factory ProdutoListModel.fromJson(Map<String, dynamic> json) {
    return ProdutoListModel(
      nome: json['nome'],
      descricao: json['descricao'],
      preco: double.parse(json['preco'].toString()),
    );
  }
}
