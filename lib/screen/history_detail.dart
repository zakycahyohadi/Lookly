import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lookly/models/history_item.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('📄 Detail Riwayat'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan gambar dengan padding dan border radius yang bagus
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(item.imagePath),
                  height: 250, // Memastikan gambar tidak terlalu besar
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Menampilkan hasil analisis dengan card dan desain yang konsisten
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menampilkan hasil analisis
                    SelectableText(
                      item.result,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        height: 1.8,
                        color: Colors.grey.shade900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol salin dengan animasi SnackBar
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.result));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('✅ Teks berhasil disalin!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height - 100,
                                right: 20,
                                left: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
