import 'package:flutter/material.dart';

import '../widgets/home_header.dart';
import '../widgets/room_action_card.dart';
import '../widgets/room_card.dart';
import '../../../core/constants/app_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              children: [
                const SizedBox(height: AppConstants.spacingXxl),
                const HomeHeader(),
                const SizedBox(height: AppConstants.spacingXxl),

                const RoomActionCard(),
                const SizedBox(height: AppConstants.spacingXxl),

                // Rooms Online Now Header
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text('rooms online now', style: textTheme.bodySmall),
                    GestureDetector(
                      onTap: () {},
                      child: Text('refresh', style: textTheme.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Room List
                const RoomCard(name: 'FROG', users: 5, isLocked: false),
                const SizedBox(height: AppConstants.spacingMd),
                const RoomCard(name: 'ZCKT', users: 2, isLocked: true),
                const SizedBox(height: AppConstants.spacingMd),
                const RoomCard(name: 'BETA', users: 1, isLocked: false),
                const SizedBox(height: AppConstants.spacingXxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
