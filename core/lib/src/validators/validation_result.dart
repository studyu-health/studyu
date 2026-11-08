enum ValidationLevel { draft, publish }

class ValidationError {
  final String code;
  final String path;
  final String message;
  final String fixHint;

  const ValidationError({
    required this.code,
    required this.path,
    required this.message,
    required this.fixHint,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'path': path,
    'message': message,
    'fixHint': fixHint,
  };
}

class ValidationResult {
  final List<ValidationError> errors;
  final List<ValidationError> warnings;

  const ValidationResult({required this.errors, required this.warnings});

  bool get valid => errors.isEmpty;

  factory ValidationResult.empty() =>
      const ValidationResult(errors: [], warnings: []);

  factory ValidationResult.merge(List<ValidationResult> results) {
    return ValidationResult(
      errors: results.expand((r) => r.errors).toList(),
      warnings: results.expand((r) => r.warnings).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'valid': valid,
    'errors': errors.map((e) => e.toJson()).toList(),
    'warnings': warnings.map((e) => e.toJson()).toList(),
  };
}
