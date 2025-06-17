import 'package:flutter/material.dart';
import 'package:unilanches/src/services/list_prod.dart';
import 'package:unilanches/src/models/edit_prod_model.dart';
import '../src/models/produto_model.dart' show ProdutoModel;
import '../src/services/delete_prod.dart';
import '../src/services/edit_prod.dart';

class ListProd extends StatefulWidget {
  const ListProd({super.key});

  @override
  State<ListProd> createState() => _ListProdState();
}

class _ListProdState extends State<ListProd> {
  List<ProdutoModel> produtosApi = [];

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    try {
      final lista = await ProdutoListApi().listarProdutos();
      setState(() {
        produtosApi = lista;
      });
    } catch (e) {
      // É uma boa prática logar o erro para depuração, mesmo que não seja exibido para o usuário
      debugPrint('Erro ao carregar produtos: $e');
      // Opcional: mostrar um SnackBar ou Dialog para o usuário sobre o erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar produtos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _editeButtom(
    BuildContext context,
    EditProdModel produto,
    // A função onSalvar não está sendo utilizada no onPressed do botão "Salvar".
    // Se a intenção é que ela seja um callback após o sucesso da edição,
    // você pode reintroduzi-la ou removê-la se não for mais necessária.
    // Function(EditProdModel) onSalvar,
  ) {
    final nomeController = TextEditingController(text: produto.nome);
    final precoController = TextEditingController(
      text: produto.preco.toStringAsFixed(
        2,
      ), // Formata o preço para 2 casas decimais
    );
    final quantidadeEstoqueController = TextEditingController(
      text:
          produto.quantidadeEstoque
              .toString(), // **CORREÇÃO AQUI: Inicializa com o valor atual**
    );

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar Produto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: precoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Preço'),
              ),
              TextField(
                controller:
                    quantidadeEstoqueController, // Usando o controller correto
                keyboardType:
                    TextInputType
                        .number, // Geralmente estoque é um número inteiro
                decoration: const InputDecoration(
                  labelText: 'Quantidade Estoque',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  // Validação básica para evitar erros de parsing com campos vazios
                  if (nomeController.text.isEmpty ||
                      precoController.text.isEmpty ||
                      quantidadeEstoqueController.text.isEmpty) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, preencha todos os campos.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return; // Sai da função se houver campos vazios
                  }

                  try {
                    final double preco = double.parse(
                      precoController.text.replaceAll(',', '.'),
                    ); // Garante que a vírgula seja tratada como ponto decimal
                    final int quantidadeEstoque = int.parse(
                      quantidadeEstoqueController.text,
                    );

                    final novoProduto = EditProdModel(
                      id: produto.id,
                      nome: nomeController.text,
                      preco: preco,
                      quantidadeEstoque: quantidadeEstoque,
                    );

                    await ProdutoEditApi().editProd(
                      novoProduto,
                    );

                    await carregarProdutos(); // Recarrega a lista após a edição

                    // ignore: use_build_context_synchronously
                    Navigator.of(
                      context,
                    ).pop(true); // Retorna true indicando sucesso
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Erro ao salvar'),
                          content: Text(
                            'Não foi possível salvar o produto. Detalhes: ${e.toString()}',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Fechar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body:
          produtosApi.isEmpty
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Mostra CircularProgressIndicator se a lista estiver vazia e ainda carregando
              : ListView.builder(
                itemCount: produtosApi.length,
                itemBuilder: (context, index) {
                  final produto = produtosApi[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading:
                          (produto.imagem != null && produto.imagem!.isNotEmpty)
                              ? ClipRRect(
                                // Para arredondar as bordas da imagem
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  // ESCOLHA UMA DAS OPÇÕES ABAIXO, BASEADO ONDE SEU APP ESTÁ RODANDO:

                                  // OPÇÃO 1: Se estiver rodando no EMULADOR ANDROID
                                  // 'http://10.0.2.2:8000${produto.imagem}',

                                  // OPÇÃO 2: Se estiver rodando em DISPOSITIVO FÍSICO (Android/iOS)
                                  // Substitua 'SEU_IP_AQUI' pelo IP da sua máquina na rede local (ex: 192.168.1.100)
                                  //'http://SEU_IP_AQUI:8000${produto.imagem}',

                                  // OPÇÃO 3: Se estiver rodando no NAVEGADOR WEB (no mesmo PC que o Django)
                                  'http://127.0.0.1:8000${produto.imagem}', // Esta é a que estava antes
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                      'Erro ao carregar imagem: ${produto.imagem} - $error',
                                    );
                                    return const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 60,
                                    );
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                              : const Icon(
                                Icons.fastfood,
                                color: Colors.orange,
                                size: 60,
                              ), // Ícone padrão se não houver imagem
                      title: Text(
                        produto.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${produto.descricao} - R\$ ${produto.preco.toStringAsFixed(2)} | Estoque: ${produto.quantidadeEstoque}', // Adicionado Quantidade Estoque aqui também
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final mudou = await _editeButtom(
                                context,
                                EditProdModel(
                                  id: produto.id!,
                                  nome: produto.nome,
                                  preco: produto.preco,
                                  quantidadeEstoque: produto.quantidadeEstoque,
                                ),
                                // A função onSalvar foi removida daqui, pois não é utilizada no `_editeButtom`
                              );
                              if (mudou == true) {
                                await carregarProdutos(); // Recarrega a lista se a edição foi bem-sucedida
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text('Confirmar exclusão'),
                                      content: Text(
                                        'Deseja excluir o produto "${produto.nome}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.of(ctx).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(ctx).pop(true),
                                          child: const Text(
                                            'Excluir',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                try {
                                  await ProdDeletAPI().deletarProduto(
                                    produto.id!,
                                  );
                                  await carregarProdutos(); // Atualiza a lista após a exclusão
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Produto excluído com sucesso!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  // ignore: use_build_context_synchronously
                                  showDialog(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text('Erro ao excluir'),
                                          content: Text(
                                            'Não foi possível excluir o produto: ${e.toString()}',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(ctx).pop(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
