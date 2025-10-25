import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

extension GoogleSignInAsGoogleApisAuth on GoogleSignIn {
  Future<auth.AuthClient?> authenticatedClient() async {
    final GoogleSignInAccount? googleSignInAccount = await this.signIn();
    if (googleSignInAccount == null) {
      return null;
    }
    final auth.AccessCredentials credentials = await googleSignInAccount.authentication
        .then((auth.Authentication auth) {
      return auth.accessToken == null
          ? throw Exception('Access token is null')
          : auth.AccessCredentials(
              auth.AccessToken(
                'Bearer',
                auth.accessToken!,
                DateTime.now().toUtc().add(const Duration(hours: 1)),
              ),
              googleSignInAccount.id,
              ['openid'],
            );
    });
    return auth.authenticatedClient(
        auth.Client(),
        credentials,
        closeUnderlyingClient: false,
    );
  }
}
