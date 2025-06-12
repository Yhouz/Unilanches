class CardapioModel {
  final int? id;
  final String nome;
  final String categoria;
  final String data;
  final List<int> produtos;
  final String? imagemUrl; // URL da imagem do cardápio

  CardapioModel({
    this.id,
    required this.nome,
    required this.categoria,
    required this.data,
    required this.produtos,
    this.imagemUrl,
  });

  factory CardapioModel.fromJson(Map<String, dynamic> json) => CardapioModel(
    id: json['id'],
    nome: json['nome'],
    categoria: json['categoria'],
    data: json['data'],
    produtos: List<int>.from(json['produtos']),
    imagemUrl: json['imagem'],
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'categoria': categoria,
    'data': data,
    'produtos': produtos,
    if (imagemUrl != null) 'imagem': imagemUrl,
  };
}
