import 'dart:io';
import 'dart:typed_data'; // Untuk Web
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lookly/models/history_item.dart';
import 'package:lookly/network/gemini.service.dart';
import 'package:flutter/services.dart';
import 'package:lookly/screen/history.dart';
import 'package:flutter/foundation.dart'; // Import untuk kIsWeb

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _geminiService = GeminiService();
  File? _image;
  Uint8List? _webImageBytes; // Untuk Web
  String _result = '';
  bool _loading = false;

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _image = null;
          _result = '';
        });
        await _analyzeImageWeb(bytes); // Analisis gambar untuk Web
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _webImageBytes = null;
          _result = '';
        });
        await _analyzeImage(_image!); // Analisis gambar untuk Mobile
      }
    }
  }

  // Fungsi untuk menganalisis gambar di platform mobile
  Future<void> _analyzeImage(File imageFile) async {
   
    setState(() => _loading = true);

    final result = await _geminiService.describeImage(imageFile);

    final historyItem = HistoryItem(
      imagePath: imageFile.path,
      result: result,
      createdAt: DateTime.now(),
    );

    final box = Hive.box<HistoryItem>('historyBox');
    await box.add(historyItem);

    setState(() {
      _result = result;
      _loading = false;
    });
  }



  // Fungsi untuk menganalisis gambar di platform web
  Future<void> _analyzeImageWeb(Uint8List imageBytes) async {
    setState(() => _loading = true);

    final result = await _geminiService.describeImageWeb(imageBytes);

 final historyItem = HistoryItem(
  imagePath: null,
  webImageBytes: imageBytes,
  result: result,
  createdAt: DateTime.now(),
);


    final box = Hive.box<HistoryItem>('historyBox');
    await box.add(historyItem);

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  // Mendapatkan badge utama berdasarkan hasil deskripsi
  String? _getMainBadge(String result) {
    final keywords = {
      'makanan': '🍽️ Makanan',
      'kuliner': '🍽️ Makanan',
      'masakan': '🍽️ Makanan',
      'mobil': '🚗 Kendaraan',
      'motor': '🏍️ Kendaraan',
      'kendaraan': '🚘 Kendaraan',
      'manusia': '👥 Aktivitas',
      'orang': '👥 Aktivitas',
      'aktivitas': '👥 Aktivitas',
      'hewan': '🐾 Hewan',
      'kucing': '🐱 Hewan',
      'anjing': '🐶 Hewan',
      'pantai': '🏖️ Tempat',
      'gunung': '🏞️ Tempat',
      'kota': '🌆 Tempat',
      'wisata': '🧳 Wisata',
      'produk': '🛍️ Produk',
      'iklan': '📢 Iklan',
      'poster': '📄 Poster',
      'teks': '📝 Teks',
      'desain': '🎨 Desain',
      'logo': '🧿 Logo / Branding',
      'branding': '🧿 Logo / Branding',
      'brand': '🧿 Logo / Branding',
      'identitas': '🧿 Logo / Branding',
      'emblem': '🧿 Logo / Branding',
      'simbol': '🧿 Logo / Branding',
    };

    final lowerResult = result.toLowerCase();
    for (var entry in keywords.entries) {
      if (lowerResult.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  // Membuat tampilan badge
  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }

  // Membuat tampilan hasil analisis
  Widget _buildResultCard() {
    final mainBadge = _getMainBadge(_result);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mainBadge != null) 
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildBadge(mainBadge),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _result,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.grey.shade900,
                  letterSpacing: 0.2,
                ),
              ),  
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.copy, color: Colors.blue.shade700),
                    tooltip: 'Copy text',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Teks berhasil disalin!'),
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
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.share, color: Colors.green.shade700),
                    tooltip: 'Share result',
                    onPressed: () {
                      // Add share functionality
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('📸 Lookly'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.history, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_loading)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.image_search, size: 24),
                    label: const Text(
                      'Pilih Gambar',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_webImageBytes != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_webImageBytes!, height: 200),
                ),
              )
            else if (_image != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, height: 200),
                ),
              ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator()),
            if (_result.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: _buildResultCard(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
