// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/users.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/users/users.dart';

Color? generateAutocompleteTagColor(
  WidgetRef ref,
  BuildContext context,
  AutocompleteData tag,
) {
  if (tag.hasCategory) {
    return ref.watch(tagColorProvider(tag.category!));
  } else if (tag.hasUserLevel) {
    return Color(getUserHexColor(stringToUserLevel(tag.level!)));
  }

  return null;
}

extension AutocompleteDataDisplayX on AutocompleteData {
  String toDisplayHtml(
    String value, [
    MetatagExtractor? metatagExtractor,
  ]) {
    final rawQuery = value.replaceAll('_', ' ').toLowerCase();
    final metatag = metatagExtractor?.fromString(value);
    final query =
        metatag != null ? rawQuery.replaceFirst('$metatag:', '') : rawQuery;

    String replaceAndHighlight(String text) {
      return text.replaceAllMapped(
        RegExp(query, caseSensitive: false),
        (match) => '<b>${match.group(0)}</b>',
      );
    }

    return hasAlias
        ? '<p>${replaceAndHighlight(antecedent!.replaceAll('_', ' '))} ➞ ${replaceAndHighlight(label)}</p>'
        : '<p>${replaceAndHighlight(label.replaceAll('_', ' '))}</p>';
  }
}
