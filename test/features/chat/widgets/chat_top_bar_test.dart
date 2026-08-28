import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/features/chat/widgets/chat_top_bar.dart';

void main() {
  Widget buildWidget({bool voiceActive = false, VoidCallback? onToggleVoice}) {
    return MaterialApp(
      home: Scaffold(
        appBar: ChatTopBar(
          roomName: 'FROG',
          usersCount: 2,
          onOpenDrawer: () {},
          voiceActive: voiceActive,
          onToggleVoice: onToggleVoice,
        ),
        body: const SizedBox(),
      ),
    );
  }

  group('ChatTopBar', () {
    testWidgets('hides the mic button when no toggle handler is provided', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.mic_none), findsNothing);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('shows an inactive mic button and toggles on tap', (
      tester,
    ) async {
      var toggled = false;
      await tester.pumpWidget(buildWidget(onToggleVoice: () => toggled = true));

      expect(find.byIcon(Icons.mic_none), findsOneWidget);

      await tester.tap(find.byIcon(Icons.mic_none));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('shows an active mic when voice is joined', (tester) async {
      await tester.pumpWidget(
        buildWidget(voiceActive: true, onToggleVoice: () {}),
      );

      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byTooltip('Leave voice'), findsOneWidget);
    });
  });
}
