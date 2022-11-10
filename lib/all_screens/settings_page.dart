import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allConstants/app_constants.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:ichat_app/all_models/user_chat.dart';
import 'package:ichat_app/all_providers/setting_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor: isWhite ? Colors.white : Colors.black,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: ColorConst.primaryColor,
          ),
          title: const Text(
            AppConstants.settingsTitle,
            style: TextStyle(
              color: ColorConst.primaryColor,
            ),
          ),
        ),
        body: const SettingsPageState(),
    );
  }
}

class SettingsPageState extends StatefulWidget {
  const SettingsPageState({Key? key}) : super(key: key);

  @override
  State<SettingsPageState> createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;

  String dialCodeDigits = "+00";
  final TextEditingController _controller = TextEditingController();

  bool isLoading = false;
  File? avatarImageFile;
  late SettingProvider settingProvider;

  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  String phoneNumber = "";

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    super.initState();
    settingProvider = context.read<SettingProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = settingProvider.getPrefs(FirestoreConstants.id);
      nickname = settingProvider.getPrefs(FirestoreConstants.nickname);
      aboutMe = settingProvider.getPrefs(FirestoreConstants.aboutMe);
      photoUrl = settingProvider.getPrefs(FirestoreConstants.photoUrl);
      phoneNumber = settingProvider.getPrefs(FirestoreConstants.phoneNumber);

      controllerNickname = TextEditingController(text: nickname);
      controllerAboutMe = TextEditingController(text: aboutMe);
    });
  }

  Future<void> getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future<void> uploadFile() async {
    String fileName = id;
    UploadTask uploadTask =
        settingProvider.uploadFile(fileName, avatarImageFile!);

    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();

      UserChat updateInfo = UserChat(
        id: id,
        photoUrl: photoUrl,
        nickname: nickname,
        aboutMe: aboutMe,
        phoneNumber: phoneNumber,
      );
      settingProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
          .then((data) async {
            await settingProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
            setState(() {
              isLoading = false;
            });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;

      if(dialCodeDigits != "+00" && _controller.text != "") {
        phoneNumber = dialCodeDigits + _controller.text;
      }
    });

    UserChat updateInfo = UserChat(
      id: id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
      phoneNumber: phoneNumber,
    );
    settingProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((data) async {
      await settingProvider.setPrefs(FirestoreConstants.nickname, nickname);
      await settingProvider.setPrefs(FirestoreConstants.aboutMe, aboutMe);
      await settingProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
      await settingProvider.setPrefs(FirestoreConstants.phoneNumber, phoneNumber);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "update Success");

    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: [
                CupertinoButton(
                  onPressed: getImage,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: avatarImageFile == null? photoUrl.isNotEmpty ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                        errorBuilder: (context, object, stackTrace) {
                          return const Icon(
                            Icons.account_circle,
                            size: 90,
                            color: ColorConst.greyColor,
                          );
                        },
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
                          if(loadingProgress == null) return child;
                          return SizedBox(
                            width: 90,
                            height: 90,
                            child:  Center(
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                                value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null?
                                loadingProgress.cumulativeBytesLoaded /loadingProgress.expectedTotalBytes! : null,
                              )
                            ),
                          );
                        },
                      ),
                    ) :
                    const Icon(
                      Icons.account_circle,
                      size: 90,
                      color: ColorConst.greyColor,
                    ) :
                    ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: Image.file(
                        avatarImageFile!,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: const Text(
                        "Name",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.primaryColor,
                        ),
                      ),
                      margin: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: Theme(data: Theme.of(context).copyWith(
                        primaryColor: ColorConst.primaryColor
                      ),
                        child: TextField(
                          style: const TextStyle(color: Colors.grey),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ColorConst.greyColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ColorConst.greyColor),
                            ),
                            hintText: "Write your name...",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: ColorConst.greyColor),
                          ),
                          controller: controllerNickname,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: focusNodeNickname,
                        ),
                      ),
                    ),
                    Container(
                      child: const Text(
                        "About me",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.primaryColor,
                        ),
                      ),
                      margin: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: Theme(data: Theme.of(context).copyWith(
                          primaryColor: ColorConst.primaryColor
                      ),
                        child: TextField(
                          style: const TextStyle(color: Colors.grey),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ColorConst.greyColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ColorConst.greyColor),
                            ),
                            hintText: "Write something about yourself...",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: ColorConst.greyColor),
                          ),
                          controller: controllerAboutMe,
                          onChanged: (value) {
                            aboutMe = value;
                          },
                          focusNode: focusNodeAboutMe,
                        ),
                      ),
                    ),
                    Container(
                      child: const Text(
                        "Phone No",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ColorConst.primaryColor,
                        ),
                      ),
                      margin: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: Theme(data: Theme.of(context).copyWith(
                          primaryColor: ColorConst.primaryColor
                      ),
                        child: TextField(
                          enabled: false,
                          style: const TextStyle(color: Colors.grey),
                          decoration: InputDecoration(
                            hintText: phoneNumber,
                            contentPadding: const EdgeInsets.all(5),
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10, top: 30, bottom: 5),
                      child: SizedBox(
                        width: 400,
                        height: 60,
                        child: CountryCodePicker(
                          onChanged: (country) {
                            setState(() {
                              dialCodeDigits = country.dialCode!;
                            });
                          },
                          initialSelection: "IT",
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          favorite: const ["+1", "US", "+92", "PAK"],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: TextField(
                        style: const TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConst.greyColor2),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConst.primaryColor),
                          ),
                          hintText: "Write something about yourself...",
                          prefix: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              dialCodeDigits,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        controller: _controller,
                        maxLength: 12,
                        keyboardType: TextInputType.number,
                      ),
                    ),

                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 50),
                  child: TextButton(
                    onPressed: handleUpdateData,
                    child: const Text(
                      "Update now",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(ColorConst.primaryColor),
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(30, 10, 30,10),),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(child: isLoading? LoadingView() : const SizedBox.shrink()),
      ],
    );
  }
}
