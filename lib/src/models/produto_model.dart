class ProdutoModel {
  int? id;
  String nome;
  String? descricao;
  double preco;
  int quantidadeEstoque;
  String categoria;

  ProdutoModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.quantidadeEstoque,
    required this.categoria,
  });

  // Converte objeto ProdutoModel para JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'quantidade_estoque': quantidadeEstoque,
      'categoria': categoria,
    };
  }
}
