// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruImageGridItem extends ConsumerWidget {
  const DanbooruImageGridItem({
    super.key,
    required this.post,
    required this.hideOverlay,
    required this.autoScrollOptions,
    required this.enableFav,
    this.onTap,
    required this.image,
    this.ignoreBanOverlay = false,
  });

  final DanbooruPost post;
  final bool hideOverlay;
  final AutoScrollOptions autoScrollOptions;
  final VoidCallback? onTap;
  final bool enableFav;
  final Widget image;
  final bool ignoreBanOverlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFaved =
        post.isBanned ? false : ref.watch(danbooruFavoriteProvider(post.id));
    final artistTags = [...post.artistTags]..remove('banned_artist');
    final settings = ref.watch(imageListingSettingsProvider);

    return ConditionalParentWidget(
      condition: !ignoreBanOverlay && post.isBanned,
      conditionalBuilder: (child) => Stack(
        children: [
          child,
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: switch (post.source) {
                          final WebSource source =>
                            WebsiteLogo(url: source.faviconUrl),
                          _ => const SizedBox.shrink(),
                        },
                      ),
                      const SizedBox(width: 4),
                      const AutoSizeText(
                        maxLines: 1,
                        'Banned post',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (artistTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Wrap(
                        children: [
                          for (final tag in artistTags)
                            ActionChip(
                              visualDensity: VisualDensity.compact,
                              label: AutoSizeText(
                                tag.replaceUnderscoreWithSpace(),
                                minFontSize: 6,
                                maxLines: 1,
                                style: TextStyle(
                                  color: context.colorScheme.onErrorContainer,
                                ),
                              ),
                              backgroundColor:
                                  context.colorScheme.errorContainer,
                              onPressed: () {
                                AppClipboard.copyAndToast(
                                  context,
                                  artistTags.join(' '),
                                  message: 'Tag copied to clipboard',
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: ImageGridItem(
        borderRadius: BorderRadius.circular(
          settings.imageBorderRadius,
        ),
        isGif: post.isGif,
        isAI: post.isAI,
        hideOverlay: hideOverlay,
        isFaved: isFaved,
        enableFav: !post.isBanned && enableFav,
        onFavToggle: (isFaved) async {
          if (!isFaved) {
            ref.danbooruFavorites.remove(post.id);
          } else {
            ref.danbooruFavorites.add(post.id);
          }
        },
        quickActionButtonBuilder: defaultImagePreviewButtonBuilder(ref, post),
        autoScrollOptions: autoScrollOptions,
        onTap: post.isBanned
            ? switch (post.source) {
                final WebSource source => () =>
                    launchExternalUrlString(source.url),
                _ => null,
              }
            : onTap,
        image: image,
        isAnimated: post.isAnimated,
        isTranslated: post.isTranslated,
        hasComments: post.hasComment,
        hasParentOrChildren: post.hasParentOrChildren,
        hasSound: post.hasSound,
        duration: post.duration,
        score: post.isBanned
            ? null
            : settings.showScoresInGrid
                ? post.score
                : null,
      ),
    );
  }
}
