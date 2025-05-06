class Entry {
  final int? id;
  final String content;
  final double score;
  final String timestamp;

  Entry({
    this.id,
    required this.content,
    required this.score,
    required this.timestamp,
  });

  // Convert an Entry object to a Map for database insertion
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'content': content,
      'score': score,
      'timestamp': timestamp,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Convert a Map from the database to an Entry object
  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'],
      content: map['content'],
      score: map['score'],
      timestamp: map['timestamp'],
    );
  }

  @override
  String toString() {
    return 'Entry{id: $id, content: $content, score: $score, timestamp: $timestamp}';
  }
}
