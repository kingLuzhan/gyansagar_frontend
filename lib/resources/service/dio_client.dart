import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:gyansagar_frontend/resources/exceptions/exceptions.dart';

class DioClient {
  final Dio _dio;
  final String? baseEndpoint;
  final bool logging;

  DioClient(this._dio, {this.baseEndpoint, this.logging = false}) {
    if (logging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          responseHeader: true,
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }

  Future<Response<T>> get<T>(
    String endpoint, {
    Options? options,
    String? fullUrl,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      var isConnected = await hasInternetConnection();
      if (!isConnected) {
        throw const SocketException("Please check your internet connection");
      }
      return await _dio.get(
        fullUrl ?? '$baseEndpoint$endpoint',
        options: options,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        '$baseEndpoint$endpoint',
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        '$baseEndpoint$endpoint',
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> getJsonBody<T>(Response<T> response) {
    try {
      // Log the response body
      print('Response body: ${response.data}');

      if (response.data is String) {
        // Try to parse the string as JSON
        return jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response type');
      }
    } catch (e) {
      print('Error parsing JSON body: $e');
      throw Exception('Bad body format');
    }
  }

  List<dynamic> getJsonBodyList<T>(Response<T> response) {
    try {
      // Log the response body
      print('Response body: ${response.data}');

      if (response.data is String) {
        // Try to parse the string as JSON
        return jsonDecode(response.data as String) as List<dynamic>;
      } else if (response.data is List<dynamic>) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Unexpected response type');
      }
    } catch (e) {
      print('Error parsing JSON body: $e');
      throw SchemeConsistencyException('Bad body format');
    }
  }

  Exception _handleError(DioException e) {
    String message = "An error occurred";

    if (e.response?.statusCode == 404 && e.response?.data == "Not found!") {
      message = "Not Found!";
    } else {
      final apiResponse = e.response != null ? getJsonBody(e.response!) : {};
      if (e.response?.statusCode != 422) {
        message = apiResponse["message"] ?? "Unknown error";
      } else {
        message = json.encode(apiResponse["errors"] ?? "Unknown error");
      }
    }

    switch (e.response?.statusCode) {
      case 500:
        return ApiInternalServerException();
      case 400:
        return BadRequestException(message, response: e.response);
      case 401:
      case 403:
        return UnauthorisedException(message, response: e.response);
      case 404:
        return ResourceNotFoundException(message, response: e.response);
      case 422:
        return UnprocessableException(message, response: e.response);
      default:
        return ApiException(message, response: e.response);
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}
