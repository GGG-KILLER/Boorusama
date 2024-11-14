// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class SimplePostStatsTile extends StatelessWidget {
  const SimplePostStatsTile({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    required this.totalComments,
    required this.favCount,
    required this.score,
    this.onFavCountTap,
    this.onScoreTap,
    this.onTotalCommentsTap,
    this.votePercentText,
  });

  final int totalComments;
  final int favCount;
  final int score;
  final EdgeInsets padding;
  final void Function()? onFavCountTap;
  final void Function()? onScoreTap;
  final void Function()? onTotalCommentsTap;
  final String? votePercentText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        children: [
          _StatButton(
            enable: onFavCountTap != null,
            onTap: () => onFavCountTap?.call(),
            child: RichText(
              text: TextSpan(
                text: '$favCount ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text: 'favorites.counter'.plural(favCount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colorScheme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _StatButton(
            enable: onScoreTap != null,
            onTap: () => onScoreTap?.call(),
            child: RichText(
              text: TextSpan(
                text: '$score ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text:
                        '${'post.detail.score'.plural(score)} ${votePercentText ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colorScheme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _StatButton(
            enable: onTotalCommentsTap != null,
            onTap: () => onTotalCommentsTap?.call(),
            child: RichText(
              text: TextSpan(
                text: '$totalComments ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
                children: [
                  TextSpan(
                    text: 'comment.counter'.plural(totalComments),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colorScheme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({
    required this.child,
    required this.enable,
    this.onTap,
  });

  final Widget child;
  final bool enable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: enable,
      conditionalBuilder: (child) => InkWell(
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        onTap: onTap,
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: child,
      ),
    );
  }
}
