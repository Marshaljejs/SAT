class DatabaseException implements Exception {
  const DatabaseException(this.message);

  final String message;

  @override
  String toString() => message;
}
