import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final String dayId;
  const ActiveWorkoutScreen({super.key, required this.dayId});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().startWorkout(widget.dayId);
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<WorkoutProvider>();

    if (provider.sessionId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ex = provider.activeExercise;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACTIVE SESSION', style: TextStyle(color: Colors.redAccent)),
        actions: [
          TextButton(
            onPressed: () {
              provider.checkoutWorkout().then((_) => Navigator.pop(context));
            },
            child: const Text('FINISH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: provider.isResting ? _buildRestTimer(provider) : _buildLoggingForm(ex),
    );
  }

  Widget _buildLoggingForm(Map<String, dynamic> ex) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(ex['name'] ?? 'Unknown Exercise', textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Target: ${ex['targetSets']} Sets • ${ex['targetReps']} Reps', style: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                if (ex['notes'] != null && ex['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(ex['notes'], style: const TextStyle(color: Colors.amber, fontStyle: FontStyle.italic)),
                ]
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text("LOG SET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.fitness_center)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps', prefixIcon: Icon(Icons.repeat)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(_weightController.text) ?? 0;
              final r = int.tryParse(_repsController.text) ?? 0;
              if (r > 0) {
                context.read<WorkoutProvider>().logSet(w, r);
                _repsController.clear();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 24)),
            child: const Text('RECORD & START REST', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimer(WorkoutProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          const Text('REST TIME', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(
            _formatTime(provider.secondsRemaining),
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.amber),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => provider.skipRest(),
            icon: const Icon(Icons.skip_next),
            label: const Text('SKIP REST'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          )
        ],
      ),
    );
  }
}
