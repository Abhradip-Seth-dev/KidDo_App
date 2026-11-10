// import 'package:flutter/material.dart';
// //import 'package:flutter_svg/svg.dart';
// import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
// import 'package:fluttermoji/fluttermojiCustomizer.dart';

// class AvatarPage extends StatefulWidget {
//   const AvatarPage({super.key});

//   @override
//   State<AvatarPage> createState() => _AvatarPageState();
// }

// class _AvatarPageState extends State<AvatarPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         //mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(height: 30),
//           Expanded(flex: 1, child: FluttermojiCircleAvatar(radius: 100)),
//           SizedBox(height: 0),
//           Expanded(flex: 2, child: FluttermojiCustomizer()),
//           SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:fluttermoji/fluttermojiFunctions.dart'; // Import functions
import 'package:fluttermoji/fluttermojiCustomizer.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  // Instance of FluttermojiFunctions to fetch raw SVG data
  final FluttermojiFunctions fluttermojiFunctions = FluttermojiFunctions();

  @override
  Widget build(BuildContext context) {
    // Get screen width to dynamically size the avatar
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Create Avatar',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('DONE', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. The custom non-circular avatar display (roughly first half)
            Expanded(
              flex: 1, // Use flex to partition the screen. Total flex is 2.
              child: Container(
                color: Colors.grey[200], // Optional background color
                alignment: Alignment.center,
                child: FutureBuilder<String>(
                  // Call the function to get the raw SVG data string
                  future: fluttermojiFunctions.encodeMySVGtoString(),
                  builder: (context, snapshot) {
                    // Handle loading and errors
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data != null) {
                      // This is the core solution:
                      // Display the raw SVG string in a SvgPicture, un-circled.
                      return SizedBox(
                        height: 250, // Set height for the avatar figure
                        width:
                            screenWidth *
                            0.6, // Optional width to restrain scaling
                        child: SvgPicture.string(
                          snapshot.data!, // The SVG data from FutureBuilder
                          fit:
                              BoxFit.contain, // Scale to fit without stretching
                        ),
                      );
                    } else {
                      return const Text('No Avatar found');
                    }
                  },
                ),
              ),
            ),
            // 2. The Fluttermoji customizer (bottom half)
            Expanded(
              flex: 1, // Second flex for 50/50 split. Total is 2.
              child: Container(
                width: double.infinity,
                color: Colors.white,
                // The original customizer remains unchanged.
                child: FluttermojiCustomizer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
