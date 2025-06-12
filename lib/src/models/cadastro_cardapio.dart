class CardapioModel {
  final String nome;
  final String categoria;
  final String data; // string ISO YYYY-MM-DD
  final List<int> produtos;

  CardapioModel({
    required this.nome,
    required this.categoria,
    required this.data,
    required this.produtos,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'categoria': categoria,
    'data': data,
    'produtos': produtos,
  };
}
