// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:termchat_app/data/cache/message_cache.dart' as _i347;
import 'package:termchat_app/data/cache/room_session_cache.dart' as _i945;
import 'package:termchat_app/features/chat/bloc/chat_bloc.dart' as _i213;
import 'package:termchat_app/features/chat/managers/active_chats_manager.dart'
    as _i605;
import 'package:termchat_app/features/chat/repositories/chat_repository.dart'
    as _i811;
import 'package:termchat_app/features/rooms/bloc/rooms_bloc.dart' as _i1055;
import 'package:termchat_app/features/rooms/repositories/room_repository.dart'
    as _i949;
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart'
    as _i48;
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart'
    as _i395;
import 'package:termchat_app/features/settings/repositories/identity_repository.dart'
    as _i351;
import 'package:termchat_app/features/settings/repositories/settings_repository.dart'
    as _i732;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i811.ChatRepository>(
      () => _i811.ChatRepositoryImpl(gh<_i347.MessageCache>()),
    );
    gh.lazySingleton<_i351.IdentityRepository>(
      () => _i351.IdentityRepositoryImpl(),
    );
    gh.lazySingleton<_i732.SettingsRepository>(
      () => _i732.SettingsRepositoryImpl(),
    );
    gh.lazySingleton<_i48.IdentityBloc>(
      () => _i48.IdentityBloc(gh<_i351.IdentityRepository>()),
    );
    gh.lazySingleton<_i949.RoomRepository>(() => _i949.RoomRepositoryImpl());
    gh.lazySingleton<_i395.SettingsBloc>(
      () => _i395.SettingsBloc(gh<_i732.SettingsRepository>()),
    );
    gh.factory<_i1055.RoomsBloc>(
      () => _i1055.RoomsBloc(gh<_i949.RoomRepository>()),
    );
    gh.lazySingleton<_i605.ActiveChatsManager>(
      () => _i605.ActiveChatsManager(gh<_i945.RoomSessionCache>()),
    );
    gh.factory<_i213.ChatBloc>(
      () => _i213.ChatBloc(
        gh<_i811.ChatRepository>(),
        gh<_i48.IdentityBloc>(),
        gh<_i395.SettingsBloc>(),
        gh<_i945.RoomSessionCache>(),
      ),
    );
    return this;
  }
}
