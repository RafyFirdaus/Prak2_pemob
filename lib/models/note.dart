class Note {
  const Note({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.category = 'Umum',
  });

  final int? id;
  final String title;
  final String content;
  final String? createdAt;
  final String category;

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    // Existing notes may predate timestamp storage. Keep their date unknown.
    'created_at':
        createdAt ?? (id == null ? DateTime.now().toIso8601String() : ''),
    'category': category,
  };

  factory Note.fromMap(Map<String, Object?> map) => Note(
    id: map['id'] as int?,
    title: map['title'] as String,
    content: map['content'] as String,
    createdAt: (map['created_at'] as String?)?.isNotEmpty == true
        ? map['created_at'] as String
        : null,
    category: (map['category'] as String?)?.isNotEmpty == true
        ? map['category'] as String
        : 'Umum',
  );
}
