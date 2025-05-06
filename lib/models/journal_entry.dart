// ignore_for_file: non_constant_identifier_names

class JournalEntry {
  final int? id;
  final String entry_text;
  final int score;
  final String reasoning;
  final String confidence;
  final int isNeglect;
  final int isRepair;
  final String? timestamp; // ✅ New field (nullable for safety)

  JournalEntry({
    this.id,
    required this.entry_text,
    required this.score,
    required this.reasoning,
    required this.confidence,
    required this.isNeglect,
    required this.isRepair,
    this.timestamp, // ✅ Include in constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entry_text': entry_text,
      'score': score,
      'reasoning': reasoning,
      'confidence': confidence,
      'isNeglect': isNeglect == 1 ? 1 : 0,
      'isRepair': isRepair == 1 ? 1 : 0,
      'timestamp':
          timestamp ??
          DateTime.now().toString(), // ✅ Default to current time if null
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      entry_text: map['entry_text'],
      score: map['score'],
      reasoning: map['reasoning'],
      confidence: map['confidence'],
      isNeglect: map['isNeglect'] == 1 ? 1 : 0,
      isRepair: map['isRepair'] == 1 ? 1 : 0,
      timestamp: map['timestamp'], // ✅ Retrieve from DB
    );
  }
}
