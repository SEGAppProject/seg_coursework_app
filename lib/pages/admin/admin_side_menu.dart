import 'package:flutter/material.dart';
import 'package:seg_coursework_app/pages/admin/admin_choice_boards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../visual_timetable/visual_timetable_interface.dart';
import 'package:seg_coursework_app/pages/child_menu/customizable_column.dart';

/// The side-menu of the admin's UI
class AdminSideMenu extends StatelessWidget {
  const AdminSideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        key: const Key("adminSideMenu"),
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(context),
            buildMenuItems(context),
          ],
        )),
      );

  // The header of the side-menu
  Widget buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
      );

  // The items of the side-menu
  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          children: [
            ListTile(
              key: const Key("choiceBoards"),
              leading: const Icon(Icons.photo_size_select_actual_outlined),
              title: const Text('Choice boards'),
              onTap: () =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AdminChoiceBoards(),
              )),
            ),
            ListTile(
              key: const Key("visualTimetable"),
              leading: const Icon(Icons.event),
              title: const Text('Visual Timetable'),
              onTap: () =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const VisualTimetableInterface(),
              )),
            ),
            ListTile(
              key: const Key("childMode"),
              leading: const Icon(Icons.child_care),
              title: const Text('Activate Child Mode'),
              // onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              //   builder: (context) => CustomizableColumn(),
              // )
              // ),
              onTap: () async {
                final pref = await SharedPreferences.getInstance();
                pref.setBool("isInChildMode",
                    true); //isInChildMode boolean set to true as we are entering
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => CustomizableColumn(),
                ));
              },
            ),
            ListTile(
              key: const Key("appColours"),
              leading: const Icon(Icons.color_lens_outlined),
              title: const Text('Edit App Colours'),
              onTap: () {},
            ),
            const Divider(
              color: Colors.black54,
            ),
            ListTile(
              key: const Key("accountDetails"),
              leading: const Icon(Icons.account_box_outlined),
              title: const Text('Edit Account Details'),
              onTap: () {},
            ),
            ListTile(
              key: const Key("logout"),
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Log out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      );
}
