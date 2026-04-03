import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final success = await context.read<AuthProvider>().login(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials or network error.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var auth = context.watch<AuthProvider>();
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: Colors.deepPurpleAccent),
              const SizedBox(height: 24),
              const Text(
                'WELCOME TO THE GRIND',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jeremy Ethier 5-Day Split',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              auth.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('LOGIN'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
