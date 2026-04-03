import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? sessionId;
  List<dynamic> currentExercises = [];
  int currentExerciseIndex = 0;
  
  // Timer State
  Timer? _restTimer;
  int _secondsRemaining = 0;
  bool _isResting = false;

  bool get isResting => _isResting;
  int get secondsRemaining => _secondsRemaining;
  
  Map<String, dynamic> get activeExercise => 
      currentExercises.isNotEmpty ? currentExercises[currentExerciseIndex] : {};

  Future<void> startWorkout(String dayId) async {
    try {
      // Check in
      final checkInRes = await _apiService.client.post('/workoutsessions/check-in', data: {'workoutDayId': dayId});
      sessionId = checkInRes.data['sessionId'];

      // Fetch exercises
      final exercisesRes = await _apiService.client.get('/plans/day/$dayId/exercises');
      currentExercises = exercisesRes.data;
      currentExerciseIndex = 0;

      notifyListeners();
    } catch (e) {
      print("Error starting workout: $e");
    }
  }

  Future<void> logSet(double weight, int reps) async {
    try {
      final exerciseId = activeExercise['id'];
      
      await _apiService.client.post('/workoutsessions/$sessionId/record-set', data: {
        'workoutDayExerciseId': exerciseId,
        'setNumber': 1, // Actually track this properly in production
        'weightUsed': weight,
        'repsCompleted': reps,
        'isFailureReached': true
      });

      // Based on PDF, look up rest time specific to this exercise (e.g., 2.5 minutes)
      final restMin = activeExercise['restTimeMinutes'] ?? 2.0;
      _startRestTimer((restMin * 60).toInt());

    } catch (e) {
      print("Error logging set: $e");
    }
  }

  void _startRestTimer(int seconds) {
    _secondsRemaining = seconds;
    _isResting = true;
    notifyListeners();

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _isResting = false;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void skipRest() {
    _isResting = false;
    _restTimer?.cancel();
    notifyListeners();
  }

  Future<void> checkoutWorkout() async {
    try {
      await _apiService.client.put('/workoutsessions/$sessionId/check-out');
      sessionId = null;
      currentExercises = [];
      _restTimer?.cancel();
      _isResting = false;
      notifyListeners();
    } catch (e) {}
  }
}
