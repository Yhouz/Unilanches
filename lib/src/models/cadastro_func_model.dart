class CadastroFuncModel {
  final String nome;
  final String senha;
  final String email;
  final String cpf;
  final String telefone;
  final String cargo;
  final String tipoUsuario;

  CadastroFuncModel({
    required this.nome,
    required this.senha,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.cargo,
    required this.tipoUsuario,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'senha': senha,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'cargo': cargo,
      'tipoUsuario': tipoUsuario,
    };
  }
}
