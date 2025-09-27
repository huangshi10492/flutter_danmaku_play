import 'package:fldanplay/service/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class Logger {
  final String module;
  late LoggerService _loggerService;

  Logger(this.module) {
    _loggerService = GetIt.I<LoggerService>();
  }

  void debug(String function, String message) {
    final time = DateFormat('HH:mm:ss').format(DateTime.now());
    final formattedMessage = '$time [$module.$function] $message';
    _loggerService.debug(formattedMessage);
  }

  void info(String function, String message) {
    final time = DateFormat('HH:mm:ss').format(DateTime.now());
    final formattedMessage = '$time [$module.$function] $message';
    _loggerService.info(formattedMessage);
  }

  void warn(
    String function,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final time = DateFormat('HH:mm:ss').format(DateTime.now());
    final formattedMessage = '$time [$module.$function] $message';
    _loggerService.warning(formattedMessage, error, stackTrace);
  }

  void error(
    String function,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final time = DateFormat('HH:mm:ss').format(DateTime.now());
    final formattedMessage = '$time [$module.$function] $message';
    _loggerService.error(formattedMessage, error, stackTrace);
  }
}
