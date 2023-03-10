import 'package:ecommerce_app/features/products/presentation/blocs/products_cubit/products_cubit.dart';

import '../common/app_themes.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../constants/enums.dart';
import '../helpers/cache_helper.dart';
import '../../features/products/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter/material.dart';

class GlobalProvider with ChangeNotifier {
  // ThemeModeManager
  bool _isDark = false;

  GlobalProvider(this._toggleFavoriteUsecase, this._productsCubit);
  bool get isDark => _isDark;
  ThemeMode _themeMode = AppThemes.systemTheme;
  ThemeMode get themeMode => _themeMode;

  void changeThemeMode(bool isDark) {
    _themeMode = isDark ? AppThemes.darkTheme : AppThemes.lightTheme;
    _isDark = isDark;
    notifyListeners();
    CacheHelper.saveDataSharedPreference(key: 'THEME_MODE', value: isDark);
  }

  void getCachedTheme() async {
    final bool? isDark =
        await CacheHelper.getDataFromSharedPreference(key: 'THEME_MODE');
    if (isDark != null) {
      _themeMode = isDark ? AppThemes.darkTheme : AppThemes.lightTheme;
      _isDark = isDark;
    } else {
      _themeMode = AppThemes.systemTheme;
    }
    notifyListeners();
  }

  // NavbarIndexManager
  int _index = 0;

  int get index => _index;

  void changeIndex(int newIndex) {
    _index = newIndex;
    notifyListeners();
  }

  // sortByManager
  String _sortBy = AppConstants.newToOld;
  String _title = 'newest';

  String get sortBy => _sortBy;
  String get title => _title;

  void changeSortBy(String newSort) {
    _sortBy = newSort;
    if (newSort == AppConstants.newToOld) {
      _title = AppStrings.newest;
    } else if (newSort == AppConstants.priceLowToHigh) {
      _title = AppStrings.priceLowToHigh;
    } else if (newSort == AppConstants.priceHighToLow) {
      _title = AppStrings.priceHighToLow;
    }
    notifyListeners();
  }

  // listStyle Manager
  ListStyle _listStyle = ListStyle.grid;

  ListStyle get listStyle => _listStyle;

  void changeListStyle() {
    if (_listStyle == ListStyle.grid) {
      _listStyle = ListStyle.list;
    } else {
      _listStyle = ListStyle.grid;
    }
    notifyListeners();
  }

  // FavProducts Manager
  final ToggleFavoriteUsecase _toggleFavoriteUsecase;
  final ProductsCubit _productsCubit;

  late Map<String, dynamic> _favProducts;

  Map<String, dynamic> get favProducts => _favProducts;

  void setFavProducts(favProducts) {
    _favProducts = favProducts;
    notifyListeners();
  }

  Future<void> toggleFavorite(int id, int uid) async {
    if (_favProducts.containsKey('$id')) {
      _favProducts.remove('$id');
      _productsCubit.removeFromFavProducts(id);
    } else {
      _favProducts.addAll({'$id': true});
    }
    notifyListeners();
    final result = await _toggleFavoriteUsecase(id, uid);
    result.fold(
      (error) => null,
      (favProducts) {
        _favProducts = favProducts;
      },
    );
    notifyListeners();
  }
}
