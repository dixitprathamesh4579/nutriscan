import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  @override
  State<EditProfile> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final editkey = GlobalKey<FormState>();

  String unickname = 'pd';
  String ufullname = '';
  int uage = 20;
  int uweight = 60;
  String uemail = 'nutriscan08@gmail.com';
  File? _imagefile;

  late TextEditingController nicknameController;
  late TextEditingController fullnameController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController emailController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImage(); 
    nicknameController = TextEditingController(text: unickname);
    fullnameController = TextEditingController(text: ufullname);
    ageController = TextEditingController(text: uage.toString());
    weightController = TextEditingController(text: uweight.toString());
    emailController = TextEditingController(text: uemail);
  }

  @override
  void dispose() {
    nicknameController.dispose();
    fullnameController.dispose();
    ageController.dispose();
    weightController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickimage(ImageSource source) async {
    final pickedfile = await _picker.pickImage(source: source);
    if (pickedfile != null) {
      setState(() {
        _imagefile = File(pickedfile.path);
      });
      _saveImage(pickedfile.path);
    }
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("profile_image");
    if (path != null) {
      setState(() {
        _imagefile = File(path);
      });
    }
  }

  Future<void> _saveImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_image", path);
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: screenheight * 0.039,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            width: screenwidth,
            color: Colors.white,
            padding: EdgeInsets.all(screenheight * 0.03),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imagefile != null
                            ? FileImage(_imagefile!) as ImageProvider
                            : const AssetImage(
                                'assets/images/default_profile.png',
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                _pickimage(ImageSource.gallery);
                              },
                              icon: Image.asset(
                                'assets/images/imagepicker.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: editkey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(' Nick name'),
                      ),
                      TextFormField(
                        controller: nicknameController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nickname cannot be empty";
                          }
                          if (value.length < 2) {
                            return "Nickname must be at least 2 characters long";
                          }
                          if (value.length > 15) {
                            return "Nickname cannot be more than 15 characters";
                          }
                          final nicknameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
                          if (!nicknameRegex.hasMatch(value)) {
                            return "Only letters, numbers, and underscores are allowed";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Your nick name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          suffixIcon: Icon(Icons.edit),
                        ),
                        onSaved: (val) => unickname = val!.trim(),
                      ),
                      SizedBox(height: screenheight * 0.01),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(' Full Name'),
                      ),
                      TextFormField(
                        controller: fullnameController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Full name cannot be empty";
                          }
                          if (value.trim().length < 2) {
                            return "Full name must be at least 2 characters long";
                          }
                          if (value.trim().length > 50) {
                            return "Full name cannot be more than 50 characters";
                          }
                          final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
                          if (!nameRegex.hasMatch(value)) {
                            return "Only letters and spaces are allowed";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Your Full name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          suffixIcon: Icon(Icons.edit),
                        ),
                        onSaved: (val) => ufullname = val!.trim(),
                      ),
                      SizedBox(height: screenheight * 0.01),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(' Email Address'),
                      ),
                      TextFormField(
                        controller: emailController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email is required";
                          } else if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value.trim())) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Your Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          suffixIcon: Icon(Icons.edit),
                        ),
                        onSaved: (val) => uemail = val!.trim(),
                      ),
                      SizedBox(height: screenheight * 0.01),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(' Age'),
                      ),
                      TextFormField(
                        controller: ageController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Age cannot be empty";
                          }
                          final age = int.tryParse(value.trim());
                          if (age == null) {
                            return "Age must be a number";
                          }
                          if (age < 12) {
                            return "Age must be at least 12";
                          }
                          if (age > 100) {
                            return "Age must be less than or equal to 100";
                          }
                          return null;
                        },
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: 'Enter Your Age',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          suffixIcon: Icon(Icons.edit),
                        ),
                        onSaved: (val) => uage = int.parse(val!.trim()),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: screenheight * 0.01),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(' Weight'),
                      ),
                      TextFormField(
                        controller: weightController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Weight cannot be empty";
                          }
                          final weight = double.tryParse(value.trim());
                          if (weight == null) {
                            return "Weight must be a number";
                          }
                          if (weight <= 10) {
                            return "Weight must be greater than 10";
                          }
                          if (weight > 300) {
                            return "(Are You Serious!!!)Weight must be less than or equal to 300 kg";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Your Weight',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          suffixIcon: Icon(Icons.edit),
                        ),
                        onSaved: (val) => uweight = int.parse(val!.trim()),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: screenheight * 0.10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 100,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (editkey.currentState!.validate()) {
                            editkey.currentState!.save();
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
