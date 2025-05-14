import 'dart:developer';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

enum SocialType { facebook, google, twitter, apple }

class LoginSocialResult {
  bool success;
  dynamic id;
  String? code;
  String? accessToken;
  String? secretToken;
  SocialType type;
  String? fullName;
  String? email;
  String? avatar;

  bool get isSuccess => success;

  LoginSocialResult(
      {this.accessToken,
      this.code,
      this.secretToken,
      this.success = false,
      this.email,
      required this.type,
      this.id,
      this.avatar,
      this.fullName});

  @override
  String toString() {
    return 'LoginSocialResult{success: $success, id: $id, code: $code, accessToken: $accessToken, secretToken: $secretToken, type: $type, fullName: $fullName, email: $email, avatar: $avatar}';
  }
}

class SocialService {
  SocialService._();

  Logger logger = Logger();
  static SocialService? _instance;

  factory SocialService() {
    _instance ??= SocialService._();
    return _instance!;
  }

  Future<LoginSocialResult> signInGoogle() async {
    LoginSocialResult result = LoginSocialResult(type: SocialType.google);

    try {
      if (await GoogleSignIn().isSignedIn()) {
        print("Signing out previous Google session...");
        await GoogleSignIn().signOut();
      }
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return throw Exception('GoogleSignInAccount from google null!');
      }
      if (await GoogleSignIn().isSignedIn()) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        logger.i('google info: $googleUser');
        logger.i('google info accessToken: ${googleAuth.accessToken}');
        log('google info accessToken: ${googleAuth.accessToken}');
        logger.i('google info idToken: ${googleAuth.idToken}');
        result.id = googleUser.id;
        result.fullName = googleUser.displayName;
        result.email = googleUser.email;
        result.avatar = googleUser.photoUrl;
        result.accessToken = googleAuth.accessToken;
        result.success = true;
      }
    } catch (error) {
      log('signInGoogle: $error');
    }
    return result;
  }
}
