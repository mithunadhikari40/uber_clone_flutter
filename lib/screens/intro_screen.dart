import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:uber_clone/screens/home.dart';
import 'package:uber_clone/utils/constants.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key key}) : super(key: key);

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyHomePage(title: Constants.APP_NAME)),
    );
  }

  void _onIntroSkip(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyHomePage(title: Constants.APP_NAME)),
    );
  }

  Widget _buildImage() {
    return Align(
      child: Image.network(Constants.kImageDemo, height: 175.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "First title page",
          body: "Text of the first page of this onboarding",
          image: _buildImage(),
        ),
        PageViewModel(
          title: "Second title page",
          body: "Text of the second page of this onboarding",
          image: _buildImage(),
          footer: RaisedButton(
            onPressed: () {
              /* Nothing */
            },
            child: const Text('Button', style: TextStyle(color: Colors.white)),
            color: Colors.lightBlue,
          ),
        ),
        PageViewModel(
          title: "Third title page",
          body: "Text of the third page of this onboarding",
          image: _buildImage(),
          decoration: PageDecoration(
            titleTextStyle: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
            bodyTextStyle: const TextStyle(fontSize: 22.0),
            dotsDecorator: const DotsDecorator(
              activeColor: Colors.red,
              activeSize: Size.fromRadius(8),
            ),
            pageColor: Colors.grey[200],
          ),
        ),
        PageViewModel(
          title: "Fourth title page",
          bodyWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Click on "),
              Icon(Icons.edit),
              Text(" to edit a post"),
            ],
          ),
          image: _buildImage(),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroSkip(context),
      // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
