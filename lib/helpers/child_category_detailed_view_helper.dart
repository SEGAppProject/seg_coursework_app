import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:seg_coursework_app/models/category_item.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:seg_coursework_app/models/image_details.dart';
import 'package:seg_coursework_app/widgets/categoryItem/image_square.dart';
import 'package:seg_coursework_app/widgets/child_view/item_unavailable.dart';

// Returns the grid of images, clickable and unavailable
Expanded getMainImages(List<CategoryItem> images) {
  return Expanded(
    child: GridView.builder(
        key: const Key("mainGridOfPictures"),
        padding: const EdgeInsets.all(8.0),
        //physics: const NeverScrollableScrollPhysics(),
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, childAspectRatio: 4 / 3),
        itemBuilder: (context, index) {
          return getImage(index, images);
        }),
  );
}

//Method for the Text-To-Speech package Flutter TTS to speak a given text
Future speak(String text) async {
  final FlutterTts flutterTts = FlutterTts();
  await flutterTts.setSharedInstance(true);

  await flutterTts.setLanguage("en-US");

  await flutterTts.setSpeechRate(0.5);

  await flutterTts.setVolume(1.0);

  await flutterTts.setPitch(0.7);

  await flutterTts.isLanguageAvailable("en-US");

  await flutterTts.speak(text);
}

// Returns one image that on click blurs the background and is available
Padding getImage(int index, List<CategoryItem> images) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    // Focused menu holder gives the blured background on click
    child: images[index].availability
        ? getAvailableItem(images, index)
        : getUnavailableItem(images, index),
  );
}

// Prepare the menu holder for available item to blur the background on click
FocusedMenuHolder getAvailableItem(List<CategoryItem> images, int index) {
  return FocusedMenuHolder(
      openWithTap: true,
      onPressed: () {
        speak(images[index].name);
      },
      menuItems: const [],
      blurSize: 5.0,
      menuItemExtent: 45,
      blurBackgroundColor: Colors.black54,
      duration: const Duration(milliseconds: 100),
      // gets image ImageSquare and adds a focused menu holder for effects
      child: ImageSquare(
          image: ImageDetails(
              name: images[index].name, imageUrl: images[index].imageUrl)));
}

// Get image as an ImageSquare without any click effects,
// if not available image is blurred and has unavailable icon
FocusedMenuHolder getUnavailableItem(List<CategoryItem> images, int index) {
  return FocusedMenuHolder(
    onPressed: () {
      final player = AudioPlayer();
      player.play(AssetSource('unavailable.mp3'));
    },
    menuItems: const [],
    child: Stack(
      children: [
        ImageSquare(
            height: 200,
            width: 250,
            image: ImageDetails(
                name: images[index].name, imageUrl: images[index].imageUrl)),
        Container(
          // if item is unavailable blur image and display icon, method imported from item_unavailable widget
          child: images[index].availability ? null : makeUnavailable(),
        ),
      ],
    ),
  );
}
