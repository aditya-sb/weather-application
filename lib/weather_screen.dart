import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'additional_info.dart';
import 'hourly_forecast.dart';
import 'secrets.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async{
    try{
    String cityName = 'Gwalior';
    final res = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apikey'
    ),);
    final data = jsonDecode(res.body);
    if(data['cod']!='200'){
      throw 'An unexpected error occurred';
    }
    return data;
    }
    catch(e){
      throw e.toString();
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            setState(() {
              
            });
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder:(context,snapshot){
    if(snapshot.connectionState == ConnectionState.waiting){
    return const Center(child: CircularProgressIndicator.adaptive());
    }
    if(snapshot.hasError){
    return Center(child: Text(snapshot.error.toString()));
    }
    final data = snapshot.data!;
    final currentList = data['list'][0];
    final currentTemp = (currentList['main']['temp'])-273.15;
    final currentSky = currentList['weather'][0]['main'];
    final humidity = currentList['main']['humidity'];
    final wind = currentList['wind']['speed'];
    final pressure = currentList['main']['pressure'];
    return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(
    width: double.infinity,
    child: Card(
    elevation: 10,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(children: [
    Text(
    '${currentTemp.toStringAsFixed(2)}° C',
    style: const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(
    height: 16,
    ),
    Icon(
    currentSky=='Clouds' || currentSky=='Rain'?Icons.cloud:Icons.sunny,
    size: 64,
    ),
    const SizedBox(
    height: 16,
    ),
    Text(
    currentSky,
    style: const TextStyle(
    fontSize: 20,
    ),
    ),
    ]),
    ),
    ),
    ),
    ),
    ),
    const SizedBox(height: 20),
    const Text(
    'Hourly Forecast',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 16),

SizedBox(
  height: 120,
  child:   ListView.builder(
  
    itemCount: 20,
    scrollDirection: Axis.horizontal,
    itemBuilder:(context,i){
      final time = DateTime.parse(data['list'][i+1]['dt_txt']);
      return HourlyForecast(time: DateFormat.Hm().format(time),
      temp: '${((data['list'][i+1]['main']['temp'])-273.15).toStringAsFixed(2)}° C',
      icon: data['list'][i+1]['weather'][0]['main']=='Clouds'||data['list'][i+1]['weather'][0]['main']=='Rain'?Icons.cloud:Icons.sunny);
    },
  
  ),
),

    const SizedBox(height: 20),
    const Text(
    'Additional Information',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 16),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
    AdditionalInfo(icon: Icons.water_drop,
    label: 'Humidity',
    value: humidity.toString(),),
    AdditionalInfo(
    icon: Icons.air,
    label: 'Wind Speed',
    value: wind.toString(),
    ),
    AdditionalInfo(
    icon: Icons.beach_access,
    label: 'Pressure',
    value: pressure.toString(),
    ),
    ],
    )
    ],
    ),
    );
    }
    ),);
}
}
