// File: tutorial_modal.dart

import 'package:flutter/material.dart';

// --- Helper Widget (Keep this unchanged) ---
Widget _buildTutorialPage({
  required String title,
  required String description,
  required IconData imagePlaceholder,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Icon(imagePlaceholder, size: 100, color: Colors.blue),
      const SizedBox(height: 20),
      Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Text(
        description,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
// --- END Helper Widget ---

// --- New Stateful Modal Widget ---

void showTutorialModal(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const _TutorialDialogContent();
      },
    );
  });
}

class _TutorialDialogContent extends StatefulWidget {
  const _TutorialDialogContent();

  @override
  State<_TutorialDialogContent> createState() => _TutorialDialogContentState();
}

class _TutorialDialogContentState extends State<_TutorialDialogContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      // Use round() to ensure the index is an integer even during a swipe
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper method for the Pips
  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String buttonText = _currentPage == _totalPages - 1 ? 'DONE' : 'NEXT';

    return AlertDialog(
      // 3. REMOVED the 'title' argument entirely.
      // 3. Adjusted padding since the title is gone.
      contentPadding: const EdgeInsets.only(
        top: 0,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      titlePadding: EdgeInsets.zero,

      // Used to position the Skip button on top right
      title: Stack(
        alignment: Alignment.topRight,
        children: [
          // Empty Padding is left here just to provide the Stack some height,
          // but you could remove this and rely on the IconButton size.
          const Padding(
            padding: EdgeInsets.only(top: 0, left: 20, right: 20),
            child: SizedBox(height: 0),
          ),

          // 2. Changed IconButton to TextButton with 'Skip'
          Padding(
            padding: const EdgeInsets.all(8.0), // Adds a little margin
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Skip'),
            ),
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content height
        children: [
          SizedBox(
            height: 400,
            width: double.maxFinite,
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                // Carousel Item 1
                _buildTutorialPage(
                  title: 'Welcome To MakiPrint',
                  description:
                      'Welcome to MakiPrint! Your journey to seamless printing starts here. Let\'s get you familiar with the app.',
                  imagePlaceholder: Icons.rocket_launch,
                ),
                // Carousel Item 2
                _buildTutorialPage(
                  title: 'Upload a File',
                  description:
                      'Tap the "+" button to select the file you would like to print from your phone.',
                  imagePlaceholder: Icons.add_circle_outline,
                ),
                // Carousel Item 3
                _buildTutorialPage(
                  title: 'Modify Printing Settings',
                  description:
                      'Before printing, you can adjust settings like color mode, number of copies, and paper size. Price of the document will update accordingly.',
                  imagePlaceholder: Icons.settings,
                ),

                // Carousel Item 4
                _buildTutorialPage(
                  title: 'Scan QR',
                  description:
                      'When you are ready to print, scan the MakiPrint QR Code on the printer.',
                  imagePlaceholder: Icons.settings,
                ),

                // Carousel Item 5
                _buildTutorialPage(
                  title: 'Wait for the Document',
                  description:
                      'That\'s it! Your document will be printed immediately. ',
                  imagePlaceholder: Icons.settings,
                ),
              ],
            ),
          ),

          // 1. Pips/Dots indicator
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, _buildDot),
            ),
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            if (_currentPage < _totalPages - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(buttonText),
        ),
      ],
    );
  }
}
