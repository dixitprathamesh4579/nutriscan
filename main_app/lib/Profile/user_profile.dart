import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/Profile/Edit_profile.dart';
import 'package:main_app/SignUp_and_Login/SignIn.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => UserProfilestate();
}

class UserProfilestate extends State<UserProfile> {
  bool isOn = false;
  bool isOn2 = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    String defaultUname = 'John Doe';
    String defaultGmail = 'nutriscan08@gmail.com';

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: screenHeight * 0.07,
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.05 / textScale,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.17,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage: const AssetImage(
                        'assets/images/default_profile.png',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      defaultUname,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.05 / textScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      defaultGmail,
                      style: GoogleFonts.roboto(
                        fontSize: screenWidth * 0.04 / textScale,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.018,
                    horizontal: screenWidth * 0.15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: Icon(Icons.edit, size: screenWidth * 0.06),
                label: Text(
                  "Edit Profile",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.045 / textScale,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfile()),
                  );
                },
              ),

              SizedBox(height: screenHeight * 0.03),
              Divider(thickness: 1, color: Colors.grey.shade300),
              SizedBox(height: screenHeight * 0.02),

              Row(
                children: [
                  Icon(Icons.settings, color: Colors.blueAccent),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Settings",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.045 / textScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.015),

              _buildSwitchTile(
                title: "Notifications",
                value: isOn,
                onChanged: (value) => setState(() => isOn = value),
              ),

              _buildSwitchTile(
                title: "Dark Mode",
                value: isOn2,
                onChanged: (value) => setState(() => isOn2 = value),
              ),

              Divider(thickness: 1, color: Colors.grey.shade300),
              SizedBox(height: screenHeight * 0.01),

              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                title: Text(
                  "Clear Scan History",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.042 / textScale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.008,
                      horizontal: screenWidth * 0.05,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Clear",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035 / textScale,
                    ),
                  ),
                ),
              ),

              Divider(thickness: 1, color: Colors.grey.shade300),

              _buildListTile(
                title: "About",
                icon: Icons.info_outline,
                onTap: () {},
              ),

              _buildListTile(
                title: "Help & Support",
                icon: Icons.help_outline,
                onTap: () {},
              ),

              Divider(thickness: 1, color: Colors.grey.shade300),

              ListTile(
                leading: Icon(Icons.logout, color: Colors.redAccent),
                title: Text(
                  "Logout",
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.045 / textScale,
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Signin()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      activeColor: Colors.blueAccent,
      activeTrackColor: Colors.blue[200],
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey.shade300,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(icon, color: Colors.blueAccent),
      onTap: onTap,
    );
  }
}
