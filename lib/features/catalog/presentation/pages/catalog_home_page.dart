import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gear_up_bloc/core/constants/app_strings.dart';
import 'package:gear_up_bloc/core/constants/routes.dart';
import 'package:gear_up_bloc/core/dependency_injection/injector.dart';
import 'package:gear_up_bloc/features/catalog/data/models/product_model.dart';
import 'package:gear_up_bloc/features/catalog/domain/use_case/get_catalog_items_use_case.dart';
import 'package:gear_up_bloc/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:gear_up_bloc/shared/config/dimens.dart';
import 'package:gear_up_bloc/shared/theme/app_colors.dart';
import 'package:gear_up_bloc/shared/theme/text_styles.dart';
import 'package:gear_up_bloc/shared/widgets/app_drawer.dart';
import 'package:gear_up_bloc/shared/widgets/custom_loader.dart';
import 'package:gear_up_bloc/shared/widgets/custom_network_image.dart';
import 'package:gear_up_bloc/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class CatalogHomePage extends StatefulWidget {
  const CatalogHomePage({super.key});

  @override
  State<CatalogHomePage> createState() => _CatalogHomePageState();
}

class _CatalogHomePageState extends State<CatalogHomePage> {
  late CatalogCubit _catalogCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _catalogCubit = CatalogCubit(injector<GetCatalogItemsUseCase>())..init();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      _catalogCubit.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _catalogCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _catalogCubit,
      child: Scaffold(
        backgroundColor: AppColors.appBackGround,
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceColor,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.notes_rounded, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.colorGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sports_motorsports_rounded,
                  color: AppColors.colorGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,  
                      style: AppTextStyles.openSansBold16.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppStrings.deliveryHeader,  
                      style: AppTextStyles.openSansRegular10.copyWith(
                        color: AppColors.colorGreen,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textPrimary),
              tooltip: AppStrings.myWishlist,  
              onPressed: () => context.push(RoutesName.wishlist),
            ),
            IconButton(
              icon: const Icon(Icons.local_mall_outlined, color: AppColors.colorGreen),
              tooltip: AppStrings.myCart,  
              onPressed: () => context.push(RoutesName.cart),
            ),
          ],
        ),
        body: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CustomLoader());
            }

            if (state.errorMessage.isNotEmpty && state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 54, color: AppColors.colorRed),
                    const SizedBox(height: Dimens.standard_12),
                    Text(
                      state.errorMessage,
                      style: AppTextStyles.openSansRegular14.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: Dimens.standard_16),
                    PrimaryButton(
                      width: 140,
                      text: AppStrings.retry,  
                      onPressed: () => _catalogCubit.init(),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. Motorsport Hero Banner
                SliverToBoxAdapter(child: _buildHeroBanner()),

                // 2. Category Filter Strip
                SliverToBoxAdapter(child: _buildCategoryStrip(state)),

                // 3. Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.selectedCategory.toUpperCase()} • ${AppStrings.browseProducts}',  
                          style: AppTextStyles.openSansBold14.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${state.items.length} ${AppStrings.items}',  
                          style: AppTextStyles.openSansBold12.copyWith(
                            color: AppColors.colorGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Horizontal Wide Spec-Cards List
                if (state.items.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        AppStrings.noProductsInCategory,  
                        style: AppTextStyles.openSansRegular14.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildGearHorizontalCard(state.items[index]),
                        childCount: state.items.length,
                      ),
                    ),
                  ),

                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CustomLoader(
                          size: 24,
                          strokeWidth: 2.5,
                          color: AppColors.colorGreen,
                          isCentered: false,
                        ),
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

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AppStrings.deliveryInMins,  
                    style: AppTextStyles.openSansBold10.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.appName,  
                  style: AppTextStyles.openSansBold20.copyWith(
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.appSubtitle,  
                  style: AppTextStyles.openSansRegular12.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.two_wheeler_rounded,
            size: 72,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStrip(CatalogState state) {
    final categories = ['All', ...state.categories.map((e) => e.name ?? '')];
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = state.selectedCategory == category;
          return GestureDetector(
            onTap: () => _catalogCubit.selectCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.colorGreen : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.colorGreen : AppColors.dividerColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.bolt_rounded : Icons.label_outline_rounded,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.toUpperCase(),
                    style: AppTextStyles.openSansBold12.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGearHorizontalCard(ProductModel item) {
    final hasDiscount = (item.mrp ?? 0) > (item.discountPrice ?? 0) && (item.discountPrice ?? 0) > 0;

    return GestureDetector(
      onTap: () {
        if (item.id != null && item.id!.isNotEmpty) {
          context.push(RoutesName.productDetail, extra: item.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: AppColors.surfaceColor,
                    child: CustomNetworkImage(
                      imageUrl: item.imageUrl ?? '',
                      width: 105,
                      height: 105,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (item.dealBadge != null && item.dealBadge!.isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.colorGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.dealBadge!,
                        style: AppTextStyles.openSansBold10.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.packSize?.isNotEmpty == true ? item.packSize!.toUpperCase() : 'STD SPEC',
                          style: AppTextStyles.openSansBold10.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (item.rating != null && item.rating! > 0)
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              item.rating!.toStringAsFixed(1),
                              style: AppTextStyles.openSansBold12.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name ?? '',
                    style: AppTextStyles.openSansBold16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${item.discountPrice ?? item.mrp ?? 0}',
                            style: AppTextStyles.openSansBold18.copyWith(
                              color: AppColors.colorGreen,
                            ),
                          ),
                          if (hasDiscount)
                            Text(
                              '${AppStrings.mrp} ₹${item.mrp}',
                              style: AppTextStyles.openSansRegular10.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.colorGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.colorGreen),
                        ),
                        child: Row(
                          children: [
                            Text(
                              AppStrings.add, 
                              style: AppTextStyles.openSansBold12.copyWith(
                                color: AppColors.colorGreen,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: AppColors.colorGreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}