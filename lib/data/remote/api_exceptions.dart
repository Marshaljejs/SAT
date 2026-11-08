abstract class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NoInternetException extends ApiException {
  const NoInternetException()
      : super('Интернет байланысы жоқ. Желіні тексеріп, қайталап көріңіз.');
}

class RequestTimeoutException extends ApiException {
  const RequestTimeoutException()
      : super('Сервер ұзақ жауап бермеді. Кейінірек қайталап көріңіз.');
}

class ParseException extends ApiException {
  const ParseException() : super('Сервер жауабын өңдеу мүмкін болмады.');
}

class ServerException extends ApiException {
  ServerException(this.statusCode, [String? detail])
      : super(_describe(statusCode, detail));

  final int statusCode;

  static String _describe(int code, String? detail) {
    final extra = (detail == null || detail.isEmpty) ? '' : ' $detail';
    if (code == 404) {
      return 'Деректер серверден табылмады (404).$extra';
    }
    if (code == 400 || code == 422) {
      return 'Сұрау дұрыс емес ($code).$extra';
    }
    if (code == 401 || code == 403) {
      return 'Қолжетімділік жоқ ($code).$extra';
    }
    if (code >= 500) {
      return 'Сервер қатесі ($code). Кейінірек қайталап көріңіз.';
    }
    return 'Сервер қатесі ($code).$extra';
  }
}
