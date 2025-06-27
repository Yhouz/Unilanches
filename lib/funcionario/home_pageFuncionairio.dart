import 'package:flutter/material.dart';
import 'package:unilanches/Login_page.dart';
import 'package:unilanches/funcionario/cadastrar_cardapio.dart';
import 'package:unilanches/funcionario/cadastro_fornecedor.dart';
import 'package:unilanches/funcionario/cadastro_funcionario.dart';
import 'package:unilanches/funcionario/cadastro_produto.dart';
import 'package:unilanches/funcionario/list_prod.dart';
import 'package:unilanches/funcionario/vendas.dart';
import 'package:unilanches/funcionario/confirma_pedido.dart';

class HomePageFuncionario extends StatefulWidget {
  final String nome;
  const HomePageFuncionario({super.key, required this.nome});

  @override
  State<HomePageFuncionario> createState() => _HomePageFuncionarioState();
}

class _HomePageFuncionarioState extends State<HomePageFuncionario> {
  // Função auxiliar para criar os botões e evitar repetição de código
  Widget _buildGridButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tela Funcionário',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 127, 243),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Ação do botão de configurações
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // AQUI ESTÁ A MUDANÇA PARA DEIXAR O LAYOUT RESPONSIVO
        child: GridView.extent(
          maxCrossAxisExtent: 250.0, // Define a largura máxima de cada item
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildGridButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastroFuncionario(),
                  ),
                );
              },
              icon: Icons.person_add,
              label: 'Cadastro Funcionário',
            ),
            _buildGridButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastroProduto(),
                  ),
                );
              },
              icon: Icons.add_shopping_cart,
              label: 'Cadastro Produto',
            ),
            _buildGridButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastroFornecedor(),
                  ),
                );
              },
              icon: Icons.group_add,
              label: 'Cadastro Fornecedor',
            ),
            _buildGridButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListProd()),
                );
              },
              icon: Icons.list,
              label: 'Lista Produtos',
            ),
            _buildGridButton(
              onPressed: () {
                // Assumindo que a classe se chama CadastroCardapioAprimoradoPage
                // Se o nome for outro, ajuste aqui.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CadastroCardapioAprimoradoPage(),
                  ),
                );
              },
              icon: Icons.menu_book,
              label: 'Cadastrar Cardápio',
            ),
            _buildGridButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Vendas()),
                );
              },
              icon: Icons.point_of_sale,
              label: 'Vendas',
            ),
            _buildGridButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfirmaPedido(),
                  ),
                );
              },
              icon: Icons.check,
              label: 'Confirmar Pedido',
            ),
          ],
        ),
      ),
    );
  }
}
