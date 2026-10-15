import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gear_up_bloc/core/constants/asset_path.dart';
import 'package:gear_up_bloc/core/constants/routes.dart';
import 'package:gear_up_bloc/core/dependency_injection/injector.dart';
import 'package:gear_up_bloc/features/login/domain/use_case/login_use_case.dart';
import 'package:gear_up_bloc/features/login/presentation/cubit/login_cubit.dart';
import 'package:gear_up_bloc/shared/config/dimens.dart';
import 'package:gear_up_bloc/shared/theme/app_colors.dart';
import 'package:gear_up_bloc/shared/theme/text_styles.dart';
import 'package:gear_up_bloc/shared/widgets/custom_text_input.dart';
import 'package:gear_up_bloc/shared/widgets/custom_toast.dart';
import 'package:gear_up_bloc/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late LoginCubit _loginCubit;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loginCubit = LoginCubit(injector<LoginUseCases>());
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _loginCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _loginCubit,
      child: Scaffold(
        backgroundColor: AppColors.surfaceColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.standard_24),
            child: BlocConsumer<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state.isSuccess && state.loginData != null) {
                  context.go(RoutesName.homePage);
                } else if (state.isFailure && state.message.isNotEmpty) {
                  CustomToast.showErrorToast(context, state.message);
                  _loginCubit.resetError();
                }
              },
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimens.standard_40),
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.sports_motorsports_rounded,
                            size: Dimens.standard_70,
                            color: AppColors.colorGreen,
                          ),
                          const SizedBox(height: Dimens.standard_12),
                          Text(
                            'GEAR UP',
                            style: AppTextStyles.openSansBold28.copyWith(
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            'Rider Apparel & Equipment',
                            style: AppTextStyles.openSansRegular12.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimens.standard_48),
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.openSansBold24.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Dimens.standard_7),
                    Text(
                      'Sign in to manage gear, garage orders & wishlist',
                      style: AppTextStyles.openSansRegular14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: Dimens.standard_32),
                    CustomTextInput(
                      textEditingController: usernameController,
                      hintText: 'Enter email or phone',
                      title: 'Email / Username',
                      svgIconPath: AssetPath.emailIcon,
                      inputType: TextInputType.emailAddress,
                    ),
                    if (state.usernameError.isNotEmpty)
                      _buildErrorText(state.usernameError),
                    const SizedBox(height: Dimens.standard_16),
                    CustomTextInput(
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      title: 'Password',
                      svgIconPath: AssetPath.eyeOpenIcon,
                      isPassword: true,
                    ),
                    if (state.passwordError.isNotEmpty)
                      _buildErrorText(state.passwordError),
                    const SizedBox(height: Dimens.standard_32),
                    PrimaryButton(
                      text: 'SIGN IN',
                      isLoading: state.isLoading,
                      onPressed: () {
                        _loginCubit.validate(
                          usernameController.text,
                          passwordController.text,
                        );
                      },
                    ),
                    const SizedBox(height: Dimens.standard_24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.openSansRegular14.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(RoutesName.signUp),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.openSansBold14.copyWith(
                              color: AppColors.colorGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.standard_6),
      child: Text(
        error,
        style: AppTextStyles.openSansRegular12.copyWith(color: AppColors.colorRed),
      ),
    );
  }
}