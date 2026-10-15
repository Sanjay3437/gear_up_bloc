import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/features/login/data/models/login_request.dart';
import 'package:gear_up_bloc/features/login/data/models/login_response.dart';
import 'package:gear_up_bloc/features/login/data/models/register_request.dart';
import 'package:gear_up_bloc/features/login/domain/repositories/login_repository.dart';


class LoginUseCases {
  final LoginRepository _loginRepository;

  const LoginUseCases(this._loginRepository);

  Future<Either<AppException, LoginResponse>> login({
    required LoginRequest user,
  }) async {
    return _loginRepository.loginUser(user: user);
  }

  Future<Either<AppException, LoginResponse>> register({
    required RegisterRequest user,
  }) async {
    return _loginRepository.registerUser(user: user);
  }
}