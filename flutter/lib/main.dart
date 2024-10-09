import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:medihabit/di/init_dependencies_main.dart';
import 'package:medihabit/presentation/login_scene/view/loginview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: '.env');
  setupLocator();
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        textTheme: GoogleFonts.juaTextTheme(),
        scaffoldBackgroundColor: Colors.white, // 배경색을 흰색으로 설정
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.transparent,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        // '/calendar': (context) => CalendarView(),
      },
    );
  }
}
