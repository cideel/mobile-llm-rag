class ItineraryModel {
  final String id;
  final String name;
  final String content;
  final DateTime createdAt;
    final String username;  // nama pembuat


  ItineraryModel({
    required this.id,
    required this.name,
    required this.content,
    required this.createdAt,
    required this.username
  });

  factory ItineraryModel.fromMap(Map map, String id) => ItineraryModel(
        id: id,
        name: map['name'] ?? '',
        content: map['content'] ?? '',
        createdAt: DateTime.parse(map['createdAt']),
        username: map['username']??''
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'username' :username
      };
}