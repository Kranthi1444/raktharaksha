import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPendingDonors() async {
    final response =
        await supabase.from('donors').select().eq('verified', false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> approveDonor(int id) async {
    await supabase.from('donors').update({'verified': true}).eq('id', id);
    setState(() {}); // refresh
  }

  Future<void> rejectDonor(int id) async {
    await supabase.from('donors').delete().eq('id', id);
    setState(() {}); // refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pending Approvals",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPendingDonors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading donors"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No pending approvals"));
          }

          final donors = snapshot.data!;
          return ListView.builder(
            itemCount: donors.length,
            itemBuilder: (context, index) {
              final donor = donors[index];
              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Donor details with column names
                      Expanded(
                        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("${donor['name']}",
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.redAccent)),
    const SizedBox(height: 6),
    RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
        children: [
          const TextSpan(text: "City: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: donor['city'] ?? ""),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
        children: [
          const TextSpan(text: "Blood Group: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: donor['blood_group'] ?? ""),
        ],
      ),
    ),
    RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
        children: [
          const TextSpan(text: "Phone: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: donor['phone'] ?? ""),
        ],
      ),
    ),
  ],
)

                      ),
                      // Approve / Reject buttons
                      Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color:Color.fromARGB(255, 227, 226, 226), // ✅ background color
      ),
      child: IconButton(
        icon: const Icon(Icons.check, color: Colors.green),
        onPressed: () => approveDonor(donor['id']),
      ),
    ),
    const SizedBox(width: 8),
    Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 227, 226, 226), // ✅ background color
      ),
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.red),
        onPressed: () => rejectDonor(donor['id']),
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
    );
  }
}
