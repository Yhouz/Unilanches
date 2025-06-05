class RegisterModel {
  final String nome;
  final String email;
  final String senha;
  final String cpf;
  final String telefone;
  final String tipoUsuario;

  RegisterModel({
    required this.nome,
    required this.email,
    required this.senha,
    required this.cpf,
    required this.telefone,
    required this.tipoUsuario,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
      'cpf': cpf,
      'telefone': telefone,
      'tipo_usuario': tipoUsuario,
    };
  }
}
