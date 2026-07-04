import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kinto_mobile/main.dart';

void main() {
  testWidgets('app launches into onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KintoApp()));

    expect(find.text('長者友善資源地圖'), findsOneWidget);
    expect(find.text('允許使用定位'), findsOneWidget);
  });

  testWidgets('onboarding "先看看地圖" navigates to the map screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KintoApp()));

    await tester.tap(find.text('先看看地圖'));
    await tester.pumpAndSettle();

    expect(find.text('搜尋地點、地址'), findsOneWidget);
  });
}
