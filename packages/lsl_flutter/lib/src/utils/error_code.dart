/// Possible error codes.
enum ErrorCode {
  /// No error occurred
  noError(0),

  /// The operation failed due to a timeout.
  timeoutError(-1),

  /// The stream has been lost.
  lostError(-2),

  /// An argument was incorrectly specified (e.g., wrong format or wrong length).
  argumentError(-3),

  /// Some other internal error has happened.
  internalError(-4);

  final int value;
  const ErrorCode(this.value);
}
