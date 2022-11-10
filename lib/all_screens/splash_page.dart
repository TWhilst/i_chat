import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/all_providers/auth_providers.dart';
import 'package:ichat_app/all_screens/home_page.dart';
import 'package:ichat_app/all_screens/login_page.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), (){
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    if(isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/splash.png",
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20,),
            const Text(
              "World's largest Private Chat App",
              style: TextStyle(
                color: ColorConst.themeColor
              ),
            ),
            const SizedBox(height: 20,),
            Container(
              width: 20,
              height: 20,
              child: const CircularProgressIndicator(color: ColorConst.themeColor,),
            ),
          ],
        ),
      ),
    );
  }
}
