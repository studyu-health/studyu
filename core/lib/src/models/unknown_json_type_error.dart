/// Error thrown when a JSON type is not recognized.
/// This is a subclass of [ArgumentError] because unknown enums also
/// throw an ArgumentError, so we can catch all of them together.
class UnknownJsonTypeError(final dynamic type) extends ArgumentError {
  @override
  String toString() {
    return 'UnknownJsonTypeError: $type';
  }
}
