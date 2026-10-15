import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gear_up_bloc/core/constants/constant.dart';
import 'package:gear_up_bloc/core/database/hive_storage_service.dart';
import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/core/network/network_service.dart';
import 'package:gear_up_bloc/core/utils/configuration.dart';
import 'package:gear_up_bloc/core/utils/error_logger.dart';
import 'package:gear_up_bloc/features/login/data/models/login_request.dart';
import 'package:gear_up_bloc/features/login/data/models/login_response.dart';
import 'package:gear_up_bloc/features/login/domain/use_case/login_use_case.dart';
import 'package:gear_up_bloc/shared/models/user_data.dart';
import 'package:get_it/get_it.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCases _loginUseCases;
  final HiveService _hiveService;
  final NetworkService _networkService;

  LoginCubit(this._loginUseCases)
      : _hiveService = GetIt.instance<HiveService>(),
        _networkService = GetIt.instance<NetworkService>(),
        super(const LoginState());

  void validate(String username, String password) {
    String usernameError = '';
    String passwordError = '';

    if (username.trim().isEmpty) {
      usernameError = 'Please enter your username/email';
    }

    if (password.trim().isEmpty) {
      passwordError = 'Please enter your password';
    }

    if (usernameError.isNotEmpty || passwordError.isNotEmpty) {
      emit(state.copyWith(
        usernameError: usernameError,
        passwordError: passwordError,
      ));
    } else {
      emit(state.copyWith(usernameError: '', passwordError: ''));
      login(LoginRequest(username: username.trim(), password: password));
    }
  }

  Future<void> login(LoginRequest user) async {
    emit(state.copyWith(isLoading: true, isFailure: false, isSuccess: false));

    Either<AppException, LoginResponse> result = await _loginUseCases.login(user: user);

    result.fold(
          (error) {
        ErrorLogger.log('LoginCubit.login', error.identifier);
        emit(state.copyWith(
          message: error.message,
          isLoading: false,
          isFailure: true,
          isSuccess: false,
        ));
      },
          (response) {
        final userData = response.data?.user ?? UserData();

        UserPreferences.instance.setUser(userData);

        String token = response.accessToken ?? '';
        String refToken = response.refreshToken ?? '';
        _hiveService.set(userToken, token);
        if (refToken.isNotEmpty) {
          _hiveService.set(refreshToken, refToken);
        }
        _hiveService.setUser(userData);

        _networkService.updateHeader({'Authorization': 'Bearer $token'});

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          isFailure: false,
          loginData: response,
        ));
      },
    );
  }

  void resetError() {
    emit(state.copyWith(isFailure: false, message: ''));
  }
}