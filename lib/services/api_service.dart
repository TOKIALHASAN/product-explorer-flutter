import 'package:dio/dio.dart';

import '../models/product.dart';
import '../models/product_page.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  ApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://dummyjson.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  static const int defaultLimit = 10;

  Future<ProductPage> fetchProducts({int limit = defaultLimit, int skip = 0}) {
    return _fetchProductPage('/products', limit: limit, skip: skip);
  }

  Future<Product> fetchProductById(int productId) async {
    final data = await _send(() => _dio.get<dynamic>('/products/$productId'));
    return Product.fromJson(data);
  }

  Future<ProductPage> searchProducts(
    String query, {
    int limit = defaultLimit,
    int skip = 0,
  }) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      throw const ApiException('Search query cannot be empty.');
    }

    return _fetchProductPage(
      '/products/search',
      limit: limit,
      skip: skip,
      queryParameters: {'q': trimmedQuery},
    );
  }

  Future<ProductPage> fetchProductsByCategory(
    String category, {
    int limit = defaultLimit,
    int skip = 0,
  }) {
    final trimmedCategory = category.trim();
    if (trimmedCategory.isEmpty) {
      throw const ApiException('Category cannot be empty.');
    }

    return _fetchProductPage(
      '/products/category/${Uri.encodeComponent(trimmedCategory)}',
      limit: limit,
      skip: skip,
    );
  }

  Future<Product> addProduct({
    required String title,
    required double price,
    required String category,
    String? description,
    String? brand,
    int stock = 0,
  }) async {
    final data = await _send(
      () => _dio.post<dynamic>(
        '/products/add',
        data: {
          'title': title,
          'price': price,
          'category': category,
          'stock': stock,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
        },
      ),
    );

    return Product.fromJson(data);
  }

  Future<Product> updateProduct(
    int productId, {
    String? title,
    double? price,
    String? category,
    String? description,
    String? brand,
    int? stock,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (price != null) updates['price'] = price;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (brand != null) updates['brand'] = brand;
    if (stock != null) updates['stock'] = stock;

    if (updates.isEmpty) {
      throw const ApiException('Provide at least one field to update.');
    }

    final data = await _send(
      () => _dio.put<dynamic>('/products/$productId', data: updates),
    );

    return Product.fromJson(data);
  }

  Future<bool> deleteProduct(int productId) async {
    final data = await _send(
      () => _dio.delete<dynamic>('/products/$productId'),
    );
    return data['isDeleted'] == true;
  }

  Future<ProductPage> _fetchProductPage(
    String path, {
    required int limit,
    required int skip,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (limit <= 0) {
      throw const ApiException('Limit must be greater than 0.');
    }
    if (skip < 0) {
      throw const ApiException('Skip cannot be negative.');
    }

    final data = await _send(
      () => _dio.get<dynamic>(
        path,
        queryParameters: {...?queryParameters, 'limit': limit, 'skip': skip},
      ),
    );

    return ProductPage.fromJson(data);
  }

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }
      throw const ApiException('The server returned an unexpected response.');
    } on DioException catch (error) {
      throw ApiException(_messageFor(error));
    }
  }

  String _messageFor(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'The request timed out. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Could not connect to the server. '
            'Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Invalid request. Please check the data you sent.';
          case 401:
            return 'You are not authorized to perform this action.';
          case 403:
            return 'You do not have permission to perform this action.';
          case 404:
            return 'The requested product was not found.';
          default:
            if (statusCode != null && statusCode >= 500) {
              return 'The server had a problem. Please try again later.';
            }
            return 'The server returned an error (status code: $statusCode).';
        }
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'The server certificate is not valid.';
      case DioExceptionType.unknown:
        return 'Something went wrong. Please check your connection.';
    }
  }
}
