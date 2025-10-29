import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

extension GoogleSignInAccountToAuthClient on GoogleSignInAccount {
  Future<auth.AuthClient> toAuthClient() async {
    final GoogleSignInAuthentication googleAuth = await authentication;
    final auth.AccessCredentials credentials = auth.AccessCredentials(
      auth.AccessToken(
        'Bearer',
        googleAuth.accessToken!,
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      googleAuth.idToken,
      ['openid'],
    );
    return auth.authenticatedClient(
      http.Client(),
      credentials,
    );
  }
}
