class UserEntity {
  final int id;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;
  final String? staffId; 
   final String? photoUrl;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    this.staffId,
    required this.photoUrl
  });
}
