import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:unilanches/src/models/cadastro_cardapio.dart';
import 'package:unilanches/src/services/cadastro_cardapio.dart';
import 'package:unilanches/src/services/list_prod.dart';

class CadastroCardapioPage extends StatefulWidget {
  const CadastroCardapioPage({super.key});

  @override
  _CadastroCardapioPageState createState() => _CadastroCardapioPageState();
}

class _CadastroCardapioPageState extends State<CadastroCardapioPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  DateTime? _dataSelecionada;

  final List<Map<String, dynamic>> _produtos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    try {
      final produtosApi = await ProdutoListApi().listarProdutos();

      setState(() {
        _produtos.clear();
        for (var produto in produtosApi) {
          _produtos.add({
            'id': produto.id,
            'nome': produto.nome,
            'preco': produto.preco,
            'selecionado': false,
            'imagem': null,
          });
        }
        _carregando = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produtos: $e')),
      );
      setState(() => _carregando = false);
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  Future<void> _escolherImagemWeb(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _produtos[index]['imagem'] = result.files.single.bytes;
      });
    }
  }

  void _salvarCardapio() async {
    if (_formKey.currentState!.validate() && _dataSelecionada != null) {
      final nome = _nomeController.text;
      final categoria = _categoriaController.text;
      // Convertendo DateTime para string YYYY-MM-DD
      final data = _dataSelecionada!.toIso8601String().split('T').first;

      // Pegar só os IDs dos produtos selecionados
      final produtosSelecionados =
          _produtos
              .where((p) => p['selecionado'] == true)
              .map<int>((p) => p['id'] as int)
              .toList();

      if (produtosSelecionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecione ao menos um produto')),
        );
        return;
      }

      final novoCardapio = CardapioModel(
        nome: nome,
        categoria: categoria,
        data: data,
        produtos: produtosSelecionados,
      );

      try {
        final response = await CardapioApi().criarCardapio(novoCardapio);

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cardápio salvo com sucesso!')),
          );

          // Limpar o formulário após salvar
          _nomeController.clear();
          _categoriaController.clear();
          setState(() {
            _dataSelecionada = null;
            for (var produto in _produtos) {
              produto['selecionado'] = false;
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar cardápio: ${response.statusCode}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar cardápio: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos e selecione a data')),
      );
    }
  }

  void _mostrarImagem(dynamic imagem) {
    if (imagem == null) return;

    if (imagem is String) {
      // imagem é URL
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              content: Image.network(imagem),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fechar'),
                ),
              ],
            ),
      );
    } else if (imagem is Uint8List) {
      // imagem é bytes (ex: carregada da memória)
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              content: Image.memory(imagem),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fechar'),
                ),
              ],
            ),
      );
    } else {
      // Outro tipo, pode só ignorar ou mostrar erro
      print('Tipo de imagem desconhecido: ${imagem.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Cardápio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome do Cardápio'),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(labelText: 'Categoria'),
                validator:
                    (value) => value!.isEmpty ? 'Informe a categoria' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _dataSelecionada == null
                        ? 'Nenhuma data selecionada'
                        : 'Data: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}',
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _selecionarData(context),
                    child: Text('Selecionar Data'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child:
                    _carregando
                        ? Center(child: CircularProgressIndicator())
                        : _produtos.isEmpty
                        ? Center(child: Text('Nenhum produto encontrado.'))
                        : ListView.builder(
                          itemCount: _produtos.length,
                          itemBuilder: (context, index) {
                            final produto = _produtos[index];
                            return Card(
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap:
                                      () => _mostrarImagem(produto['imagem']),
                                  child:
                                      produto['imagem'] == null
                                          ? Icon(Icons.image_not_supported)
                                          : produto['imagem'] is String
                                          ? Image.network(
                                            produto['imagem'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                          : produto['imagem'] is Uint8List
                                          ? Image.memory(
                                            produto['imagem'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                          : Icon(Icons.error),
                                ),
                                title: Text(produto['nome']),
                                subtitle: Text('R\$ ${produto['preco']}'),
                                trailing: Checkbox(
                                  value: produto['selecionado'],
                                  onChanged: (value) {
                                    setState(() {
                                      produto['selecionado'] = value!;
                                    });
                                  },
                                ),
                                onTap: () => _escolherImagemWeb(index),
                              ),
                            );
                          },
                        ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _salvarCardapio,
                    child: Text('Salvar Cardápio'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
