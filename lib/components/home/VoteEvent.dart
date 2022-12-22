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

class VoteEvent extends StatefulWidget {
  final String eventID;
  const VoteEvent({super.key, required this.eventID});

  @override
  State<VoteEvent> createState() => _VoteEventState();
}

String eventTitle = "";
String eventDesc = "";
String eventVenue = "";
int participantNum = 0;
List<dynamic> participantsData = [];

class _VoteEventState extends State<VoteEvent> {
  Future getEventDetails(String eventID) async {
    final fbase = FirebaseFirestore.instance.collection("events").doc(eventID);
    final eventData = await fbase.get();
    Map<dynamic, dynamic>? umAp = eventData.data();
    participantsData = umAp!['participants'];
    participantNum = participantsData.length;
    setState(() {
      eventTitle = umAp!['title'];
      eventDesc = umAp['desc'];
      eventVenue = umAp['venue'];
      participantNum = participantNum;
      participantsData = umAp['participants'];
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
    }

    final participantNameController = TextEditingController();
    final walletAddressController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Vote Now"),
      ),
      body: Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i=0;i<participantsData.length;i++)
                  ElevatedButton.icon(
                    
                      onPressed: () async {
onPress(i);
                        final fbIns = FirebaseFirestore.instance.collection("events").doc(widget.eventID);
                        final resulterMan = await fbIns.get();

                      List<dynamic> px = resulterMan.data()!['participants'];

                        for(var p in px){
                          if(p['walletaddress']==participantsData[i]['walletaddress']){
                            p['votes']=p['votes']+1;
                          }
                        }

                        List<dynamic> votedBy = resulterMan.data()!['votedby'];
                        votedBy.add(ReefAppState.instance.model.accounts.selectedAddress);

                        fbIns.update({
                          'participants':px,
                          'votedby':votedBy
                        });

                      var tokens =
                      ReefAppState.instance.model.tokens.selectedSignerTokens;
                  
                  try {
                    _onConfirmSend(tokens[0],resulterMan.data()!['address'] , "5");
                   
                  } catch (e) {
                    print("fuck errors");
                    print(e);
                  }

                      },
                      icon: const Icon(
                        CupertinoIcons.add_circled_solid,
                        color: Colors.white,
                        size: 16.0,
                      ),
                      label: Text(participantsData[i]!['name']+" "+participantsData[i]!['votes'].toString()))
              ],
            ),
            
          ]),
        ),
      ),
    );
  }
}

void onPress(int id) {
  print('pressed $id');
}