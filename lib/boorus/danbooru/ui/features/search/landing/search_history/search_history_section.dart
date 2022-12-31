// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'history_list.dart';

import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart'
    show SearchHistoryBloc;

class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryRemoved,
    required this.onHistoryCleared,
  });

  final ValueChanged<String> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;
  final void Function() onHistoryCleared;

  @override
  Widget build(BuildContext context) {
    final status =
        context.select((SearchHistoryBloc cubit) => cubit.state.histories);

    return status.isNotEmpty
        ? HistoryList(
            onHistoryRemoved: onHistoryRemoved,
            onHistoryTap: onHistoryTap,
            onHistoryCleared: onHistoryCleared,
          )
        : const SizedBox.shrink();
  }
}