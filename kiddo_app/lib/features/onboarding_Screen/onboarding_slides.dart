import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SlideTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final VoidCallback? onSkip;

  const SlideTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff7C3AED), // Primary purple
      body: SafeArea(
        child: Stack(
          children: [
            if (onSkip != null)
              Positioned(
                top: 10,
                right: 20,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imageAsset, height: 250).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 40),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 20),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Slide 4: Name Input
class SlideNameInput extends StatefulWidget {
  const SlideNameInput({super.key});

  @override
  State<SlideNameInput> createState() => _SlideNameInputState();
}

class _SlideNameInputState extends State<SlideNameInput> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff7C3AED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/kido_character.png', height: 150),
              const SizedBox(height: 30),
              const Text(
                "Hey there! What's your name?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black, fontSize: 20),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your name...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Slide 5: Demographics
class SlideDemographics extends StatelessWidget {
  const SlideDemographics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff7C3AED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Tell us about yourself!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Dummy slider for Age
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Age: 10', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Slider(value: 10, min: 6, max: 16, onChanged: (v) {}, activeColor: const Color(0xfffac62f)),
                ],
              ),
              const SizedBox(height: 20),
              // Dummy class selector
              const Text('Class: 5', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(10, (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Chip(label: Text('Class ${index+1}')),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Slide 6: Completion
class SlideComplete extends StatelessWidget {
  final VoidCallback onStart;
  const SlideComplete({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff7C3AED),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/kido_character.png', height: 200).animate().shake(duration: 800.ms, hz: 4),
              const SizedBox(height: 40),
              const Text(
                "You're all set! 🎓",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff59e0b),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Start Learning →', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
