import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:ichat_app/all_screens/home_page.dart';
import 'package:provider/provider.dart';

import '../all_providers/auth_providers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    switch(authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in failed");
        break;
      case Status.authenticateCancelled:
        Fluttertoast.showToast(msg: "Sign in cancelled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset("images/back.png"),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () async {
                bool isSuccess = await authProvider.handleSignIn();
                if(isSuccess) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false);
                }
              },
              child: Image.asset("images/google_login.jpg"),
            ),
          ),

          SizedBox(
            child: authProvider.status == Status.authenticating? LoadingView() : SizedBox.shrink()

          ),
        ],
      ),
    );
  }
}
