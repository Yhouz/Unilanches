class RegisterModel {
  final String? name;
  final String? email;
  final String? cpf;
  final String? telefone;
  final String? senha;
  final String? tipoUsuario;

  RegisterModel({
    this.name,
    this.email,
    this.cpf,
    this.telefone,
    this.senha,
    this.tipoUsuario,
  });

  // 🔥 Construtor de fábrica dentro da classe
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      name: json['name'],
      email: json['email'],
      cpf: json['cpf'],
      telefone: json['telefone'],
      senha: json['senha'], // Estava faltando no seu
      tipoUsuario: json['tipo_usuario'],
    );
  }

  // 🔥 Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'senha': senha,
      'tipo_usuario': tipoUsuario,
    };
  }
}
