class User {
  final String id; // Assuming you have a unique ID for each user in Firestore
  final String username;
  final String name;
  final String email;
  final String shortDescription;
  final List<int> interests;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.shortDescription,
    required this.interests,
  });

  // Factory constructor to create a User object from a map (Firestore data)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      name: map['name'],
      email: map['email'],
      shortDescription: map['shortDescription'],
      interests: List<int>.from(map['interests']),
    );
  }
}