import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/home/RegisterParticipant.dart';
import 'package:reef_mobile_app/components/home/VoteEvent.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/pages/send_page.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';

class TokenView extends StatefulWidget {
  const TokenView({Key? key}) : super(key: key);

  @override
  State<TokenView> createState() => _TokenViewState();
}

class _TokenViewState extends State<TokenView> {
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
  final eventIDcontroller = TextEditingController();

  
Future searchEvent(String eventID) async{
  final eventToBeUploaded = FirebaseFirestore.instance.collection("events").doc(eventID);

  final tempCheck = await eventToBeUploaded.get();
  if(!tempCheck.exists){

    Fluttertoast.showToast(
        msg: "Sorry! Event with this ID doesn't exist. Kindly check the ID again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Styles.errorColor,
        textColor: Colors.white,
        fontSize: 12.0
    );

  }else{
  // print(tempCheck.data());
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RegisterParticipant(eventID: eventID)),
  );
  }
}
Future voteEvent(String eventID) async{
  final eventToBeUploaded = FirebaseFirestore.instance.collection("events").doc(eventID);

  final tempCheck = await eventToBeUploaded.get();
  if(!tempCheck.exists){

    Fluttertoast.showToast(
        msg: "Sorry! Event with this ID doesn't exist. Kindly check the ID again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Styles.errorColor,
        textColor: Colors.white,
        fontSize: 12.0
    );

  }else{
  // print(tempCheck.data());
  List<dynamic> votedByPeople = tempCheck.data()!['votedby'];
  bool flag = false;
  for(int i=0;i<votedByPeople.length;i++){
    if(votedByPeople[i]==ReefAppState.instance.model.accounts.selectedAddress){
      flag = true;
    }
  }

  if(flag){
    Fluttertoast.showToast(
        msg: "You have already voted Bro.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Styles.errorColor,
        textColor: Colors.white,
        fontSize: 12.0
    );
  }else{
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => VoteEvent(eventID: eventID)),
  );
  }
  }
}

  Widget tokenCard(String name,
      {String? iconURL,
      double balance = 0.0,
      double price = 0.0,
      String tokenName = ""}) {
    return ViewBoxContainer(
        child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            child: Column(
              children: [
                TextField(
                  controller: eventIDcontroller,
                  decoration: new InputDecoration(labelText: "Enter Event #id"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                        height: 48,
                        width: 48,
                        child: iconURL != null
                            ? CachedNetworkImage(
                                imageUrl: iconURL,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[350]!,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: ShapeDecoration(
                                      color: Colors.grey[350]!,
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  CupertinoIcons.exclamationmark_circle_fill,
                                  color: Colors.black12,
                                  size: 48,
                                ),
                              )
                            : const SizedBox.shrink()),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 100),
                          child: Text(name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Styles.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                        Text(
                          // TODO allow conversionRate to be null for no data
                          "\$${price != 0 ? price.toStringAsFixed(4) : 'No pool data'}",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Styles.textColor,
                              fontSize: 14),
                        )
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientText(
                            "US\$${getBalanceValue(balance, price).toStringAsFixed(2)}",
                            gradient: textGradient(),
                            style: GoogleFonts.poppins(
                              color: Styles.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            )),
                        Text(
                          // TODO allow conversionRate to be null for no data
                          price != 0
                              ? "${balance != 0 ? balance.toStringAsFixed(4) : 0} ${tokenName != "" ? tokenName : name.toUpperCase()}"
                              : 'No pool data',
                          style: GoogleFonts.poppins(
                            color: Styles.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xff742cb2),
                                spreadRadius: -10,
                                offset: Offset(0, 5),
                                blurRadius: 20),
                          ],
                          borderRadius: BorderRadius.circular(80),
                          gradient: const LinearGradient(
                            colors: [Color(0xffae27a5), Color(0xff742cb2)],
                            begin: Alignment(-1, -1),
                            end: Alignment(1, 1),
                          )),
                      child: ElevatedButton.icon(
                          icon: const Icon(
                            CupertinoIcons.chevron_up_circle_fill,
                            color: Colors.white,
                            size: 16.0,
                          ),
                          style: ElevatedButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.transparent,
                              shape: StadiumBorder(),
                              elevation: 0),
                          label: const Text(
                            'Vote',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () async {
                            
                            voteEvent(eventIDcontroller.text);
                                            
                          }),
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xff742cb2),
                                spreadRadius: -10,
                                offset: Offset(0, 5),
                                blurRadius: 20),
                          ],
                          borderRadius: BorderRadius.circular(80),
                          gradient: const LinearGradient(
                            colors: [Color(0xffae27a5), Color(0xff742cb2)],
                            begin: Alignment(-1, -1),
                            end: Alignment(1, 1),
                          )),
                      child: ElevatedButton.icon(
                          icon: const Icon(
                            CupertinoIcons.arrow_down_right_circle_fill,
                            color: Colors.white,
                            size: 16.0,
                          ),
                          style: ElevatedButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.transparent,
                              shape: StadiumBorder(),
                              elevation: 0),
                          label: const Text(
                            'Register',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () async {
                            
                            searchEvent(eventIDcontroller.text);
                                            
                          }),
                    )),
                  ],
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: [
          SizedBox(
            width: double.infinity,
   
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
              child: Observer(builder: (_) {
                return Wrap(
                  spacing: 24,
                  children: ReefAppState
                      .instance.model.tokens.selectedSignerTokens
                      .map((TokenWithAmount tkn) {
                    return Column(
                      children: [
                        tokenCard(tkn.name,
                            tokenName: tkn.symbol,
                            iconURL: tkn.iconUrl,
                            price: tkn.price?.toDouble() ?? 0,
                            balance: decimalsToDouble(tkn.balance)),
                        SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),
          )
        ]);
  }
}

