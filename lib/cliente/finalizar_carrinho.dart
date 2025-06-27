import 'package:flutter/material.dart';
import 'package:unilanches/cliente/qr_code_page_ger.dart' show QrCodeScreen;
// O import do CarrinhoService não é mais necessário aqui.
import 'package:unilanches/src/services/pedido_service.dart';
import 'package:unilanches/src/models/item_carrinho_model.dart';

// Enum para gerenciar as opções de pagamento
enum FormaPagamento { cartao, pix, boleto }

class FinalizarCarrinho extends StatefulWidget {
  final int carrinhoId;
  final double total;
  final List<ItemCarrinhoModel> itens;

  const FinalizarCarrinho({
    super.key,
    required this.carrinhoId,
    required this.total,
    required this.itens,
  });

  @override
  State<FinalizarCarrinho> createState() => _FinalizarCarrinhoState();
}

class _FinalizarCarrinhoState extends State<FinalizarCarrinho> {
  // A instância do CarrinhoService foi removida.
  final PedidoService _pedidoService = PedidoService();

  // Variáveis de estado
  FormaPagamento? _formaPagamentoSelecionada = FormaPagamento.pix;
  bool _isProcessing = false;

  // ✅ FUNÇÃO SIMPLIFICADA: Agora faz apenas uma chamada à API.
  Future<void> _processarPedido() async {
    if (_isProcessing) return;

    if (_formaPagamentoSelecionada == null) {
      _showErrorSnackBar('Por favor, selecione uma forma de pagamento.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Chama o serviço e AGUARDA o retorno com os dados do novo pedido
      final novoPedido = await _pedidoService.criarPedido(
        carrinhoId: widget.carrinhoId,
        total: widget.total,
        //formaPagamento: _formaPagamentoSelecionada!.name,
      );

      if (!mounted) return;

      // Verifica se o backend enviou os dados do QR Code
      if (novoPedido.qr_code_pedido != null &&
          novoPedido.qr_code_pedido!.isNotEmpty) {
        // NAVEGA para a tela do QR Code, passando os dados e limpando a pilha de telas
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder:
                (context) => QrCodeScreen(
                  // ✅ CORRIGIDO: Use o nome de parâmetro correto.
                  qrCodeData: novoPedido.qr_code_pedido!,
                ),
          ),
          (Route<dynamic> route) => route.isFirst,
        );
      } else {
        // Se, por algum motivo, não vier um QR code, mostra um sucesso e volta para a home
        _showSuccessSnackBar('Pedido realizado com sucesso!');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erro ao processar pedido: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar e Pagar'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Resumo do Pedido'),
            _buildOrderSummaryCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Endereço de Entrega'),
            _buildAddressCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Forma de Pagamento'),
            _buildPaymentOptions(),
            const SizedBox(height: 24),
            _buildTotalSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildCheckoutButton(),
    );
  }

  // ... (todos os seus métodos _build... não precisam de mudança)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itens.length,
          itemBuilder: (context, index) {
            final item = widget.itens[index];
            return ListTile(
              leading: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.orange,
              ),
              title: Text(item.produto.nome),
              subtitle: Text('Qtd: ${item.quantidade}'),
              trailing: Text(
                'R\$ ${(item.produto.preco * item.quantidade).toStringAsFixed(2)}',
              ),
            );
          },
          separatorBuilder:
              (context, index) => const Divider(indent: 16, endIndent: 16),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const ListTile(
        leading: Icon(Icons.location_on_outlined, color: Colors.orange),
        title: Text('Rua Exemplo, 123'),
        subtitle: Text('Bairro Centro, Cidade-UF, 12345-678'),
        trailing: Icon(Icons.edit_outlined, size: 20),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          RadioListTile<FormaPagamento>(
            title: const Text('Cartão de Crédito'),
            value: FormaPagamento.cartao,
            groupValue: _formaPagamentoSelecionada,
            onChanged: (FormaPagamento? value) {
              setState(() {
                _formaPagamentoSelecionada = value;
              });
            },
            secondary: const Icon(Icons.credit_card_outlined),
            activeColor: Colors.orange,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          RadioListTile<FormaPagamento>(
            title: const Text('Pix'),
            value: FormaPagamento.pix,
            groupValue: _formaPagamentoSelecionada,
            onChanged: (FormaPagamento? value) {
              setState(() {
                _formaPagamentoSelecionada = value;
              });
            },
            secondary: const Icon(Icons.pix_outlined),
            activeColor: Colors.orange,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          RadioListTile<FormaPagamento>(
            title: const Text('Boleto Bancário'),
            value: FormaPagamento.boleto,
            groupValue: _formaPagamentoSelecionada,
            onChanged: (FormaPagamento? value) {
              setState(() {
                _formaPagamentoSelecionada = value;
              });
            },
            secondary: const Icon(Icons.receipt_long_outlined),
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'R\$ ${widget.total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        // Chama a função simplificada.
        onPressed: _isProcessing ? null : _processarPedido,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child:
            _isProcessing
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                : const Text('Confirmar e Pagar'),
      ),
    );
  }
}
