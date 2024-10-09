import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:medihabit/data/services/implements/user_info_service.dart';
import '../repository/mock/mock_repositories.mocks.dart';


void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late UserInfoService userInfoService;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    userInfoService = UserInfoService(mockFirebaseAuth);
  });

  test('given: 유저가 로그인되어 있을 때, when: currentUser를 호출하면, then: 유저 정보가 반환되어야 한다', () {
    // given
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('user_123');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.photoURL).thenReturn('http://example.com/photo.jpg');

    // when
    final user = userInfoService.currentUser;

    // then
    expect(user, isNotNull);
    expect(user!.id, 'user_123');
    expect(user.name, 'Test User');
    expect(user.email, 'test@example.com');
    expect(user.photoUrl, 'http://example.com/photo.jpg');
  });

  test('given: 유저가 로그인되어 있지 않을 때, when: currentUser를 호출하면, then: null이 반환되어야 한다', () {
    // given
    when(mockFirebaseAuth.currentUser).thenReturn(null);

    // when
    final user = userInfoService.currentUser;

    // then
    expect(user, isNull);
  });
}
