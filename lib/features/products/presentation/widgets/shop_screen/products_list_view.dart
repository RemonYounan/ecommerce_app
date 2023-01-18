import 'package:ecommerce_app/core/common/app_colors.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/favorite_button.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/loading_widget.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/no_more_items_widget.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ProductsListView extends StatelessWidget {
  const ProductsListView({
    Key? key,
    required this.pagingController,
  }) : super(key: key);

  final PagingController<int, Product> pagingController;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => Future.sync(() => pagingController.refresh()),
      child: PagedListView(
        key: const PageStorageKey('ProductsListView'),
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<Product>(
            itemBuilder: (context, item, _) => Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  child: ProductListCard(
                    product: item,
                    icon: FavoriteButton(id: item.id),
                  ),
                ),
            noMoreItemsIndicatorBuilder: (context) =>
                SizedBox(height: 40.h, child: const NoMoreItemsWidget()),
            newPageProgressIndicatorBuilder: (_) => const LoadingWidget(),
            firstPageProgressIndicatorBuilder: (_) => const LoadingWidget()),
      ),
    );
  }
}
