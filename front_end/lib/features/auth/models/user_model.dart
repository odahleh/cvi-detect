class UserModel {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoURL;
  
  const UserModel({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoURL,
  });
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
    };
  }
  
  // Create a copy with updated properties
  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
    );
  }
} 