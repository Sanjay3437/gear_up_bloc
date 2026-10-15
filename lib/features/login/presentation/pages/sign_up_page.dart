import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gear_up_bloc/core/constants/asset_path.dart';
import 'package:gear_up_bloc/core/constants/routes.dart';
import 'package:gear_up_bloc/core/dependency_injection/injector.dart';
import 'package:gear_up_bloc/features/login/domain/use_case/login_use_case.dart';
import 'package:gear_up_bloc/features/login/presentation/cubit/register_cubit.dart';
import 'package:gear_up_bloc/shared/config/dimens.dart';
import 'package:gear_up_bloc/shared/theme/app_colors.dart';
import 'package:gear_up_bloc/shared/theme/text_styles.dart';
import 'package:gear_up_bloc/shared/widgets/custom_text_input.dart';
import 'package:gear_up_bloc/shared/widgets/custom_toast.dart';
import 'package:gear_up_bloc/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late RegisterCubit _registerCubit;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _registerCubit = RegisterCubit(injector<LoginUseCases>());
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    _registerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _registerCubit,
      child: Scaffold(
        backgroundColor: AppColors.surfaceColor,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.standard_24),
            child: BlocConsumer<RegisterCubit, RegisterState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  CustomToast.showSuccessToast(context, 'Account created successfully!');
                  context.go(RoutesName.homePage);
                } else if (state.isFailure && state.errorMessage.isNotEmpty) {
                  CustomToast.showErrorToast(context, state.errorMessage);
                }
              },
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: AppTextStyles.openSansBold28.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: Dimens.standard_6),
                    Text(
                      'Join GearUp to order riding suits, helmets and parts',
                      style: AppTextStyles.openSansRegular14.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: Dimens.standard_32),
                    CustomTextInput(
                      textEditingController: nameController,
                      title: 'Full Name',
                      hintText: 'Enter your name',
                      inputType: TextInputType.name,
                    ),
                    if (state.nameError.isNotEmpty)
                      _buildErrorText(state.nameError),
                    const SizedBox(height: Dimens.standard_16),
                    CustomTextInput(
                      textEditingController: emailController,
                      title: 'Email Address',
                      hintText: 'Enter your email',
                      svgIconPath: AssetPath.emailIcon,
                      inputType: TextInputType.emailAddress,
                    ),
                    if (state.emailError.isNotEmpty)
                      _buildErrorText(state.emailError),
                    const SizedBox(height: Dimens.standard_16),
                    CustomTextInput(
                      textEditingController: phoneController,
                      title: 'Phone Number (Optional)',
                      hintText: 'Enter 10-digit mobile',
                      inputType: TextInputType.phone,
                    ),
                    const SizedBox(height: Dimens.standard_16),
                    CustomTextInput(
                      textEditingController: passwordController,
                      title: 'Password',
                      hintText: 'Min 6 characters',
                      svgIconPath: AssetPath.eyeOpenIcon,
                      isPassword: true,
                    ),
                    if (state.passwordError.isNotEmpty)
                      _buildErrorText(state.passwordError),
                    const SizedBox(height: Dimens.standard_32),
                    PrimaryButton(
                      text: 'CREATE ACCOUNT',
                      isLoading: state.isLoading,
                      onPressed: () {
                        _registerCubit.validateAndRegister(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          password: passwordController.text,
                        );
                      },
                    ),
                    const SizedBox(height: Dimens.standard_24),
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