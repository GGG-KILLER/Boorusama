// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

const kFavoriteTagsSelectedLabelKey = 'favorite_tags_selected_label';

enum BlacklistedTagsSortType {
  recentlyAdded,
  // recentlyUpdated,
  nameAZ,
  nameZA,
}

final selectedBlacklistedTagQueryProvider =
    StateProvider.autoDispose<String>((ref) {
  return '';
});

final selectedBlacklistedTagsSortTypeProvider =
    StateProvider.autoDispose<BlacklistedTagsSortType>((ref) {
  return BlacklistedTagsSortType.recentlyAdded;
});

class BlacklistedTagPage extends ConsumerWidget {
  const BlacklistedTagPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(globalBlacklistedTagsProvider);
    final sortType = ref.watch(selectedBlacklistedTagsSortTypeProvider);
    final sortedTags = sortBlacklistedTags(tags, sortType);
    return Scaffold(
      appBar: AppBar(
        title: const Text('blacklist.manage.title').tr(),
        actions: [
          IconButton(
            onPressed: () {
              showMaterialModalBottomSheet(
                context: context,
                backgroundColor: context.colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                builder: (context) => BlacklistedTagConfigSheet(
                  onSorted: (value) {
                    ref
                        .read(selectedBlacklistedTagsSortTypeProvider.notifier)
                        .state = value;
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.sort,
              fill: 1,
              size: 20,
            ),
          ),
          AddBlacklistedTagButton(
            onAdd: (tag) {
              ref
                  .read(globalBlacklistedTagsProvider.notifier)
                  .addTagWithToast(context, tag);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlacklistedTagsList(
          tags: sortedTags.map((e) => e.name).toList(),
          onEditTap: (oldTag, newTag) {
            final oldBlacklistedTag =
                sortedTags.firstWhereOrNull((e) => e.name == oldTag);

            if (oldBlacklistedTag == null) {
              showErrorToast(context, 'Cannot find tag $oldTag');
              return;
            }

            ref.read(globalBlacklistedTagsProvider.notifier).updateTag(
                  oldTag: oldBlacklistedTag,
                  newTag: newTag,
                );
          },
          onRemoveTag: (tag) {
            final blacklistedTag =
                sortedTags.firstWhereOrNull((e) => e.name == tag);

            if (blacklistedTag == null) {
              showErrorToast(context, 'Cannot find tag $tag');
              return;
            }

            ref
                .read(globalBlacklistedTagsProvider.notifier)
                .removeTag(blacklistedTag);
          },
        ),
      ),
    );
  }
}

class AddBlacklistedTagButton extends StatelessWidget {
  const AddBlacklistedTagButton({
    super.key,
    required this.onAdd,
  });

  final void Function(String tag) onAdd;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        goToBlacklistedTagsSearchPage(
          context,
          onSelectDone: (tagItems, currentQuery) {
            final tagString = [
              ...tagItems.map((e) => e.toString()),
              if (currentQuery.isNotEmpty) currentQuery,
            ].join(' ');

            onAdd(tagString);
            context.navigator.pop();
          },
        );
      },
      icon: const Icon(Symbols.add),
    );
  }
}

List<BlacklistedTag> sortBlacklistedTags(
  IList<BlacklistedTag> tags,
  BlacklistedTagsSortType sortType,
) =>
    switch (sortType) {
      BlacklistedTagsSortType.recentlyAdded =>
        tags.sortedByCompare((e) => e.createdDate, (a, b) => b.compareTo(a)),
      // BlacklistedTagsSortType.recentlyUpdated =>
      //   tags.sortedByCompare((e) => e.updatedDate, (a, b) => b.compareTo(a)),
      BlacklistedTagsSortType.nameAZ =>
        tags.sortedByCompare((e) => e.name, (a, b) => a.compareTo(b)),
      BlacklistedTagsSortType.nameZA =>
        tags.sortedByCompare((e) => e.name, (a, b) => b.compareTo(a))
    };

class BlacklistedTagsList extends ConsumerWidget {
  const BlacklistedTagsList({
    super.key,
    required this.tags,
    required this.onRemoveTag,
    required this.onEditTap,
  });

  final List<String>? tags;
  final void Function(String tag) onRemoveTag;
  final void Function(String oldTag, String newTag) onEditTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return tags.toOption().fold(
          () => const Center(child: CircularProgressIndicator()),
          (tags) => tags.isNotEmpty
              ? CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: WarningContainer(
                        title: 'Limitation',
                        contentBuilder: (context) => AppHtml(
                          data: 'blacklisted_tags.limitation_notice'.tr(),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tag = tags[index];

                          return BlacklistedTagTile(
                            tag: tag,
                            onRemoveTag: (_) => onRemoveTag(tag),
                            onEditTap: () {
                              goToBlacklistedTagsSearchPage(
                                context,
                                initialTags: tag.split(' '),
                                onSelectDone: (tagItems, currentQuery) {
                                  final tagString = [
                                    ...tagItems.map((e) => e.toString()),
                                    if (currentQuery.isNotEmpty) currentQuery,
                                  ].join(' ');

                                  onEditTap(tag, tagString);
                                  context.navigator.pop();
                                },
                              );
                            },
                          );
                        },
                        childCount: tags.length,
                      ),
                    ),
                  ],
                )
              : const Center(child: Text('No blacklisted tags')),
        );
  }
}

// ignore: prefer-single-widget-per-file
class BlacklistedTagTile extends StatelessWidget {
  const BlacklistedTagTile({
    super.key,
    required this.tag,
    required this.onEditTap,
    required this.onRemoveTag,
  });

  final String tag;
  final VoidCallback onEditTap;
  final void Function(String tag) onRemoveTag;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tag),
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 'remove':
              onRemoveTag.call(tag);
              break;
            case 'edit':
              onEditTap.call();
              break;
          }
        },
        itemBuilder: {
          'remove': const Text('blacklisted_tags.remove').tr(),
          'edit': const Text('blacklisted_tags.edit').tr(),
        },
      ),
    );
  }
}

class BlacklistedTagConfigSheet extends StatelessWidget {
  const BlacklistedTagConfigSheet({
    super.key,
    required this.onSorted,
  });

  final void Function(BlacklistedTagsSortType) onSorted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DragLine(),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Recently added',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(BlacklistedTagsSortType.recentlyAdded);
                },
              ),
              // ListTile(
              //   title: const Text(
              //     'Recently updated',
              //     style: TextStyle(
              //       fontSize: 16,
              //     ),
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //     onSorted(BlacklistedTagsSortType.recentlyUpdated);
              //   },
              // ),
              ListTile(
                title: const Text(
                  'Name (A-Z)',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(BlacklistedTagsSortType.nameAZ);
                },
              ),
              // name (z-a)
              ListTile(
                title: const Text(
                  'Name (Z-A)',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(BlacklistedTagsSortType.nameZA);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}
