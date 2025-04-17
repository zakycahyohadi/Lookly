import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';
import 'dart:typed_data';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('❌ API Key tidak ditemukan di .env');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    _chat = _model.startChat(history: [
      Content.multi([
        TextPart('''
Halo Gemini! Aku akan mengirimkan sebuah gambar—bisa berupa makanan, kendaraan, tempat, manusia, atau aktivitas.

Tolong deskripsikan gambar ini secara detail dan menarik dalam bahasa Indonesia. Tulis dengan gaya santai, seolah ngobrol, tapi tetap informatif.

Format penjelasan yang aku butuhkan:

1. 🔍 Objek yang Terlihat  
(utama & tambahan)  

2. 🎨 Warna Dominan  
Kesan visual  

3. 👥 Aktivitas/Interaksi  
(jika ada manusia/hewan)  

4. 🌍 Latar Belakang  
Konteks tempat  

5. 🕰️ Waktu/Suasana  
(siang/malam, ramai/sepi)  

6. 🧾 Teks Terlihat  
(jika ada)  

7. 💡 Makna/Fungsi  
Interpretasi gambar  

8. 🧠 Insight Tambahan  
Fun fact terkait tema  

9. 🔎 Rekomendasi  
Eksplorasi lanjutan  

Khusus Kategori:  
- 🍽️ Makanan: Ide kuliner, info gizi, tempat populer  
- 🚗 Kendaraan: Jenis, fitur, budaya otomotif  
- 🏞️ Tempat: Sejarah, lokasi, tips traveling  
- 🎭 Aktivitas: Insight sosial & budaya  

Tolong buat deskripsinya enak dibaca, pakai paragraf pendek atau poin-poin kalau perlu.
'''
        ),
      ]),
      Content.model([
        TextPart('Siap! Kirim gambarnya dan saya akan berikan deskripsi detail dengan format rapi.'),
      ]),
    ]);
  }

  Future<String> describeImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

    try {
      final response = await _chat.sendMessage(
        Content.multi([
          DataPart(mimeType, imageBytes),
        ]),
      );
      String description = response.text ?? '❌ Tidak ada hasil dari Gemini.';
      return _removeAsterisks(description);
    } catch (e) {
      return '❌ Terjadi error: $e';
    }
  }

  Future<String> describeImageWeb(Uint8List imageBytes) async {
    try {
      final response = await _chat.sendMessage(
        Content.multi([
          DataPart('image/jpeg', imageBytes),
        ]),
      );
      String description = response.text ?? '❌ Tidak ada hasil dari Gemini.';
      return _removeAsterisks(description);
    } catch (e) {
      return '❌ Terjadi error: $e';
    }
  }

  String _removeAsterisks(String text) {
    return text.replaceAll('*', '');
  }
}
