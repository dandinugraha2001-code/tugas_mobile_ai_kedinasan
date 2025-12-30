import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F4FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  String _response = "Silakan tanya sejarah Indonesia.";
  bool _loading = false;
  String? _modelName;

  // ============================
  // LOAD MODEL (TIDAK DIUBAH)
  // ============================
  Future<void> _loadValidModel(String apiKey) async {
    final uri = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey",
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil daftar model: ${res.body}");
    }

    final data = jsonDecode(res.body);
    final models = data["models"] as List<dynamic>;

    for (final m in models) {
      final methods = (m["supportedGenerationMethods"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      if (methods.contains("generateContent")) {
        _modelName = m["name"];
        break;
      }
    }

    if (_modelName == null) {
      throw Exception("Tidak ada model yang mendukung generateContent.");
    }
  }

  // ============================
  // ASK AI (TIDAK DIUBAH)
  // ============================
  Future<void> _askAI(String question) async {
    if (question.trim().isEmpty) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _response = "❌ API Key tidak ditemukan di .env";
      });
      return;
    }

    setState(() {
      _loading = true;
      _response = "⏳ AI sedang berpikir...";
    });

    try {
      _modelName ??= (await () async {
        await _loadValidModel(apiKey);
        return _modelName!;
      }());

      final uri = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/$_modelName:generateContent?key=$apiKey",
      );

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Kamu adalah pakar sejarah Indonesia. Jawab dengan jelas:\n$question"
                }
              ]
            }
          ]
        }),
      );

      if (res.statusCode != 200) {
        throw Exception("API Error ${res.statusCode}: ${res.body}");
      }

      final data = jsonDecode(res.body);
      setState(() {
        _response =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
                "⚠️ Tidak ada jawaban dari AI.";
      });
    } catch (e) {
      setState(() {
        _response = "❌ Error: $e";
      });
    } finally {
      setState(() {
        _loading = false;
        _controller.clear();
      });
    }
  }

  // ============================
  // UI DENGAN AVATAR AI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pakar Sejarah AI"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // CHAT AI
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AVATAR AI
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF8F88FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // CHAT BUBBLE AI
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _response,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(minHeight: 3),
            ),

          // INPUT
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Tanyakan sejarah Indonesia...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: _askAI,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF6C63FF),
                    ),
                    onPressed: () => _askAI(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
