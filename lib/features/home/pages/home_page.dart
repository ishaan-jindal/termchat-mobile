import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/home_header.dart';
import '../widgets/room_action_card.dart';
import '../widgets/room_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../rooms/bloc/rooms_bloc.dart';
import '../../../core/utils/room_join_helper.dart';

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
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<RoomsBloc>().add(LoadActiveSessions());
              },
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                children: [
                  const SizedBox(height: AppConstants.spacing48),
                  const HomeHeader(),
                  const SizedBox(height: AppConstants.spacing48),

                  const RoomActionCard(),
                  const SizedBox(height: AppConstants.spacing48),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('rooms online now', style: textTheme.bodySmall),
                      GestureDetector(
                        onTap: () {
                          context.read<RoomsBloc>().add(LoadActiveSessions());
                        },
                        child: Text('refresh', style: textTheme.bodySmall),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing16),

                  BlocBuilder<RoomsBloc, RoomsState>(
                    builder: (context, state) {
                      if (state.isLoading && state.activeSessions.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.activeSessions.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'no public rooms right now.\ncreate one!',
                              style: textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: state.activeSessions.map((room) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.spacing16,
                            ),
                            child: GestureDetector(
                              onTap: () => RoomJoinHelper.joinRoom(
                                context,
                                room.id,
                                room.isLocked,
                              ),
                              child: RoomCard(
                                name: room.name,
                                users: room.usersCount,
                                isLocked: room.isLocked,
                                onJoin: () => RoomJoinHelper.joinRoom(
                                  context,
                                  room.name,
                                  room.isLocked,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
