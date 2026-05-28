import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  final _authService = AuthService();
  final _dbService = DatabaseService();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  late String _userId;
  String _selectedType = 'Receita';
  DateTime? _selectedDate;

  final List<String> _types = ['Receita', 'Despesa', 'FIIs', 'Renda Fixa'];

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser!.id;
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _showTransactionDialog() {
    _titleController.clear();
    _amountController.clear();
    _selectedType = 'Receita';
    _selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Nova Movimentação'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(controller: _titleController, label: 'Título'),
                      CustomTextField(
                        controller: _amountController,
                        label: 'Valor (R\$)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _types.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setDialogState(() => _selectedType = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) setDialogState(() => _selectedDate = pickedDate);
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Data: ${_formatDate(_selectedDate!)}'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  ElevatedButton(
                    onPressed: () async {
                      if (_titleController.text.trim().isNotEmpty && _amountController.text.trim().isNotEmpty) {
                        double? parsedAmount = double.tryParse(_amountController.text.replaceAll(',', '.'));

                        if (parsedAmount != null) {
                          if (_selectedType == 'Despesa') parsedAmount = -parsedAmount.abs();
                          if (_selectedType == 'Receita' || _selectedType == 'FIIs' || _selectedType == 'Renda Fixa') {
                            parsedAmount = parsedAmount.abs();
                          }

                          final transaction = FinanceTransaction(
                            id: '',
                            userId: _userId,
                            title: _titleController.text.trim(),
                            amount: parsedAmount,
                            type: _selectedType,
                            date: _selectedDate!,
                          );
                          await _dbService.addTransaction(transaction);
                          if (mounted) {
                            Navigator.pop(context);
                            setState(() {});
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salvar'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'R\$ ${amount.abs().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentBar(String label, double percentage, Color color, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage.isNaN ? 0 : percentage,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<FinanceTransaction>>(
        future: _dbService.getTransactions(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar finanças.'));
          }

          final transactions = snapshot.data ?? [];

          double totalIncome = 0;
          double totalExpense = 0;
          double totalFii = 0;
          double totalFixed = 0;

          for (var tx in transactions) {
            if (tx.type == 'Receita') totalIncome += tx.amount;
            if (tx.type == 'Despesa') totalExpense += tx.amount.abs();
            if (tx.type == 'FIIs') totalFii += tx.amount;
            if (tx.type == 'Renda Fixa') totalFixed += tx.amount;
          }

          double totalInvestments = totalFii + totalFixed;
          double pctFii = totalInvestments > 0 ? (totalFii / totalInvestments) : 0.0;
          double pctFixed = totalInvestments > 0 ? (totalFixed / totalInvestments) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSummaryCard('Receitas', totalIncome, Colors.green, Icons.arrow_upward),
                    const SizedBox(width: 12),
                    _buildSummaryCard('Despesas', totalExpense, Colors.red, Icons.arrow_downward),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Minha Carteira',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInvestmentBar('Fundos Imobiliários (FIIs)', pctFii, Colors.blueAccent, 'R\$ ${totalFii.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        _buildInvestmentBar('Renda Fixa (Tesouro Direto)', pctFixed, Colors.orange, 'R\$ ${totalFixed.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Últimas Movimentações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Nenhuma movimentação registrada.', style: TextStyle(color: Colors.grey[600])),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isExpense = tx.type == 'Despesa';
                      final isInvestment = tx.type == 'FIIs' || tx.type == 'Renda Fixa';

                      IconData txIcon = Icons.account_balance_wallet_outlined;
                      Color txColor = Colors.green;

                      if (isInvestment) {
                        txIcon = Icons.trending_up;
                        txColor = Colors.blue;
                      } else if (isExpense) {
                        txIcon = Icons.shopping_bag_outlined;
                        txColor = Colors.red;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: txColor.withOpacity(0.1),
                            child: Icon(txIcon, color: txColor, size: 20),
                          ),
                          title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(_formatDate(tx.date)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isExpense ? '-' : '+'}R\$ ${tx.amount.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isExpense ? Colors.black87 : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () async {
                                  await _dbService.deleteTransaction(tx.id);
                                  setState(() {});
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}