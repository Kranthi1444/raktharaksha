import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class UpdateDonationPage extends StatefulWidget {
  const UpdateDonationPage({super.key});

  @override
  State<UpdateDonationPage> createState() => _UpdateDonationPageState();
}

class _UpdateDonationPageState extends State<UpdateDonationPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchDonors() async {
    final response = await supabase.from('donors').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateLastDonated(int id, DateTime date) async {
    // calculate availability (90 days rule)
    final diff = DateTime.now().difference(date).inDays;


    await supabase.from('donors').update({
      'last_donated': date.toIso8601String(),
    }).eq('id', id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Last donated date updated",
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // refresh list
    }
  }

  void pickDate(int donorId) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await updateLastDonated(donorId, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Donation Records",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDonors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading donors"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No donors found"));
          }

          final donors = snapshot.data!;
          return ListView.builder(
            itemCount: donors.length,
            itemBuilder: (context, index) {
              final donor = donors[index];
              final lastDonated = donor['last_donated'];
              final available = donor['available'] ?? true;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(donor['name'],
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Blood Group: ${donor['blood_group']}"),
                      Text("City: ${donor['city']}"),
                      Text("Phone: ${donor['phone']}"),
                      Text(
                          "Last Donated: ${lastDonated != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(lastDonated)) : 'Not updated'}"),
                      
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.redAccent),
                    onPressed: () => pickDate(donor['id']),
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
