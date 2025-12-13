class UpdateHabitScoreModel {
  final int day;
  final int month;
  final int year;
  final String habit;
  final int score;

  UpdateHabitScoreModel({
    required this.day,
    required this.month,
    required this.year,
    required this.habit,
    required this.score,
  });
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'habit': habit,
      'score': score,
    };
  }
}
