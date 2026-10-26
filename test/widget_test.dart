import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:setools_final_project_xanikk/main.dart';
import 'package:setools_final_project_xanikk/providers/backlog_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app starts and shows the three tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BacklogProvider(),
        child: const CartridgeApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Backlog'), findsWidgets);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Stats'), findsWidgets);
  });
}