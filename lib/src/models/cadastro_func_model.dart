class CadastroFuncModel {
  final String nome;
  final String senha;
  final String email;
  final String cpf;
  final String telefone;
  final String cargo;
  final String tipoUsuario;
  final String dtAdmissao;
  final String dtNascimento;
  final String salario;
  final String endereco;
  final String numero;
  final String uf;
  final String cidade;

  CadastroFuncModel({
    required this.nome,
    required this.senha,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.cargo,
    required this.tipoUsuario,
    required this.dtAdmissao,
    required this.dtNascimento,
    required this.salario,
    required this.endereco,
    required this.numero,
    required this.uf,
    required this.cidade,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'senha': senha,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'cargo': cargo,
      'tipo_usuario': tipoUsuario,
      'dt_admissao': dtAdmissao,
      'dt_nascimento': dtNascimento,
      'salario': salario,
      'endereco': endereco,
      'numero': numero,
      'uf': uf,
      'cidade': cidade,
    };
  }
}
