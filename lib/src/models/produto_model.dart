class ProdutoModel {
  int? id;
  String nome;
  String? descricao;
  double preco;
  int quantidadeEstoque;
  String categoria;
  String custo;
  String margem;
  String unidade;

  ProdutoModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.quantidadeEstoque,
    required this.categoria,
    required this.custo,
    required this.margem,
    required this.unidade,
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
      'custo': custo,
      'margem': margem,
      'unidade': unidade,
    };
  }
}
