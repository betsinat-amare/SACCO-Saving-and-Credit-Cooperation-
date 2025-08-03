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

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  bool _loading = false;
  String? _error;
  List<User> _allMembers = [];
  List<Savings> _pendingSavings = [];
  List<Credit> _pendingCredits = [];
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
      // Fetch all members
      final membersRes = await ApiService.getAllMembers(auth.token!);
      if (membersRes.statusCode == 200) {
        final membersData = jsonDecode(membersRes.body);
        _allMembers =
            (membersData['users'] as List?)
                ?.map((e) => User.fromJson(e))
                .toList() ??
            [];
      }

      // Fetch pending savings
      final psRes = await ApiService.getPendingSavings(auth.token!);
      if (psRes.statusCode == 200) {
        final psData = jsonDecode(psRes.body);
        _pendingSavings =
            (psData['savings'] as List?)
                ?.map((e) => Savings.fromJson(e))
                .toList() ??
            [];
      }

      // Fetch pending credits
      final pcRes = await ApiService.getPendingCredits(auth.token!);
      if (pcRes.statusCode == 200) {
        final pcData = jsonDecode(pcRes.body);
        _pendingCredits =
            (pcData['credits'] as List?)
                ?.map((e) => Credit.fromJson(e))
                .toList() ??
            [];
      }

      // Fetch stats
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

  Widget _buildStatsScreen() {
    if (_stats == null) {
      return const Center(child: Text('No stats available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Total Capital'),
            trailing: Text(
              '\$${_stats!.totalCapital.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Total Members'),
            trailing: Text(
              '${_stats!.totalMembers}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Total Savings'),
            trailing: Text(
              '\$${_stats!.totalSavings.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Total Credits'),
            trailing: Text(
              '\$${_stats!.totalCredits.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Meeting Day'),
            trailing: Text(
              _stats!.meetingDay,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersScreen() {
    return ListView.builder(
      itemCount: _allMembers.length,
      itemBuilder: (context, index) {
        final member = _allMembers[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  member.status == 'approved' ? Colors.green : Colors.orange,
              child: Text(member.name[0].toUpperCase()),
            ),
            title: Text(member.name),
            subtitle: Text(member.email),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    member.status == 'approved' ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                member.status.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            onTap: () => _showMemberDetails(member),
          ),
        );
      },
    );
  }

  Widget _buildSavingsScreen() {
    return ListView.builder(
      itemCount: _pendingSavings.length,
      itemBuilder: (context, index) {
        final savings = _pendingSavings[index];
        final member = _allMembers.firstWhere(
          (m) => m.id == savings.userId,
          orElse:
              () => User(
                id: 'unknown',
                name: 'Unknown',
                email: '',
                role: '',
                status: '',
              ),
        );

        return Card(
          child: ListTile(
            leading: const Icon(Icons.savings, color: Colors.green),
            title: Text('\$${savings.amount.toStringAsFixed(2)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Member: ${member.name}'),
                Text(
                  'Date: ${savings.date.toLocal().toString().split(' ')[0]}',
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _approveSavings(savings.id),
              child: const Text('Approve'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreditsScreen() {
    return ListView.builder(
      itemCount: _pendingCredits.length,
      itemBuilder: (context, index) {
        final credit = _pendingCredits[index];
        final member = _allMembers.firstWhere(
          (m) => m.id == credit.userId,
          orElse:
              () => User(
                id: 'unknown',
                name: 'Unknown',
                email: '',
                role: '',
                status: '',
              ),
        );

        return Card(
          child: ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.red),
            title: Text('\$${credit.amount.toStringAsFixed(2)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Member: ${member.name}'),
                Text('Date: ${credit.date.toLocal().toString().split(' ')[0]}'),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _approveCredit(credit.id),
              child: const Text('Approve'),
            ),
          ),
        );
      },
    );
  }

  void _showMemberDetails(User member) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    List<Savings> memberSavings = [];
    List<Credit> memberCredits = [];

    try {
      final sRes = await ApiService.getSavings(member.id, auth.token!);
      if (sRes.statusCode == 200) {
        final sData = jsonDecode(sRes.body);
        memberSavings =
            (sData['savings'] as List?)
                ?.map((e) => Savings.fromJson(e))
                .toList() ??
            [];
      }

      final cRes = await ApiService.getCredits(member.id, auth.token!);
      if (cRes.statusCode == 200) {
        final cData = jsonDecode(cRes.body);
        memberCredits =
            (cData['credits'] as List?)
                ?.map((e) => Credit.fromJson(e))
                .toList() ??
            [];
      }
    } catch (e) {
      // Handle error
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${member.name} Details'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Email: ${member.email}'),
                  Text('Status: ${member.status}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Savings:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...memberSavings.map(
                    (s) => ListTile(
                      title: Text('\$${s.amount.toStringAsFixed(2)}'),
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
                  const SizedBox(height: 16),
                  const Text(
                    'Credits:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...memberCredits.map(
                    (c) => ListTile(
                      title: Text('\$${c.amount.toStringAsFixed(2)}'),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildStatsScreen(),
      _buildMembersScreen(),
      _buildSavingsScreen(),
      _buildCreditsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(['Stats', 'Members', 'Savings', 'Credits'][_currentIndex]),
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
              : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Credits',
          ),
        ],
      ),
    );
  }
}
