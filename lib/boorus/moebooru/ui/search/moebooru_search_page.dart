// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/post_grid_config_icon_button.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';
import 'package:boorusama/core/ui/search/search_app_bar.dart';
import 'package:boorusama/core/ui/search/search_app_bar_result_view.dart';
import 'package:boorusama/core/ui/search/search_button.dart';
import 'package:boorusama/core/ui/search/search_divider.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/ui/search/tag_suggestion_items.dart';

class MoebooruSearchPage extends ConsumerStatefulWidget {
  const MoebooruSearchPage({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(BuildContext context, {String? tag}) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: MoebooruProvider.of(
        context,
        builder: (gcontext) {
          final favoriteTagBloc = gcontext.read<FavoriteTagBloc>()
            ..add(const FavoriteTagFetched());

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: favoriteTagBloc),
            ],
            child: CustomContextMenuOverlay(
              child: ProviderScope(
                overrides: [
                  selectedTagsProvider.overrideWith(SelectedTagsNotifier.new),
                ],
                child: MoebooruSearchPage(
                  metatagHighlightColor: Theme.of(context).colorScheme.primary,
                  initialQuery: tag,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<MoebooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<MoebooruSearchPage> {
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      ref.read(searchMetatagStringRegexProvider): TextStyle(
        fontWeight: FontWeight.w800,
        color: widget.metatagHighlightColor,
      ),
    },
    // ignore: no-empty-block
    onMatch: (List<String> match) {},
  );
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        ref
            .read(searchProvider.notifier)
            .skipToResultWithTag(widget.initialQuery!);
      }
    });
  }

  @override
  void dispose() {
    queryEditingController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayState = ref.watch(searchProvider);
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    ref.listen(
      sanitizedQueryProvider,
      (prev, curr) {
        if (prev != curr) {
          final displayState = ref.read(searchProvider);
          if (curr.isEmpty && displayState != DisplayState.result) {
            queryEditingController.clear();
          }
        }
      },
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Builder(builder: (context) {
        switch (displayState) {
          case DisplayState.options:
            return Scaffold(
              floatingActionButton: const SearchButton(),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                child: SearchAppBar(
                  focusNode: focus,
                  queryEditingController: queryEditingController,
                ),
              ),
              body: const SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SelectedTagListWithData(),
                      SearchDivider(),
                      SearchLandingView(),
                    ],
                  ),
                ),
              ),
            );
          case DisplayState.suggestion:
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                child: SearchAppBar(
                  focusNode: focus,
                  queryEditingController: queryEditingController,
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    const SelectedTagListWithData(),
                    const SearchDivider(),
                    Expanded(
                      child: TagSuggestionItemsWithData(
                        textColorBuilder: (tag) =>
                            generateDanbooruAutocompleteTagColor(tag, theme),
                      ),
                    ),
                  ],
                ),
              ),
            );
          case DisplayState.result:
            final selectedTags = ref.watch(selectedRawTagStringProvider);

            return PostScope(
              fetcher: (page) =>
                  context.read<PostRepository>().getPostsFromTags(
                        selectedTags.join(' '),
                        page,
                      ),
              builder: (context, controller, errors) =>
                  MoebooruInfinitePostList(
                errors: errors,
                controller: controller,
                sliverHeaderBuilder: (context) => [
                  const SearchAppBarResultView(),
                  const SliverToBoxAdapter(child: SearchDivider(height: 7)),
                  const SliverToBoxAdapter(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: PostGridConfigIconButton(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        }
      }),
    );
  }
}
