import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/all_models/popup_choices.dart';
import 'package:ichat_app/all_screens/settings_page.dart';
import 'package:provider/provider.dart';
import '../all_providers/auth_providers.dart';
import '../main.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late String currentUserId;
  late AuthProvider authProvider;
  // late HomeProvider homeProvider;

  List<PopupChoices> choices = [
    PopupChoices(title: "Settings", icon: Icons.settings),
    PopupChoices(title: "Sign out", icon: Icons.exit_to_app),
  ];

  handleSignOut()  {
    authProvider.handleSignOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage(),), (route) => false);
  }

  void scrollListener() {
    if(listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onItemMenuPress(PopupChoices choice) {
    if(choice.title == "Sign out") {
      print("clicked");
      handleSignOut();
    } else {
      print("clicked");
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SettingsPage()));
    }
  }

  Widget buildPopUpMenu() {
    return PopupMenuButton<PopupChoices>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.grey
      ),
      itemBuilder: (BuildContext context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
            onTap: () async{
              await Future.delayed(Duration.zero);
              onItemMenuPress(choice);
            },
            child: Row(
              children: [
                Icon(
                  choice.icon,
                  color: ColorConst.primaryColor,
                ),
                Container(
                  width: 10,
                ),
                Text(
                  choice.title,
                  style: const TextStyle(
                    color: ColorConst.primaryColor,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    // homeProvider = context.read<HomeProvider>();

    if(authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()), 
              (Route<dynamic> route) => false);
    }
    listScrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite? Colors.white : Colors.black,
        leading: IconButton(
          onPressed: () => "",
          icon: Switch(
            value: isWhite,
            onChanged: (value) {
              setState(() {
                isWhite = value;
                print(isWhite);
              });
            },
            activeTrackColor: Colors.grey,
            activeColor: Colors.white,
            inactiveTrackColor: Colors.grey,
            inactiveThumbColor: Colors.black45,
          ),
        ),
        actions: [
          buildPopUpMenu(),
        ],
      ),
    );
  }
}
