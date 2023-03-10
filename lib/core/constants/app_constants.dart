class AppConstants {
  // API endPoints:
  static const baseUrl = 'https://feaw.kenrys.net/ramni/wp-json/app/v1';
  static const checkTokenPathUrl = '$baseUrl/token';
  static const registerPathUrl = '$baseUrl/register';
  static const loginPathUrl = '$baseUrl/login';
  static const forgetPassPathUrl = '$baseUrl/forgetPass';
  static const loginWithPathUrl = '$baseUrl/fblogin';
  static const getProductsPathUrl = '$baseUrl/getProducts';
  static const initDataPathUrl = '$baseUrl/initData';
  static const getProductPathUrl = '$baseUrl/getProduct';
  static const toggleFavoritePathUrl = '$baseUrl/togglefav';
  static const getFavoritePathUrl = '$baseUrl/getFav';
  static const addAddressPathUrl = '$baseUrl/addAddress';
  static const getStatePathUrl = '$baseUrl/getState';
  static const removeAddressPathUrl = '$baseUrl/removeAddress';
  static const getShippingCostPathUrl = '$baseUrl/getShippingCost';
  static const createOrderPathUrl = '$baseUrl/createOrder';
  static const getOrdersPathUrl = '$baseUrl/getOrders';
  static const getOrderPathUrl = '$baseUrl/getOrder';

  // App constants:
  static const newToOld = 'news';
  static const priceLowToHigh = 'priceL2H';
  static const priceHighToLow = 'priceH2L';
}
