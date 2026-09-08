import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';
import '../features/chat/bloc/chat_bloc.dart';
import '../features/chat/managers/active_chats_manager.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  getIt.init();

  // ActiveChatsManager needs a ChatBloc factory (a function type, which the
  // injectable generator can't resolve). Register it manually, wired to the
  // factory ChatBloc so it stays mockable and out of the service locator.
  getIt.registerLazySingleton<ActiveChatsManager>(
    () => ActiveChatsManager(() => getIt<ChatBloc>()),
  );
}
