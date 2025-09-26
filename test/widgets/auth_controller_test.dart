import 'package:ecommerce/features/auth/application/auth_controller.dart';
import 'package:ecommerce/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late User mockUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser(); 
  });

  ProviderContainer createContainer({AuthRepository? authRepository}) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository ?? mockAuthRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthController Tests', () {
    test('Test 1: signIn avec succès met à jour l\'état de l\'utilisateur', () async {
      // ARRANGE
      when(mockAuthRepository.signIn('test@test.com', 'password')).thenAnswer((_) async => {});
      when(mockAuthRepository.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));
      when(mockAuthRepository.currentUser).thenReturn(null);

      final container = createContainer();
      final controller = container.read(authControllerProvider.notifier);

      // ACT
      await controller.signIn('test@test.com', 'password');

      // ASSERT
      verify(mockAuthRepository.signIn('test@test.com', 'password')).called(1);
      expect(controller.debugState.error, isNull);
      expect(controller.debugState.isLoading, isFalse);
    });

    test('Test 2: signIn avec une erreur met à jour l\'état avec un message d\'erreur', () async {
      // ARRANGE
      final exception = FirebaseAuthException(code: 'user-not-found', message: 'User not found');
      when(mockAuthRepository.signIn(any, any)).thenThrow(exception);
      when(mockAuthRepository.authStateChanges()).thenAnswer((_) => Stream.value(null));
      when(mockAuthRepository.currentUser).thenReturn(null);

      final container = createContainer();
      final controller = container.read(authControllerProvider.notifier);

      // ACT
      await controller.signIn('test@test.com', 'wrong-password');

      // ASSERT
      expect(controller.debugState.error, 'User not found');
      expect(controller.debugState.isLoading, isFalse);
    });

  });
}