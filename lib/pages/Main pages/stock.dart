import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodStockViewPage extends StatefulWidget {
  const BloodStockViewPage({super.key});

  @override
  State<BloodStockViewPage> createState() => _BloodStockViewPageState();
}

class _BloodStockViewPageState extends State<BloodStockViewPage> {
  final supabase = Supabase.instance.client;

  String? selectedGroup;
  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<List<Map<String, dynamic>>> fetchStock() async {
    final response = await supabase.from('blood_stock').select();
    final data = List<Map<String, dynamic>>.from(response);

    if (selectedGroup != null) {
      final filtered = data.where((row) {
        final count = row[selectedGroup];
        return count != null && count > 0;
      }).toList();

      filtered.sort((a, b) => (b[selectedGroup] as int).compareTo(a[selectedGroup] as int));
      return filtered;
    }

    return data;
  }

  void openMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

Widget buildStockRow(Map<String, dynamic> item) {
  if (selectedGroup != null) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$selectedGroup ',
              style: GoogleFonts.poppins(fontSize: 15,                fontWeight: FontWeight.bold,),
              
            ),
             TextSpan(
                    text: ': ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                    ),
                  ),
            TextSpan(
              text: ' ${item[selectedGroup] ?? 0} ',
              style: GoogleFonts.poppins(
                fontSize: 15,

              ),
            ),
            TextSpan(
              text: 'Units',
              style: GoogleFonts.poppins(
                fontSize: 15,

              ),
            ),
          ],
        ),
      ),
    );
  } else {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: bloodGroups.map((group) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$group ',
                    style: GoogleFonts.poppins(fontSize: 13,fontWeight: FontWeight.bold),
                    
                  ),
                  TextSpan(
                    text: ': ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: '${item[group] ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                    ),
                  ),
                
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Blood Stock Finder', style: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
  value: selectedGroup,
  isExpanded: true, // ✅ expands to full width
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
      child: Text(
        group,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
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
              future: fetchStock(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading data', style: GoogleFonts.poppins()));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No data available',
                        style: GoogleFonts.poppins(fontSize: 16)),
                  );
                }

                final data = snapshot.data!;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                )),
                            const SizedBox(height: 6),
                            Text(item['address'], style: GoogleFonts.poppins(fontSize: 14)),
                            const SizedBox(height: 12),
                            buildStockRow(item),
                            const SizedBox(height: 10),
                            Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    ElevatedButton.icon(
      onPressed: () {
        final phoneNumber = item['phone']; // Add phone number in your DB
        final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
        launchUrl(launchUri);
      },
      icon: const Icon(Icons.call),
      label: const Text("Call"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    ElevatedButton.icon(
      onPressed: () {
        final lat = item['latitude'];
        final lng = item['longitude'];
        final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
        launchUrl(mapUri);
      },
      icon: const Icon(Icons.navigation),
      label: const Text("Navigate"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  ],
)

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
