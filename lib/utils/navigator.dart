import 'package:flutter/material.dart';

navigateWithAnimationWithBackStack(Widget child, BuildContext context,
    {Offset beginOffset = const Offset(0, .8),
    Offset endOffset = Offset.zero,
    int duration = 1}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionsBuilder: (BuildContext context, animation,
              Animation secondaryAnimation, Widget child) =>
//                            FadeTransition(opacity: animation, child: child),
//                        ScaleTransition(scale: animation,child: child,alignment: Alignment.center,),
          SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
//              begin: Offset(0, .8),
          end: endOffset,
//              end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return child;
      },
      transitionDuration: Duration(seconds: duration),
    ),
  );
}

navigateWithAnimationDestroyingBackStack(Widget child, BuildContext context,
    {Offset beginOffset = const Offset(0, .8),
    Offset endOffset = Offset.zero,
    int duration = 1}) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionsBuilder: (BuildContext context, animation,
              Animation secondaryAnimation, Widget child) =>
//                            FadeTransition(opacity: animation, child: child),
//                        ScaleTransition(scale: animation,child: child,alignment: Alignment.center,),
          SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
//              begin: Offset(0, .8),
          end: endOffset,
//              end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return child;
      },
      transitionDuration: Duration(seconds: duration),
    ),
  );
}
