class Task {
  String task, date, time;
  bool isDone;
  Task(
      {required this.task,
      required this.date,
      required this.time,
      this.isDone = false});

  factory Task.fromJSON(Map<String, dynamic> json) {
    return Task(
        task: json['task'],
        date: json['date'],
        time: json['time'],
        isDone: json['isDone']);
  }
}
