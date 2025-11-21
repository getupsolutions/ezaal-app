import 'package:ezaal/features/user_side/login_screen/domain/Entity/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.accessToken,
    required super.refreshToken,
    super.staffId,
    super.photoUrl,
    required super.role,
  });

  // Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      staffId: entity.staffId,
      photoUrl: entity.photoUrl,
      role: entity.role,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return UserModel(
      id: int.parse(data['id'].toString()),
      name: data['name'] ?? data['sname'] ?? 'User',
      email: data['email'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      staffId: data['staffId'] ?? data['typeId'],
      photoUrl: data['photo'],
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'id': id.toString(),
        'name': name,
        'email': email,
        'staffId': staffId,
        'photo': photoUrl,
        'role' : role,
      },
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
