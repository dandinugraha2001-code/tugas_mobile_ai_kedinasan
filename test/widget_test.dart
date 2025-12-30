import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const SejarahIndonesiaApp());
}

class SejarahIndonesiaApp extends StatelessWidget {
  const SejarahIndonesiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduSejarah AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const ChatSejarahScreen(),
    );
  }
}

class ChatSejarahScreen extends StatefulWidget {
  const ChatSejarahScreen({super.key});

  @override
  State<ChatSejarahScreen> createState() => _ChatSejarahScreenState();
}

class _ChatSejarahScreenState extends State<ChatSejarahScreen> {
  final TextEditingController _controller = TextEditingController();
  String _aiResponse = "Halo! Silakan tanya sejarah Indonesia. Saya akan menjawab dengan singkat dan akurat.";
  bool _isLoading = false;

  // GANTI DENGAN API KEY ANDA
  final String _apiKey = 'AIzaSyAwhU4L5-dP6CKHwKKFHVNuTOKZj4_E8Zg';

  Future<void> _askAi(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResponse = "Sedang mencari jawaban...";
    });

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      
      // INI ADALAH INSTRUKSI KHUSUS DENGAN 30 DATA ANDA
      final prompt = """
      Kamu adalah asisten sejarah Indonesia. Jawablah pertanyaan dengan SANGAT SINGKAT.
      Gunakan data berikut sebagai referensi utama:
      1. Pendiri Majapahit: Raden Wijaya.
      2. Kerajaan Buddha terbesar: Kerajaan Sriwijaya.
      3. Patih Sumpah Palapa: Gajah Mada.
      4. Bangsa Eropa pertama: Bangsa Portugis 1511.
      5. VOC: Vereenigde Oostindische Compagnie.
      6. Pemimpin Perang Diponegoro: Pangeran Diponegoro.
      7. Tanam Paksa: Johannes van den Bosch.
      8. Max Havelaar: Multatuli (Eduard Douwes Dekker).
      9. Ayam Jantan dari Timur: Sultan Hasanuddin.
      10. Perlawanan Maluku: Pattimura.
      11. Budi Utomo: 20 Mei 1908.
      12. Organisasi politik pertama: Indische Partij.
      13. Pendiri Muhammadiyah: K.H. Ahmad Dahlan.
      14. Sumpah Pemuda: 28 Oktober 1928.
      15. Lokasi Sumpah Pemuda: Gedung Indonesische Clubgebouw.
      16. Pencipta Indonesia Raya: Wage Rudolf Supratman.
      17. Tiga Serangkai: Douwes Dekker, Cipto Mangunkusumo, Ki Hajar Dewantara.
      18. Perumus dasar negara: BPUPKI.
      19. Jepang menyerah: 14 Agustus 1945.
      20. Tujuan Rengasdengklok: Mendesak Soekarno-Hatta segera proklamasi.
      21. Lokasi rumusan Proklamasi: Rumah Laksamana Maeda.
      22. Penjahit bendera: Ibu Fatmawati.
      23. Pengetik naskah proklamasi: Sayuti Melik.
      24. Pengesahan Pancasila: 18 Agustus 1945.
      25. Pertempuran 10 November: Surabaya.
      26. Hasil Linggarjati: Belanda akui Jawa, Madura, Sumatra.
      27. KMB: Tahun 1949.
      28. Presiden kedua: Soeharto.
      29. Akhir Orde Baru: Gerakan Reformasi.
      30. Tokoh Mosi Integral: Mohammad Natsir.

      Pertanyaan User: $query
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _aiResponse = response.text ?? "Maaf, jawaban tidak ditemukan.";
      });
    } catch (e) {
      setState(() {
        _aiResponse = "Gagal terhubung. Cek API Key dan Internet.";
      });
    } finally {
      setState(() {
        _isLoading = false;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Sejarah Indonesia AI", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Jawaban:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    const Divider(),
                    if (_isLoading) const LinearProgressIndicator(color: Colors.red),
                    const SizedBox(height: 10),
                    Text(_aiResponse, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pertanyaan sejarah...",
                      filled: true,
                      fillColor: Colors.red.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (val) => _askAi(val),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _askAi(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}