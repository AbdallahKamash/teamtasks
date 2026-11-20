import 'package:flutter_test/flutter_test.dart';
import 'package:teamtasks/router/router.dart';

void main() {
  String? redirect(
    String location, {
    bool signedIn = true,
    bool verified = true,
    bool signingOut = false,
    bool holding = false,
  }) => authRedirect(
    location: location,
    signedIn: signedIn,
    verified: verified,
    signingOut: signingOut,
    holdingLogin: holding,
  );

  group('authRedirect', () {
    test('signed out on a protected page goes to the welcome screen', () {
      expect(redirect('/settings', signedIn: false, verified: false), '/');
    });

    test('signed out may stay on public pages', () {
      expect(redirect('/auth', signedIn: false, verified: false), isNull);
      expect(redirect('/', signedIn: false, verified: false), isNull);
      expect(
        redirect('/forgot-password', signedIn: false, verified: false),
        isNull,
      );
    });

    test('login hold keeps the user on public pages', () {
      expect(redirect('/auth', holding: true), isNull);
      expect(redirect('/', verified: false, holding: true), isNull);
    });

    test('verified user on a public page goes home', () {
      expect(redirect('/auth'), '/home');
      expect(redirect('/forgot-password'), '/home');
    });

    test('unverified user is sent to /verify', () {
      expect(redirect('/home', verified: false), '/verify');
      expect(redirect('/verify', verified: false), isNull);
    });

    test('verified user on /verify goes home', () {
      expect(redirect('/verify'), '/home');
    });

    test('signing out pins every location to /', () {
      expect(redirect('/home', signingOut: true), '/');
      expect(redirect('/', signingOut: true), isNull);
      expect(redirect('/verify', verified: false, signingOut: true), '/');
    });

    test('verified user on a protected page stays', () {
      expect(redirect('/settings'), isNull);
      expect(redirect('/home'), isNull);
    });
  });
}
