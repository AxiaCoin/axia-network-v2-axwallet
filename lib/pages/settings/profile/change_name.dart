import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/database.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/spinner.dart';

class ChangeUserProfile extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  const ChangeUserProfile({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  State<ChangeUserProfile> createState() => _ChangeUserProfileState();
}

class _ChangeUserProfileState extends State<ChangeUserProfile> {
  final formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool submitting = false;

  _changeName() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        submitting = true;
      });
      var response = await APIServices().userNameUpdate(
        firstName: firstNameController.text,
        lastName:
            lastNameController.text == "" ? null : lastNameController.text,
      );
      setState(() {
        submitting = false;
      });
      if (response["success"]) {
        User user = Get.find();
        var userModel = user.userModel.value
          ..firstName = firstNameController.text
          ..lastName =
              lastNameController.text == "" ? null : lastNameController.text;
        user.updateUser(userModel);
        Services().loadUser(loadController: false);

        await Get.dialog(
          AlertDialog(
            title: Text("Success"),
            content: Text("Name Successfully Changed!"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text("Okay"),
              ),
            ],
          ),
        );
        Get.back(result: true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.firstName ?? "";
    lastNameController.text = widget.lastName ?? "";
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> nameFields = [
      Align(alignment: Alignment.centerLeft, child: Text("First Name")),
      SizedBox(
        height: 8,
      ),
      TextFormField(
        controller: firstNameController,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: "First Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
        validator: (val) =>
            val!.isNotEmpty ? null : "Please provide at least the first name",
        maxLength: 20,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
        ],
      ),
      SizedBox(
        height: 16,
      ),
      Align(alignment: Alignment.centerLeft, child: Text("Last Name")),
      SizedBox(
        height: 8,
      ),
      TextFormField(
        controller: lastNameController,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: "Last Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
        maxLength: 20,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
        ],
      ),
      SizedBox(
        height: 16,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Change Name"),
        centerTitle: true,
        leading: CommonWidgets.backButton(context),
      ),
      body: Form(
        key: formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  // Text(
                  //   "Change name",
                  //   style: context.textTheme.headline4,
                  // ),
                  // SizedBox(
                  //   height: 32,
                  // ),
                  ...nameFields,
                  SizedBox(
                    height: 16,
                  ),
                  submitting
                      ? Center(
                          child: Spinner(),
                        )
                      : SizedBox(
                          width: Get.width,
                          child: TextButton(
                            onPressed: () {
                              _changeName();
                            },
                            child: Text("Save Changes"),
                            style: MyButtonStyles.onboardStyle,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
