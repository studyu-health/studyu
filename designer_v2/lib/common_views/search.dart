import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

const _searchBarMinHeight = 35.0;
const _searchIconSize = 20.0;
const _searchLeadingInset = 4.0;
const _searchHorizontalPadding = 12.0;

class const Search({
  super.key,
  required final Function(String) onQueryChanged,
  final SearchController? searchController,
  final String? hintText,
  final String? initialText,
}) extends StatefulWidget {
  @override
  SearchState createState() => SearchState();
}

class SearchState() extends State<Search> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    widget.searchController?.setText = setText;
    _searchController = TextEditingController(text: widget.initialText);
    _searchController.addListener(_onSearchPressed);
  }

  @override
  void didUpdateWidget(Search oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText &&
        widget.initialText != _searchController.text) {
      _searchController.text = widget.initialText ?? '';
    }
  }

  void _onSearchPressed() {
    final String query = _searchController.text;
    widget.onQueryChanged(query);
  }

  void setText(String text) {
    setState(() {
      _searchController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SearchBar(
      hintText: widget.hintText ?? tr.search,
      controller: _searchController,
      leading: const Padding(
        padding: EdgeInsetsDirectional.only(start: _searchLeadingInset),
        child: Icon(Icons.search_rounded, size: _searchIconSize),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
      constraints: const BoxConstraints(
        minHeight: _searchBarMinHeight,
        maxHeight: _searchBarMinHeight,
      ),
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.fromSTEB(
          _searchHorizontalPadding,
          0,
          _searchHorizontalPadding,
          0,
        ),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(theme.textTheme.bodyMedium),
      hintStyle: WidgetStatePropertyAll<TextStyle?>(
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      shadowColor: WidgetStateProperty.resolveWith((states) {
        return Colors.transparent;
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(_onSearchPressed);
    _searchController.dispose();
  }
}

class SearchController() {
  late void Function(String text) setText;
}
