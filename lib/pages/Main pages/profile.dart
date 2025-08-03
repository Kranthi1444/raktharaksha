import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:raktharaksha/pages/Authentication/auth_page.dart';
import 'package:raktharaksha/pages/Main%20pages/reg_donor.dart'; // ✅ Register Donor Page
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? donorData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('donors')
        .select()
        .eq('email', user.email!)
        .maybeSingle();

    setState(() {
      donorData = response;
      isLoading = false;
    });
  }

  /// 📌 Upload Profile Pic
  Future<void> uploadProfilePic() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    String fileName = "${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";

    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result == null || result.files.single.bytes == null) return;

        await supabase.storage
            .from('profiles')
            .uploadBinary(fileName, result.files.single.bytes!);
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? picked =
            await picker.pickImage(source: ImageSource.gallery);
        if (picked == null) return;

        final file = File(picked.path);
        await supabase.storage.from('profiles').upload(fileName, file);
      }

      final imageUrl = supabase.storage.from('profiles').getPublicUrl(fileName);

      await supabase
          .from('donors')
          .update({'profile_pic': imageUrl})
          .eq('email', user.email!);

      fetchProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Profile picture updated"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Error uploading: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 📌 Pick and update last donated date
  Future<void> pickLastDonatedDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase
          .from('donors')
          .update({'last_donated': pickedDate.toIso8601String()})
          .eq('email', user.email!);

      fetchProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "✅ Last donated date updated to ${DateFormat('dd MMM yyyy').format(pickedDate)}"),
          backgroundColor: Colors.green,
        ));
      }
    }
  }

  /// 📌 Edit donor details
  Future<void> _showEditDetailsDialog() async {
    final nameController = TextEditingController(text: donorData?['name']);
    final phoneController = TextEditingController(text: donorData?['phone']);
    final cityController = TextEditingController(text: donorData?['city']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: "City"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final user = supabase.auth.currentUser;
              if (user == null) return;

              await supabase.from('donors').update({
                'name': nameController.text,
                'phone': phoneController.text,
                'city': cityController.text,
              }).eq('email', user.email!);

              Navigator.pop(context);
              fetchProfile();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("✅ Profile updated successfully"),
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🚨 Case: No donor record → Show placeholder with "Fill Details"
    if (donorData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Profile",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 254, 222, 222),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/profile.png"),
                  ),
                  const SizedBox(height: 10),
                  Text("Details not filled",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.redAccent),
              title: Text("Fill Details",
                  style: GoogleFonts.poppins(color: Colors.redAccent)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DonorRegistrationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text("Log Out",
                  style: GoogleFonts.poppins(color: Colors.redAccent)),
              onTap: () async {
                await supabase.auth.signOut();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      );
    }

    // ✅ Case: Donor exists → show full profile
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 254, 222, 222),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: uploadProfilePic,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: donorData!['profile_pic'] != null
                        ? NetworkImage(donorData!['profile_pic'])
                        : const AssetImage("assets/profile.png")
                            as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.redAccent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(donorData!['name'] ?? "",
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(donorData!['phone'] ?? "",
                    style: GoogleFonts.poppins(fontSize: 15)),
                Text(donorData!['email'] ?? "",
                    style: GoogleFonts.poppins(fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text("Edit Details", style: GoogleFonts.poppins()),
            onTap: _showEditDetailsDialog,
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text("Update Last Donated Date",
                style: GoogleFonts.poppins()),
            onTap: pickLastDonatedDate,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text("Log Out",
                style: GoogleFonts.poppins(color: Colors.redAccent)),
            onTap: () async {
              await supabase.auth.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
