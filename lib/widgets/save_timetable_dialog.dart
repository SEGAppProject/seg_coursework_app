import 'package:flutter/material.dart';
import 'package:seg_coursework_app/helpers/snackbar_manager.dart';
import 'package:seg_coursework_app/models/image_details.dart';

import '../models/timetable.dart';
import '../services/check_connection.dart';
import 'loading_indicator.dart';


class SaveTimetableDialog extends StatefulWidget {
  SaveTimetableDialog({super.key, required this.imagesList, required this.saveTimetable});
  
  List<ImageDetails> imagesList;
  Function saveTimetable;

  @override
  State<SaveTimetableDialog> createState() => _SaveTimetableDialogState();
}

class _SaveTimetableDialogState extends State<SaveTimetableDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    CheckConnection.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _textEditingController.clear();
        return true;
      },
      child: AlertDialog(
        title: Text('Enter a title for the Timetable to save it'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            maxLength: 30,
            controller: _textEditingController,
            decoration: InputDecoration(hintText: 'Timetable title'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a title';
              }
              RegExp alphanumeric = RegExp(r'^[\w\s]+$');
              if (!alphanumeric.hasMatch(value)) {
                return 'Title should only contain letters, numbers, and spaces';
              }
              return null;
            },
            onChanged: (value) {
              _formKey.currentState!.validate();
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              _textEditingController.clear();
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('Submit'),
            onPressed: () async {
              if(!_formKey.currentState!.validate()) {
                SnackBarManager.showSnackBarMessage(context, "Title is not valid!");
                return;
              }
              if(!CheckConnection.isDeviceConnected)
              {
                SnackBarManager.showSnackBarMessage(context, "Cannot save timetable. No connection.");
                return;
              }
                
              String title = _textEditingController.text;
              _textEditingController.clear();
              LoadingIndicatorDialog().show(context, text: "Saving timetable...");
              await widget.saveTimetable(timetable: Timetable(title: title, listOfImages: widget.imagesList));
              LoadingIndicatorDialog().dismiss();
              SnackBarManager.showSnackBarMessage(context, "Timetable saved successfully");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}