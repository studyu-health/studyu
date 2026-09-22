int clampInviteCodePageIndex({
  required int requestedPageIndex,
  required int totalCount,
  required int pageSize,
}) {
  if (requestedPageIndex < 0 || totalCount <= 0) {
    return 0;
  }

  final lastValidPageIndex = (totalCount - 1) ~/ pageSize;
  return requestedPageIndex.clamp(0, lastValidPageIndex);
}
