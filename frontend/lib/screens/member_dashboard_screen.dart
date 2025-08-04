import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/savings.dart';
import '../models/credit.dart';
import '../models/payment.dart';
import '../models/stats.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  bool _loading = false;
  String? _error;
  List<Savings> _savings = [];
  List<Credit> _credits = [];
  List<Payment> _payments = [];
  CooperativeStats? _stats;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final sRes = await ApiService.getSavings(auth.user!.id, auth.token!);
      if (sRes.statusCode == 200) {
        final sData = jsonDecode(sRes.body);
        _savings =
            (sData['savings'] as List?)
                ?.map((e) => Savings.fromJson(e))
                .toList() ??
            [];
      }

      final cRes = await ApiService.getCredits(auth.user!.id, auth.token!);
      if (cRes.statusCode == 200) {
        final cData = jsonDecode(cRes.body);
        _credits =
            (cData['credits'] as List?)
                ?.map((e) => Credit.fromJson(e))
                .toList() ??
            [];
      }

      final pRes = await ApiService.getPayments(auth.user!.id, auth.token!);
      if (pRes.statusCode == 200) {
        final pData = jsonDecode(pRes.body);
        _payments =
            (pData['payments'] as List?)
                ?.map((e) => Payment.fromJson(e))
                .toList() ??
            [];
      }

      final statsRes = await ApiService.getStats(auth.token!);
      if (statsRes.statusCode == 200) {
        final statsData = jsonDecode(statsRes.body);
        _stats = CooperativeStats.fromJson(statsData['stats']);
      }
    } catch (e) {
      _error = 'Failed to load data: $e';
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _addSavings() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    dateController.text = DateTime.now().toIso8601String().split('T')[0];

    String? errorText;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Savings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      helperText: 'YYYY-MM-DD',
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amountText = amountController.text.trim();
                    final dateText = dateController.text.trim();
                    final isAmountValid =
                        amountText.isNotEmpty &&
                        double.tryParse(amountText) != null;
                    final isDateValid =
                        dateText.isNotEmpty &&
                        DateTime.tryParse(dateText) != null;
                    if (isAmountValid && isDateValid) {
                      Navigator.of(
                        context,
                      ).pop({'amount': amountText, 'date': dateText});
                    } else {
                      setState(() {
                        errorText = 'Please enter a valid amount and date';
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        final amount = double.parse(result['amount']);
        final date = DateTime.parse(result['date']);
        final response = await ApiService.addSavings(
          auth.user!.id,
          amount,
          date,
          auth.token!,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Savings added successfully! Pending admin approval.',
              ),
            ),
          );
          _fetchAll();
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${errorData['error'] ?? 'Failed to add savings'}',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid amount or date format')),
        );
      }
    }
  }

  Future<void> _addCredit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    dateController.text = DateTime.now().toIso8601String().split('T')[0];

    String? errorText;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Credit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      helperText: 'YYYY-MM-DD',
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amountText = amountController.text.trim();
                    final dateText = dateController.text.trim();
                    final isAmountValid =
                        amountText.isNotEmpty &&
                        double.tryParse(amountText) != null;
                    final isDateValid =
                        dateText.isNotEmpty &&
                        DateTime.tryParse(dateText) != null;
                    if (isAmountValid && isDateValid) {
                      Navigator.of(
                        context,
                      ).pop({'amount': amountText, 'date': dateText});
                    } else {
                      setState(() {
                        errorText = 'Please enter a valid amount and date';
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        final amount = double.parse(result['amount']);
        final date = DateTime.parse(result['date']);
        final response = await ApiService.addCredit(
          auth.user!.id,
          amount,
          date,
          auth.token!,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Credit added successfully! Pending admin approval.',
              ),
            ),
          );
          _fetchAll();
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${errorData['error'] ?? 'Failed to add credit'}',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid amount or date format')),
        );
      }
    }
  }

  Future<void> _addPayment() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    dateController.text = DateTime.now().toIso8601String().split('T')[0];

    String? errorText;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      helperText: 'YYYY-MM-DD',
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amountText = amountController.text.trim();
                    final dateText = dateController.text.trim();
                    final isAmountValid =
                        amountText.isNotEmpty &&
                        double.tryParse(amountText) != null;
                    final isDateValid =
                        dateText.isNotEmpty &&
                        DateTime.tryParse(dateText) != null;
                    if (isAmountValid && isDateValid) {
                      Navigator.of(
                        context,
                      ).pop({'amount': amountText, 'date': dateText});
                    } else {
                      setState(() {
                        errorText = 'Please enter a valid amount and date';
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        final amount = double.parse(result['amount']);
        final date = DateTime.parse(result['date']);
        print('Payment attempt - Amount: $amount, Date: $date'); // Debug info
        final response = await ApiService.addPayment(
          auth.user!.id,
          amount,
          date,
          auth.token!,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Payment added successfully! Pending admin approval.',
              ),
            ),
          );
          _fetchAll();
        } else {
          final errorData = jsonDecode(response.body);
          print('Payment error: ${response.body}'); // Debug info
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${errorData['error'] ?? 'Failed to add payment'}',
              ),
            ),
          );
        }
      } catch (e) {
        print('Payment exception: $e'); // Debug info
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSavings = _savings
        .where((s) => s.status == 'approved')
        .fold<double>(0, (sum, s) => sum + s.amount);
    final totalCredits = _credits
        .where((c) => c.status == 'approved')
        .fold<double>(0, (sum, c) => sum + c.amount);
    // Calculate total remaining debt more accurately
    final totalApprovedCredits = _credits
        .where((c) => c.status == 'approved')
        .fold<double>(0, (sum, c) => sum + c.amount);
    final totalApprovedPayments = _payments
        .where((p) => p.status == 'approved')
        .fold<double>(0, (sum, p) => sum + p.amount);
    final totalRemainingDebt = (totalApprovedCredits - totalApprovedPayments)
        .clamp(0.0, double.infinity);
    final totalPaidPayments = _payments
        .where((p) => p.status == 'approved')
        .fold<double>(0, (sum, p) => sum + p.amount);
    final pendingSavings = _savings.where((s) => s.status == 'pending').length;
    final pendingCredits = _credits.where((c) => c.status == 'pending').length;
    final pendingPayments =
        _payments.where((p) => p.status == 'pending').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAll,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : RefreshIndicator(
                onRefresh: _fetchAll,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Stats Cards
                    if (_stats != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                'Meeting Day',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _stats!.meetingDay,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Total Savings',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '\$${totalSavings.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  if (pendingSavings > 0)
                                    Text(
                                      '$pendingSavings pending',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Total Credits',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '\$${totalCredits.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  if (pendingCredits > 0)
                                    Text(
                                      '$pendingCredits pending',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Debt and Payment Cards
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Remaining Debt',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '\$${totalRemainingDebt.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Total Paid',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '\$${totalPaidPayments.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  if (pendingPayments > 0)
                                    Text(
                                      '$pendingPayments pending',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addSavings,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Savings'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addCredit,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Credit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Payment Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addPayment,
                        icon: const Icon(Icons.payment),
                        label: const Text('Make Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Savings History
                    const Text(
                      'Savings History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_savings.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No savings history yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._savings.map(
                        (s) => Card(
                          child: ListTile(
                            leading: Icon(
                              s.status == 'approved'
                                  ? Icons.check_circle
                                  : s.status == 'rejected'
                                  ? Icons.cancel
                                  : Icons.pending,
                              color:
                                  s.status == 'approved'
                                      ? Colors.green
                                      : s.status == 'rejected'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                            title: Text('\$${s.amount.toStringAsFixed(2)}'),
                            subtitle: Text(
                              'Date: ${s.date.toLocal().toString().split(' ')[0]}',
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    s.status == 'approved'
                                        ? Colors.green
                                        : s.status == 'rejected'
                                        ? Colors.red
                                        : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Credits History
                    const Text(
                      'Credits History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_credits.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No credits history yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._credits.map(
                        (c) => Card(
                          child: ListTile(
                            leading: Icon(
                              c.status == 'approved'
                                  ? Icons.check_circle
                                  : c.status == 'rejected'
                                  ? Icons.cancel
                                  : Icons.pending,
                              color:
                                  c.status == 'approved'
                                      ? Colors.green
                                      : c.status == 'rejected'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                            title: Text('\$${c.amount.toStringAsFixed(2)}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${c.date.toLocal().toString().split(' ')[0]}',
                                ),
                                if (c.status == 'approved')
                                  Text(
                                    'Remaining: \$${c.remainingDebt.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    c.status == 'approved'
                                        ? Colors.green
                                        : c.status == 'rejected'
                                        ? Colors.red
                                        : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                c.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Payments History
                    const Text(
                      'Payments History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_payments.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No payments history yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._payments.map(
                        (p) => Card(
                          child: ListTile(
                            leading: Icon(
                              p.status == 'approved'
                                  ? Icons.check_circle
                                  : p.status == 'rejected'
                                  ? Icons.cancel
                                  : Icons.pending,
                              color:
                                  p.status == 'approved'
                                      ? Colors.green
                                      : p.status == 'rejected'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                            title: Text('\$${p.amount.toStringAsFixed(2)}'),
                            subtitle: Text(
                              'Date: ${p.date.toLocal().toString().split(' ')[0]}',
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    p.status == 'approved'
                                        ? Colors.green
                                        : p.status == 'rejected'
                                        ? Colors.red
                                        : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
