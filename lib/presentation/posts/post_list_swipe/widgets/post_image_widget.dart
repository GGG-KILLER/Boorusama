import 'package:boorusama/application/posts/post_translate_note/bloc/post_note_bloc.dart';
import 'package:boorusama/domain/posts/note.dart';
import 'package:boorusama/domain/posts/note_coordinate.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:super_tooltip/super_tooltip.dart';

class PostImage extends StatefulWidget {
  PostImage(
      {@required this.post,
      this.onLongPressed,
      this.onNoteVisibleChanged,
      this.postHeroTag,
      @required this.controller});

  final ValueChanged<bool> onNoteVisibleChanged;
  final Function onLongPressed;
  final Post post;
  final PostImageController controller;
  final String postHeroTag;

  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  ValueNotifier<bool> notesVisible = ValueNotifier(false);
  List<Note> notes = <Note>[];
  Flushbar _noteFlushbar;

  @override
  void initState() {
    super.initState();
    widget.controller.postImageState = this;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _noteFlushbar = Flushbar(
        icon: Icon(
          Icons.info_outline,
          color: Theme.of(context).accentColor,
        ),
        leftBarIndicatorColor: Theme.of(context).accentColor,
        title: "Loading",
        message: "Fetching translation notes, plese hold on...",
      );
    });
  }

  @override
  void dispose() {
    _noteFlushbar = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.postHeroTag,
      child: BlocListener<PostNoteBloc, PostNoteState>(
        listener: (context, state) {
          state.when(
            empty: () {},
            loading: () => _noteFlushbar.show(context),
            fetched: (notes) {
              setState(() {
                this.notes = notes;
              });
              _noteFlushbar.dismiss();
            },
          );
        },
        child: ValueListenableBuilder(
          valueListenable: notesVisible,
          builder: (context, value, child) => Stack(
            children: <Widget>[
              _Image(imageUrl: widget.post.normalImageUri.toString()),
              if (value) ...buildNotes(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildNotes() {
    final widgets = List<Widget>();

    final screenWidth = MediaQuery.of(context).size.width;
    //TODO: Can't get status bar height inside Scaffold
    final screenHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        24 -
        60; // minus toolbar height, status bar height and custom value for the bottom sheet;
    final screenAspectRatio = screenWidth / screenHeight;

    for (var note in notes) {
      final coordinate = note.coordinate.calibrate(
          screenHeight,
          screenWidth,
          screenAspectRatio,
          widget.post.height,
          widget.post.width,
          widget.post.aspectRatio);

      widgets.add(
        _Note(
          coordinate: coordinate,
          content: note.content,
          targetContext: context,
        ),
      );
    }

    return widgets;
  }

  void showTranslationNotes() {
    if (notes.isEmpty) {
      BlocProvider.of<PostNoteBloc>(context)
          .add(PostNoteEvent.requested(postId: widget.post.id));
    }

    notesVisible.value = true;

    widget.onNoteVisibleChanged(notesVisible.value);
  }

  void hideTranslationNotes() {
    notesVisible.value = false;

    widget.onNoteVisibleChanged(notesVisible.value);
  }
}

class _Note extends StatelessWidget {
  const _Note({
    Key key,
    @required this.coordinate,
    @required this.content,
    @required this.targetContext,
  }) : super(key: key);

  final NoteCoordinate coordinate;
  final String content;
  final BuildContext targetContext;

  @override
  Widget build(BuildContext context) {
    var tooltip = SuperTooltip(
      backgroundColor: Theme.of(context).cardColor,
      arrowTipDistance: 0,
      arrowBaseWidth: 0,
      arrowLength: 0,
      popupDirection: TooltipDirection.left,
      content: Material(
        child: Html(data: content),
        color: Theme.of(context).cardColor,
      ),
    );
    return GestureDetector(
      onTap: () => tooltip.show(targetContext),
      child: Container(
        margin: EdgeInsets.only(left: coordinate.x, top: coordinate.y),
        width: coordinate.width,
        height: coordinate.height,
        decoration: BoxDecoration(
            color: Colors.white54,
            border: Border.all(color: Colors.red, width: 1)),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        precacheImage(imageProvider, context);
        return PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.color,
          ),
        );
      },
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class PostImageController {
  _PostImageState postImageState;

  PostImageController();

  bool get notesVisible => postImageState.notesVisible.value;

  void showTranslationNotes() {
    postImageState.showTranslationNotes();
  }

  void hideTranslationNotes() {
    postImageState.hideTranslationNotes();
  }

  void toggleTranslationNotes() {
    postImageState.notesVisible.value
        ? postImageState.hideTranslationNotes()
        : postImageState.showTranslationNotes();
  }

  void dispose() {
    postImageState = null;
  }
}
