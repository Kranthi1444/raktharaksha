import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class DonorScreen extends StatefulWidget {
  const DonorScreen({super.key});

  @override
  State<DonorScreen> createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  final supabase = Supabase.instance.client;
  String? selectedGroup;

  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<List<Map<String, dynamic>>> fetchDonors() async {
    final response =
        await supabase.from('donors').select().eq('verified', true); // ✅ Only verified donors
    final data = List<Map<String, dynamic>>.from(response);

    if (selectedGroup != null) {
      return data.where((donor) => donor['blood_group'] == selectedGroup).toList();
    }
    return data;
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('❌ Cannot launch dialer for $phoneNumber');
    }
  }

  bool isAvailable(Map<String, dynamic> donor) {
    if (donor['last_donated'] == null) {
      return true; // never donated → available
    }
    final lastDonated = DateTime.parse(donor['last_donated']);
    final nextEligible = lastDonated.add(const Duration(days: 90));
    return DateTime.now().isAfter(nextEligible);
  }

  String nextEligibleDate(Map<String, dynamic> donor) {
    if (donor['last_donated'] == null) return "Available now";
    final lastDonated = DateTime.parse(donor['last_donated']);
    final nextEligible = lastDonated.add(const Duration(days: 90));
    return DateFormat('dd MMM yyyy').format(nextEligible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Donor List',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: selectedGroup,
              isExpanded: true,
              hint: Text("Select Blood Group", style: GoogleFonts.poppins(fontSize: 16)),
              decoration: InputDecoration(
                labelText: 'Blood Group',
                labelStyle: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w500),
                floatingLabelStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.redAccent,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
              items: bloodGroups.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGroup = value;
                });
              },
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDonors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading data', style: GoogleFonts.poppins()));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No donors available', style: GoogleFonts.poppins(fontSize: 16)));
                }

                final donors = snapshot.data!;
                return ListView.builder(
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    final available = isAvailable(donor);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Donor info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(donor['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      )),
                                  const SizedBox(height: 6),
                                  Text(donor['city'],
                                      style: GoogleFonts.poppins(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text("Blood Group: ",
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                      Text(donor['blood_group'],
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 6),
                                      if (donor['verified'] == true)
                                        const Icon(Icons.verified, color: Colors.green, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    available
                                        ? "✅ Available for donation"
                                        : "⛔ Not available until ${nextEligibleDate(donor)}",
                                    style: GoogleFonts.poppins(
                                        color: available ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            // Call button only if available
                            if (available)
                              ElevatedButton.icon(
                                onPressed: () => makePhoneCall(donor['phone']),
                                icon: const Icon(Icons.call),
                                label: const Text("Call"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
