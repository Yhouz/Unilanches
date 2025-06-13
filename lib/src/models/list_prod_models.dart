class ProdutoListModel {
  final int id; // ✅ Adicionado
  final String nome;
  final String descricao;
  final double preco;
  final int quantidadeEstoque;

  ProdutoListModel({
    required this.id, // ✅ Adicionado
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.quantidadeEstoque,
  });

  factory ProdutoListModel.fromJson(Map<String, dynamic> json) {
    return ProdutoListModel(
      id: json['id'], // ✅ Pega o ID vindo do backend
      nome: json['nome'],
      descricao: json['descricao'],
      preco: double.parse(json['preco'].toString()),
      quantidadeEstoque: int.parse(json['quantidadeEstoque'].toString()),
    );
  }
}
