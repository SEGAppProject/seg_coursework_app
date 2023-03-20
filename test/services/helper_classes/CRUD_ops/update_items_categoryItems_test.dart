import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seg_coursework_app/services/firebase_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:seg_coursework_app/helpers/mock_firebase_authentication.dart';

Future<void> main() async {
  late FirebaseFunctions firebaseFunctions;
  late FirebaseAuth mockAuth;
  late FirebaseFirestore mockFirestore;
  late FirebaseStorage mockStorage;
  late MockUser mockUser;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockAuth = MockFirebaseAuthentication();
    mockFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockUser = MockUser(uid: "user1");
    firebaseFunctions = FirebaseFunctions(
        auth: mockAuth, firestore: mockFirestore, storage: mockStorage);

    when(mockAuth.currentUser).thenReturn(mockUser);
  });
  tearDown(() async {
    mockFirestore = FakeFirebaseFirestore();
  });

  Future<DocumentSnapshot> _createCategory(
      {required String id, int rank = 0, required bool is_available}) async {
    mockFirestore.collection('categories').doc(id).set({
      'title': "Drinks",
      'illustration': "drink.jpeg",
      'userId': mockUser.uid,
      'rank': rank,
      'is_available': is_available
    });
    return mockFirestore.collection('categories').doc(id).get();
  }

  test("update item name edits the item's name successfully", () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);
    DocumentSnapshot item =
        await mockFirestore.collection('items').doc(newItemId).get();

    expect(item.get('name'), name);
    await firebaseFunctions.updateItemName(
        itemId: newItemId, newName: "Nova Water");

    item = await mockFirestore.collection('items').doc(newItemId).get();
    expect(item.get('name'), "Nova Water");
  });

  test("updating the name of an item that doesn't exist throws an exception",
      () async {
    expect(
        firebaseFunctions.updateItemName(
            itemId: "doesn't exist", newName: "Nove Water"),
        throwsA(isInstanceOf<FirebaseException>()));
  });

  test("update categoryItem name edits the name successfully (1 categoryItem)",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId = "00xx";
    await _createCategory(id: categoryId, is_available: true);

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId);

    DocumentSnapshot newCategoryItem = await mockFirestore
        .collection('categoryItems/$categoryId/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem.get('name'), name);
    await firebaseFunctions.updateCategoryItemsName(
        itemId: newItemId, newName: "Nova Water");

    newCategoryItem = await mockFirestore
        .collection('categoryItems/$categoryId/items')
        .doc(newItemId)
        .get();
    expect(newCategoryItem.get('name'), "Nova Water");
  });

  test(
      "update categoryItem name edits the name successfully (2 categoryItems in 2 categories)",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId1 = "00xx";
    const String categoryId2 = "11yy";
    await _createCategory(id: categoryId1, is_available: true);
    await _createCategory(id: categoryId2, is_available: true);

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId1,
        itemId: newItemId);
    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId2,
        itemId: newItemId);

    DocumentSnapshot newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();
    DocumentSnapshot newCategoryItem2 = await mockFirestore
        .collection('categoryItems/$categoryId2/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('name'), name);
    expect(newCategoryItem2.get('name'), name);
    await firebaseFunctions.updateCategoryItemsName(
        itemId: newItemId, newName: "Nova Water");

    newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();
    newCategoryItem2 = await mockFirestore
        .collection('categoryItems/$categoryId2/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('name'), "Nova Water");
    expect(newCategoryItem2.get('name'), "Nova Water");
  });

  test(
      "updating the name of a categoryItem without having categories throws an exception",
      () async {
    expect(
        firebaseFunctions.updateCategoryItemsName(
            itemId: "doesn't exist", newName: "Nova Water"),
        throwsA(isInstanceOf<FirebaseException>()));
  });

  test(
      "updating the name of a categoryItem that doesn't exist (when categories exist) does nothing",
      () async {
    await _createCategory(id: "00xx", is_available: true);
    expect(
        await firebaseFunctions.updateCategoryItemsName(
            itemId: "doesn't exist", newName: "Nova Water"),
        null);
  });

  test(
      "updating the name of a categoryItem in a deleted category throws an exception",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId = "00xx";

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId);

    expect(
        firebaseFunctions.updateCategoryItemsName(
            itemId: newItemId, newName: "Nova Water"),
        throwsA(isInstanceOf<FirebaseException>()));
  });

  test("update item image edits the item's image successfully", () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);
    DocumentSnapshot item =
        await mockFirestore.collection('items').doc(newItemId).get();

    expect(item.get('illustration'), imageUrl);
    await firebaseFunctions.updateItemImage(
        itemId: newItemId, newImageUrl: "Hana-water.jpeg");

    item = await mockFirestore.collection('items').doc(newItemId).get();
    expect(item.get('illustration'), "Hana-water.jpeg");
  });

  test("updating the image of an item that doesn't exist throws an exception",
      () async {
    expect(
        firebaseFunctions.updateItemImage(
            itemId: "doesn't exist", newImageUrl: "Hana-water.jpeg"),
        throwsA(isInstanceOf<FirebaseException>()));
  });

  test(
      "update categoryItem image edits the image successfully (1 categoryItem)",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId = "00xx";
    await _createCategory(id: categoryId, is_available: true);

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId);

    DocumentSnapshot newCategoryItem = await mockFirestore
        .collection('categoryItems/$categoryId/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem.get('illustration'), imageUrl);
    await firebaseFunctions.updateCategoryItemsImage(
        itemId: newItemId, newImageUrl: "Hana-water.jpeg");

    newCategoryItem = await mockFirestore
        .collection('categoryItems/$categoryId/items')
        .doc(newItemId)
        .get();
    expect(newCategoryItem.get('illustration'), "Hana-water.jpeg");
  });

  test(
      "update categoryItem image edits the image successfully (2 categoryItems in 2 categories)",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId1 = "00xx";
    const String categoryId2 = "11yy";
    await _createCategory(id: categoryId1, is_available: true);
    await _createCategory(id: categoryId2, is_available: true);

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId1,
        itemId: newItemId);
    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId2,
        itemId: newItemId);

    DocumentSnapshot newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();
    DocumentSnapshot newCategoryItem2 = await mockFirestore
        .collection('categoryItems/$categoryId2/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('illustration'), imageUrl);
    expect(newCategoryItem2.get('illustration'), imageUrl);
    await firebaseFunctions.updateCategoryItemsImage(
        itemId: newItemId, newImageUrl: "Hana-water.jpeg");

    newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();
    newCategoryItem2 = await mockFirestore
        .collection('categoryItems/$categoryId2/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('illustration'), "Hana-water.jpeg");
    expect(newCategoryItem2.get('illustration'), "Hana-water.jpeg");
  });

  test(
      "updating the image of a categoryItem without having categories throws an exception",
      () async {
    expect(
        firebaseFunctions.updateCategoryItemsImage(
            itemId: "doesn't exist", newImageUrl: "Hana-water.jpeg"),
        throwsA(isInstanceOf<FirebaseException>()));
  });

  test(
      "updating the image of a categoryItem that doesn't exist (when categories exist) does nothing",
      () async {
    await _createCategory(id: "00xx", is_available: true);
    expect(
        await firebaseFunctions.updateCategoryItemsImage(
            itemId: "doesn't exist", newImageUrl: "Hana-water.jpeg"),
        null);
  });

  test(
      "updating the image of a categoryItem in a deleted category throws an exception",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId = "00xx";

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId);

    expect(
        firebaseFunctions.updateCategoryItemsImage(
            itemId: newItemId, newImageUrl: "Hana-water.jpeg"),
        throwsA(isInstanceOf<FirebaseException>()));
  });

  test(
      "updateCategoryItemsRanks decrements all ranks of categoryItems higher than given rank",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId = "00xx";

    String newItemId1 =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);
    String newItemId2 =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);
    String newItemId3 =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId1);
    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId2);
    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId3);

    expect(
        await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId2),
        1);
    expect(
        await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId3),
        2);

    await firebaseFunctions.updateCategoryItemsRanks(
        categoryId: categoryId,
        removedRank: await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId1));
    await firebaseFunctions.deleteCategoryItem(
        categoryId: categoryId, itemId: newItemId1); // delete isn't necessary

    expect(
        await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId2),
        0);
    expect(
        await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId3),
        1);
  });

  test(
      "updateCategoryItemsRanks does nothing if the deleted categoryItem had highest rank",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId = "00xx";

    String newItemId1 =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);
    String newItemId2 =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);
    String newItemId3 =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId1);
    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId2);
    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId,
        itemId: newItemId3);

    expect(
        await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId1),
        0);
    expect(
        await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId2),
        1);

    await firebaseFunctions.updateCategoryItemsRanks(
        categoryId: categoryId,
        removedRank: await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId3));
    await firebaseFunctions.deleteCategoryItem(
        categoryId: categoryId, itemId: newItemId3); // delete isn't necessary

    expect(
        await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId1),
        0);
    expect(
        await firebaseFunctions.getCategoryItemRank(
            categoryId: categoryId, itemId: newItemId2),
        1);
  });

  test("updateCategoryItemsRanks does nothing if given non existing categoryId",
      () async {
    expect(
        await firebaseFunctions.updateCategoryItemsRanks(
            categoryId: "00xx", removedRank: 1),
        null);
  });

  test("update category name edits the category's name successfully", () async {
    const String name = "Breakfast";
    const String imageUrl = "Nova-water.jpeg";

    String newCategoryId =
        await firebaseFunctions.createCategory(name: name, imageUrl: imageUrl);
    DocumentSnapshot category =
        await mockFirestore.collection('categories').doc(newCategoryId).get();

    expect(category.get('title'), name);
    await firebaseFunctions.updateCategoryName(
        categoryId: newCategoryId, newName: "Lunch");

    category =
        await mockFirestore.collection('categories').doc(newCategoryId).get();
    expect(category.get('title'), "Lunch");
  });

  test("updating the name of a category that doesn't exist throws an exception",
      () async {
    expect(
        firebaseFunctions.updateCategoryName(
            categoryId: "doesnt exist", newName: "doesnt matter"),
        throwsA(isInstanceOf<FirebaseException>()));
  });

  test("update category image edits the category's image successfully",
      () async {
    const String name = "Dinner";
    const String imageUrl = "Nova-water.jpeg";

    String newCategoryId =
        await firebaseFunctions.createCategory(name: name, imageUrl: imageUrl);
    DocumentSnapshot category =
        await mockFirestore.collection('categories').doc(newCategoryId).get();

    expect(category.get('illustration'), imageUrl);
    await firebaseFunctions.updateCategoryImage(
        categoryId: newCategoryId, newImageUrl: "Hana-water.jpeg");

    category =
        await mockFirestore.collection('categories').doc(newCategoryId).get();
    expect(category.get('illustration'), "Hana-water.jpeg");
  });

  test(
      "updating the image of a category that doesn't exist throws an exception",
      () async {
    expect(
        firebaseFunctions.updateCategoryImage(
            categoryId: "doesn't exist", newImageUrl: "Hana-water.jpeg"),
        throwsA(isInstanceOf<FirebaseException>()));
  });

  test(
      "update item availability status edits the is_available field successfully (1 item)",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    DocumentSnapshot newCategoryItem =
        await mockFirestore.collection('items').doc(newItemId).get();

    expect(newCategoryItem.get('is_available'), true);

    await firebaseFunctions.updateItemAvailability(itemId: newItemId);

    DocumentSnapshot upCategoryItem =
        await mockFirestore.collection('items').doc(newItemId).get();

    expect(upCategoryItem.get('is_available'), false);
  });

  test(
      "update categoryItem availability status edits the 'is_available' field successfully (1 categoryItems in 1 categories)",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId1 = "00xx";
    await _createCategory(id: categoryId1, is_available: true);

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId1,
        itemId: newItemId);

    DocumentSnapshot newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('is_available'), true);
    await firebaseFunctions.updateItemAvailability(itemId: newItemId);

    newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('is_available'), false);
  });

  test(
      "update categoryItem availability status edits the 'is_available' field successfully (2 categoryItems in 2 categories)",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId1 = "00xx";
    const String categoryId2 = "11yy";
    await _createCategory(id: categoryId1, is_available: true);
    await _createCategory(id: categoryId2, is_available: true);

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId1,
        itemId: newItemId);
    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId2,
        itemId: newItemId);

    DocumentSnapshot newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();
    DocumentSnapshot newCategoryItem2 = await mockFirestore
        .collection('categoryItems/$categoryId2/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('is_available'), true);
    expect(newCategoryItem2.get('is_available'), true);
    await firebaseFunctions.updateItemAvailability(itemId: newItemId);

    newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();
    newCategoryItem2 = await mockFirestore
        .collection('categoryItems/$categoryId2/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('is_available'), false);
    expect(newCategoryItem2.get('is_available'), false);
  });

  test(
      "update categoryItem availability status two times edits the 'is_available' field successfully two times(1 categoryItems in 1 categories)",
      () async {
    const String name = "Water";
    const String imageUrl = "Nova-water.jpeg";
    const String categoryId1 = "00xx";
    await _createCategory(id: categoryId1, is_available: true);

    String newItemId =
        await firebaseFunctions.createItem(name: name, imageUrl: imageUrl);

    await firebaseFunctions.createCategoryItem(
        name: name,
        imageUrl: imageUrl,
        categoryId: categoryId1,
        itemId: newItemId);

    DocumentSnapshot newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('is_available'), true);
    await firebaseFunctions.updateItemAvailability(itemId: newItemId);

    newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('is_available'), false);
    await firebaseFunctions.updateItemAvailability(itemId: newItemId);

    newCategoryItem1 = await mockFirestore
        .collection('categoryItems/$categoryId1/items')
        .doc(newItemId)
        .get();

    expect(newCategoryItem1.get('is_available'), true);
  });

  test(
      "update item availability status of non-existent item returns a boolean False",
      () async {
    expect(await firebaseFunctions.updateItemAvailability(itemId: "wrongId"),
        false);
  });
}
