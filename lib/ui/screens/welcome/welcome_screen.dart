import 'package:flutter/material.dart';
import 'package:time_gem/ui/screens/welcome/widgets/intro_widget.dart';
import 'package:time_gem/ui/screens/welcome/widgets/calendar_integration_widget.dart';
import 'package:time_gem/ui/screens/welcome/widgets/welcome_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final List<Widget> _pages = const [
    WelcomeWidget(),
    IntroWidget(),
    CalendarIntegrationWidget(),
  ];
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: _pages,
              ),
            ),
            // Dots Indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
