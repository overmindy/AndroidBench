enum TaskType {
  text('文本任务'),
  image('图片任务'),
  video('视频任务'),
  audio('语音任务'),
  uiUnderstanding('UI理解任务'),
  fileUnderstanding('文件理解任务'),
  sensor('传感器任务'),
  automation('自动执行任务');

  final String displayName;
  const TaskType(this.displayName);

  static TaskType fromString(String value) {
    return TaskType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => TaskType.text,
    );
  }

  static List<TaskType> get availableTypes => TaskType.values;
}
