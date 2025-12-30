import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  // Wajib untuk inisialisasi plugin sebelum app running
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Memuat file .env
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Peringatan: File .env tidak ditemukan atau gagal dimuat.");
  }
  
  runApp(const KediNavApp());
}

class KediNavApp extends StatelessWidget {
  const KediNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KediNav AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ChatAiScreen(),
    );
  }
}

class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Mengambil API Key dari .env
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    // Validasi API Key sederhana
    if (_apiKey.isEmpty || _apiKey == "ISI_API_KEY_DISINI") {
      _showError("API Key Gemini belum diatur di file .env");
      return;
    }

    String userPrompt = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userPrompt});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final content = [
        Content.text("Kamu adalah asisten ahli sekolah kedinasan Indonesia. Jawab pertanyaan ini: $userPrompt")
      ];
      
      final response = await model.generateContent(content);
      
      setState(() {
        _messages.add({
          "role": "ai", 
          "text": response.text ?? "Maaf, asisten AI tidak memberikan respon."
        });
      });
    } catch (e) {
      _showError("Gagal terhubung ke AI. Cek koneksi internet.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul disesuaikan dengan pencarian di widget_test.dart
        title: const Text("KediNav AI Consultant", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.indigo,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty 
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    // TEKS INI WAJIB SAMA PERSIS DENGAN YANG ADA DI TEST
                    child: Text(
                      "Silakan tanya seputar info kedinasan (STAN, IPDN, STIS, dll)",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    bool isUser = msg["role"] == "user";
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.indigo[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75
                        ),
                        child: Text(msg["text"]!),
                      ),
                    );
                  },
                ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          // Input Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Tanya syarat STAN / IPDN...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}