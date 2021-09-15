import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

class MockLogin extends Mock implements GoogleSignIn {}

void main() async {
  MockLogin mockLogin = MockLogin();

  test('Google login function worked', () {
    mockLogin.signIn();
    verify(mockLogin.signIn());
  });
}
