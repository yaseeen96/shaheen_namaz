import 'package:flutter/material.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CustomLoadingIndicator extends StatelessWidget {
  CustomLoadingIndicator({this.text = ''});

  final String text;

  @override
  Widget build(BuildContext context) {
    var displayedText = text.isNotEmpty ? text : Constants.getRandomQuote();

    return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(50),
        color: Constants.bgColor,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getCustomLoadingIndicator(),
              _getHeading(context),
              _getText(displayedText)
            ]));
  }

  Padding _getCustomLoadingIndicator() {
    return Padding(
        child: Container(
            child: LoadingIndicator(
              indicatorType: Indicator.ballScaleMultiple,

              /// Required, The loading type of the widget
              colors: const [Colors.green, Colors.red],

              /// Optional, The color collections
              strokeWidth: 2,

              /// Optional, The stroke of the line, only applicable to widget which contains line
            ),
            width: 50,
            height: 50),
        padding: EdgeInsets.only(bottom: 16));
  }

  Widget _getHeading(context) {
    return Padding(
        child: Text(
          'Just a moment…',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        padding: EdgeInsets.only(bottom: 4));
  }

  Text _getText(String displayedText) {
    return Text(
      '$displayedText',
      style: TextStyle(color: Colors.white, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}
