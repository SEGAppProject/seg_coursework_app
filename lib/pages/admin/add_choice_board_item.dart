import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seg_coursework_app/helpers/firestore_functions.dart';
import 'package:seg_coursework_app/helpers/image_picker_functions.dart';
import 'package:seg_coursework_app/pages/admin/admin_choice_boards.dart';
import 'package:seg_coursework_app/widgets/pick_image_button.dart';

class AddChoiceBoardItem extends StatefulWidget {
  final String categoryId;
  const AddChoiceBoardItem({Key? key, required this.categoryId})
      : super(key: key);

  @override
  State<AddChoiceBoardItem> createState() => _AddChoiceBoardItem();
}

/// A Popup card to add a new item to a category.
class _AddChoiceBoardItem extends State<AddChoiceBoardItem> {
  File? selectedImage; // hold the currently selected image by the user
  // controller to retrieve the user input for item name
  final itemNameController = TextEditingController();
  final firestoreFunctions = FirestoreFunctions();
  final imagePickerFunctions = ImagePickerFunctions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: "add-item-hero",
          child: Material(
            color: Theme.of(context).canvasColor,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // page (Hero) contents
                  children: [
                    // shows the currently selected image
                    Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.all(10),
                        child: selectedImage != null
                            ? Image.file(
                                selectedImage!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.image_search_outlined,
                                size: 160,
                              )),
                    // instructions text
                    Text(
                      "Pick an image",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // buttons to take/upload images
                    PickImageButton(
                        label: Text("Choose from Gallery"),
                        icon: Icon(Icons.image),
                        onPressed: () async {
                          File? newImage = await imagePickerFunctions.pickImage(
                              source: ImageSource.gallery, context: context);
                          if (newImage != null) {
                            setState(() => selectedImage = newImage);
                          }
                        }),
                    PickImageButton(
                        label: Text("Take a Picture"),
                        icon: Icon(Icons.camera_alt),
                        onPressed: () async {
                          File? newImage = await imagePickerFunctions.pickImage(
                              source: ImageSource.camera, context: context);
                          if (newImage != null) {
                            setState(() => selectedImage = newImage);
                          }
                        }),
                    const SizedBox(height: 20),
                    // field to enter the item name
                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(
                          hintText: "Item's name",
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontWeight: FontWeight.bold)),
                      cursorColor: Colors.white,
                    ),
                    const Divider(
                      color: Colors.black38,
                      thickness: 0.2,
                    ),
                    const SizedBox(height: 20),
                    // submit to database button
                    TextButton.icon(
                        key: const Key("createItemButton"),
                        onPressed: () => handleSavingItemToFirestore(
                            image: selectedImage,
                            itemName: itemNameController.text),
                        icon: Icon(Icons.add),
                        label: const Text("Create new item"),
                        style: const ButtonStyle(
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.white),
                            backgroundColor: MaterialStatePropertyAll(
                                Color.fromARGB(255, 105, 187, 123))))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Given an item's image and name,
  /// - upload the image to the cloud storage
  /// - create a new item with the uploaded image's Url in Firestore
  /// - create a new categoryItem entry in the selected category
  /// - Take the user back to the Choice Boards page
  void handleSavingItemToFirestore(
      {required File? image, required String? itemName}) async {
    if (itemName!.isEmpty || image == null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("A field or more are missing!"),
            );
          });
    } else {
      String? imageUrl = await firestoreFunctions.uploadImageToCloud(
          image: image, itemName: itemName);
      if (imageUrl != null) {
        try {
          String itemId = await firestoreFunctions.createItem(
              name: itemName, imageUrl: imageUrl);
          await firestoreFunctions.createCategoryItem(
              name: itemName,
              imageUrl: imageUrl,
              categoryId: widget.categoryId,
              itemId: itemId);
          // go back to choice boards page
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const AdminChoiceBoards(),
          ));
          // update message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$itemName added successfully.")),
          );
        } catch (e) {
          print(e);
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    content: Text(
                        'An error occurred while communicating with the database'));
              });
        }
      }
    }
  }
}
