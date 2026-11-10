// import 'package:flutter/material.dart';
// //import 'package:kiddo_app/features/avatar_Screen/avatar_page.dart';
// import 'package:kiddo_app/features/games/game_page.dart';
// import 'package:kiddo_app/features/home/home_page.dart';
// import 'package:kiddo_app/features/leaderboard/leaderboard_page.dart';
// import 'package:kiddo_app/features/lessons/lesson_page.dart';
// import 'package:kiddo_app/features/shop/shop_page.dart';
// //import 'package:kiddo_app/test.dart';
// import 'package:lottie/lottie.dart';
// import 'package:rive/rive.dart' hide LinearGradient;
// import 'package:gif/gif.dart';

// class MainScaffold extends StatefulWidget {
//   const MainScaffold({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _MainScaffoldState createState() => _MainScaffoldState();
// }

// class _MainScaffoldState extends State<MainScaffold> {
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   final List<Widget> _pages = [
//     HomePage(),
//     LessonPage(),
//     GamePage(),
//     LeaderboardPage(),
//     ShopPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Colors.white,
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         // A fixed height ensures the Stack sizes correctly for the sliding line
//         height: 75,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.white, Color.fromARGB(255, 206, 219, 228)],
//           ),
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 8),
//             ),
//           ],
//           border: Border.all(
//             width: 2,
//             color: const Color.fromARGB(255, 228, 236, 239),
//           ),
//         ),

//         // 👇 NEW: A Stack to put the line ON TOP of the row
//         child: Stack(
//           children: [
//             // 1. The Icons Row
//             Row(
//               // Notice we removed mainAxisAlignment.
//               // 'Expanded' handles the spacing automatically now!
//               children: [
//                 Expanded(
//                   child: Center(
//                     child: LottieNavItem(
//                       assetPath: 'assets/animation/Store.json',
//                       isSelected: _selectedIndex == 0,
//                       onTap: () => _onItemTapped(0),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: LottieNavItem(
//                       assetPath:
//                           'assets/animation/Book rotate with object..json',
//                       isSelected: _selectedIndex == 1,
//                       onTap: () => _onItemTapped(1),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: LottieNavItem(
//                       assetPath: 'assets/animation/Game Controller.json',
//                       isSelected: _selectedIndex == 2,
//                       onTap: () => _onItemTapped(2),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: GifNavItem(
//                       assetPath: 'assets/animation/leaderboard.gif',
//                       isSelected: _selectedIndex == 3,
//                       onTap: () => _onItemTapped(3),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: LottieNavItem(
//                       assetPath: 'assets/animation/shop.json',
//                       isSelected: _selectedIndex == 4,
//                       onTap: () => _onItemTapped(4),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // 2. The Sliding Indicator Line!
//             Positioned.fill(
//               child: AnimatedAlign(
//                 // This curve makes it stretch and snap into place playfully
//                 curve: Curves.easeOutBack,
//                 duration: const Duration(milliseconds: 300),
//                 // The Magic Math:
//                 // 1.0 means bottom of the container.
//                 // -0.8 + (_selectedIndex * 0.4) perfectly calculates the center of the 5 slices!
//                 alignment: Alignment(-0.8 + (_selectedIndex * 0.42), 1.0),
//                 child: Container(
//                   width: 24, // Width of the line
//                   height: 4, // Thickness of the line
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(
//                       255,
//                       130,
//                       172,
//                       244,
//                     ), // Put your app's main color here
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------
// // 1. FIXED LOTTIE WIDGET (No more disappearing)
// // ---------------------------------------------------
// class LottieNavItem extends StatefulWidget {
//   final String assetPath;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const LottieNavItem({
//     super.key,
//     required this.assetPath,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   State<LottieNavItem> createState() => _LottieNavItemState();
// }

// class _LottieNavItemState extends State<LottieNavItem>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//   }

//   @override
//   void didUpdateWidget(covariant LottieNavItem oldWidget) {
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       // Increase hit area slightly so the user doesn't miss the click
//       behavior: HitTestBehavior.opaque,
//       onTap: () {
//         widget.onTap();
//         _controller.reset();
//         _controller.forward();
//       },
//       // 👇 NEW: AnimatedScale added here
//       child: AnimatedScale(
//         scale: widget.isSelected ? 1.25 : 1.0, // 25% larger when selected
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOutBack, // Gives it a nice "pop" or bounce
//         child: AnimatedOpacity(
//           duration: const Duration(milliseconds: 200),
//           opacity: widget.isSelected ? 1.0 : 0.4,
//           child: SizedBox(
//             width: 70,
//             height: 55,
//             child: Lottie.asset(
//               widget.assetPath,
//               controller: _controller,
//               onLoaded: (composition) {
//                 _controller.duration = composition.duration;
//                 if (widget.isSelected) {
//                   _controller.forward();
//                 } else {
//                   _controller.value = 1.0;
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------
// // REVISED RIVE WIDGET (With Invisible Click Logic)
// // ---------------------------------------------------
// class RiveNavItem extends StatefulWidget {
//   final String assetPath;
//   final String stateMachineName;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const RiveNavItem({
//     super.key,
//     required this.assetPath,
//     required this.stateMachineName,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   State<RiveNavItem> createState() => _RiveNavItemState();
// }

// class _RiveNavItemState extends State<RiveNavItem> {
//   StateMachineController? _stateController;
//   SMIBool? _booleanInput;
//   SMITrigger? _triggerInput;

//   void _onRiveInit(Artboard artboard) {
//     final controller = StateMachineController.fromArtboard(
//       artboard,
//       widget.stateMachineName,
//     );

//     if (controller != null) {
//       artboard.addController(controller);
//       _stateController = controller;

//       for (var input in controller.inputs) {
//         if (input is SMIBool) _booleanInput = input;
//         if (input is SMITrigger) _triggerInput = input;
//       }

//       if (_booleanInput != null) {
//         _booleanInput!.value = widget.isSelected;
//       }
//       if (_triggerInput != null && widget.isSelected) {
//         _triggerInput!.fire();
//       }
//     }
//   }

//   @override
//   void didUpdateWidget(covariant RiveNavItem oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.isSelected != widget.isSelected) {
//       if (_booleanInput != null) {
//         _booleanInput!.value = widget.isSelected;
//       }
//       if (_triggerInput != null) {
//         _triggerInput!.fire();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _stateController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () {
//         if (!widget.isSelected) {
//           widget.onTap();
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 10.0),
//         // 👇 NEW: AnimatedScale added here
//         child: AnimatedScale(
//           scale: widget.isSelected ? 1.25 : 1.0,
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeOutBack,
//           child: AnimatedOpacity(
//             duration: const Duration(milliseconds: 200),
//             opacity: widget.isSelected ? 1.0 : 0.4,
//             child: SizedBox(
//               width: 60,
//               height: 40,
//               child: RiveAnimation.asset(
//                 widget.assetPath,
//                 onInit: _onRiveInit,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------
// // 3. NEW GIF WIDGET (Fixed AnimationController error)
// // ---------------------------------------------------
// class GifNavItem extends StatefulWidget {
//   final String assetPath;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const GifNavItem({
//     super.key,
//     required this.assetPath,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   State<GifNavItem> createState() => _GifNavItemState();
// }

