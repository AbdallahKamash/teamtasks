import 'package:flutter/material.dart';
import 'package:teamtasks/components/workspace_swapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Wrapping in SafeArea and Padding to match your MainPage style
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text('لا يوجد مساحة عمل \n قم بإضافة مساحة عمل جديدة من الاعلى', textAlign: .center, style: TextStyle(color: Colors.grey.shade500,fontFamily: 'Alexandria')),
        ),
      ),
    );
  }
}