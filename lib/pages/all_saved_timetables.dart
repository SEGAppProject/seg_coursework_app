import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:seg_coursework_app/models/list_of_lists_of_image_details.dart';
import 'package:seg_coursework_app/widgets/image_square.dart';

class AllSavedTimetables extends StatelessWidget {
  const AllSavedTimetables({super.key, required this.listOfTimetables});
  final ListOfListsOfImageDetails listOfTimetables;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Saved Timetables'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: listOfTimetables.length(),
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: listOfTimetables[index].length,
              itemBuilder: (context, subIndex) {
                return ImageSquare(
                  image: listOfTimetables[index][subIndex],
                );
              },
            ),
          );
        },
      ),
    );
  }
}