class Contact {
  final String id;
  final String name;
  final String publicKey;
  final int lastSeen;

  Contact({
    required this.id,
    required this.name,
    required this.publicKey,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'publicKey': publicKey,
      'lastSeen': lastSeen,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      publicKey: map['publicKey'],
      lastSeen: map['lastSeen'],
    );
  }
}
