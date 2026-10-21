import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gear_up_bloc/core/constants/app_language.dart';
import 'package:gear_up_bloc/core/constants/app_strings.dart';
import 'package:gear_up_bloc/core/constants/routes.dart';
import 'package:gear_up_bloc/core/dependency_injection/injector.dart';
import 'package:gear_up_bloc/core/extension/roles.dart';
import 'package:gear_up_bloc/core/utils/configuration.dart';
import 'package:gear_up_bloc/features/login/domain/use_case/login_use_case.dart';
import 'package:gear_up_bloc/features/login/presentation/cubit/login_cubit.dart';
import 'package:gear_up_bloc/shared/theme/app_colors.dart';
import 'package:gear_up_bloc/shared/theme/text_styles.dart';
import 'package:gear_up_bloc/shared/widgets/custom_toast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late LoginCubit _loginCubit;
  late final AnimationController _enterController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _keepSignedIn = true;

  @override
  void initState() {
    super.initState();
    _loginCubit = LoginCubit(injector<LoginUseCases>());
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _enterController.dispose();
    _loginCubit.close();
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
        value: _loginCubit,
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.isSuccess && state.loginData != null) {
              UserPreferences.instance.setUserRole(UserRole.customer);
              context.go(RoutesName.homePage);
            } else if (state.isFailure && state.message.isNotEmpty) {
              CustomToast.showErrorToast(context, state.message);
              _loginCubit.resetError();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.appBackGround,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildTopDarkHeader(),
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
                                _buildSignInForm(),
                                const SizedBox(height: 24),
                                _buildOrDivider(),
                                const SizedBox(height: 20),
                                _buildSocialButtons(),
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

  Widget _buildTopDarkHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 72),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _buildCompactLanguageSwitcher(),
          ),
          const SizedBox(height: 170),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.colorPrimary),
                ),
                child: const Icon(
                  Icons.sports_motorsports_rounded,
                  size: 16,
                  color: AppColors.colorPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.appName,
                style: AppTextStyles.openSansBold16.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.welcomeBack,
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
            AppStrings.signInContinue,
            textAlign: TextAlign.center,
            style: AppTextStyles.openSansRegular12.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStyledField(
              controller: _emailController,
              hint: AppStrings.enterUsername,
              prefixIcon: Icons.mail_outline_rounded,
              errorText: state.usernameError,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _buildStyledField(
              controller: _passwordController,
              hint: AppStrings.enterPassword,
              prefixIcon: Icons.lock_outline_rounded,
              errorText: state.passwordError,
              isPassword: true,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _keepSignedIn = !_keepSignedIn),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _keepSignedIn ? AppColors.colorPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _keepSignedIn ? AppColors.colorPrimary : AppColors.dividerColor,
                            width: 1.5,
                          ),
                        ),
                        child: _keepSignedIn
                            ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.colorWhite,
                        )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Keep me signed in',
                        style: AppTextStyles.openSansRegular12.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.openSansBold12.copyWith(
                      color: AppColors.colorPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAnimatedSubmitButton(
              label: AppStrings.signIn,
              isLoading: state.isLoading,
              onTap: () {
                FocusScope.of(context).unfocus();
                _loginCubit.validate(
                  _emailController.text.trim(),
                  _passwordController.text,
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
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.error_rounded,
                size: 15,
                color: AppColors.colorRed,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  errorText,
                  style: const TextStyle(
                    color: AppColors.colorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
            child: CircularProgressIndicator(
              color: AppColors.colorWhite,
              strokeWidth: 2.5,
            ),
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

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialTile(
            label: 'Google',
            iconWidget: const Icon(Icons.g_mobiledata_rounded, size: 26, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSocialTile(
            label: 'Apple',
            iconWidget: const Icon(Icons.apple_rounded, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialTile({
    required String label,
    required Widget iconWidget,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomFooterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${AppStrings.dontHaveAccount} ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => context.push(RoutesName.signUp),
          child: Text(
            AppStrings.signUp,
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

  Widget _buildCompactLanguageSwitcher() {
    final currentCode = Get.locale?.languageCode ?? 'en';
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.supportedLanguages.map((lang) {
          final isSelected = currentCode == lang.code;
          return GestureDetector(
            onTap: () async {
              await AppLanguage.changeLanguage(lang.code);
              if (mounted) setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.colorPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lang.code.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? AppColors.colorWhite : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}