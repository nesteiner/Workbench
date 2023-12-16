void main() {
  final datetime0 = DateTime(2023, 12, 31);
  final datetime1 = DateTime(datetime0.year, datetime0.month + 1, 0);
  print(datetime1);
}