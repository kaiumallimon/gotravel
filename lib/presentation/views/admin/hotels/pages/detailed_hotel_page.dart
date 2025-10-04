import 'package:flutter/material.dart';
import 'package:gotravel/data/models/hotel_model.dart';

class DetailedHotelPage extends StatefulWidget {

  final Hotel hotel;
  const DetailedHotelPage({super.key, required this.hotel});

  @override
  State<DetailedHotelPage> createState() => _DetailedHotelPageState();
}

class _DetailedHotelPageState extends State<DetailedHotelPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Detailed Hotel Page')));
  }
}
