import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../features/chat/bloc/chat_bloc.dart';
import '../features/chat/managers/active_chats_manager.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  getIt.init();

  // Manual: injectable can't resolve the ChatBloc factory function type.
  getIt.registerLazySingleton<ActiveChatsManager>(
    () => ActiveChatsManager(() => getIt<ChatBloc>()),
  );
}
