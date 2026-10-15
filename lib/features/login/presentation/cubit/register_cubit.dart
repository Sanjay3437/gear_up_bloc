import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gear_up_bloc/core/constants/constant.dart';
import 'package:gear_up_bloc/core/database/hive_storage_service.dart';
import 'package:gear_up_bloc/core/network/network_service.dart';
import 'package:gear_up_bloc/core/utils/configuration.dart';
import 'package:gear_up_bloc/core/utils/error_logger.dart';
import 'package:gear_up_bloc/features/login/data/models/login_response.dart';
import 'package:gear_up_bloc/features/login/data/models/register_request.dart';
import 'package:gear_up_bloc/features/login/domain/use_case/login_use_case.dart';
import 'package:gear_up_bloc/shared/models/user_data.dart';
import 'package:get_it/get_it.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final LoginUseCases _loginUseCases;
  final HiveService _hiveService;
  final NetworkService _networkService;

  RegisterCubit(this._loginUseCases)
      : _hiveService = GetIt.instance<HiveService>(),
        _networkService = GetIt.instance<NetworkService>(),
        super(const RegisterState());

  void validateAndRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    String nameError = '';
    String emailError = '';
    String passwordError = '';

    if (name.trim().isEmpty) nameError = 'Please enter your full name';
    if (email.trim().isEmpty || !email.contains('@')) nameError = 'Please enter a valid email';
    if (password.length < 6) passwordError = 'Password must be at least 6 characters';

    if (nameError.isNotEmpty || emailError.isNotEmpty || passwordError.isNotEmpty) {
      emit(state.copyWith(
        nameError: nameError,
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    emit(state.copyWith(nameError: '', emailError: '', passwordError: ''));
    register(RegisterRequest(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim().isNotEmpty ? phone.trim() : null,
      password: password,
    ));
  }

  Future<void> register(RegisterRequest request) async {
    emit(state.copyWith(isLoading: true, isFailure: false, isSuccess: false));

    final result = await _loginUseCases.register(user: request);

    result.fold(
          (error) {
        ErrorLogger.log('RegisterCubit.register', error.identifier);
        emit(state.copyWith(
          isLoading: false,
          isFailure: true,
          isSuccess: false,
          errorMessage: error.message,
        ));
      },
          (response) {
        final userData = response.data?.user ?? UserData();

        UserPreferences.instance.setUser(userData);
        final token = response.accessToken ?? '';
        final refToken = response.refreshToken ?? '';
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
          registerData: response,
        ));
      },
    );
  }
}