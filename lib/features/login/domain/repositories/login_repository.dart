import 'package:gear_up_bloc/core/exceptions/http_exception.dart';
import 'package:gear_up_bloc/core/network/model/either.dart';
import 'package:gear_up_bloc/features/login/data/models/login_request.dart';
import 'package:gear_up_bloc/features/login/data/models/login_response.dart';
import 'package:gear_up_bloc/features/login/data/models/register_request.dart';

abstract class LoginRepository {
  Future<Either<AppException, LoginResponse>> loginUser({
    required LoginRequest user,
  });

  Future<Either<AppException, LoginResponse>> registerUser({
    required RegisterRequest user,
  });
}