// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/creator_repository.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/functional.dart';

class CreatorsNotifier extends Notifier<IMap<int, Creator>> {
  CreatorRepository get repo => ref.watch(danbooruCreatorRepoProvider);

  @override
  IMap<int, Creator> build() {
    return <int, Creator>{}.lock;
  }

  Future<void> load(List<int> ids) async {
    // only load ids that are not already loaded
    final notInCached = ids.where((id) => !state.containsKey(id)).toList();

    final creators =
        await repo.getCreatorsByIdStringComma(notInCached.join(','));

    final map = {
      for (final creator in creators) creator.id: creator,
    }.lock;

    state = state.addAll(map);
  }
}
