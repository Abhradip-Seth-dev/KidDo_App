import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
//import 'package:rive/rive.dart' hide Image;

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    content: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.only(top: 20),
                          height: 100,
                          decoration: BoxDecoration(
                            color: Color(0xffc2ffaf),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 80),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Great",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff149200),
                                      ),
                                    ),
                                    Text(
                                      "EXTRA INFO : This is the meaning of that answer.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 90, 159, 97),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          left: -30,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              SizedBox(
                                height: 150,
                                child: Image.asset(
                                  "assets/animation/correct.gif",
                                ),
                              ),

                              Positioned(
                                bottom: -20,
                                child: SizedBox(
                                  height: 80,
                                  child: Image.asset(
                                    "assets/images/correct-bubble.png",
                                  ),
                                ),
                              ),

                              Positioned(
                                child: SizedBox(
                                  height: 100,
                                  child: Lottie.asset(
                                    'assets/animation/click.json',
                                    repeat: false,
                                    delegates: LottieDelegates(
                                      values: [
                                        ValueDelegate.color(
                                          const ['**'],
                                          value: const Color.fromARGB(
                                            255,
                                            119,
                                            255,
                                            124,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                );
              },
              child: Text("right button"),
            ),

            SizedBox(width: 20),
            // ---- wrong button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 3),
                    content: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.only(top: 20),
                          height: 100,
                          decoration: BoxDecoration(
                            color: Color(0xffffadb7),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 80),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Oops !",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffa0041e),
                                      ),
                                    ),
                                    Text(
                                      "Correct Answer : This is the meaning of that answer.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 186, 90, 90),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          left: -30,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              SizedBox(
                                height: 150,
                                child: Image.asset(
                                  "assets/animation/incorrect.gif",
                                ),
                              ),

                              Positioned(
                                bottom: -20,
                                left: 30,
                                child: SizedBox(
                                  height: 80,
                                  child: Image.asset(
                                    "assets/images/incorrect-bubble.png",
                                  ),
                                ),
                              ),

                              Positioned(
                                child: SizedBox(
                                  height: 100,
                                  child: Lottie.asset(
                                    'assets/animation/click.json',
                                    repeat: false,
                                    delegates: LottieDelegates(
                                      values: [
                                        ValueDelegate.color(const [
                                          '**',
                                        ], value: Colors.red),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                );
              },
              child: Text("Wrong button"),
            ),
          ],
        ),
      ),
    );
  }
}
