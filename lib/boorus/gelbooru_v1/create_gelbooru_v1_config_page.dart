// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';

class CreateGelbooruV1ConfigPage extends StatelessWidget {
  const CreateGelbooruV1ConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
    this.isNewConfig = false,
    this.initialTab,
  });

  final BooruConfig config;
  final String? initialTab;
  final Color? backgroundColor;
  final bool isNewConfig;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWithValue(config),
      ],
      child: CreateBooruConfigScaffold(
        isNewConfig: isNewConfig,
        backgroundColor: backgroundColor,
        initialTab: initialTab,
      ),
    );
  }
}
