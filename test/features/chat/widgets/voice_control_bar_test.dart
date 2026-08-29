import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/features/chat/widgets/voice_control_bar.dart';

void main() {
  Widget buildWidget({
    required ValueChanged<bool> onSetTransmitting,
    bool isTransmitting = false,
    int speakersCount = 1,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: VoiceControlBar(
          isTransmitting: isTransmitting,
          speakersCount: speakersCount,
          onSetTransmitting: onSetTransmitting,
        ),
      ),
    );
  }

  group('VoiceControlBar', () {
    testWidgets('renders status labels and speaker count', (tester) async {
      await tester.pumpWidget(
        buildWidget(onSetTransmitting: (_) {}, speakersCount: 3),
      );

      expect(find.text('hold the mic to talk'), findsOneWidget);
      expect(find.text('3 in voice'), findsOneWidget);
    });

    testWidgets('hold to talk transmits on pointer down and stops on up', (
      tester,
    ) async {
      final calls = <bool>[];
      await tester.pumpWidget(buildWidget(onSetTransmitting: calls.add));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('voice_ptt_button'))),
      );
      await tester.pump();
      expect(calls, [true]);

      await gesture.up();
      await tester.pump();
      expect(calls, [true, false]);
    });

    testWidgets('lock enables hands-free transmit without further input', (
      tester,
    ) async {
      final calls = <bool>[];
      await tester.pumpWidget(buildWidget(onSetTransmitting: calls.add));

      await tester.tap(find.byTooltip('Lock transmit on'));
      await tester.pump();
      expect(calls, [true]);
      expect(find.text('voice locked on - tap mic to stop'), findsOneWidget);

      // No pointer interaction has happened, so no further callbacks fire.
      expect(calls, [true]);
    });

    testWidgets('tapping the mic while locked stops and unlocks', (
      tester,
    ) async {
      final calls = <bool>[];
      await tester.pumpWidget(buildWidget(onSetTransmitting: calls.add));

      await tester.tap(find.byTooltip('Lock transmit on'));
      await tester.pump();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('voice_ptt_button'))),
      );
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(calls, [true, false]);
      expect(find.text('hold the mic to talk'), findsOneWidget);
    });
  });
}
