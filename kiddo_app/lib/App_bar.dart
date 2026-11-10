// import 'package:flutter/material.dart';

// class Appbar extends StatefulWidget {
//   const Appbar({super.key});

//   @override
//   _AppbarState createState() => _AppbarState();
// }

// class _AppbarState extends State<AppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100,
//       width: 400,
//       color: Colors.white,
//       child: Row(
//         children: [
//           Container(
//             height: 20,
//             width: 20,
//             decoration: BoxDecoration(
//               color: Colors.grey,
//               shape: BoxShape.circle,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:kiddo_app/features/user/profilepage.dart';

/// Standalone app bar widget — used by screens OTHER than HomePage.
/// HomePage builds its own animated app bar inline for the profile animation.
class CustomStatefulAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  /// Optional callback. If null, tapping the avatar navigates to [Profilepage].
  final VoidCallback? onProfileTap;
  final double height;

  const CustomStatefulAppBar({
    super.key,
    this.onProfileTap,
    this.height = kToolbarHeight + 20,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<CustomStatefulAppBar> createState() => _CustomStatefulAppBarState();
}

class _CustomStatefulAppBarState extends State<CustomStatefulAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 400,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // PROFILE CIRCLE
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 0.0),
            child: GestureDetector(
              onTap: widget.onProfileTap ??
                  () => Navigator.of(context, rootNavigator: true).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const Profilepage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 350),
                        ),
                      ),
              child: Hero(
                tag: 'profile',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 70,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 60, left: 70.0),
            child: Container(
              height: 70,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xffe9ddff),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 60, left: 20.0),
            child: Container(
              height: 70,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xffffdfc5),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
