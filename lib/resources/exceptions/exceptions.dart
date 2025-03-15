import 'package:dio/dio.dart';

class SchemeConsistencyException implements Exception {
  final String message;

  SchemeConsistencyException([this.message = 'Schemes consistency error']);

  @override
  String toString() {
    return 'SchemeConsistencyException: $message';
  }
}

abstract class DiagnosticMessageException implements Exception {
  String get diagnosticMessage;
}

class ApiException implements Exception {
  final String message;
  final Response<dynamic>? response;

  ApiException(this.message, {this.response});

  @override
  String toString() => "ApiException: $message";
}

class ApiInternalServerException extends ApiException {
  ApiInternalServerException() : super('Internal Server Error');
}

class ApiDataNotFoundException extends ApiException {
  ApiDataNotFoundException() : super('Data Not Found Error');
}

abstract class LocalizeMessageException implements Exception {
  String get message;
}

class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() => message;
}

class FetchDataException extends HttpException {
  FetchDataException(String message)
      : super("Error During Communication: $message");
}

class BadRequestException extends HttpException {
  BadRequestException(String message, {Response<dynamic>? response})
      : super("Invalid Request: $message");
}

class BadUrlException extends HttpException {
  BadUrlException(String message) : super("Bad URL: $message");
}

class UnauthorisedException extends HttpException {
  UnauthorisedException(String message, {Response<dynamic>? response})
      : super("Unauthorised: $message");
}

class ResourceNotFoundException extends HttpException {
  ResourceNotFoundException(super.message, {Response<dynamic>? response});
}

class InvalidInputException extends HttpException {
  InvalidInputException(String message) : super("Invalid Input: $message");
}

class ApiUnauthorizedException extends HttpException {
  ApiUnauthorizedException(super.message);
}

class UnprocessableException extends HttpException {
  UnprocessableException(super.message, {Response<dynamic>? response});
}
