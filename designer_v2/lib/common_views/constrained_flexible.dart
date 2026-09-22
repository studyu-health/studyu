import 'package:flutter/widgets.dart';

/// Taken from
/// https://stackoverflow.com/questions/56417186/specific-min-and-max-size-for-expanded-widgets-in-column
class const ConstrainedWidthFlexible({
  required final double minWidth,
  required final double maxWidth,
  required final int flex,
  required final int flexSum,
  required final BoxConstraints outerConstraints,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      child: SizedBox(
        width: _getWidth(outerConstraints.maxWidth),
        child: child,
      ),
    );
  }

  double _getWidth(double outerContainerWidth) {
    return outerContainerWidth * flex / flexSum;
  }
}
