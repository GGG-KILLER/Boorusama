// Flutter imports:
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/boorus/current_booru_config_repository.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pool_repository.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

mixin PostExplorerServiceProviderMixin<T extends StatefulWidget> on State<T> {
  BlacklistedTagsRepository get blacklistedTagsRepository =>
      context.read<BlacklistedTagsRepository>();

  BooruUserIdentityProvider get booruUserIdentityProvider =>
      context.read<BooruUserIdentityProvider>();

  CurrentBooruConfigRepository get currentBooruConfigRepository =>
      context.read<CurrentBooruConfigRepository>();

  FavoritePostCubit get favoriteCubit => context.read<FavoritePostCubit>();

  PoolRepository get poolRepository => context.read<PoolRepository>();

  PostVoteCubit get postVoteCubit => context.read<PostVoteCubit>();

  PostVoteRepository get postVoteRepository =>
      context.read<PostVoteRepository>();

  PostPreviewPreloader? get previewPreloader =>
      context.read<PostPreviewPreloader>();
}

mixin PostExplorerMixin<T extends StatefulWidget, E> on State<T> {
  PostGridController<E> get controller;

  var posts = <E>[];

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChange);
    controller.refresh();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onControllerChange);
    controller.dispose();
  }

  void _onControllerChange() {
    if (controller.items.isNotEmpty) {
      setState(() {
        posts = controller.items;
      });
    }
  }
}
