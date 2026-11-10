import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  // Add this callback so the Master Screen can handle the button press
  final VoidCallback onNextPressed;

  const Page1({super.key, required this.onNextPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color.fromARGB(255, 194, 28, 133),
            child: Image.asset(
              "assets/images/yellow.jpeg",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 75,
            child: Container(
              height: 600,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "Lets Explore Our App ..",
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 3,
            right: -50,
            child: Container(
              height: 400,
              width: 400,
              child: Image.asset("assets/images/kido_character.png"),
            ),
          ),

          // THE NEXT BUTTON
          Positioned(
            bottom: 75,
            left: -5,
            child: GestureDetector(
              // USE THE CALLBACK HERE INSTEAD OF NAVIGATOR
              onTap: onNextPressed,
              child: Container(
                height: 50,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 40, 0, 115).withOpacity(.2),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(.8),
                    width: 5,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 30.0, top: 5),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
