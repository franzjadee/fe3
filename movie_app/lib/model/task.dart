class Task {
  final int? id;
  final String title;
  final bool isDone;
  final String? finishedDate;
  final String? showType;
  final String? season;
  final String? episode;

  Task({
    this.id,
    required this.title,
    required this.isDone,
    this.finishedDate,
    this.showType,
    this.season,
    this.episode,
  });

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    String? finishedDate,
    String? showType,
    String? season,
    String? episode,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      finishedDate: finishedDate ?? this.finishedDate,
      showType: showType ?? this.showType,
      season: season ?? this.season,
      episode: episode ?? this.episode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'finishedDate': finishedDate,
      'showType': showType,
      'season': season,
      'episode': episode,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
      finishedDate: map['finishedDate'],
      showType: map['showType'],
      season: map['season'],
      episode: map['episode'],
    );
  }
}
