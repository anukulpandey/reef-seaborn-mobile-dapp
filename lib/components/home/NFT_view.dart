import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/home/EventRoute.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../../model/ReefAppState.dart';

class NFTView extends StatefulWidget {
  const NFTView({Key? key}) : super(key: key);

  @override
  State<NFTView> createState() => _NFTViewState();
}

class _NFTViewState extends State<NFTView> {
  Widget nftCard(String name, String iconURL, int balance) {
    return ViewBoxContainer(
        imageUrl: iconURL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(children: [
                      const Gap(12),
                      Text(
                        // TODO allow conversionRate to be null for no data
                        "${balance}x",
                        style: TextStyle(
                            color: Styles.textLightColor,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Gap(8),
                      Text(
                        name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Gap(12),
                    ]))
              ],
            ),
            const Gap(12)
          ],
        )
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: [
          SizedBox(
            width: double.infinity,
            child:
                ReefAppState.instance.model.tokens.selectedSignerNFTs.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 32, horizontal: 48.0),
                        child: Observer(builder: (_) {
                          return Wrap(
                            runSpacing: 24,
                            children: ReefAppState
                                .instance.model.tokens.selectedSignerNFTs
                                .map((TokenNFT tkn) {
                              return Column(
                                children: [
                                  nftCard(tkn.name, tkn.iconUrl ?? '',
                                      tkn.balance.toInt() ?? 0),
                                ],
                              );
                            }).toList(),
                          );
                        }))
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: ViewBoxContainer(
                            child: Center(
                                child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            "No live events found. Launch an event. ",
                            style: TextStyle(
                              
                                color: Styles.textLightColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ))),
                      ),
          )
        ,
          Container(
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
                            CupertinoIcons.chevron_left_slash_chevron_right,
                            color: Colors.white,
                            size: 16.0,
                          ),
                          style: ElevatedButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.transparent,
                              shape: StadiumBorder(),
                              elevation: 0),
                          label: const Text(
                            'Create Event',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () async {
                          
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EventRoute()));
                          }),
                    ),
        ]);
  }
}
