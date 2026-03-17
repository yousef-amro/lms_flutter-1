import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'app_loader.dart';

class AppListView extends HookWidget {
  final bool isInitialLoading;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final List itemsList;
  final ScrollController? scrollController;
  final Widget? emptyListPlaceholder;
  final EdgeInsets? listPadding;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const AppListView({
    super.key,
    required this.isInitialLoading,
    this.listPadding,
    this.onRefresh,
    required this.itemsList,
    required this.itemBuilder,
    this.separatorBuilder,
    this.scrollController,
    this.emptyListPlaceholder,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  factory AppListView.paginated({
    required bool isInitialLoading,
    bool scrollableChild = false,
    required Future<void> Function() onRefresh,
    required Widget Function(BuildContext context, int index) itemBuilder,
    required Widget Function(BuildContext context, int index)? separatorBuilder,
    required List itemsList,
    Widget? emptyListPlaceholder,
    required ScrollController scrollController,
    required bool isPaginationLoading,
    required VoidCallback onReachedScrollBottom,
    EdgeInsets? listPadding,
    bool shrinkWrap = false,
  }) {
    return _AppPaginatedListView(
      scrollController: scrollController,
      isPaginationLoading: isPaginationLoading,
      scrollableChild: scrollableChild,
      isInitialLoading: isInitialLoading,
      onReachedScrollBottom: onReachedScrollBottom,
      onRefresh: onRefresh,
      itemsList: itemsList,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      emptyListPlaceholder: emptyListPlaceholder,
      listPadding: listPadding,
      shrinkWrap: shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isInitialLoading
        ? const Center(child: AppLoader(withBackground: true))
        : (itemsList.isEmpty || itemsList.isEmpty)
        ? SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(child: emptyListPlaceholder),
          )
        : RefreshIndicator(
            onRefresh: onRefresh ?? () async {},
            backgroundColor: onRefresh == null ? Colors.transparent : null,
            color: onRefresh == null ? Colors.transparent : null,
            child: ListView.separated(
              controller: scrollController,
              padding: listPadding,
              scrollDirection: scrollDirection,
              shrinkWrap: shrinkWrap,
              physics: shrinkWrap
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              itemCount: itemsList.length,
              itemBuilder: (context, index) {
                if (index >= itemsList.length) {
                  return const SizedBox.shrink();
                }
                return itemBuilder(context, index);
              },
              separatorBuilder:
                  separatorBuilder ?? (_, __) => const SizedBox.shrink(),
            ),
          );
  }
}

class _AppPaginatedListView extends AppListView {
  const _AppPaginatedListView({
    required super.scrollController,
    required this.isPaginationLoading,
    required this.onReachedScrollBottom,
    required super.isInitialLoading,
    required super.onRefresh,
    required super.listPadding,
    required super.itemsList,
    required super.itemBuilder,
    super.separatorBuilder,
    super.emptyListPlaceholder,
    super.shrinkWrap = false,
    this.scrollableChild = false,
  }) : assert(
         scrollController != null,
         '"scrollController" of "_ArabgtPaginatedListView" can\'t be null',
       );

  final VoidCallback onReachedScrollBottom;
  final bool isPaginationLoading;
  final bool scrollableChild;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      scrollController!.addListener(() {
        if (scrollController!.offset >=
            scrollController!.position.maxScrollExtent - 500) {
          onReachedScrollBottom();
        }
      });
      return null;
    }, []);

    return isInitialLoading
        ? const Center(child: AppLoader(withBackground: true))
        : (itemsList.isEmpty || itemsList.isEmpty)
        ? SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(child: emptyListPlaceholder),
          )
        : RefreshIndicator(
            onRefresh: onRefresh ?? () async {},
            child: ListView.separated(
              padding: listPadding,
              itemCount: itemsList.length + (isPaginationLoading ? 1 : 0),
              shrinkWrap: shrinkWrap,
              physics: shrinkWrap
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              controller: scrollableChild ? null : scrollController,
              itemBuilder: (context, index) {
                if (isPaginationLoading && index == itemsList.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: AppLoader(withBackground: true)),
                  );
                }
                if (index >= itemsList.length) {
                  return const SizedBox.shrink();
                }
                return itemBuilder(context, index);
              },
              separatorBuilder:
                  separatorBuilder ?? (_, __) => const SizedBox.shrink(),
            ),
          );
  }
}
