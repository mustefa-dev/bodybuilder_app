import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final res = await _apiService.client.get('/workoutsessions/history');
      setState(() {
        _history = res.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Unknown Date';
    final parsed = DateTime.parse(dateStr).toLocal();
    return "${parsed.month}/${parsed.day}/${parsed.year} - ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WORKOUT HISTORY', style: TextStyle(color: Colors.amber))),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _history.isEmpty 
          ? const Center(child: Text('Go lift something heavy! No history yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final session = _history[index];
                return Card(
                  color: const Color(0xFF2C2C2C),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
                    title: Text(session['title'] ?? 'Workout', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Date: ${_formatDate(session['checkInTime'])}', style: const TextStyle(color: Colors.grey)),
                        Text('Duration: ${session['totalDurationMinutes'].toStringAsFixed(1)} mins', style: const TextStyle(color: Colors.deepPurpleAccent)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
