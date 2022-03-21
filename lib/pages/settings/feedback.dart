import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/widgets/common.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isValid = controller.text.length >= 10;

    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Got some feedback for us? Let us know with the form below",
              style: context.textTheme.bodyText2,
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                // labelText: "Phrase",
                hintText: "Write at least 10 characters",
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() {}),
              minLines: 4,
              maxLines: 8,
            ),
            Spacer(),
            SizedBox(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () {
                  if (isValid) {
                    Get.back();
                    CommonWidgets.snackBar("Feedback Submitted",
                        copyMode: false);
                  }
                },
                child: Text("SUBMIT"),
                style: MyButtonStyles.statefulStyle(isValid),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
