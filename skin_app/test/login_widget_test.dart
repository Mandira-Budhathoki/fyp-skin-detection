import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:skin_app/screens/login_screen.dart';

void main() {
  testGoldens('Login Screen Exact UI Test', (tester) async {
    // 1. Setup the specific device "look" (like an iPhone or Android)
    final builder = GoldenBuilder.column()
      ..addScenario('Professional Login State', const LoginScreen());

    // 2. Load everything and specify the screen size
    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
      ),
      surfaceSize: const Size(400, 800),
    );

    // 3. Capture the EXACT screenshot
    // This will create a high-fidelity image with REAL text
    await screenMatchesGolden(tester, 'login_screen_exact');
  });
}
