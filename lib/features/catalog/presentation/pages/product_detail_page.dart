import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gear_up_bloc/core/constants/app_strings.dart';
import 'package:gear_up_bloc/core/dependency_injection/injector.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_detail_request.dart';
import 'package:gear_up_bloc/features/catalog/domain/use_case/get_product_detail_use_case.dart';
import 'package:gear_up_bloc/features/catalog/presentation/cubit/product_detail_cubit.dart';
import 'package:gear_up_bloc/shared/config/dimens.dart';
import 'package:gear_up_bloc/shared/theme/app_colors.dart';
import 'package:gear_up_bloc/shared/theme/text_styles.dart';
import 'package:gear_up_bloc/shared/widgets/custom_loader.dart';
import 'package:gear_up_bloc/shared/widgets/custom_network_image.dart';
import 'package:gear_up_bloc/shared/widgets/primary_button.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProductDetailCubit(injector<GetProductDetailUseCase>())
      ..fetchProductDetail(ProductDetailRequest(id: widget.productId));
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        backgroundColor: AppColors.appBackGround,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppStrings.productDetails,   
            style: AppTextStyles.openSansBold16.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CustomLoader());
            }

            final product = state.product;
            if (product == null) {
              return Center(
                child: Text(
                  AppStrings.unknownError,   
                  style: AppTextStyles.openSansRegular14.copyWith(color: AppColors.textSecondary),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimens.standard_16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 260,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.dividerColor),
                          ),
                          child: CustomNetworkImage(
                            imageUrl: product.imageUrl ?? '',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.colorGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (product.categoryName?.isNotEmpty == true
                                    ? product.categoryName!
                                    : AppStrings.appName)
                                    .toUpperCase(),
                                style: AppTextStyles.openSansBold12.copyWith(
                                  color: AppColors.colorGreen,
                                ),
                              ),
                            ),
                            if (product.rating != null && product.rating! > 0)
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.rating} (${product.ratingCount ?? 0} ${AppStrings.reviews})',   
                                    style: AppTextStyles.openSansBold12.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.name ?? '',
                          style: AppTextStyles.openSansBold22.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildSpecTile(AppStrings.type, product.packSize ?? 'Standard'),
                            const SizedBox(width: 12),
                            _buildSpecTile(
                              AppStrings.items,
                              '${product.stock ?? 10}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.productDetails,   
                                style: AppTextStyles.openSansBold12.copyWith(
                                  color: AppColors.colorGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description?.isNotEmpty == true
                                    ? product.description!
                                    : AppStrings.appSubtitle,
                                style: AppTextStyles.openSansRegular14.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceColor,
                    border: Border(top: BorderSide(color: AppColors.dividerColor)),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.total,   
                              style: AppTextStyles.openSansBold10.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${(product.discountPrice ?? product.mrp ?? 0) * state.quantity}',
                              style: AppTextStyles.openSansBold22.copyWith(
                                color: AppColors.colorGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: PrimaryButton(
                            text: AppStrings.add,   
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.colorGreen,
                                  content: Text('${product.name} ${AppStrings.add}!'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.openSansBold10.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.openSansBold14.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}