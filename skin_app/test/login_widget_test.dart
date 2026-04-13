import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:skin_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  
  testGoldens('Login Screen Exact UI Test', (tester) async {
    // 1. Load the screen directly
    await tester.pumpWidgetBuilder(
      const LoginScreen(),
      wrapper: materialAppWrapper(
        theme: ThemeData.light(),
      ),
      surfaceSize: const Size(400, 800),
    );

    // 2. Capture the EXACT screenshot
    await screenMatchesGolden(tester, 'login_screen_exact');
  });
}
