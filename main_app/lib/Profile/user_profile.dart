import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/Profile/Edit_profile.dart';
import 'package:main_app/SignUp_and_Login/SignIn.dart';

class UserProfile extends StatefulWidget {
  State<UserProfile> createState() => UserProfilestate();
}

class UserProfilestate extends State<UserProfile> {
  bool isOn = false;
  bool isOn2 = false;
  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    String default_uname = 'name';
    String uname;
    String default_gmail = 'nutriscan08@gmail.com';
    String gmail;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            padding: EdgeInsets.all(screenheight * 0.03),
            width: screenwidth,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    'assets/images/default_profile.png',
                  ),
                ),
                SizedBox(height: screenheight * 0.02),
                Text(
                  default_uname,
                  style: GoogleFonts.poppins(
                    fontSize: screenwidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  default_gmail,
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenheight * 0.02),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: screenwidth * 0.05),
                      Icon(Icons.edit, weight: screenheight * 0.05),
                    ],
                  ),
                ),
                SizedBox(height: screenheight * 0.03),
                Divider(color: Colors.black, thickness: 1),
                SizedBox(height: screenheight * 0.01),
                Row(
                  children: [
                    Padding(padding: EdgeInsetsGeometry.directional(start: 15)),
                    Icon(Icons.settings),
                    SizedBox(width: screenwidth * 0.03),
                    Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: screenwidth * 0.04,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenheight * 0.01),

                Transform.scale(
                  scale: 0.9,
                  child: SwitchListTile(
                    title: Text('Notifications'),
                    inactiveThumbColor: Colors.blue[400],
                    inactiveTrackColor: Colors.blue[200],
                    activeThumbColor: Colors.blue[300],
                    activeTrackColor: Colors.blue[500],
                    value: isOn,
                    onChanged: (value) {
                      setState(() {
                        isOn = value;
                      });
                    },
                  ),
                ),

                Transform.scale(
                  scale: 0.9,
                  child: SwitchListTile(
                    title: Text('Theme(Dark/Light)'),
                    inactiveThumbColor: Colors.blue[400],
                    inactiveTrackColor: Colors.blue[200],
                    activeThumbColor: Colors.blue[300],
                    activeTrackColor: Colors.blue[500],
                    value: isOn2,
                    onChanged: (value) {
                      setState(() {
                        isOn2 = value;
                      });
                    },
                  ),
                ),
                Divider(color: Colors.black, thickness: 1),
                Transform.scale(
                  scale: 0.9,
                  child: ListTile(
                    title: Text('Clear Scan History'),
                    trailing: SizedBox(
                      height: 30,
                      width: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {},
                        child: Text('Clear'),
                      ),
                    ),
                  ),
                ),

                Divider(color: Colors.black, thickness: 1),

                Transform.scale(
                  scale: 0.9,
                  child: ListTile(
                    title: Text('About'),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ),

                Transform.scale(
                  scale: 0.9,
                  child: ListTile(
                    title: Text('Help & Support'),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ),

                ListTile(
                  leading: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signin()),
                      );
                    },
                    icon: Icon(Icons.logout),
                    color: Colors.red,
                  ),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.poppins(color: (Colors.red)),
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
