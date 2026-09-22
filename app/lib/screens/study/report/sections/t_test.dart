import 'dart:math';

import 'package:statistics/statistics.dart';

/// A class implementing Welch's two-sample t-test for comparing means of two populations
/// with potentially different sizes and variances.
/// Based on the formula described at https://en.wikipedia.org/wiki/Student%27s_t-test
class TTest(final List<num> sampleA, final List<num> sampleB) {
  // Cached calculation results
  num? _meanA;
  num? _meanB;
  num? _varianceA;
  num? _varianceB;
  num? _tStatistic;
  num? _degreesOfFreedom;
  double? _pValue;

  /// Creates a new TTest with two samples to compare
  this {
    // Validate input data
    if (sampleA.isEmpty || sampleB.isEmpty) {
      throw ArgumentError('Samples cannot be empty');
    }
    if (sampleA.length < 2 || sampleB.length < 2) {
      throw ArgumentError(
        'Each sample must contain at least 2 values for variance calculation',
      );
    }
  }

  /// Returns the mean of sample A
  num get meanA => _meanA ??= sampleA.mean;

  /// Returns the mean of sample B
  num get meanB => _meanB ??= sampleB.mean;

  /// Returns the variance of sample A
  num get varianceA => _varianceA ??= _calculateVariance(sampleA);

  /// Returns the variance of sample B
  num get varianceB => _varianceB ??= _calculateVariance(sampleB);

  /// Calculates the variance of a sample
  num _calculateVariance(List<num> sample) {
    return pow(sample.standardDeviation, 2);
  }

  /// Returns the calculated t-statistic
  num get tStatistic {
    _tStatistic ??= _calculateTStatistic(
      meanA,
      meanB,
      varianceA,
      varianceB,
      sampleA.length,
      sampleB.length,
    );
    return _tStatistic!;
  }

  /// Returns the calculated degrees of freedom
  num get degreesOfFreedom {
    _degreesOfFreedom ??= _calculateDegreesOfFreedom(
      meanA,
      meanB,
      varianceA,
      varianceB,
      sampleA.length,
      sampleB.length,
    );
    return _degreesOfFreedom!;
  }

  /// Calculate t-statistic using Welch's formula for two sample t-test
  num _calculateTStatistic(
    num meanA,
    num meanB,
    num varianceA,
    num varianceB,
    int nA,
    int nB,
  ) {
    final num numerator = meanA - meanB;
    final num denominator = sqrt((varianceA / nA) + (varianceB / nB));
    return numerator / denominator;
  }

  /// Calculate degrees of freedom using Welch-Satterthwaite equation
  num _calculateDegreesOfFreedom(
    num meanA,
    num meanB,
    num varianceA,
    num varianceB,
    int nA,
    int nB,
  ) {
    final num numerator = pow((varianceA / nA) + (varianceB / nB), 2);
    final num denominator =
        (pow(varianceA / nA, 2) / (nA - 1)) +
        (pow(varianceB / nB, 2) / (nB - 1));
    return numerator / denominator;
  }

  /// Gamma function using Lanczos approximation
  num _gamma(num x) {
    const List<num> p = [
      676.5203681218851,
      -1259.1392167224028,
      771.32342877765313,
      -176.61502916214059,
      12.507343278686905,
      -0.13857109526572012,
      9.9843695780195716e-6,
      1.5056327351493116e-7,
    ];

    if (x < 0.5) {
      return pi / (sin(pi * x) * _gamma(1 - x));
    } else {
      final num y = x - 1;
      num a = 0.99999999999980993;
      final num t = y + 7.5;
      // Apply Lanczos approximation
      for (int i = 0; i < p.length; i++) {
        a += p[i] / (y + i + 1);
      }
      return sqrt(2 * pi) * pow(t, y + 0.5) * exp(-t) * a;
    }
  }

  /// Calculate the PDF of the t-distribution
  num _tDistributionPDF(num t, num v) {
    final num gammaHalfVPlus1 = _gamma((v + 1) / 2);
    final num gammaHalfV = _gamma(v / 2);
    final num sqrtVPI = sqrt(v * pi);

    final num numerator = gammaHalfVPlus1;
    final num denominator =
        sqrtVPI * gammaHalfV * pow(1 + (t * t) / v, (v + 1) / 2);

    return numerator / denominator;
  }

  /// Calculate the p-value for a two-tailed t-test
  double get pValue {
    if (_pValue == null) {
      final num absT = tStatistic.abs();
      final double positiveTailProbability = _integratePDF(
        absT,
        degreesOfFreedom,
      );
      _pValue = 2 * positiveTailProbability; // Two-tailed p-value
    }
    return _pValue!;
  }

  /// Numerical integration using the trapezoidal rule to approximate the CDF
  double _integratePDF(num tStatistic, num degreesOfFreedom) {
    const double stepSize = 0.001; // Step size for integration
    const double upperLimit = 10.0; // Upper integration limit
    double sum = 0.0;

    // Use trapezoidal rule for better accuracy
    double previousValue =
        _tDistributionPDF(tStatistic, degreesOfFreedom) as double;

    for (
      double t = tStatistic.toDouble() + stepSize;
      t < upperLimit;
      t += stepSize
    ) {
      final double currentValue =
          _tDistributionPDF(t, degreesOfFreedom) as double;
      sum += (previousValue + currentValue) / 2 * stepSize;
      previousValue = currentValue;
    }

    return sum;
  }

  /// Checks if the result is significant based on alpha level 0.05
  bool isSignificantlyDifferent({double alpha = 0.05}) {
    return pValue < alpha;
  }

  /// Returns a detailed results report
  Map<String, dynamic> getResults() {
    return {
      'meanA': meanA,
      'meanB': meanB,
      'varianceA': varianceA,
      'varianceB': varianceB,
      'sampleSizeA': sampleA.length,
      'sampleSizeB': sampleB.length,
      'tStatistic': tStatistic,
      'degreesOfFreedom': degreesOfFreedom,
      'pValue': pValue,
      'isSignificant': isSignificantlyDifferent(),
    };
  }

  /// Returns a string representation of the test results
  @override
  String toString() {
    return '''
    Welch's t-test Results:
    - Sample A: n=${sampleA.length}, mean=${meanA.toStringAsFixed(4)}, var=${varianceA.toStringAsFixed(4)}
    - Sample B: n=${sampleB.length}, mean=${meanB.toStringAsFixed(4)}, var=${varianceB.toStringAsFixed(4)}
    - t-statistic: ${tStatistic.toStringAsFixed(4)}
    - Degrees of freedom: ${degreesOfFreedom.toStringAsFixed(4)}
    - p-value: ${pValue.toStringAsFixed(6)}
    - Result: ${isSignificantlyDifferent() ? 'Significantly different' : 'Not significantly different'}
    ''';
  }
}
