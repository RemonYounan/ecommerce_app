import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:ecommerce_app/features/products/domain/usecases/get_fav_products_usecase.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_search_products_usecase.dart';

import '../../../data/models/banner_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/entities/banner.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_details.dart';
import '../../../domain/usecases/get_category_products_usecase.dart';
import '../../../domain/usecases/get_product_details_usecase.dart';
import '../../../domain/usecases/init_data_usecase.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(
    this._getProductDetailsUsecase,
    this._getCategoryProductsUsecase,
    this._initDataUsecase,
    this._getFavProductsUsecase,
    this._getSearchProductsUsecase,
  ) : super(ProductsState());

  final GetProductDetailsUsecase _getProductDetailsUsecase;
  final GetCategoryProductsUsecase _getCategoryProductsUsecase;
  final InitDataUsecase _initDataUsecase;
  final GetFavProductsUsecase _getFavProductsUsecase;
  final GetSearchProductsUsecase _getSearchProductsUsecase;
  ProductsState _state = ProductsState();

  late int userId;
  final List<Product> _favProducts = [];
  final List<ProductDetails> _productsDetails = [];
  Map<String, dynamic> _addressFields = {};
  Map<String, dynamic> _countries = {};

  Map<String, dynamic> get addressFields => _addressFields;
  Map<String, dynamic> get countries => _countries;

  Future<void> initData() async {
    emit(_state.copyWith(status: ProductsStatus.loading));
    final result = await _initDataUsecase();
    result.fold(
      (error) => emit(_state.copyWith(
        status: ProductsStatus.error,
        errorMessage: error.message,
      )),
      (data) {
        final List bannersJson = data['banners'];
        final banners =
            bannersJson.map((banner) => BannerModel.fromJson(banner)).toList();
        final List featuresProductsJson = data['featuresProducts'];
        final featuresProducts = featuresProductsJson
            .map((product) => ProductModel.fromJson(product))
            .toList();
        final List popularProductsJson = data['popularProducts'];
        final popularProducts = popularProductsJson
            .map((product) => ProductModel.fromJson(product))
            .toList();
        final List newestProductsJson = data['newestProducts'];
        final newestProducts = newestProductsJson
            .map((product) => ProductModel.fromJson(product))
            .toList();
        final List categoriesJson = data['categories'];
        final categories = categoriesJson
            .map((category) => CategoryModel.fromJson(category))
            .toList();
        _addressFields = data['address_fields'];
        _countries = data['countries'];
        _state = _state.copyWith(
          banners: banners,
          featuresProducts: featuresProducts,
          popularProducts: popularProducts,
          newestProducts: newestProducts,
          categories: categories,
          status: ProductsStatus.loaded,
        );
        emit(_state);
      },
    );
  }

  Future<void> getProduct(int id) async {
    if (_productsDetails.where((element) => element.id == id).isEmpty) {
      emit(_state.copyWith(status: ProductsStatus.productLoading));
      final result = await _getProductDetailsUsecase(id);
      result.fold(
        (error) => emit(ProductsState(
          errorMessage: error.message,
          status: ProductsStatus.error,
        )),
        (product) {
          _productsDetails.add(product);
          _state = _state.copyWith(
            productsDetails: _productsDetails,
            status: ProductsStatus.loaded,
          );
          emit(_state);
        },
      );
    }
  }

  Future<List<Product>> getCategoryProducts(
      int id, int offset, String orderBy) async {
    if (offset == 0) {
      emit(ProductsState(status: ProductsStatus.loading));
    }
    final result = await _getCategoryProductsUsecase(id, offset, orderBy);
    late List<Product> products;
    result.fold(
      (error) => emit(ProductsState(
        errorMessage: error.message,
        status: ProductsStatus.error,
      )),
      (newProducts) {
        products = newProducts;
        emit(_state.copyWith(status: ProductsStatus.loaded));
      },
    );
    return products;
  }

  Future<void> getFavProducts(int id) async {
    if (_favProducts.isEmpty) {
      emit(ProductsState(status: ProductsStatus.loading));
      userId = id;
      final result = await _getFavProductsUsecase(id);
      result.fold(
        (error) => emit(ProductsState(
          errorMessage: error.message,
          status: ProductsStatus.error,
        )),
        (products) {
          _favProducts.addAll(products);
          _state = _state.copyWith(
            favProducts: products,
          );
          emit(_state);
        },
      );
    }
  }

  Future<void> removeFromFavProducts(int id) async {
    emit(ProductsState(status: ProductsStatus.loading));
    _favProducts.removeWhere((element) => element.id == id);
    _state = _state.copyWith(
      favProducts: _favProducts,
    );
    emit(_state);
  }

  Future<void> refreshFavProducts() async {
    _favProducts.clear();
    getFavProducts(userId);
  }

  String searchText = '';
  Future<void> getSearchProducts(String search) async {
    if (searchText.isEmpty || searchText != search) {
      emit(ProductsState(status: ProductsStatus.loading));
      final result = await _getSearchProductsUsecase(search);
      result.fold(
          (error) => emit(ProductsState(
                errorMessage: error.message,
                status: ProductsStatus.error,
              )), (products) {
        _state = _state.copyWith(
          status: ProductsStatus.loaded,
          searchProducts: products,
        );
        emit(_state);
      });
    }
    searchText = search;
  }

  void clearSearchProducts() {
    emit(_state.copyWith(searchProducts: []));
  }

  void clear() {
    _favProducts.clear();
    _productsDetails.clear();
  }
}
