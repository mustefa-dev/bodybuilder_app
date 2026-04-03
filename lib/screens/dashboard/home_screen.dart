import 'package:flutter/material.dart';
import '../../services/plans_service.dart';
import '../workout/active_workout_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlansService _plansService = PlansService();
  bool _isLoading = true;
  List<dynamic> _plans = [];
  List<dynamic> _days = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final plans = await _plansService.fetchPlans();
    if (plans.isNotEmpty) {
      final planId = plans[0]['id']; 
      final days = await _plansService.fetchPlanDays(planId);
      setState(() {
        _plans = plans;
        _days = days;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THE PROGRAM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history), 
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            }
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
        : _days.isEmpty 
          ? const Center(child: Text("No workouts found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                return _buildDayCard(day);
              },
            ),
    );
  }

  Widget _buildDayCard(dynamic day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActiveWorkoutScreen(dayId: day['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DAY ${day['dayNumber']}", 
                    style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.black, fontSize: 16, letterSpacing: 2)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day['title'].toString().toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)
                  ),
                ],
              ),
              const Icon(Icons.play_circle_filled, size: 48, color: Colors.deepPurpleAccent),
            ],
          ),
        ),
      ),
    );
  }
}
