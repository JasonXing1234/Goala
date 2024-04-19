import 'dart:io';

import 'package:Goala/ui/page/profile/widgets/Choices.dart';
import 'package:flutter/material.dart';
import 'package:Goala/helper/customRoute.dart';
import 'package:Goala/helper/utility.dart';
import 'package:Goala/ui/page/profile/widgets/circular_image.dart';
import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../model/user.dart';
import '../../../state/authState.dart';
import '../../../widgets/customFlatButton.dart';

class ProfileImageView extends StatefulWidget {
  const ProfileImageView({Key? key, required this.avatar}) : super(key: key);
  final String avatar;
  static Route<T> getRoute<T>(String avatar) {
    return SlideLeftRoute<T>(
        builder: (BuildContext context) => ProfileImageView(avatar: avatar));
  }

  @override
  State<ProfileImageView> createState() => _ProfileImageViewState();
}

class _ProfileImageViewState extends State<ProfileImageView> {
  String tempAvatar = '';

  @override
  void initState() {
    super.initState();
    tempAvatar = widget.avatar;
  }

  openImagePicker(BuildContext context, Function(File) onImageSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              const Text(
                'Pick an image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomFlatButton(
                      label: "Use Camera",
                      borderRadius: 5,
                      onPressed: () {
                        getImage(context, ImageSource.camera, onImageSelected);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomFlatButton(
                      label: "Use Gallery",
                      borderRadius: 5,
                      onPressed: () {
                        getImage(context, ImageSource.gallery, onImageSelected);
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  getImage(BuildContext context, ImageSource source,
      Function(File) onImageSelected) {
    ImagePicker().pickImage(source: source, imageQuality: 50).then((
        XFile? file,
        ) {
      //FIXME
      onImageSelected(File(file!.path));
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    const List<Choice> choices = [
      Choice(
        title: 'Change Profile Photo',
        icon: Icons.share,
        isEnable: true,
      ),
    ];
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: AppBar(
        actions: <Widget>[
        ],
      ),
      body:
    ProgressHUD(child: Builder(builder: (context) {
    return FutureBuilder(
        future: state.getUserDetail(state.userId),
        builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    height: 400,
                    width: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 5),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: customAdvanceNetworkImage(snapshot.data!.profilePic),
                          fit: BoxFit.cover),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: customAdvanceNetworkImage(snapshot.data!.profilePic),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black38,
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: (){
                              openImagePicker(context, (file) {
                                setState(() {
                                  var state = Provider.of<AuthState>(context, listen: false);
                                  final progress =
                                  ProgressHUD.of(context);
                                  progress!.show();
                                  state.updateUserProfile(state.userModel, image: file);
                                  Future.delayed(Duration(seconds: 2), () {
                                    progress.dismiss();
                                  });
                                  tempAvatar = file.path;
                                });
                              });
                            },
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 50,),
                          ),
                        ),
                      ),
                    ),
                  )
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      );}))
    );
  }
}
