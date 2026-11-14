import 'dart:io';

import 'package:astrox/core/database/app_database.dart';
import 'package:astrox/data/models/assistant_message.dart';
import 'package:astrox/features/assistant/view/assistant_screen.dart';
import 'package:astrox/features/user/cubit/user_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('suggestions and typed messages are user-only chat entries', (
    tester,
  ) async {
    final fixture = await _AssistantFixture.create();
    addTearDown(() => fixture.dispose(tester));
    await _pumpAssistant(tester, fixture);

    expect(find.textContaining('Hi Mina Chen.'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Send'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('assistantMessageInput')),
          )
          .maxLines,
      4,
    );
    expect(
      find.byKey(const ValueKey('suggestion-Explain my heart rate.')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('suggestion-Explain my heart rate.')),
    );
    await tester.pumpAndSettle();
    final suggestedMessage = find.byKey(const ValueKey('assistantMessage-0'));
    expect(suggestedMessage, findsOneWidget);
    expect(
      find.descendant(
        of: suggestedMessage,
        matching: find.text('Explain my heart rate.'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Try a fixed'), findsNothing);

    final input = find.byKey(const ValueKey('assistantMessageInput'));
    await tester.enterText(input, 'What does my latest sleep reading mean?');
    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();

    final sentMessage = find.byKey(const ValueKey('assistantMessage-1'));
    expect(sentMessage, findsOneWidget);
    expect(
      find.descendant(
        of: sentMessage,
        matching: find.text('What does my latest sleep reading mean?'),
      ),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(input).controller!.text, isEmpty);
    expect(
      find.text('Guidance only, not a medical diagnosis.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'chat scrolls to the latest message at desktop and tablet sizes',
    (tester) async {
      final fixture = await _AssistantFixture.create();
      addTearDown(() => fixture.dispose(tester));

      for (final size in [
        const Size(1280, 900),
        const Size(720, 900),
        const Size(360, 760),
      ]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await _pumpAssistant(
          tester,
          fixture,
          screenKey: ValueKey('assistant-${size.width}'),
        );

        final input = find.byKey(const ValueKey('assistantMessageInput'));
        for (var i = 0; i < 14; i++) {
          await tester.enterText(input, 'Message $i');
          await tester.tap(find.widgetWithText(FilledButton, 'Send'));
          await tester.pumpAndSettle();
        }

        final latest = find.byKey(const ValueKey('assistantMessage-13'));
        expect(latest, findsOneWidget);
        expect(
          tester.getRect(latest).bottom,
          lessThan(tester.getRect(input).top),
        );
        expect(tester.takeException(), isNull);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  test('message model carries roles, timestamps, and loading state', () {
    final createdAt = DateTime(2026, 11, 14);
    final message = AssistantMessage(
      role: AssistantMessageRole.assistant,
      text: 'Welcome',
      createdAt: createdAt,
      isLoading: true,
    );
    expect(message.role, AssistantMessageRole.assistant);
    expect(message.createdAt, createdAt);
    expect(message.isLoading, isTrue);
  });
}

Future<void> _pumpAssistant(
  WidgetTester tester,
  _AssistantFixture fixture, {
  Key? screenKey,
}) async {
  await tester.pumpWidget(
    BlocProvider<UserCubit>.value(
      value: fixture.userCubit,
      child: MaterialApp(
        home: Scaffold(body: AssistantScreen(key: screenKey)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _AssistantFixture {
  _AssistantFixture(this.directory, this.database, this.userCubit);

  final Directory directory;
  final AppDatabase database;
  final UserCubit userCubit;

  static Future<_AssistantFixture> create() async {
    final directory = await Directory.systemTemp.createTemp(
      'astrox_assistant_',
    );
    final database = AppDatabase(
      connection: NativeDatabase(
        File('${directory.path}${Platform.pathSeparator}assistant.db'),
      ),
    );
    final userCubit = UserCubit(database: database);
    await userCubit.register('Mina Chen', 'AST-TEST');
    return _AssistantFixture(directory, database, userCubit);
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await userCubit.close();
    await database.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
