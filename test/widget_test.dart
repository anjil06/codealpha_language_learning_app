import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingualearn/app/app.dart';
import 'package:lingualearn/core/services/app_providers.dart';
import 'package:lingualearn/core/services/storage_service.dart';

void main() {
  testWidgets('LinguaLearn App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
        child: const LinguaLearnApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Onboarding screen is loaded initially
    expect(find.text('Learn a New Language'), findsOneWidget);
  });
}
