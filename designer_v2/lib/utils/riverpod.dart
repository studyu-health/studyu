/// Interface for providers of data of type [R] given arguments [A]
///
/// Should be used when providing an object via Riverpod that is owned/managed
/// by another object (and injecting the owner directly or managing the object
/// independently is not possible or desirable)
abstract class IProviderArgsResolver<R, A>() {
  R provide(A args);
}
