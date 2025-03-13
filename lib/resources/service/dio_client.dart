import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:gyansagar_frontend/resources/exceptions/exceptions.dart';

class DioClient {
  final Dio _dio;
  final String? baseEndpoint; // Make nullable
  final bool logging;

  DioClient(
      this._dio, {
        this.baseEndpoint, // Nullable to avoid null issues
        this.logging = false,
      }) {
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
        Options? options, // Make nullable
        String? fullUrl, // Make nullable
        Map<String, dynamic>? queryParameters, // Explicitly type
      }) async {
    try {
      var isConnected = await hasInternetConnection();
      if (!isConnected) {
        throw SocketException("Please check your internet connection");
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
        Options? options, // Make nullable
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
        Options? options, // Make nullable
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
      return response.data as Map<String, dynamic>;
    } on Exception catch (e, stackTrace) {
      debugPrint(stackTrace.toString());
      throw Exception('Bad body format');
    }
  }

  List<dynamic> getJsonBodyList<T>(Response<T> response) {
    try {
      return response.data as List<dynamic>;
    } on Exception catch (e, stackTrace) {
      debugPrint(stackTrace.toString());
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
