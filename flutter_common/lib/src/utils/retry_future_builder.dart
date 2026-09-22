/*
MIT License

Copyright (c) 2020 Tom Beckmann <tom@4ed1.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import 'package:flutter/material.dart';

typedef CustomErrorWidgetBuilder = Widget Function(
  BuildContext context,
  dynamic error,
  void Function() reload,
);

class const RetryFutureBuilder<T>({
  super.key,
  required final Future<T> Function() tryFunction,
  required final Widget Function(BuildContext, T?) successBuilder,

  /// a value to show immediately, before evaluating [tryFunction]
  final T? initialData,
  final Widget Function(BuildContext)? loadingBuilder,

  /// error handler function that gets to handle the error
  /// and return a widget to be displayed instead.
  /// return [null] to revert to default behavior
  final CustomErrorWidgetBuilder? errorWidgetBuilder,
  final List<Widget> extraWidgets = const [],
}) extends StatefulWidget {
  static RetryFutureBuilderState? of(BuildContext context) =>
      context.findAncestorStateOfType<RetryFutureBuilderState>();

  @override
  State<RetryFutureBuilder<T>> createState() => RetryFutureBuilderState<T>();
}

class RetryFutureBuilderState<T>() extends State<RetryFutureBuilder<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void didUpdateWidget(RetryFutureBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ATTENTION: This is based on the equality of functions. Not equal, if they are part of different instances
    if (widget.tryFunction != oldWidget.tryFunction) {
      reload();
    }
  }

  void reload() {
    setState(() {
      _future = widget.tryFunction();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      key: widget.key,
      initialData: widget.initialData,
      future: _future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              if (widget.errorWidgetBuilder != null) {
                return widget.errorWidgetBuilder!(
                  context,
                  snapshot.error,
                  reload,
                );
              }
              return buildErrorView(context, snapshot.error);
            }
            return widget.successBuilder(context, snapshot.data);
          default:
            return widget.loadingBuilder != null
                ? widget.loadingBuilder!(context)
                : const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildErrorView(BuildContext context, Object? error) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            // todo translate
            const Text('Could not load information. Device might be offline.'),
            //const SizedBox(height: 16),
            //Text(error.toString()),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: reload,
              icon: const Icon(Icons.sync),
              // todo translate
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
              ),
            ),
            ...widget.extraWidgets,
          ],
        ),
      ),
    );
  }
}
