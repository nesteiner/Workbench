import 'package:frontend/api/daily-attendance-api.dart';

Future<void> main() async {
  final api = DailyAttendanceApi(dailyAttendanceUrl: "http://192.168.31.249:8082/api/daily-attendance");

  api.setToken("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJzdGVpbmVyIiwiZXhwIjoxNzAwODQ1MDM1LCJpYXQiOjE3MDA4MjcwMzV9.rk3e1URjL1jmdVAh0HPC6soDsXN4N8I4_RGh8TeulvksfOPaKKK9oan_B5m1GbhQrPXQF3d932ey-CZgOeh6Fg");

  final result = await api.findAllOfLatest7Days();
  print(result);
  print(result.keys.toList());
}