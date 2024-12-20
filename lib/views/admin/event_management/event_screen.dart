import 'package:flutter/material.dart';
import 'dart:io'; // Menambahkan import untuk File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/event_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/views/admin/event_management/create_event_screen.dart';
import 'package:guideme/views/admin/event_management/modify_event_screen.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:intl/intl.dart'; // Import DateFormat

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  String page = 'event';

  @override
  void initState() {
    super.initState();

    // Memulai pengecekan status event secara periodik
    EventController().scheduleEventStatusCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Management"),
      ),
      body: EventScreenContent(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: AddButton(page),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 2),
    );
  }
}

class EventScreenContent extends StatelessWidget {
  final EventController _eventController = EventController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomTitle(firstText: 'Hi, Admin!', secondText: 'Design your data exactly how you want it'),
            ],
          ),
          SizedBox(height: 16),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('events').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  color: AppColors.backgroundColor,
                  elevation: 4.0, // Menambahkan shadow pada card
                  shape: RoundedRectangleBorder(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.accentColor), // Warna latar belakang header
                      headingTextStyle: AppTextStyles.mediumStyle.copyWith(
                        color: Colors.white, // Warna teks header
                        fontWeight: FontWeight.bold, // Menebalkan teks header
                      ),
                      columns: [
                        DataColumn(label: Text('Event Name')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Image URL')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Rating')),
                        DataColumn(label: Text('Organizer')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Latitude')),
                        DataColumn(label: Text('Longitude')),
                        DataColumn(label: Text('Opening Time')),
                        DataColumn(label: Text('Closing Time')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        EventModel eventModel = EventModel.fromMap(data, doc.id);

                        // Format openingTime dan closingTime
                        String openingTimeFormatted = DateFormat('yyyy-MM-dd HH:mm').format(eventModel.openingTime.toDate());
                        String closingTimeFormatted = DateFormat('yyyy-MM-dd HH:mm').format(eventModel.closingTime.toDate());

                        return DataRow(
                          cells: [
                            DataCell(Text(eventModel.name)),
                            DataCell(Text(eventModel.location)),
                            DataCell(Text(eventModel.category)),
                            DataCell(Text(eventModel.imageUrl)),
                            DataCell(Text('\$${eventModel.price}')),
                            DataCell(Text('${eventModel.rating}')),
                            DataCell(Text(eventModel.organizer)),
                            DataCell(Text(eventModel.description)),
                            DataCell(Text('${eventModel.latitude}')),
                            DataCell(Text('${eventModel.longitude}')),
                            DataCell(Text(openingTimeFormatted)),
                            DataCell(Text(closingTimeFormatted)),
                            DataCell(
                              Row(
                                children: [
                                  EditButton(
                                    data: eventModel,
                                    page: 'event',
                                  ),
                                  SizedBox(width: 8.0),
                                  DeleteButton(
                                    itemId: eventModel.eventId,
                                    itemType: 'event',
                                    controller: _eventController,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}




// class EventScreenContent extends StatelessWidget {
//   final EventController _eventController = EventController();
//   final Map<String, bool> showButtons = {};

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance.collection('events').snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var doc = snapshot.data!.docs[index];
//             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//             EventModel event = EventModel.fromMap(data, doc.id);

//             // Inisialisasi status tombol untuk setiap event
//             showButtons.putIfAbsent(event.eventId, () => false);

//             return Padding(
//               padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
//               child: Card(
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: ExpansionTile(
//                   title: Text(event.name),
//                   subtitle: Text('Location: ${event.location}'),
//                   leading: event.imageUrl.startsWith('/')
//                       ? Image.file(
//                           File(event.imageUrl),
//                           fit: BoxFit.cover,
//                           width: 60,
//                           height: 60,
//                         )
//                       : Image.network(
//                           event.imageUrl,
//                           fit: BoxFit.cover,
//                           width: 60,
//                           height: 60,
//                         ),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Latitude: ${event.latitude}'),
//                           Text('Longitude: ${event.longitude}'),
//                           Text('Organizer: ${event.organizer}'),
//                           Text('Category: ${event.category}'),
//                           Text('Description: ${event.description}'),
//                           Text('Information: ${event.information}'),
//                           Text('Rating: ${event.rating}'),
//                           Text('Price: ${event.price}'),
//                           Text('Opening Time: ${event.openingTime}'),
//                           Text('Closing Time: ${event.closingTime}'),
//                           Text('Created At: ${event.createdAt.toDate()}'),
//                           SizedBox(height: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               FloatingActionButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           ModifyEventScreen(event: event),
//                                     ),
//                                   );
//                                 },
//                                 mini: true,
//                                 backgroundColor: Colors.yellow,
//                                 child: Icon(Icons.edit, color: Colors.white),
//                               ),
//                               SizedBox(width: 8),
//                               FloatingActionButton(
//                                 onPressed: () async {
//                                   bool? confirmDelete = await showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         title: Text('Delete Event'),
//                                         content: Text(
//                                             'Are you sure you want to delete this event?'),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.of(context).pop(false),
//                                             child: Text('Cancel'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.of(context).pop(true),
//                                             child: Text('Delete'),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );

//                                   if (confirmDelete == true) {
//                                     await _eventController.deleteEvent(event.eventId);
//                                   }
//                                 },
//                                 mini: true,
//                                 backgroundColor: Colors.red,
//                                 child: Icon(Icons.delete, color: Colors.white),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
