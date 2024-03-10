class TaskModel {
  final int? taskId;
  final String taskTitle;
  final String createdAt;

  TaskModel({
    this.taskId,
    required this.taskTitle,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> json) => TaskModel(
        taskId: json["taskId"],
        taskTitle: json["taskTitle"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toMap() => {
        "taskId": taskId,
        "taskTitle": taskTitle,
        "createdAt": createdAt,
      };
}
