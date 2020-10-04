import 'package:flutter_chat/chat_list/models/auth_model.dart';
import 'package:flutter_chat/repository/user_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockUserRepo extends Mock implements UserRepository {}
class MockFlutterToast extends Mock implements Fluttertoast {}

void main() {
  MockUserRepo mockRepo;
  group('Auth state', () {
    setUpAll(() {
      mockRepo = MockUserRepo();
      when(mockRepo.isSignedIn()).thenAnswer((realInvocation) => false);
    });
    test('WHEN no saved user THEN state is none', () {
      // given

      // when
      final model = AuthModel(mockRepo);

      // then
      expect(model.result, AuthResult.none);
    });

    test('WHEN there is saved user THEN state is signedIn', () {
      // given
      when(mockRepo.isSignedIn()).thenAnswer((realInvocation) => true);

      // when
      final model = AuthModel(mockRepo);

      // then
      expect(model.result, AuthResult.signedIn);
    });

    test('WHEN google sign success THEN state is signedIn', () async {
      // given
      when(mockRepo.signInWithGoogle()).thenAnswer((realInvocation) =>
          Stream.fromIterable([AuthResult.signedIn]));
      final model = AuthModel(mockRepo);

      // when
      await model.signInWithGoogle();

      // then
      verify(mockRepo.signInWithGoogle()).called(1);
      expect(model.result, AuthResult.signedIn);
    });

    test('WHEN google sign failed THEN state is failed', () async {
      // given
      when(mockRepo.signInWithGoogle()).thenAnswer((realInvocation) =>
          Stream.fromIterable([AuthResult.failed]));
      final model = AuthModel(mockRepo);

      // when
      await model.signInWithGoogle();

      // then
      verify(mockRepo.signInWithGoogle()).called(1);
      expect(model.result, AuthResult.failed);
    });

    test('WHEN google throws error THEN state is failed', () async {
      // given
      when(mockRepo.signInWithGoogle()).thenThrow("error");
      final model = AuthModel(mockRepo);

      // when
      await model.signInWithGoogle();

      // then
      verify(mockRepo.signInWithGoogle()).called(1);
      expect(model.result, AuthResult.failed);
    });
  });
}
