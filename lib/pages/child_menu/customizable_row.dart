import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seg_coursework_app/models/categories.dart';
import 'package:seg_coursework_app/models/category.dart';
import 'package:seg_coursework_app/models/category_item.dart';
import 'package:seg_coursework_app/models/clickable_image.dart';
import 'package:seg_coursework_app/models/image_details.dart';
import 'package:seg_coursework_app/pages/child_board/child_board.dart';
import 'package:seg_coursework_app/widgets/categoryItem/image_square.dart';
import '../../themes/themes.dart';
import '../../widgets/category/category_image_row.dart';
import '../../widgets/category/category_title.dart';

class ChildMenuCategoryRow extends StatefulWidget {
  final List<CategoryItem> categoryItems;
  final Category category;
  late FirebaseAuth? auth;
  late FirebaseFirestore? firebaseFirestore;
  late final FirebaseStorage? storage;
  late final Categories? testCategories;

  ChildMenuCategoryRow(
      {Key? key,
      required this.categoryItems,
      required this.category,
      this.auth,
      this.firebaseFirestore,
      this.storage,
      this.testCategories})
      : super(key: key);

  @override
  State<ChildMenuCategoryRow> createState() => _ChildMenuCategoryRowState();
}

class _ChildMenuCategoryRowState extends State<ChildMenuCategoryRow> {
  // Everything is wrapped in Material() and InkWell() so the onTap gesture shows

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<CustomTheme>(context);
    return Material(
      color: themeNotifier.getTheme().scaffoldBackgroundColor,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 1),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Column of category image and text below it
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 15),
                    child: ImageSquare(
                        width: 250,
                        height: 250,
                        image: ImageDetails(
                            name: widget.category.title,
                            imageUrl: widget.category.imageUrl)),
                  ),
                  CategoryTitle(title: widget.category.title),
                ],
              ),
              // Row of images within category that wraps should list become too long
              CategoryItemsPreview(imagePreviews: widget.categoryItems),
            ],
          ),
        ),
        onTap: () {
          final player = AudioPlayer();
          player.play(AssetSource('category_click.mp3'));
          print("image previews in row class = ${widget.categoryItems}");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChildBoards(
                      categoryTitle: widget.category.title,
                      categoryImage: widget.category.imageUrl,
                      images: widget.categoryItems,
                      firebaseFirestore: widget.firebaseFirestore,
                      storage: widget.storage,
                      auth: widget.auth,
                      testCategories: widget.testCategories)));
        },
      ),
    );
  }
}
