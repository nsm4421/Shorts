import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../constant/error_code.dart';

class CustomException implements Exception {
  final ErrorCode? _errorCode;
  final String? _message;

  CustomException({ErrorCode? errorCode, String? message})
      : _errorCode = errorCode,
        _message = message;

  ErrorCode get code => _errorCode ?? ErrorCode.unKnownError;

  String get message => _message ?? ErrorCode.unKnownError.name;

  static CustomException from(dynamic error,
      {String? message, ErrorCode? errorCode, Logger? logger}) {
    if (logger != null) {
      logger.e(error);
    }
    if (errorCode != null) {
      return CustomException(
          errorCode: errorCode, message: message ?? errorCode.name);
    } else if (error is ArgumentError) {
      // bad request
      return CustomException(
          errorCode: ErrorCode.invalidArgs,
          message: message ?? ErrorCode.invalidArgs.name);
    } else if (error is FirebaseAuthException) {
      // firebase auth
      return CustomException(
          errorCode: ErrorCode.firebaseAuthException,
          message: message ?? ErrorCode.firebaseAuthException.name);
    } else if (error is FirebaseException) {
      // firestore
      switch (error.code) {
        case 'permission-denied':
          return CustomException(
              errorCode: ErrorCode.firebasePermissionDenied,
              message: message ?? error.message);
        case 'unavailable':
          return CustomException(
              errorCode: ErrorCode.firebaseUnavailable,
              message: message ?? error.message);
        case 'not-found':
          return CustomException(
              errorCode: ErrorCode.firebaseNotFound,
              message: message ?? error.message);
        case 'already-exists':
          return CustomException(
              errorCode: ErrorCode.firebaseAlreadyExists,
              message: message ?? error.message);
        default:
          return CustomException(
              errorCode: ErrorCode.firebaseUnKnown,
              message: message ?? error.message);
      }
    } else {
      // un known
      return CustomException(
          errorCode: ErrorCode.unKnownError,
          message: message ?? ErrorCode.unKnownError.name);
    }
  }
}