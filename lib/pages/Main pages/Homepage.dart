import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:raktharaksha/pages/Authentication/auth_page.dart';
import 'package:raktharaksha/pages/Main%20pages/admin_reg.dart';
import 'package:raktharaksha/pages/Main%20pages/admin_verify.dart';
import 'package:raktharaksha/pages/Main%20pages/availblefordonation.dart';
import 'package:raktharaksha/pages/Main%20pages/donors.dart';
import 'package:raktharaksha/pages/Main%20pages/profile.dart';
import 'package:raktharaksha/pages/Main%20pages/reg_donor.dart';
import 'package:raktharaksha/pages/Main%20pages/stock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = Supabase.instance.client.auth.currentUser;
  bool isDonor = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkIfDonor();
  }

  Future<void> _checkIfDonor() async {
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('donors')
        .select()
        .eq('email', user!.email!)
        .maybeSingle();

    setState(() {
      isDonor = response != null;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? "User";
    final username = email.split('@')[0];
    final isAdmin = email == "admin@gmail.com";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Raktha Raksha',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
       actions: [
  if (isAdmin)
    IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      tooltip: "Sign Out",
      onPressed: () async {
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
      (route) => false, // remove all previous routes
    );
        }
      },
    )
  else
    IconButton(
      icon: const Icon(Icons.person, color: Colors.white),
      tooltip: "Profile",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      },
    ),
],

      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔴 Banner - edge to edge
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: AnotherCarousel(
                      images: const [
                        AssetImage('lib/images/b1.jpg'),
                        AssetImage('lib/images/b2.jpg'),
                        AssetImage('lib/images/b3.jpg'),
                        AssetImage('lib/images/b4.jpg'),
                      ],
                      showIndicator: true,
                      dotSize: 4.0,
                      dotSpacing: 12.0,
                      dotColor: Colors.white70,
                      dotBgColor: Colors.transparent,
                      borderRadius: false,
                      autoplay: true,
                      autoplayDuration: const Duration(seconds: 5),
                      animationCurve: Curves.easeInOut,
                      animationDuration: const Duration(milliseconds: 800),
                    ),
                  ),

                  // ✅ Padded content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                     

                        Text(
                          "Welcome, $username",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ✅ Admin Features
                        if (isAdmin) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Admin Features",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildFeatureCard(
                            context,
                            "Verify Donors",
                            Icons.verified_user,
                            Colors.blue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdminApprovalPage()),
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            "Update Last Donated",
                            Icons.calendar_today,
                            Colors.purple,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => UpdateDonationPage()),
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            "Register Donor",
                            Icons.app_registration,
                            Colors.orange,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminDonorRegistrationPage()),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ✅ Normal Features
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Features",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureCard(
                          context,
                          "View Blood Stock",
                          Icons.bloodtype,
                          Colors.redAccent,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BloodStockViewPage()),
                          ),
                        ),
                        _buildFeatureCard(
                          context,
                          "Donors",
                          Icons.people,
                          Colors.teal,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DonorScreen()),
                          ),
                        ),

                        // ✅ Show Register Donor/Profile only for normal users
                        if (!isAdmin)
                          _buildFeatureCard(
                            context,
                            isDonor ? "Profile" : "Register Donor",
                            isDonor ? Icons.person : Icons.app_registration,
                            isDonor ? Colors.green : Colors.orange,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => isDonor
                                    ? const ProfilePage()
                                    : DonorRegistrationPage(),
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),
                        Center(
                          child: Text(
                            "'Be a lifeline, donate blood — your generosity sustains the symphony of life.'",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 26,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        title: Text(
          title,
          style:
              GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
