import 'package:bloc/bloc.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/remove_address_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecommerce_app/core/helpers/cache_helper.dart';
import 'package:ecommerce_app/core/providers/global_provider.dart';
import 'package:ecommerce_app/features/auth/domain/entities/login.dart';
import 'package:ecommerce_app/features/auth/domain/entities/register.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/add_address_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/check_auth_token_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/login_with_facebook_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/register_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  RegisterUsecase registerUsecase;
  LoginUsecase loginUsecase;
  ForgotPasswordUsecase forgotPasswordUsecase;
  LoginWithFacebookUsecase loginWithFacebookUsecase;
  LoginWithGoogleUsecase loginWithGoogleUsecase;
  CheckAuthTokenUsecase checkAuthTokenUsecase;
  AddAddressUsecase addAddressUsecase;
  RemoveAddressUsecase removeAddressUsecase;
  LogoutUsecase logoutUsecase;
  late GlobalProvider globalProvider;

  AuthCubit(
    this.registerUsecase,
    this.loginUsecase,
    this.forgotPasswordUsecase,
    this.loginWithFacebookUsecase,
    this.loginWithGoogleUsecase,
    this.checkAuthTokenUsecase,
    this.logoutUsecase,
    this.addAddressUsecase,
    this.removeAddressUsecase,
    this.globalProvider,
  ) : super(AuthInitial());

  late User _user;
  User get user => _user;

  Future<void> checkAuthToken() async {
    final auth = await CacheHelper.getDataFromSharedPreference(key: 'AUTH');
    if (auth != null) {
      final result = await checkAuthTokenUsecase(auth);
      result.fold(
          (error) => emit(
                AuthErrorState(error.message),
              ), (user) {
        _user = user;
        emit(AuthSuccessState(user: user));
        globalProvider.setFavProducts(user.favProducts);
      });
    } else {
      emit(NoTokenState());
    }
  }

  Future<void> register(Register register) async {
    emit(AuthLoadingState());
    final result = await registerUsecase(register);
    result.fold(
        (error) => emit(
              SignUpErrorState(error.message),
            ), (user) {
      _user = user;
      emit(AuthSuccessState(user: user));
      globalProvider.setFavProducts(user.favProducts);
      CacheHelper.saveDataSharedPreference(
        key: 'AUTH',
        value: user.auth,
      );
    });
  }

  Future<void> loginWithFacebook() async {
    emit(AuthLoginWithLoadingState());
    final result = await loginWithFacebookUsecase();
    result.fold((error) {
      emit(LoginErrorState(error.message));
    }, (user) {
      _user = user;
      emit(AuthSuccessState(user: user));
      globalProvider.setFavProducts(user.favProducts);
      CacheHelper.saveDataSharedPreference(
        key: 'AUTH',
        value: user.auth,
      );
    });
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoginWithLoadingState());
    final result = await loginWithGoogleUsecase();
    result.fold((error) {
      emit(LoginErrorState(error.message));
    }, (user) {
      _user = user;
      emit(AuthSuccessState(user: user));
      globalProvider.setFavProducts(user.favProducts);
      CacheHelper.saveDataSharedPreference(
        key: 'AUTH',
        value: user.auth,
      );
    });
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoadingState());
    final login = Login(email: email, password: password);
    final result = await loginUsecase(login);
    result.fold(
        (error) => emit(
              LoginErrorState(error.message),
            ), (user) {
      _user = user;
      emit(AuthSuccessState(user: user));
      globalProvider.setFavProducts(user.favProducts);
      CacheHelper.saveDataSharedPreference(
        key: 'AUTH',
        value: user.auth,
      );
    });
  }

  Future<void> logout() async {
    await CacheHelper.removeData(key: 'AUTH');
    await logoutUsecase();
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoadingState());
    final result = await forgotPasswordUsecase(email);
    result.fold(
      (error) => emit(
        ForgotPasswordErrorState(error.message),
      ),
      (message) => emit(
        ForgotPasswordSuccessState(message),
      ),
    );
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    emit(AuthLoadingState());
    final result = await addAddressUsecase(_user.id, address);
    result.fold(
      (error) => emit(AuthErrorState(error.message)),
      (data) {
        _user.addresses = data;
        if (_user.addresses.length == 1) {
          _user.defaultAddresse = _user.addresses.keys.first;
        }
        emit(AuthSuccessState(user: _user));
      },
    );
  }

  Future<void> removeAddress(String addresskey) async {
    emit(AuthLoadingState());
    _user.addresses.removeWhere((key, value) => key == addresskey);
    if (_user.defaultAddresse == addresskey) {
      _user.defaultAddresse =
          _user.addresses.isNotEmpty ? _user.addresses.keys.first : '';
    }
    final result = await removeAddressUsecase(_user.id, addresskey);
    result.fold(
      (error) => emit(AuthErrorState(error.message)),
      (data) {
        _user.addresses = data;
        emit(AuthSuccessState(user: _user));
      },
    );
  }

  void changeDefaultAddress(String key) {
    emit(AuthLoadingState());
    _user.defaultAddresse = key;
    emit(AuthSuccessState(user: _user));
  }

  bool hasAddress() {
    final defaultAddress = _user.defaultAddresse;
    return _user.addresses[defaultAddress] != null;
  }

  Map<String, dynamic> getDefaultAddress() {
    final defaultAddress = _user.defaultAddresse;
    return _user.addresses[defaultAddress];
  }
}
