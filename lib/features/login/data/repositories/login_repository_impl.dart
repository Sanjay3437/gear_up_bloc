import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/features/login/data/data_source/login_remote_data_source.dart';
import 'package:gear_up_bloc/features/login/data/models/login_request.dart';
import 'package:gear_up_bloc/features/login/data/models/login_response.dart';
import 'package:gear_up_bloc/features/login/data/models/register_request.dart';
import 'package:gear_up_bloc/features/login/domain/repositories/login_repository.dart';


class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource _loginDataSource;

  LoginRepositoryImpl(this._loginDataSource);

  @override
  Future<Either<AppException, LoginResponse>> loginUser({
    required LoginRequest user,
  }) {
    return _loginDataSource.login(user: user);
  }

  @override
  Future<Either<AppException, LoginResponse>> registerUser({
    required RegisterRequest user,
  }) {
    return _loginDataSource.register(user: user);
  }
}