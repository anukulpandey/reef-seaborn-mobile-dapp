import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EventRoute extends StatefulWidget {
  // final String? eventOrganiserAddress;
  const EventRoute({Key? key}): super(key: key);

  @override
  State<EventRoute> createState() => _EventRouteState();

  
}

class _EventRouteState extends State<EventRoute> {
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final eventTitleController = TextEditingController();
  final eventDescController = TextEditingController();
  final eventIdController = TextEditingController();
  final eventOrganiserAddressController = TextEditingController();
  final eventVenueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140,
        title: Text('Launch Event',style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
        flexibleSpace: Container(
    decoration: 
      BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/reef-header.png'),
          
          fit: BoxFit.cover,
        ),
      ),
  ),
  backgroundColor: Colors.transparent,
        
      ),
      body: Center(
        child: Column(
          children:<Widget> [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10.0),
                  TextField(
                    controller: eventTitleController,
                    decoration: InputDecoration(
                      labelText: "Enter Event Name",
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: eventDescController,
                    decoration: InputDecoration(
                      labelText: "Enter Event Description",
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: eventOrganiserAddressController,
                    decoration: InputDecoration(
                      labelText: "Enter your wallet address",
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    controller: eventVenueController,
                    decoration: InputDecoration(
                      labelText: "Enter Event Venue",
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    controller: eventIdController,
                    decoration: new InputDecoration(labelText: "Event ID"),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async {
          String title=eventTitleController.text;
          String desc=eventDescController.text;
          String eventID = eventIdController.text;
          String organiserAddress = eventOrganiserAddressController.text;
          String venue = eventVenueController.text;
          await createEvent(title, desc,eventID,organiserAddress,venue);
          getEvents();
        },
        child: const Icon(Icons.file_upload_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

Future getEvents()async{
  dynamic eventsFetched = await FirebaseFirestore.instance.collection("events").get();
  for(var event in eventsFetched.docs){
    Map<String,dynamic> M = event.data();
    print(M['title']);
  }
}

Future createEvent(String title,String desc,String eventID,String address,String venue) async{
  final eventToBeUploaded = FirebaseFirestore.instance.collection("events").doc(eventID);

  final tempCheck = await eventToBeUploaded.get();
  if(tempCheck.exists){

    Fluttertoast.showToast(
        msg: "Sorry! Event with this ID exists. Kindly choose a unique ID.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Styles.errorColor,
        textColor: Colors.white,
        fontSize: 12.0
    );

  }else{
    
  final eventJson = {
    "title":title,
    "desc":desc,
    "venue":venue,
    "address":address,
    "participants":[],
    "votedby":[]
  };

  await eventToBeUploaded.set(eventJson);
  
  print("event added");
  }


}