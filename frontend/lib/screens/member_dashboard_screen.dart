import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/savings.dart';
import '../models/credit.dart';
import '../models/stats.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  bool _loading = false;
  String? _error;
  List<Savings> _savings = [];
  List<Credit> _credits = [];
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
    double? amount;
    DateTime? date;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Savings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = double.tryParse(val),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
                onChanged: (val) => date = DateTime.tryParse(val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amount != null && date != null) {
                  await ApiService.addSavings(
                    auth.user!.id,
                    amount!,
                    date!,
                    auth.token!,
                  );
                  Navigator.pop(context);
                  _fetchAll();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCredit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    double? amount;
    DateTime? date;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Credit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = double.tryParse(val),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
                onChanged: (val) => date = DateTime.tryParse(val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amount != null && date != null) {
                  await ApiService.addCredit(
                    auth.user!.id,
                    amount!,
                    date!,
                    auth.token!,
                  );
                  Navigator.pop(context);
                  _fetchAll();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSavings = _savings
        .where((s) => s.status == 'approved')
        .fold<double>(0, (sum, s) => sum + s.amount);
    final totalCredits = _credits
        .where((c) => c.status == 'approved')
        .fold<double>(0, (sum, c) => sum + c.amount);
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
                    if (_stats != null)
                      Card(
                        child: ListTile(
                          title: const Text('Meeting Day'),
                          trailing: Text(_stats!.meetingDay),
                        ),
                      ),
                    Card(
                      child: ListTile(
                        title: const Text('Total Savings'),
                        trailing: Text(totalSavings.toStringAsFixed(2)),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Total Credits'),
                        trailing: Text(totalCredits.toStringAsFixed(2)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addSavings,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Savings'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addCredit,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Credit'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Savings History',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._savings.map(
                      (s) => Card(
                        child: ListTile(
                          title: Text('Amount: ${s.amount}'),
                          subtitle: Text(
                            'Date: ${s.date.toLocal().toString().split(' ')[0]}',
                          ),
                          trailing: Text(
                            s.status,
                            style: TextStyle(
                              color:
                                  s.status == 'approved'
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Credits History',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._credits.map(
                      (c) => Card(
                        child: ListTile(
                          title: Text('Amount: ${c.amount}'),
                          subtitle: Text(
                            'Date: ${c.date.toLocal().toString().split(' ')[0]}',
                          ),
                          trailing: Text(
                            c.status,
                            style: TextStyle(
                              color:
                                  c.status == 'approved'
                                      ? Colors.green
                                      : Colors.orange,
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
