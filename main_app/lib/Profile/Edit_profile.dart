import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:main_app/SignUp_and_Login/googleauth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  late TextEditingController FirstnameController;
  late TextEditingController LastnameController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController emailController;
  final ImagePicker _picker = ImagePicker();

  bool isSaving = false;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    loadProfileData();
    updateProfile();
    FirstnameController = TextEditingController(text: unickname);
    LastnameController = TextEditingController(text: ufullname);
    ageController = TextEditingController(text: uage.toString());
    weightController = TextEditingController(text: uweight.toString());
    emailController = TextEditingController(text: uemail);
  }

  @override
  void dispose() {
    FirstnameController.dispose();
    LastnameController.dispose();
    ageController.dispose();
    weightController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> loadProfileData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile not found')));
        return;
      }

      profileData = response;
      setState(() {
        FirstnameController = TextEditingController(
          text: profileData?['first_name'] ?? '',
        );
        LastnameController = TextEditingController(
          text: profileData?['last_name'] ?? '',
        );
        emailController = TextEditingController(
          text: profileData?['email'] ?? '',
        );
        ageController = TextEditingController(
          text: profileData?['age']?.toString() ?? '',
        );
        weightController = TextEditingController(
          text: profileData?['weight']?.toString() ?? '',
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    }
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

  Future<String?> uploadAvatar(String userId) async {
    try {
      if (_imagefile == null) return profileData?['avatar_url'];

      final fileName = 'avatar_$userId.jpg';
      final filePath = 'avatars/$fileName';

      await supabase.storage
          .from('avatars')
          .upload(
            filePath,
            _imagefile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return profileData?['avatar_url'];
    }
  }

  Future<void> updateProfile() async {
    if (!editkey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final avatarUrl = await uploadAvatar(user.id);

      await supabase
          .from('profiles')
          .update({
            'first_name': FirstnameController.text.trim(),
            'last_name': LastnameController.text.trim(),
            'email': emailController.text.trim(),
            'age': int.tryParse(ageController.text.trim()),
            'weight': double.tryParse(weightController.text.trim()),
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
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
                            ? FileImage(_imagefile!)
                            : (profileData?['avatar_url'] != null
                                      ? NetworkImage(profileData!['avatar_url'])
                                      : const AssetImage(
                                          'assets/images/default_profile.png',
                                        ))
                                  as ImageProvider,
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
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.blueAccent,
                              size: screenWidth * 0.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                _buildInput(
                  "First Name",
                  Icons.person,
                  FirstnameController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    return null;
                  },
                ),
                _buildInput("Last Name", Icons.badge, LastnameController),
                _buildInput(
                  "Email",
                  Icons.email,
                  emailController,
                  readOnly:true,
                  
                ),
                _buildInput(
                  "Age",
                  Icons.cake,
                  ageController,
                  keyboardType: TextInputType.number,
                ),
                _buildInput(
                  "Weight (kg)",
                  Icons.monitor_weight,
                  weightController,
                  keyboardType: TextInputType.number,
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
                  onPressed: isSaving ? null : () => updateProfile(),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Save Changes",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045 / textScale,
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

  Widget _buildInput(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false, 
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        controller: ctrl,
        validator: validator,
        keyboardType: keyboardType,
          readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
