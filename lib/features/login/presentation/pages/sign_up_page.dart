import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gear_up_bloc/core/constants/app_strings.dart';
import 'package:gear_up_bloc/core/constants/routes.dart';
import 'package:gear_up_bloc/core/dependency_injection/injector.dart';
import 'package:gear_up_bloc/features/login/domain/use_case/login_use_case.dart';
import 'package:gear_up_bloc/features/login/presentation/cubit/register_cubit.dart';
import 'package:gear_up_bloc/shared/theme/app_colors.dart';
import 'package:gear_up_bloc/shared/theme/text_styles.dart';
import 'package:gear_up_bloc/shared/widgets/custom_toast.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  late RegisterCubit _registerCubit;
  late final AnimationController _enterController;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _registerCubit = RegisterCubit(injector<LoginUseCases>());
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _enterController.dispose();
    _registerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: BlocProvider.value(
        value: _registerCubit,
        child: BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state.isSuccess) {
              CustomToast.showSuccessToast(context, AppStrings.registrationSuccess);
              context.go(RoutesName.homePage);
            } else if (state.isFailure && state.errorMessage.isNotEmpty) {
              CustomToast.showErrorToast(context, state.errorMessage);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.appBackGround,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildTopHeader(context),
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.12),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _enterController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _enterController,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                            child: Column(
                              children: [
                                _buildSignUpForm(),
                                const SizedBox(height: 28),
                                _buildBottomFooterLink(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 28),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.createAccount,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.createAccountSub,
            textAlign: TextAlign.center,
            style: AppTextStyles.openSansRegular12.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStyledField(
              controller: _nameController,
              hint: AppStrings.enterName,
              prefixIcon: Icons.person_outline_rounded,
              errorText: state.nameError,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 14),
            _buildStyledField(
              controller: _emailController,
              hint: AppStrings.enterEmail,
              prefixIcon: Icons.mail_outline_rounded,
              errorText: state.emailError,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _buildStyledField(
              controller: _phoneController,
              hint: AppStrings.enterPhone,
              prefixIcon: Icons.phone_outlined,
              errorText: '',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _buildStyledField(
              controller: _passwordController,
              hint: AppStrings.enterPassword,
              prefixIcon: Icons.lock_outline_rounded,
              errorText: state.passwordError,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            _buildAnimatedSubmitButton(
              label: AppStrings.createAccount,
              isLoading: state.isLoading,
              onTap: () {
                FocusScope.of(context).unfocus();
                _registerCubit.validateAndRegister(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  phone: _phoneController.text.trim(),
                  password: _passwordController.text,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required String errorText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final hasError = errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hasError ? const Color(0xFF2D1515) : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.colorRed : AppColors.inputBorder,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: hasError ? AppColors.colorRed.withValues(alpha: 0.7) : AppColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                prefixIcon,
                size: 20,
                color: hasError ? AppColors.colorRed : AppColors.textSecondary,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_rounded, size: 15, color: AppColors.colorRed),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  errorText,
                  style: const TextStyle(color: AppColors.colorRed, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAnimatedSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          width: isLoading ? 54 : MediaQuery.of(context).size.width - 48,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.colorPrimary,
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPrimary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: AppColors.colorWhite, strokeWidth: 2.5),
          )
              : Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.colorWhite,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFooterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            AppStrings.signIn,
            style: const TextStyle(
              color: AppColors.colorPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}