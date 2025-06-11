class CadastrarFornecedorModel {
  // String? id; // ID opcional (gerado pelo backend ou Firebase)
  String nome;
  String cnpj;
  String email;
  String? telefone;
  String? celular;
  String? endereco;
  String? cidade;
  String? estado; // Sigla do estado (ex: MG)
  String? cep;
  String? contato;
  bool ativo;
  DateTime? dataCadastro;
  String? observacoes;

  CadastrarFornecedorModel({
    //this.id,
    required this.nome,
    required this.cnpj,
    required this.email,
    this.telefone,
    this.celular,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.contato,
    this.ativo = true,
    this.dataCadastro,
    this.observacoes,
  });

  // Conversão de JSON para objeto Dart
  factory CadastrarFornecedorModel.fromJson(Map<String, dynamic> json) {
    return CadastrarFornecedorModel(
      // id: json['id'],
      nome: json['nome'],
      cnpj: json['cnpj'],
      email: json['email'],
      telefone: json['telefone'],
      celular: json['celular'],
      endereco: json['endereco'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
      contato: json['contato'],
      ativo: json['ativo'] ?? true,
      dataCadastro:
          json['data_cadastro'] != null
              ? DateTime.parse(json['data_cadastro'])
              : null,
      observacoes: json['observacoes'],
    );
  }

  // Conversão de objeto Dart para JSON
  Map<String, dynamic> toJson() {
    return {
      // if (id != null) 'id': id, // envia só se tiver id
      'nome': nome,
      'cnpj': cnpj,
      'email': email,
      'telefone': telefone,
      'celular': celular,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'contato': contato,
      'ativo': ativo,
      'data_cadastro': dataCadastro?.toIso8601String(),
      'observacoes': observacoes,
    };
  }
}
