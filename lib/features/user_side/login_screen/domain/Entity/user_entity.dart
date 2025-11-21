class UserEntity {
  final int id;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;
  final String? staffId;
  final String? photoUrl;
  final String role;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    this.staffId,
    required this.photoUrl,
    required this.role,
  });
  bool get isAdmin {
    final lowerRole = role.toLowerCase();
    return lowerRole.contains('admin');
  }

  // Check if user is regular user
  bool get isUser => !isAdmin;
}
