class Weather {
  final String cityName;
  final double temp;
  final String description;

  Weather({required this.cityName, required this.temp, required this.description});

  factory Weather.fromJson(Map<String, dynamic> json, String city) {
    return Weather(
      cityName: city,
      temp: (json['current']['temperature_2m'] as num).toDouble(),
      // Open-Meteo trả về mã số (weather_code), ta tạm dịch thành chữ
      description: _getWeatherDescription(json['current']['weather_code']),
    );
  }

  static String _getWeatherDescription(int code) {
    if (code == 0) return "Trời quang đãng";
    if (code <= 3) return "Ít mây / Nhiều mây";
    if (code <= 48) return "Có sương mù";
    if (code <= 67) return "Có mưa nhỏ/vừa";
    return "Có mưa dông";
  }
}