// class _GifNavItemState extends State<GifNavItem>
//     with SingleTickerProviderStateMixin {
//   late final GifController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = GifController(vsync: this);

//     if (widget.isSelected) {
//       _controller.animateTo(1.0, duration: const Duration(milliseconds: 1000));
//     }
//   }

//   @override
//   void didUpdateWidget(covariant GifNavItem oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.isSelected && !oldWidget.isSelected) {
//       _controller.value = 0.0;
//       _controller.animateTo(1.0, duration: const Duration(milliseconds: 1000));
//     } else if (!widget.isSelected && oldWidget.isSelected) {
//       _controller.stop();
//       _controller.value = 0.0;
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: widget.onTap,
//       // 👇 NEW: AnimatedScale added here
//       child: AnimatedScale(
//         scale: widget.isSelected ? 1.25 : 1.0, // 25% larger when selected
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOutBack,
//         child: AnimatedOpacity(
//           duration: const Duration(milliseconds: 200),
//           opacity: widget.isSelected ? 1.0 : 0.4,
//           child: SizedBox(
//             width: 60,
//             height: 35,
//             child: Gif(
//               image: AssetImage(widget.assetPath),
//               controller: _controller,
//               autostart: Autostart.no,
//               repeat: ImageRepeat.noRepeat,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:gif/gif.dart';
import 'package:rive/rive.dart' hide LinearGradient;

