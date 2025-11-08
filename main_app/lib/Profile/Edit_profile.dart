import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: screenHeight * 0.06,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: screenWidth * 0.05 / textScale,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Form(
            key: editkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.17,
                        backgroundColor: Colors.blue.shade50,
                        backgroundImage: _imagefile != null
                            ? FileImage(_imagefile!) as ImageProvider
                            : const AssetImage('assets/images/default_profile.png'),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 6,
                        child: InkWell(
                          onTap: () => _pickimage(ImageSource.gallery),
                          child: Container(
                            height: screenWidth * 0.1,
                            width: screenWidth * 0.1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.blueAccent, width: 1),
                            ),
                            child: Icon(Icons.camera_alt,
                                color: Colors.blueAccent, size: screenWidth * 0.05),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                _buildLabel("Nickname", screenWidth),
                _buildTextField(
                  controller: nicknameController,
                  hint: "Enter your nickname",
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Nickname cannot be empty";
                    if (value.length < 2) return "Nickname must be at least 2 characters";
                    if (value.length > 15) return "Nickname too long";
                    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
                    if (!regex.hasMatch(value)) return "Only letters, numbers, underscores";
                    return null;
                  },
                  onSaved: (val) => unickname = val!.trim(),
                ),

                _buildLabel("Full Name", screenWidth),
                _buildTextField(
                  controller: fullnameController,
                  hint: "Enter your full name",
                  icon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Name required";
                    if (value.trim().length < 2) return "Too short";
                    final regex = RegExp(r'^[a-zA-Z\s]+$');
                    if (!regex.hasMatch(value)) return "Only letters & spaces allowed";
                    return null;
                  },
                  onSaved: (val) => ufullname = val!.trim(),
                ),

                _buildLabel("Email Address", screenWidth),
                _buildTextField(
                  controller: emailController,
                  hint: "Enter your email",
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email required";
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return "Invalid email";
                    }
                    return null;
                  },
                  onSaved: (val) => uemail = val!.trim(),
                ),

                _buildLabel("Age", screenWidth),
                _buildTextField(
                  controller: ageController,
                  hint: "Enter your age",
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Age required";
                    final age = int.tryParse(value);
                    if (age == null || age < 12 || age > 100) return "Age 12–100 only";
                    return null;
                  },
                  onSaved: (val) => uage = int.parse(val!.trim()),
                ),

                _buildLabel("Weight (kg)", screenWidth),
                _buildTextField(
                  controller: weightController,
                  hint: "Enter your weight",
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Weight required";
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 10 || weight > 300) {
                      return "Enter valid weight (10–300)";
                    }
                    return null;
                  },
                  onSaved: (val) => uweight = int.parse(val!.trim()),
                ),

                SizedBox(height: screenHeight * 0.06),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (editkey.currentState!.validate()) {
                      editkey.currentState!.save();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.045 / textScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.04, bottom: screenWidth * 0.015),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onSaved: onSaved,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }
}
