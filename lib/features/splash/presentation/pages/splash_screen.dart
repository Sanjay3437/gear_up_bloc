import 'package:flutter/material.dart';
import 'package:gear_up_bloc/core/constants/constant.dart';
import 'package:gear_up_bloc/core/constants/routes.dart';
import 'package:gear_up_bloc/core/database/hive_storage_service.dart';
import 'package:gear_up_bloc/core/network/network_service.dart';
import 'package:gear_up_bloc/shared/config/dimens.dart';
import 'package:gear_up_bloc/shared/theme/app_colors.dart';
import 'package:gear_up_bloc/shared/theme/text_styles.dart';
import 'package:gear_up_bloc/shared/widgets/custom_loader.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final hiveService = GetIt.instance<HiveService>();
    final token = await hiveService.get(userToken);

    if (token != null && token.toString().isNotEmpty) {
      final networkService = GetIt.instance<NetworkService>();
      networkService.updateHeader({'Authorization': 'Bearer $token'});
      if (mounted) context.go(RoutesName.homePage);
    } else {
      if (mounted) context.go(RoutesName.loginPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_motorsports_rounded,
              size: Dimens.standard_100,
              color: AppColors.colorGreen,
            ),
            const SizedBox(height: Dimens.standard_20),
            Text(
              'GEAR UP',
              style: AppTextStyles.openSansBold32.copyWith(
                color: AppColors.colorWhite,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: Dimens.standard_8),
            Text(
              'Pro Riding Gear & Accessories',
              style: AppTextStyles.openSansRegular14.copyWith(
                color: AppColors.colorGrey,
              ),
            ),
            const SizedBox(height: Dimens.standard_48),
            const CustomLoader(
              size: Dimens.standard_32,
              strokeWidth: Dimens.standard_3,
              isCentered: false,
              color: AppColors.colorGreen,
            ),
          ],
        ),
      ),
    );
  }
}