class EditProdModel {
  final int id; // Ou int? se o id puder ser nulo em algum contexto
  final String nome;
  final double preco;
  final int quantidadeEstoque;
  // Talvez falte a descrição aqui se a API de edição precisar dela
  // final String? descricao; // Adicione se necessário
  // ... outros campos que a API de edição possa exigir

  EditProdModel({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidadeEstoque,
    // this.descricao, // Adicione no construtor se adicionou acima
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'quantidadeEstoque': quantidadeEstoque,
      // 'descricao': descricao, // Inclua no JSON se adicionou
      // ... inclua todos os campos que a sua API de edição espera no body da requisição
    };
  }
}
