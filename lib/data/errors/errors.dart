import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import '../../services/service_locator.dart';

import '../../helpers/utils.dart';

final _log = sl<Logger>();

class FBErrorCodes {
  static const DocumentNotFoundCode = "NOT_FOUND";
  static const EmailExistsCode = "EMAIL_EXISTS";
  static const EmailNotFoundCode = "EMAIL_NOT_FOUND";
  static const InvalidEmailCode = "INVALID_EMAIL";
  static const InvalidPasswordCode = "INVALID_PASSWORD";
  static const TooManyAttempts = "TOO_MANY_ATTEMPTS_TRY_LATER";
  static const UserNotFoundCode = "USER_NOT_FOUND";
}

enum FBFailures {
  arg,
  data,
  user,
  config,
  dependency,
}

class FBError extends Error {
  final FBFailures type;
  final String message;
  Response response;
  dynamic map;

  FBError(this.message, this.type, {this.map, this.response});

  @override
  String toString() => '$runtimeType(this). $type. $message';

  static void throwIfEmpty(dynamic value, String name, FBFailures failure) {
    if (!isEmpty(value)) {
      return;
    }

    if (failure == FBFailures.user) {
      throw FBError("$name should not be empty", FBFailures.user);
    } else if (failure == FBFailures.data) {
      throw FBError("$name should not be empty", FBFailures.data);
    }
    throw FBError("$name should not be empty, but it is $value", failure);
  }

  static String exceptionToUiMessage(dynamic exception) {
    if (exception is String) {
      if (!kReleaseMode) _log.d(exception);
      return exception;
    }

    if (exception is FBError && exception.type == FBFailures.user) {
      if (!kReleaseMode) _log.d(exception.message);
      return exception.message;
    }

    if (exception is FBError) {
      if (exception.toString().contains(FBErrorCodes.UserNotFoundCode)) return "User not found.";
      if (exception.toString().contains(FBErrorCodes.EmailNotFoundCode)) return "Email address not found.";
      if (exception.toString().contains(FBErrorCodes.TooManyAttempts)) return "Too many login attempts. Please try again later.";
      if (exception.toString().contains(FBErrorCodes.InvalidEmailCode)) return "Invalid EMail address.";
      if (exception.toString().contains(FBErrorCodes.InvalidPasswordCode)) return "Invalid password. Please try again.";
      if (exception.toString().contains(FBErrorCodes.EmailExistsCode)) return "This email is already registered.";
    }

    if (exception is ClientException) {
      if (exception.message.contains("HttpRequest error")) return "Issues with internet connection.";
    }

    _log.d("Unexpected error of type ${exception.runtimeType}: ", exception.toString());

    return "Unexpected error. Check console for details.";
  }
}
