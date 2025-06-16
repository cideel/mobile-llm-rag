class UserModel {
  String uid;
  String username;
  String email;
  String img;
  String role; // menambahkan atribut role

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.img,
    required this.role,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      img: map['img'] ?? '',
      role: map['role'] ?? 'user', // default 'user' jika tidak ada
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'img': img,
      'role': role, // menyertakan role saat menyimpan
    };
  }
}
