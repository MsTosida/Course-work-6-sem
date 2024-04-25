class UserModel {
  String? uid;
  String? email;
  String? name;
  String? role;
  String? imageUrl;


// receiving data
  UserModel({this.uid, this.email, this.name, this.role, this.imageUrl});
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
      imageUrl: map['imageUrl'],
    );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
    };
  }
}