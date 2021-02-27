// Flutter imports:
import 'package:flutter/cupertino.dart';

class SlideInRoute extends PageRouteBuilder {
  SlideInRoute({@required RoutePageBuilder pageBuilder})
      : assert(pageBuilder != null),
        super(pageBuilder: pageBuilder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    var tween = Tween(begin: Offset(1, 0), end: Offset.zero);

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}