class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // Function to handle tab changes using GoRouter
  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      // Display the page content with the floating bottom navigation bar overlay
      body: Stack(
        children: [
          // 1. Currently active page from the navigation shell
          Positioned.fill(child: widget.navigationShell),

          // 2. Floating Bottom Navigation Bar (No white container underneath)
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                height:
                    75, // Fixed height ensures the line slides exactly at the bottom
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color.fromARGB(255, 206, 219, 228)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    width: 2,
                    color: const Color.fromARGB(255, 228, 236, 239),
                  ),
                ),

                // Stack to place the sliding line ON TOP of the Row
                child: Stack(
                  children: [
                    // 1. The Row of Icons
                    Row(
                      children: [
                        // 1. HOME (Lottie)
                        Expanded(
                          child: Center(
                            child: LottieNavItem(
                              assetPath: 'assets/animation/Store.json',
                              isSelected: selectedIndex == 0,
                              onTap: () => _onItemTapped(0),
                            ),
                          ),
                        ),

                        // 2. LESSON (Lottie)
                        Expanded(
                          child: Center(
                            child: LottieNavItem(
                              assetPath:
                                  'assets/animation/Book rotate with object..json',
                              isSelected: selectedIndex == 1,
                              onTap: () => _onItemTapped(1),
                            ),
                          ),
                        ),

                        // 3. GAME (Lottie)
                        Expanded(
                          child: Center(
                            child: LottieNavItem(
                              assetPath:
                                  'assets/animation/Game Controller.json',
                              isSelected: selectedIndex == 2,
                              onTap: () => _onItemTapped(2),
                            ),
                          ),
                        ),

                        // 4. LEADERBOARD (Gif)
                        Expanded(
                          child: Center(
                            child: GifNavItem(
                              assetPath: 'assets/animation/leaderboard.gif',
                              isSelected: selectedIndex == 3,
                              onTap: () => _onItemTapped(3),
                            ),
                          ),
                        ),

                        // 5. SHOP (Lottie)
                        Expanded(
                          child: Center(
                            child: LottieNavItem(
                              assetPath: 'assets/animation/shop.json',
                              isSelected: selectedIndex == 4,
                              onTap: () => _onItemTapped(4),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 2. The Sliding Indicator Line
                    Positioned.fill(
                      child: AnimatedAlign(
                        curve: Curves.easeOutBack,
                        duration: const Duration(milliseconds: 300),
                        alignment: Alignment(-1.0 + (selectedIndex * 0.5), 1.0),
                        child: FractionallySizedBox(
                          widthFactor: 0.2,
                          child: Align(
                            heightFactor: 1.0,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 24,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------
// 1. UPDATED LOTTIE WIDGET
// ---------------------------------------------------
class LottieNavItem extends StatefulWidget {
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const LottieNavItem({
    super.key,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<LottieNavItem> createState() => _LottieNavItemState();
}

class _LottieNavItemState extends State<LottieNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensures the whole box is clickable
      onTap: () {
        widget.onTap();
        _controller.reset();
        _controller.forward();
      },
      child: AnimatedScale(
        scale: widget.isSelected ? 1.25 : 1.0, // Pops up 25% when selected
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.isSelected ? 1.0 : 0.4,
          child: SizedBox(
            width: 60,
            height: 50,
            child: Lottie.asset(
              widget.assetPath,
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                if (widget.isSelected) {
                  _controller.forward();
                } else {
                  _controller.value =
                      1.0; // Sit at the end frame when unselected
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------
// 2. UPDATED GIF WIDGET
// ---------------------------------------------------
class GifNavItem extends StatefulWidget {
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const GifNavItem({
    super.key,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<GifNavItem> createState() => _GifNavItemState();
}

class _GifNavItemState extends State<GifNavItem>
    with SingleTickerProviderStateMixin {
  late final GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);

    if (widget.isSelected) {
      _controller.animateTo(1.0, duration: const Duration(milliseconds: 1000));
    }
  }

  @override
  void didUpdateWidget(covariant GifNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.value = 0.0;
      _controller.animateTo(1.0, duration: const Duration(milliseconds: 1000));
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: widget.isSelected ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.isSelected ? 1.0 : 0.4,
          child: SizedBox(
            width: 60,
            height: 35,
            child: Gif(
              image: AssetImage(widget.assetPath),
              controller: _controller,
              autostart: Autostart.no,
              repeat: ImageRepeat.noRepeat,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------
// 3. UPDATED RIVE WIDGET (Included just in case you need it later!)
// ---------------------------------------------------
class RiveNavItem extends StatefulWidget {
  final String assetPath;
  final String stateMachineName;
  final bool isSelected;
  final VoidCallback onTap;

  const RiveNavItem({
    super.key,
    required this.assetPath,
    required this.stateMachineName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<RiveNavItem> createState() => _RiveNavItemState();
}

class _RiveNavItemState extends State<RiveNavItem> {
  StateMachineController? _stateController;
  SMIBool? _booleanInput;
  SMITrigger? _triggerInput;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      widget.stateMachineName,
    );

    if (controller != null) {
      artboard.addController(controller);
      _stateController = controller;

      for (var input in controller.inputs) {
        if (input is SMIBool) _booleanInput = input;
        if (input is SMITrigger) _triggerInput = input;
      }

      if (_booleanInput != null) {
        _booleanInput!.value = widget.isSelected;
      }
      if (_triggerInput != null && widget.isSelected) {
        _triggerInput!.fire();
      }
    }
  }

  @override
  void didUpdateWidget(covariant RiveNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSelected != widget.isSelected) {
      if (_booleanInput != null) {
        _booleanInput!.value = widget.isSelected;
      }
      if (_triggerInput != null) {
        _triggerInput!.fire();
      }
    }
  }

  @override
  void dispose() {
    _stateController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!widget.isSelected) {
          widget.onTap();
        }
      },
      child: AnimatedScale(
        scale: widget.isSelected ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.isSelected ? 1.0 : 0.4,
          child: SizedBox(
            width: 60,
            height: 40,
            child: RiveAnimation.asset(
              widget.assetPath,
              onInit: _onRiveInit,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
