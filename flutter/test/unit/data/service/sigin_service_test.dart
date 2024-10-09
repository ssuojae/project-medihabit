import 'package:flutter_test/flutter_test.dart';
import 'package:medihabit/data/services/implements/signin_service.dart';
import 'package:mockito/mockito.dart';

import '../repository/mock/mock_repositories.mocks.dart';


void main() {
  late MockIUserRepository mockUserRepository;
  late SignInService signInService;

  setUp(() {
    mockUserRepository = MockIUserRepository();
    signInService = SignInService(mockUserRepository);
  });

  test('given: 구글 로그인을 성공적으로 했을 때, when: signInWithGoogle을 호출하면, then: true를 반환해야 한다', () async {
    // given
    when(mockUserRepository.signInWithGoogle()).thenAnswer((_) async => {});

    // when
    final result = await signInService.signInWithGoogle();

    // then
    expect(result, isTrue);
  });

  test('given: 애플 로그인을 실패했을 때, when: signInWithApple을 호출하면, then: false를 반환해야 한다', () async {
    // given
    when(mockUserRepository.signInWithApple()).thenThrow(Exception());

    // when
    final result = await signInService.signInWithApple();

    // then
    expect(result, isFalse);
  });
}
