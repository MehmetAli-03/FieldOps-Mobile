class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final int? roleId;
  final int? teamId;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.roleId,
    this.teamId,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    if (roleId != null) 'roleId': roleId,
    if (teamId != null) 'teamId': teamId,
  };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;

  AuthResponse({required this.accessToken, required this.refreshToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? json['data']?['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? json['data']?['refreshToken'] ?? '',
    );
  }
}