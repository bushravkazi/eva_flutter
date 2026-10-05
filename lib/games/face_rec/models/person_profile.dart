class PersonProfile {
  final String id;
  final String name;
  final String relationship; // e.g. "Daughter", "Grandchild", "Neighbor"
  final List<String> contextNotes; // Multiple context notes per person
  final String? localImagePath; // Local photo file path if uploaded
  final String? photoUrl; // Real human photography URL
  final bool isDemo;
  final String? age;
  final String? city;

  PersonProfile({
    required this.id,
    required this.name,
    required this.relationship,
    required this.contextNotes,
    this.localImagePath,
    this.photoUrl,
    this.isDemo = false,
    this.age,
    this.city,
  });

  /// Primary 1-2 sentence description narrative
  String get fullNarrative {
    if (contextNotes.isNotEmpty) {
      return contextNotes.first;
    }
    final relation = relationship.isNotEmpty ? relationship : "Family member";
    final locStr = city != null && city!.isNotEmpty ? " — lives in $city" : "";
    return "$relation $name$locStr.";
  }

  /// Description narrative with the target person's name strictly removed for Hard difficulty level
  String get descriptionOnly {
    String text = fullNarrative;
    if (name.isNotEmpty) {
      // Remove occurrences of the person's name (case-insensitive)
      final regExp = RegExp(RegExp.escape(name), caseSensitive: false);
      text = text.replaceAll(regExp, '').replaceAll(RegExp(r'\s+'), ' ').trim();
      // Clean up leading dashes, colons, or double spaces
      text = text.replaceAll(RegExp(r'^[\s—\-:]+'), '').trim();
    }
    if (text.isEmpty) {
      final relation = relationship.isNotEmpty ? relationship : "Family member";
      final locStr = city != null && city!.isNotEmpty ? " — lives in $city" : "";
      return "$relation$locStr.";
    }
    return text;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'contextNotes': contextNotes,
      'localImagePath': localImagePath,
      'photoUrl': photoUrl,
      'isDemo': isDemo,
      'age': age,
      'city': city,
    };
  }

  factory PersonProfile.fromJson(Map<String, dynamic> json) {
    return PersonProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      contextNotes: List<String>.from(json['contextNotes'] ?? []),
      localImagePath: json['localImagePath'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isDemo: json['isDemo'] as bool? ?? false,
      age: json['age'] as String?,
      city: json['city'] as String?,
    );
  }

  PersonProfile copyWith({
    String? id,
    String? name,
    String? relationship,
    List<String>? contextNotes,
    String? localImagePath,
    String? photoUrl,
    bool? isDemo,
    String? age,
    String? city,
  }) {
    return PersonProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      contextNotes: contextNotes ?? List<String>.from(this.contextNotes),
      localImagePath: localImagePath ?? this.localImagePath,
      photoUrl: photoUrl ?? this.photoUrl,
      isDemo: isDemo ?? this.isDemo,
      age: age ?? this.age,
      city: city ?? this.city,
    );
  }
}
