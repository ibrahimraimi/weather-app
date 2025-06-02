import 'package:flutter/material.dart';
import 'package:mobile/services/weather_service.dart';
import 'package:mobile/models/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherDashboard(),
    );
  }
}

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  Weather? _weather;
  String? _error;

  Future<void> _getWeather(String city) async {
    try {
      final weatherData = await _weatherService.getWeather(city);
      setState(() {
        _weather = Weather.fromJson(weatherData);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _weather = null;
        _error = 'Failed to load weather data. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_cityController.text.isNotEmpty) {
                      _getWeather(_cityController.text);
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _getWeather(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              )
            else if (_weather != null)
              Expanded(
                child: _buildWeatherInfo(),
              )
            else
              const Text('Enter a city name to get weather information'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _weather!.city,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weather!.temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      _weather!.description,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Image.network(
                  'https://openweathermap.org/img/w/${_weather!.icon}.png',
                  scale: 0.5,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeatherDetail('Humidity', '${_weather!.humidity}%'),
            const SizedBox(height: 8),
            _buildWeatherDetail('Wind Speed', '${_weather!.windSpeed} m/s'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
