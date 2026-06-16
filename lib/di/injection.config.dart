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
import 'package:termchat_app/core/repositories/chat_repository.dart' as _i681;
import 'package:termchat_app/core/repositories/identity_repository.dart'
    as _i32;
import 'package:termchat_app/core/repositories/room_repository.dart' as _i967;
import 'package:termchat_app/core/repositories/settings_repository.dart'
    as _i805;
import 'package:termchat_app/features/chat/bloc/chat_bloc.dart' as _i213;
import 'package:termchat_app/features/rooms/bloc/rooms_bloc.dart' as _i1055;
import 'package:termchat_app/features/settings/bloc/identity/identity_bloc.dart'
    as _i48;
import 'package:termchat_app/features/settings/bloc/settings/settings_bloc.dart'
    as _i395;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i805.SettingsRepository>(
      () => _i805.SettingsRepositoryImpl(),
    );
    gh.lazySingleton<_i681.ChatRepository>(() => _i681.ChatRepositoryImpl());
    gh.factory<_i213.ChatBloc>(
      () => _i213.ChatBloc(gh<_i681.ChatRepository>()),
    );
    gh.lazySingleton<_i967.RoomRepository>(() => _i967.RoomRepositoryImpl());
    gh.factory<_i1055.RoomsBloc>(
      () => _i1055.RoomsBloc(gh<_i967.RoomRepository>()),
    );
    gh.lazySingleton<_i32.IdentityRepository>(
      () => _i32.IdentityRepositoryImpl(),
    );
    gh.factory<_i395.SettingsBloc>(
      () => _i395.SettingsBloc(gh<_i805.SettingsRepository>()),
    );
    gh.factory<_i48.IdentityBloc>(
      () => _i48.IdentityBloc(gh<_i32.IdentityRepository>()),
    );
    return this;
  }
}
