import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_samy/main.dart';
import 'package:alarm_samy/services/app_state.dart';

void main() {
  testWidgets('Alarm Samy smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.initialize();

    await tester.pumpWidget(AlarmSamyApp(appState: appState));
    expect(find.text('Alarm Samy'), findsOneWidget);

    appState.dispose();
  });
}
