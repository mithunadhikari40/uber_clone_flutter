import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/intro/sms_code_validation_section.dart';
import 'package:uber_clone/screens/app_showcase_map.dart';
import 'package:uber_clone/screens/reusable/animation/animating_rotating_arc.dart';
import 'package:uber_clone/screens/reusable/radio_button_list.dart';
import 'package:uber_clone/utils/navigator.dart';

class PersonalInformationSection extends StatefulWidget {
  @override
  _PersonalInformationSectionState createState() =>
      _PersonalInformationSectionState();
}

class _PersonalInformationSectionState extends State<PersonalInformationSection>
    with TickerProviderStateMixin<PersonalInformationSection> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  GlobalKey<AnimatingRotatingArcState> _arcKey = GlobalKey();
  USER_VERIFICATION userVerified = USER_VERIFICATION.UNDER_PROCESS;
  String firstName;
  String lastName;
  String gender;
  String errorMessage = "";
  List<RadioModel> sampleData = new List<RadioModel>();
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              _buildBackArrow(context),
              _buildDescriptionSection(context),
//              Row(
//                mainAxisSize: MainAxisSize.max,
//                crossAxisAlignment: CrossAxisAlignment.center,
//                children: <Widget>[
//                  Expanded(
//                    child: Padding(
//                      padding: const EdgeInsets.only(
//                          left: 8.0, right: 8.0, bottom: 8.0),
//                      child: _buildPersonalInfoInput(context, "name",
//                          maxLength: 100, minLength: 10),
//                    ),
//                  ),
//                  Expanded(
//                    child: Padding(
//                      padding: const EdgeInsets.only(
//                          left: 8.0, right: 8.0, bottom: 8.0),
//                      child: _buildPersonalInfoInput(context, "gender"),
//                    ),
//                  ),
//                ],
//              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 8.0),
                      child: _buildPersonalInfoFirstName(context),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 8.0),
                      child: _buildPersonalInfoLastName(context),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Your preferred gender (Optional)",
                    style: TextStyle(color: Colors.blue, fontSize: 16.0),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                height: 50,
                child: CustomRadioListTile(
                    sampleData: sampleData,
                    selectedData: (int index, String value) {
                      Fluttertoast.showToast(
                          msg:
                              "selected index $index and selcted value $value");
                    }),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: _buildGotoNextScreenButton(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Widget _buildPersonalInfoFirstName(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
          border: Border.all(color: Colors.blue[400])),
      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Container(
//          margin: EdgeInsets.only(left: 10, top: 0),
          child: TextField(
            autofocus: true,
            controller: _firstNameController,
            style: TextStyle(fontSize: 16.0),
            textInputAction: TextInputAction.next,
            onSubmitted: (value) {
              FocusScope.of(context).requestFocus(_focusNode);
            },
            decoration: InputDecoration(
              hintText: "Albert",
              border: InputBorder.none,
              suffixIcon: IconButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "This thing is called");
                  _firstNameController.clear();
                },
                icon: Icon(Icons.clear),
              ),
//              contentPadding: EdgeInsets.only(left: 5.0, top: 16.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoLastName(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
          border: Border.all(color: Colors.blue[400])),
      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Container(
//          margin: EdgeInsets.only(left: 10, top: 0),
          child: TextField(
            controller: _lastNameController,
            focusNode: _focusNode,
            style: TextStyle(fontSize: 16.0),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              _navigateToNextScreen(context);
            },
            decoration: InputDecoration(
              hintText: "Einstine",
              border: InputBorder.none,
              suffixIcon: IconButton(
                onPressed: () {
                  _lastNameController.clear();
                },
                icon: Icon(Icons.clear),
              ),
//              contentPadding: EdgeInsets.only(left: 5.0, top: 16.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    sampleData.add(RadioModel(false, 'Male', 'April 18'));
    sampleData.add(RadioModel(false, 'Female', 'April 17'));
    sampleData.add(RadioModel(false, 'Others', 'April 16'));
  }

  Widget _buildBackArrow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          onPressed: () {
            _arcKey.currentState.toggleAnimation(false);
            navigateWithAnimationWithBackStack(
                SmsCodeValidationSection(
                  phoneNumber: _firstNameController.text,
                  verificationId: "",
                ),
                context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ],
    );
  }

  _buildGotoNextScreenButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
      child: AnimatingRotatingArc(
        child: FloatingActionButton(
          onPressed: () {
            _navigateToNextScreen(context);
          },
          backgroundColor: Colors.black,
          child: Icon(
            Icons.arrow_forward_ios,
            size: 32.0,
          ),
        ),
        key: _arcKey,
      ),
    );
  }

  bool validateName(TextEditingController controller) {
    if (!(controller.text.length > 5)) {
      this.setState(() {
        errorMessage = "Name must be at least 5 charactes long";
      });
      return false;
    } else {
      return true;
    }
  }

  _buildDescriptionSection(BuildContext context) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
          child: Text(
            "Fill in your first and last name",
            style: TextStyle(fontSize: 20.0),
          )),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    if (validateInputs()) {
      this.setState(() {
        errorMessage = "";
      });

      _arcKey.currentState.toggleAnimation(true);
      Future.delayed(Duration(seconds: 3), () {
        _arcKey.currentState.toggleAnimation(false);
        navigateWithAnimationWithBackStack(AppShowCaseMap(), context);
      });
    }
  }

  bool validateInputs() {
    return validateName(_firstNameController) &&
        validateName(_lastNameController);
  }
}
