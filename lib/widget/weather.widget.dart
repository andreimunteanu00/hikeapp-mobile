import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../util/constants.dart' as constants;

class WeatherWidget extends StatefulWidget {
  final LatLng position;
  final Function(double) handleValueChanged;

  const WeatherWidget({super.key, required this.position, required this.handleValueChanged});

  @override
  WeatherWidgetState createState() => WeatherWidgetState();
}

class WeatherWidgetState extends State<WeatherWidget> {
  Timer? timer;
  Future<Map<String, dynamic>>? future;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    double latitude = widget.position.latitude;
    double longitude = widget.position.longitude;
    String apiUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=${constants.weatherApiKey}';
    http.Response response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      widget.handleValueChanged(data['main']['temp'] - 273.15);
      return data;
    } else {
      throw Exception('Failed to get weather data');
    }
  }

  IconData getWeatherIcon(String weatherType) {
    IconData icon;
    switch (weatherType) {
      case 'clear sky':
        icon = Icons.wb_sunny;
        break;
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
        icon = Icons.cloud;
        break;
      case 'shower rain':
      case 'rain':
        icon = Icons.beach_access;
        break;
      case 'thunderstorm':
        icon = Icons.flash_on;
        break;
      case 'snow':
        icon = Icons.ac_unit;
        break;
      case 'mist':
        icon = Icons.filter_drama;
        break;
      default:
        icon = Icons.help_outline;
    }
    return icon;
  }

  @override
  void initState() {
    super.initState();
    future = getCurrentWeather();
    timer = Timer.periodic(const Duration(minutes: 10), (timer) {
      setState(() {
        future = getCurrentWeather();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!;
            double temperature = data['main']['temp'] - 273.15; // convert to Celsius
            int humidity = data['main']['humidity'];
            double windSpeed = data['wind']['speed'];
            String weatherType = data['weather'][0]['description'];
            IconData weatherIcon = getWeatherIcon(weatherType);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.opacity,
                          size: 32.0,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '$humidity%',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Humidity',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(children: [
                      Icon(
                        weatherIcon,
                        size: 64.0,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '${temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ]),
                    Column(
                      children: [
                        const Icon(
                          Icons.air,
                          size: 32.0,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${windSpeed.toStringAsFixed(1)} km/h',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Wind Speed',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}