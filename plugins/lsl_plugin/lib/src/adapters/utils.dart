import 'dart:ffi';

void checkError(Pointer<Int32> ec) {
  if (ec[0] < 0) {
    switch (ec[0]) {
      case -1:
        throw Exception("The operation failed due to a timeout.");
      case -2:
        throw Exception("The stream has been lost.");
      case -3:
        throw Exception(
            "An argument was incorrectly specified (e.g., wrong format or wrong length).");
      case -4:
        throw Exception("An internal internal error has occurred.");
      default:
        throw Exception("An unknown error has occurred.");
    }
  }
}
