import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

class HotelRoomBookingSystem extends StatelessWidget {
  const HotelRoomBookingSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Room Booking System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}