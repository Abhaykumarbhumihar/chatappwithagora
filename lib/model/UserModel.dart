class UserModel {
  final String? email;
  final String? fname;
  final String? lname;
  final String? password;
  final String? profileImage;
  final String? id;

  UserModel({
  this.email,
  this.fname,
  this.lname,
  this.password,
  this.profileImage,
    this.id
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      fname: map['fname'] ?? '',
      lname: map['lanme'] ?? '',
      password: map['password'] ?? '',
      id: map['id'] ?? '',
      profileImage: map['profile_image'] ?? '',
    );
  }
}
