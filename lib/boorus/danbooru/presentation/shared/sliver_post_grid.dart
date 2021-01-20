import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/post_image.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter_riverpod/all.dart';

class SliverPostGrid extends StatelessWidget {
  const SliverPostGrid({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          if (index != null) {
            final post = posts[index];
            final items = <Widget>[];
            final image = PostImage(
              imageUrl: post.isAnimated
                  ? post.previewImageUri.toString()
                  : post.normalImageUri.toString(),
              placeholderUrl: post.previewImageUri.toString(),
            );

            // if (post.isFavorited) {
            //   items.add(
            //     Icon(
            //       Icons.favorite,
            //       color: Colors.redAccent,
            //     ),
            //   );
            // }

            if (post.isAnimated) {
              items.add(
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white70,
                ),
              );
            }

            if (post.isTranslated) {
              items.add(
                Icon(
                  Icons.g_translate_outlined,
                  color: Colors.white70,
                ),
              );
            }

            if (post.hasComment) {
              items.add(
                Icon(
                  Icons.comment,
                  color: Colors.white70,
                ),
              );
            }

            return Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () => AppRouter.router.navigateTo(context, "/posts",
                      routeSettings: RouteSettings(
                          arguments: [post, "${key.toString()}_${post.id}"])),
                  child:
                      Hero(tag: "${key.toString()}_${post.id}", child: image),
                ),
                _buildTopShadowGradient(),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Column(
                    children: items,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: LikeButton(
                    likeBuilder: (isLiked) => Icon(
                      Icons.favorite_border_rounded,
                      color: isLiked ? Colors.red : Colors.white,
                    ),
                    onTap: (isLiked) {
                      //TODO: check for success here
                      if (!isLiked) {
                        context
                            .read(postFavoriteStateNotifierProvider)
                            .favorite(post.id);

                        return Future(() => true);
                      } else {
                        context
                            .read(postFavoriteStateNotifierProvider)
                            .unfavorite(post.id);
                        return Future(() => false);
                      }
                    },
                  ),
                )
              ],
            );
          } else {
            return Center();
          }
        },
        staggeredTileBuilder: (index) =>
            StaggeredTile.extent(1, MediaQuery.of(context).size.height * 0.3),
      ),
    );
  }

  Widget _buildTopShadowGradient() {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: const Alignment(0.0, 0.4),
              begin: const Alignment(0.0, -1),
              colors: <Color>[
                const Color(0x2F000000),
                Colors.black12.withOpacity(0.0)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
