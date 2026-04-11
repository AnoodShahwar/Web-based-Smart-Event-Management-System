class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // Converts Firestore document into a UserModel object
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Converts UserModel object into a Map to save in Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'role': role, 'createdAt': createdAt};
  }
}
