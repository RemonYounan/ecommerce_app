import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'package:ecommerce_app/core/constants/app_strings.dart';
import 'package:ecommerce_app/core/error/failures.dart';
import 'package:ecommerce_app/features/order/data/models/shipping_cost_model.dart';
import 'package:ecommerce_app/features/order/domain/entities/shipping_cost.dart';

abstract class OrderRemoteDataSource {
  Future<Either<Failure, ShippingCost>> getShippingCost(
      String country, String city);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  Dio dio;

  OrderRemoteDataSourceImpl({
    required this.dio,
  });
  @override
  Future<Either<Failure, ShippingCost>> getShippingCost(
      String country, String city) async {
    try {
      final response =
          await dio.get(AppConstants.getShippingCostPathUrl, queryParameters: {
        'cc': country,
        'city': city,
      });
      if (response.statusCode == 200) {
        final cost =
            ShippingCostModel.fromJson((response.data as Map).values.first);
        return Right(cost);
      } else {
        return Left(ServerFailure(message: AppStrings.errorOccured));
      }
    } catch (e) {
      print(e);
      return Left(ServerFailure(message: AppStrings.errorOccured));
    }
  }
}
