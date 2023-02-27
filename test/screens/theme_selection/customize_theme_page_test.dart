import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:seg_coursework_app/pages/theme_page/customize_theme_page.dart';
import 'package:seg_coursework_app/pages/theme_page/theme_page.dart';
import 'package:seg_coursework_app/themes/theme_provider.dart';
import 'package:seg_coursework_app/themes/themes.dart';


void main() {

  testWidgets('Add theme page loads, theme changing and save buttons are loaded', 
    (WidgetTester tester) async {
      mockNetworkImagesFor(() async {

    // Build our app and trigger a frame.
    await tester.pumpWidget(ThemeProvider(themeNotifier: CustomTheme(), child: MaterialApp(home: ThemePage(),)));

    await tester.tap(find.byKey(const ValueKey("addThemeButton")));
    await tester.pumpAndSettle();

    expect(find.byType(CustomizeThemePage), findsOneWidget);

    expect(find.byKey(const ValueKey("menuColorListTile")), findsOneWidget);
    expect(find.byKey(const ValueKey("backgroundColorListTile")), findsOneWidget);
    expect(find.byKey(const ValueKey("buttonsColorListTile")), findsOneWidget);
    expect(find.byKey(const ValueKey("iconsAndTextsColorListTile")), findsOneWidget);

    expect(find.byKey(const ValueKey("saveButton")), findsOneWidget);

  });
  });
  
  testWidgets('Simulate creating a new theme and applying it.', 
    (WidgetTester tester) async {
      mockNetworkImagesFor(() async {

    // Build our app and trigger a frame.
    await tester.pumpWidget(ThemeProvider(themeNotifier: CustomTheme(), child: MaterialApp(home: ThemePage(),)));

    await tester.tap(find.byKey(const ValueKey("addThemeButton")));
    await tester.pumpAndSettle();

    final initialTheme = CustomTheme().getTheme();

    // Tap menuColorListTile and pick a color
    await tester.tap(find.byKey(ValueKey('menuColorListTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Tap backgroundColorListTile and pick a color
    await tester.tap(find.byKey(ValueKey('backgroundColorListTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Tap buttonsColorListTile and pick a color
    await tester.tap(find.byKey(ValueKey('buttonsColorListTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Tap iconsAndTextsColorListTile and pick a color
    await tester.tap(find.byKey(ValueKey('iconsAndTextsColorListTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('blackButton')));
    await tester.pumpAndSettle();

    // Tap saveButton
    await tester.tap(find.byKey(ValueKey('saveButton')));
    await tester.pump();

    await tester.tap(find.byKey(ValueKey("backButton")));
    await tester.pumpAndSettle();

    // Choose the newly created theme.
    await tester.tap(find.text("Custom theme", skipOffstage: false), warnIfMissed: false);
    await tester.pumpAndSettle();
    
    final newTheme = CustomTheme().getTheme();

    // Verify that the theme has changed
    expect(newTheme, isNot(equals(initialTheme)));

  });
  });
}
