import 'package:dio/dio.dart';
import 'api_service.dart';

class PlansService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> fetchPlans() async {
    try {
      final response = await _apiService.client.get('/plans');
      return response.data;
    } catch (e) {
      print('Failed to load plans: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchPlanDays(String planId) async {
    try {
      final response = await _apiService.client.get('/plans/$planId/days');
      return response.data;
    } catch (e) {
      print('Failed to load days: $e');
      return [];
    }
  }
}
