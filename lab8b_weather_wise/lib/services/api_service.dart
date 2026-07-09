import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  Future<Weather> fetchWeather(String city) async {
    // Gọi thẳng API lấy tọa độ Hà Nội (Vĩ độ: 21.0245, Kinh độ: 105.8412)
    final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=21.0245&longitude=105.8412&current=temperature_2m,weather_code");
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body), city);
    } else {
      throw Exception('Không thể tải dữ liệu từ Open-Meteo');
    }
  }
}