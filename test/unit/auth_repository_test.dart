import 'package:flutter_test/flutter_test.dart';
import 'package:toem_here/features/auth/data/auth_repository.dart';
import 'package:toem_here/features/auth/domain/models/user.dart';

void main() {
  group('DemoAuthRepository', () {
    late DemoAuthRepository repository;

    setUp(() {
      repository = DemoAuthRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('starts signed out', () async {
      await expectLater(repository.watchCurrentUser(), emits(null));
    });

    test('signInAnonymously creates demo explorer profile', () async {
      final user = await repository.signInAnonymously();

      expect(user.uid, 'demo-user');
      expect(user.displayName, 'Demo Explorer');
      expect(user.totalCollected, 3);
      await expectLater(
        repository.watchCurrentUser(),
        emits(
          isA<AppUser>()
              .having((user) => user.uid, 'uid', 'demo-user')
              .having(
                (user) => user.displayName,
                'displayName',
                'Demo Explorer',
              )
              .having((user) => user.totalCollected, 'totalCollected', 3),
        ),
      );
    });

    test('signOut clears current demo user', () async {
      await repository.signInAnonymously();
      await repository.signOut();

      await expectLater(repository.watchCurrentUser(), emits(null));
    });
  });
}
