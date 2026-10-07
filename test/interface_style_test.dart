import 'package:daily_you/config_provider.dart';
import 'package:daily_you/interface_style.dart';
import 'package:daily_you/l10n/generated/app_localizations.dart';
import 'package:daily_you/widgets/persona_day_header.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'support/config_provider_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  useTemporaryConfig();

  test('default preserves the original theme and unknown styles fall back', () {
    final base = ThemeData(colorSchemeSeed: Colors.green);
    expect(applyInterfaceStyle(base, InterfaceStyle.standard), same(base));
    expect(InterfaceStyle.fromKey('unknown'), InterfaceStyle.standard);
  });

  test('style persists independently of existing appearance preferences',
      () async {
    final config = ConfigProvider.instance;
    await config.set(Settings.theme, 'amoled');
    await config.set(Settings.accentColor, 0xff123456);
    await config.set(Settings.interfaceStyle, 'p5');
    EasyDebounce.fire('save-config');
    final file = File(config.configFilePath);
    for (var i = 0; i < 100; i++) {
      if (file.existsSync() && file.readAsStringSync().contains('p5')) break;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await config.readConfig();
    expect(config.get(Settings.interfaceStyle), 'p5');
    expect(config.get(Settings.theme), 'amoled');
    expect(config.get(Settings.accentColor), 0xff123456);
    expect(Settings.all, contains(Settings.interfaceStyle));
  });

  testWidgets('date header fits a narrow screen with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('zh'),
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: const Scaffold(
            body: Column(children: [
          PersonaDayHeader(style: InterfaceStyle.p3),
          PersonaDayHeader(style: InterfaceStyle.p5),
        ])),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final context = tester.element(find.byType(PersonaDayHeader).first);
    final l10n = AppLocalizations.of(context)!;
    expect(personaPeriod(DateTime(2026, 10, 5, 4, 59), l10n),
        l10n.personaLateNight);
    expect(personaPeriod(DateTime(2026, 10, 5, 5), l10n),
        l10n.personaEarlyMorning);
    expect(personaPeriod(DateTime(2026, 10, 5, 12), l10n), l10n.personaNoon);
    expect(
        personaPeriod(DateTime(2026, 10, 5, 22), l10n), l10n.personaLateNight);
    await tester.pumpWidget(const SizedBox());
  });
}
