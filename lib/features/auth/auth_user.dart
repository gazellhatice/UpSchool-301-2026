import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Firebase User'ı wrap eden immutable model.
/// Freezed sayesinde copyWith, ==, toString otomatik üretilir.
@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) = _AuthUser;

  /// Firebase User → AuthUser dönüşümü
  factory AuthUser.fromFirebase(dynamic user) => AuthUser(
        uid: user.uid as String,
        email: user.email as String,
        displayName: user.displayName as String?,
        photoUrl: user.photoURL as String?,
      );
}
