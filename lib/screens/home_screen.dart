import 'package:flutter/material.dart';
import 'package:maps_flutter/widgets/primary_app_bar.dart';
import 'maps_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PrimaryAppBar(title: 'Simple Maps'),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapsScreen()),
            );
          },
          child: const Text('Show Maps'),
        ),
      ),
    );
  }
}
