import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'app_loader.dart';

class AppGridView extends HookWidget {
  final bool isInitialLoading;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final List itemsList;
  final ScrollController? scrollController;
  final Widget? emptyListPlaceholder;
  final EdgeInsets? listPadding;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const AppGridView({
    super.key,
    required this.isInitialLoading,
    this.listPadding,
    this.onRefresh,
    required this.itemsList,
    required this.itemBuilder,
    this.scrollController,
    this.emptyListPlaceholder,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
  });

  factory AppGridView.paginated({
    required bool isInitialLoading,
    bool scrollableChild = false,
    required Future<void> Function() onRefresh,
    required Widget Function(BuildContext context, int index) itemBuilder,
    required List itemsList,
    Widget? emptyListPlaceholder,
    required ScrollController scrollController,
    required bool isPaginationLoading,
    required VoidCallback onReachedScrollBottom,
    EdgeInsets? listPadding,
    bool shrinkWrap = false,
    int crossAxisCount = 2,
    double childAspectRatio = 1.0,
    double crossAxisSpacing = 0.0,
    double mainAxisSpacing = 0.0,
  }) {
    return _AppPaginatedGridView(
      scrollController: scrollController,
      isPaginationLoading: isPaginationLoading,
      scrollableChild: scrollableChild,
      isInitialLoading: isInitialLoading,
      onReachedScrollBottom: onReachedScrollBottom,
      onRefresh: onRefresh,
      itemsList: itemsList,
      itemBuilder: itemBuilder,
      emptyListPlaceholder: emptyListPlaceholder,
      listPadding: listPadding,
      shrinkWrap: shrinkWrap,
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isInitialLoading
        ? const Center(child: AppLoader(withBackground: true))
        : itemsList.isEmpty
        ? SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(child: emptyListPlaceholder),
          )
        : onRefresh != null
        ? RefreshIndicator(
            onRefresh: onRefresh!,
            child: GridView.builder(
              controller: scrollController,
              padding: listPadding,
              scrollDirection: scrollDirection,
              shrinkWrap: shrinkWrap,
              physics: shrinkWrap
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              itemCount: itemsList.length,
              itemBuilder: itemBuilder,
            ),
          )
        : GridView.builder(
            controller: scrollController,
            padding: listPadding,
            scrollDirection: scrollDirection,
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
            ),
            itemCount: itemsList.length,
            itemBuilder: itemBuilder,
          );
  }
}

class _AppPaginatedGridView extends AppGridView {
  const _AppPaginatedGridView({
    required super.scrollController,
    required this.isPaginationLoading,
    required this.onReachedScrollBottom,
    required super.isInitialLoading,
    required super.onRefresh,
    required super.listPadding,
    required super.itemsList,
    required super.itemBuilder,
    super.emptyListPlaceholder,
    super.shrinkWrap = false,
    this.scrollableChild = false,
    super.crossAxisCount = 2,
    super.childAspectRatio = 1.0,
    super.crossAxisSpacing = 0.0,
    super.mainAxisSpacing = 0.0,
  }) : assert(
         scrollController != null,
         '"scrollController" of "_AppPaginatedGridView" can\'t be null',
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
        : itemsList.isEmpty
        ? SizedBox(child: Center(child: emptyListPlaceholder))
        : onRefresh != null
        ? RefreshIndicator(
            onRefresh: onRefresh!,
            child: GridView.builder(
              padding: listPadding,
              itemCount: itemsList.length + (isPaginationLoading ? 1 : 0),
              shrinkWrap: shrinkWrap,
              physics: shrinkWrap
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              controller: scrollableChild ? null : scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              itemBuilder: (context, index) {
                if (isPaginationLoading && index == itemsList.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: AppLoader(withBackground: true)),
                  );
                }
                return itemBuilder(context, index);
              },
            ),
          )
        : GridView.builder(
            padding: listPadding,
            itemCount: itemsList.length + (isPaginationLoading ? 1 : 0),
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            controller: scrollableChild ? null : scrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
            ),
            itemBuilder: (context, index) {
              if (isPaginationLoading && index == itemsList.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: AppLoader(withBackground: true)),
                );
              }
              return itemBuilder(context, index);
            },
          );
  }
}
