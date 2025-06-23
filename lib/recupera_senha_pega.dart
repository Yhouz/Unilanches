// lib/src/pages/RecuperarSenhaPage.dart
import 'dart:convert' show jsonDecode; // Importa apenas a função jsonDecode do pacote 'dart:convert'
import 'package:flutter/material.dart'; // Importa o pacote essencial do Flutter para UI
import 'package:unilanches/src/services/RecuperarSenha.dart'; // Importa sua classe de API
import 'package:http/http.dart' as http; // Importa o pacote http para usar o tipo Response

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  _RecuperarSenhaPageState createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  // Controladores para pegar o texto digitado nos campos de email e senha
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Variável para armazenar e exibir mensagens de feedback ao usuário (sucesso, erro, etc.)
  String mensagem = '';
  // Flag para controlar o estado de carregamento do botão (mostra/esconde o indicador de progresso)
  bool _isLoading = false;

  /// Função assíncrona que é chamada quando o botão "Alterar Senha" é pressionado.
  /// Ela lida com a validação de entrada, chamada da API e tratamento da resposta.
  Future<void> enviarRecuperacao() async {
    // Pega o texto dos campos de entrada e remove espaços em branco extras.
    String email = _emailController.text.trim();
    String novaSenha = _senhaController.text.trim();

    // 1. Validação inicial: verifica se os campos estão vazios.
    if (email.isEmpty || novaSenha.isEmpty) {
      setState(() {
        mensagem = 'Por favor, preencha todos os campos!';
      });
      return; // Interrompe a execução se os campos estiverem vazios.
    }

    // 2. Define o estado de carregamento e limpa mensagens anteriores.
    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento.
      mensagem = ''; // Limpa qualquer mensagem antiga.
    });

    try {
      // 3. Instancia a classe de serviço da API.
      var api = RecuperarSenhaApi();
      // 4. Faz a chamada à API e aguarda a resposta.
      // O 'response' será um objeto http.Response, conforme definido na sua API.
      http.Response response = await api.recuperarSenha(email, novaSenha);

      // 5. Trata a resposta da API com base no código de status HTTP.
      if (response.statusCode == 200) {
        // Se o status for 200 (OK), a operação foi um sucesso.
        setState(() {
          mensagem = 'Senha alterada com sucesso!';
          // Opcional: Limpa os campos após a alteração bem-sucedida.
          _emailController.clear();
          _senhaController.clear();
        });
      } else {
        // Se o status não for 200, houve um erro da API.
        // Tenta decodificar o corpo da resposta, que deve ser um JSON com a mensagem de erro.
        var respostaJson = jsonDecode(response.body);
        setState(() {
          // Define a mensagem de erro. A API deve retornar um JSON com uma chave 'erro'.
          // Se 'erro' não existir, usa uma mensagem genérica.
          mensagem = respostaJson['erro'] ?? 'Erro ao atualizar senha. Por favor, tente novamente.';
        });
      }
    } catch (e) {
      // 6. Captura exceções (erros) que podem ocorrer durante a chamada da API
      // (ex: problema de rede, servidor offline, exceção lançada pelo 'throw Exception' na API).
      setState(() {
        mensagem = 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.';
      });
    } finally {
      // 7. Este bloco é executado SEMPRE, independentemente de sucesso ou erro.
      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        centerTitle: true, // Centraliza o título na barra de aplicativo.
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Adiciona preenchimento em toda a volta do conteúdo.
        child: Column(
          // Centraliza os elementos verticalmente na tela.
          mainAxisAlignment: MainAxisAlignment.center,
          // Estica os elementos horizontalmente para preencher a largura disponível.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Altere sua senha',
              // Estiliza o texto para ser um título com fonte maior e negrito.
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // Centraliza o texto.
            ),
            const SizedBox(height: 30), // Espaço vertical entre o título e o primeiro campo.

            // Campo de entrada para o Email.
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress, // Mostra o teclado otimizado para e-mails.
              decoration: InputDecoration(
                labelText: 'Email', // Rótulo acima do campo.
                hintText: 'Digite seu email', // Texto de dica dentro do campo.
                border: OutlineInputBorder( // Adiciona uma borda arredondada ao redor do campo.
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.email), // Ícone de e-mail dentro do campo.
              ),
            ),
            const SizedBox(height: 20), // Espaço entre o campo de email e o de senha.

            // Campo de entrada para a Nova Senha.
            TextField(
              controller: _senhaController,
              obscureText: true, // Esconde o texto digitado (para senhas).
              decoration: InputDecoration(
                labelText: 'Nova Senha',
                hintText: 'Crie sua nova senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.lock), // Ícone de cadeado.
              ),
            ),
            const SizedBox(height: 30), // Espaço antes do botão de ação.

            // Exibe um indicador de carregamento ou o botão, dependendo do estado.
            _isLoading
                ? const Center(child: CircularProgressIndicator()) // Mostra uma bolinha de carregamento.
                : ElevatedButton(
                    onPressed: enviarRecuperacao, // Chama a função quando o botão é clicado.
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15.0), // Aumenta o tamanho do botão.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Cantos arredondados para o botão.
                      ),
                      elevation: 5, // Adiciona uma pequena sombra para um efeito 3D.
                    ),
                    child: const Text(
                      'Alterar Senha',
                      style: TextStyle(fontSize: 18), // Aumenta o tamanho da fonte do texto do botão.
                    ),
                  ),
            const SizedBox(height: 15), // Espaço abaixo do botão.

            // Exibe a mensagem de feedback (sucesso ou erro) ao usuário.
            if (mensagem.isNotEmpty) // Só mostra o Text se a mensagem não estiver vazia.
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: TextStyle(
                  // A cor do texto muda para verde em caso de sucesso, vermelho em caso de erro.
                  color: mensagem.contains('sucesso') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold, // Deixa a mensagem em negrito.
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}