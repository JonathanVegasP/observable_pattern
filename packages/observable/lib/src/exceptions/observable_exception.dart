class ObservableException implements Exception {
  final String message;

  const ObservableException(bool close)
      : message = 'You cannot ${close ? 'close' : 'add event to'} a closed '
            'Observable';

  @override
  String toString() => 'ObservableException: $message';
}
