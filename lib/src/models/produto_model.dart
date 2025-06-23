class ProdutoModel {
  final int? id;
  final String nome;
  final String? descricao;
  final double preco;
  final int quantidadeEstoque;
  final String? categoria;
  final String? custo;
  final String? margem;
  final String? unidade;
  final String? imagem;

  ProdutoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.quantidadeEstoque,
    this.categoria,
    this.custo,
    this.margem,
    this.unidade,
    this.imagem,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json["id"] as int?,
      nome: json["nome"] as String,
      descricao: json["descricao"] as String?,
      // LINHA CORRIGIDA AQUI:
      preco: double.parse(json["preco"].toString()),
      quantidadeEstoque: json["quantidade_estoque"] as int,
      categoria: json["categoria"] as String?,
      custo: json["custo"] as String?,
      margem: json["margem"] as String?,
      unidade: json["unidade"] as String?,
      imagem: json["imagem"] as String?,
    );
  }

  get imagemUrl => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'quantidade_estoque': quantidadeEstoque,
      'categoria': categoria,
      'custo': custo,
      'margem': margem,
      'unidade': unidade,
      'imagem': imagem,
    };
  }
}
