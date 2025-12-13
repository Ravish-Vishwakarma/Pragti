class HabitDataModel {
  final int month;
  final int year;

  HabitDataModel({required this.month, required this.year});

  Map<String, dynamic> toJson() {
    return {"month": month, "year": year};
  }
}
