// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'gelbooru_autocomplete_repository_api.dart';

final gelbooruAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final api = ref.watch(gelbooruClientProvider);

  return GelbooruAutocompleteRepositoryApi(api);
});