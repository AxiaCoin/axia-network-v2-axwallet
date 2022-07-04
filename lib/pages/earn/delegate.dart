import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:wallet/Crypto_Models/validator.dart';
import 'package:wallet/code/cache.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/services.dart';
import 'package:wallet/code/utils.dart';
import 'package:wallet/widgets/common.dart';
import 'package:wallet/widgets/home_widgets.dart';
import 'package:wallet/widgets/onboard_widgets.dart';
import 'package:wallet/widgets/spinner.dart';
import 'package:wallet/widgets/validator_tile.dart';

class DelegatePage extends StatefulWidget {
  const DelegatePage({Key? key}) : super(key: key);

  @override
  State<DelegatePage> createState() => _DelegatePageState();
}

class _DelegatePageState extends State<DelegatePage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  TextEditingController controller = new TextEditingController();
  List<ValidatorItem> validators = [];
  bool isLoading = false;

  getValidators() async {
    setState(() => isLoading = true);
    _refreshKey.currentState?.show();
    var response = (await services.axSDK.api!.nomination
        .getValidators())["validators"] as List;
    validators = response.map((e) => ValidatorItem.fromMap(e)).toList();
    validators
        .sort((a, b) => b.nominators.length.compareTo(a.nominators.length));
    CustomCacheManager.instance.cacheValidators(validators);
    if (mounted) setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    validators = CustomCacheManager.instance.validatorsFromCache();
    getValidators();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar() => AppBar(
          title: Text("Nominate"),
          centerTitle: true,
          leading: CommonWidgets.backButton(context),
        );

    Widget searchbar() => Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(0x4040401A),
                spreadRadius: 0,
                blurRadius: 16,
              ),
            ],
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black12,
                ),
                hintText: "Search Node",
                hintStyle: TextStyle(
                  color: Colors.black12,
                )),
          ),
        );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: appBar(),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.add),
        //   onPressed: () async {
        //   },
        // ),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: validators.isEmpty
                ? Center(
                    child: Spinner(
                      text: "Fetching Validators",
                    ),
                  )
                : RefreshIndicator(
                    key: _refreshKey,
                    onRefresh: () async => await getValidators(),
                    child: SearchableList<ValidatorItem>(
                      initialList: validators,
                      builder: (validator) {
                        return ValidatorTile(validator: validator);
                      },
                      emptyWidget:
                          OnboardWidgets.neverShare(text: "No nodes found"),
                      filter: (value) => validators
                          .where((element) => element.nodeID
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList(),
                      // onRefresh: () async => await getValidators(),
                      defaultSuffixIconColor: appColor,
                      inputDecoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          // prefixIcon: Icon(
                          //   Icons.search,
                          //   color: Colors.black12,
                          // ),
                          hintText: "Search Node",
                          hintStyle: TextStyle(
                              // color: Colors.black12,
                              )),
                    ),
                  )
            // child: Column(
            //   children: [
            //     searchbar(),
            //     validators.isEmpty
            //         ? Spinner()
            //         : Expanded(
            //             child: RefreshIndicator(
            //               onRefresh: () async {
            //                 await getValidators();
            //               },
            //               child: ListView.builder(
            //                   shrinkWrap: true,
            //                   itemCount: validators.length,
            //                   itemBuilder: ((context, index) {
            //                     var item = validators[index];
            //                     return ValidatorTile(validator: item);
            //                   })),
            //             ),
            //           ),
            //   ],
            // ),
            ),
      ),
    );
  }
}
