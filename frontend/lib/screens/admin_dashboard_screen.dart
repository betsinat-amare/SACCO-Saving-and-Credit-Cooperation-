import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/savings.dart';
import '../models/credit.dart';
import '../models/stats.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;
  String? _error;
  List<User> _pendingMembers = [];
  List<Savings> _pendingSavings = [];
  List<Credit> _pendingCredits = [];
  CooperativeStats? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      // Pending members
      final pmRes = await ApiService.getPendingMembers(auth.token!);
      if (pmRes.statusCode == 200) {
        final pmData = jsonDecode(pmRes.body);
        _pendingMembers =
            (pmData['users'] as List?)?.map((e) => User.fromJson(e)).toList() ??
            [];
      }
      // Pending savings
      final psRes = await ApiService.getPendingSavings(auth.token!);
      if (psRes.statusCode == 200) {
        final psData = jsonDecode(psRes.body);
        _pendingSavings =
            (psData['savings'] as List?)
                ?.map((e) => Savings.fromJson(e))
                .toList() ??
            [];
      }
      // Pending credits
      final pcRes = await ApiService.getPendingCredits(auth.token!);
      if (pcRes.statusCode == 200) {
        final pcData = jsonDecode(pcRes.body);
        _pendingCredits =
            (pcData['credits'] as List?)
                ?.map((e) => Credit.fromJson(e))
                .toList() ??
            [];
      }
      // Stats
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

  Future<void> _approveMember(String userId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiService.approveMember(userId, auth.token!);
    _fetchAll();
  }

  Future<void> _approveSavings(String savingsId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiService.approveSavings(savingsId, auth.token!);
    _fetchAll();
  }

  Future<void> _approveCredit(String creditId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiService.approveCredit(creditId, auth.token!);
    _fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Members'),
            Tab(text: 'Savings'),
            Tab(text: 'Credits'),
          ],
        ),
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
              : TabBarView(
                controller: _tabController,
                children: [
                  // Stats
                  _stats == null
                      ? const Center(child: Text('No stats'))
                      : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: ListTile(
                              title: const Text('Total Capital'),
                              trailing: Text(
                                _stats!.totalCapital.toStringAsFixed(2),
                              ),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              title: const Text('Total Members'),
                              trailing: Text(_stats!.totalMembers.toString()),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              title: const Text('Total Savings'),
                              trailing: Text(
                                _stats!.totalSavings.toStringAsFixed(2),
                              ),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              title: const Text('Total Credits'),
                              trailing: Text(
                                _stats!.totalCredits.toStringAsFixed(2),
                              ),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              title: const Text('Meeting Day'),
                              trailing: Text(_stats!.meetingDay),
                            ),
                          ),
                        ],
                      ),
                  // Pending Members
                  ListView.builder(
                    itemCount: _pendingMembers.length,
                    itemBuilder: (context, i) {
                      final user = _pendingMembers[i];
                      return Card(
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: ElevatedButton(
                            onPressed: () => _approveMember(user.id),
                            child: const Text('Approve'),
                          ),
                        ),
                      );
                    },
                  ),
                  // Pending Savings
                  ListView.builder(
                    itemCount: _pendingSavings.length,
                    itemBuilder: (context, i) {
                      final s = _pendingSavings[i];
                      return Card(
                        child: ListTile(
                          title: Text('User: ${s.userId}'),
                          subtitle: Text(
                            'Amount: ${s.amount}\nDate: ${s.date.toLocal().toString().split(' ')[0]}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _approveSavings(s.id),
                            child: const Text('Approve'),
                          ),
                        ),
                      );
                    },
                  ),
                  // Pending Credits
                  ListView.builder(
                    itemCount: _pendingCredits.length,
                    itemBuilder: (context, i) {
                      final c = _pendingCredits[i];
                      return Card(
                        child: ListTile(
                          title: Text('User: ${c.userId}'),
                          subtitle: Text(
                            'Amount: ${c.amount}\nDate: ${c.date.toLocal().toString().split(' ')[0]}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _approveCredit(c.id),
                            child: const Text('Approve'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
    );
  }
}
