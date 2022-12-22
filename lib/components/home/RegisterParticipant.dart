import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
// import 'dart:core';

class RegisterParticipant extends StatefulWidget {
  final String eventID;
  const RegisterParticipant({super.key, required this.eventID});

  @override
  State<RegisterParticipant> createState() => _RegisterParticipantState();
}

String eventTitle = "";
String eventDesc = "";
String eventVenue = "";
int participantNum = 0;

class _RegisterParticipantState extends State<RegisterParticipant> {
  Future getEventDetails(String eventID) async {
    final fbase = FirebaseFirestore.instance.collection("events").doc(eventID);
    final eventData = await fbase.get();
    Map<dynamic, dynamic>? umAp = eventData.data();
    List<dynamic> participantsData = umAp!['participants'];
    participantNum = participantsData.length;
    setState(() {
      eventTitle = umAp!['title'];
      eventDesc = umAp['desc'];
      eventVenue = umAp['venue'];
      participantNum = participantNum;
    });
  }

  @override
  void initState() {
    super.initState();
    getEventDetails(widget.eventID);
  }

  @override
  Widget build(BuildContext context) {
    void _onConfirmSend(
        TokenWithAmount sendToken, String sendAddress, String amount) async {
      var signerAddress = await ReefAppState.instance.storage
          .getValue(StorageKey.selected_address.name);
      TokenWithAmount tokenToTranfer = TokenWithAmount(
          name: sendToken.name,
          address: sendToken.address,
          iconUrl: sendToken.iconUrl,
          symbol: sendToken.name,
          balance: sendToken.balance,
          decimals: sendToken.decimals,
          amount:
              BigInt.parse(toStringWithoutDecimals(amount, sendToken.decimals)),
          price: 0);
      var res = await ReefAppState.instance.transferCtrl
          .transferTokens(signerAddress, sendAddress, tokenToTranfer);
      print(res);
      Navigator.pop(context);
    }

    final participantNameController = TextEditingController();
    final walletAddressController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Yourself"),
      ),
      body: Container(
        child: Column(children: [
          Text("Event Name"),
          SizedBox(
            height: 10.0,
          ),
          Text(eventTitle),
          SizedBox(
            height: 10.0,
          ),
          Text("Event Description"),
          SizedBox(
            height: 10.0,
          ),
          Text(eventDesc),
          SizedBox(
            height: 10.0,
          ),
          Text("Event Venue"),
          SizedBox(
            height: 10.0,
          ),
          Text(eventVenue),
          SizedBox(
            height: 10.0,
          ),
          Text("Participants Registered"),
          SizedBox(
            height: 10.0,
          ),
          Text(participantNum.toString()),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            controller: participantNameController,
            decoration: InputDecoration(
              labelText: "Enter Participant Name",
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            controller: walletAddressController,
            decoration:
                InputDecoration(label: Text("Enter your wallet address")),
          ),
          SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
              onPressed: () async {
                final walletAddress = walletAddressController.text;
                final participantName = participantNameController.text;

                final firebaseVal = FirebaseFirestore.instance
                    .collection("events")
                    .doc(widget.eventID);
                final res = await firebaseVal.get();
                List<dynamic> participants = res.data()!['participants'];
                bool addParticipant = true;
                for (var p in participants) {
                  print(p['walletaddress']);
                  if (p['walletaddress'] == walletAddress) {
                    addParticipant = false;
                    break;
                  }
                }

                if (addParticipant) {
                  participants.add({
                    'name': participantName,
                    'walletaddress': walletAddress,
                    'votes': 0
                  });
                  FirebaseFirestore.instance
                      .collection("events")
                      .doc(widget.eventID)
                      .update({'participants': participants});
                  addParticipant = true;
                  Fluttertoast.showToast(
                      msg: "Successfully registered for the event!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Styles.greenColor,
                      textColor: Colors.white,
                      fontSize: 12.0);

                  String sendAddress = res.data()!['address'];
                  var tokens =
                      ReefAppState.instance.model.tokens.selectedSignerTokens;
                  bool SuccessfullyRegistered = false;
                  try {
                    _onConfirmSend(tokens[0], sendAddress, "5");
                    SuccessfullyRegistered = true;
                  } catch (e) {
                    print("fuck errors");
                    print(e);
                  }
                  // if (SuccessfullyRegistered) {
                  //   Navigator.pop(context);
                  // }
                } else {
                  Fluttertoast.showToast(
                      msg: "Sorry! You have already registered",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Styles.errorColor,
                      textColor: Colors.white,
                      fontSize: 12.0);
                  Navigator.pop(context);
                }
              },
              child: Text("Register"))
        ]),
      ),
    );
  }
}
