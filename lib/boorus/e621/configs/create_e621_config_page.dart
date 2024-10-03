// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';

class CreateE621ConfigPage extends StatelessWidget {
  const CreateE621ConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
    this.isNewConfig = false,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;
  final BooruConfig config;
  final bool isNewConfig;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWithValue(config),
      ],
      child: CreateBooruConfigScaffold(
        initialTab: initialTab,
        isNewConfig: isNewConfig,
        backgroundColor: backgroundColor,
        authTab: const DefaultBooruAuthConfigView(),
        hasRatingFilter: true,
      ),
    );
  }
}
