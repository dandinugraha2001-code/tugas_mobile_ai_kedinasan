import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kedinav_ai/main.dart'; // Pastikan nama package sesuai dengan pubspec.yaml Anda

void main() {
  testWidgets('KediNav AI Smoke Test', (WidgetTester tester) async {
    // Mock loading .env agar test tidak error karena file tidak ditemukan
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=test_key');

    // Membangun aplikasi
    await tester.pumpWidget(const KediNavApp());

    // 1. Memastikan judul AppBar muncul
    expect(find.text('KediNav AI Consultant'), findsOneWidget);

    // 2. Memastikan pesan sambutan awal muncul
    expect(find.text('Silakan tanya seputar info kedinasan (STAN, IPDN, STIS, dll)'), findsOneWidget);

    // 3. Mencoba mengetik di TextField
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    
    await tester.enterText(textField, 'Syarat masuk STAN');
    expect(find.text('Syarat masuk STAN'), findsOneWidget);

    // 4. Memastikan tombol kirim ada
    expect(find.byIcon(Icons.send), findsOneWidget);
    
    // Tap tombol send
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(); // Memberi waktu frame untuk update
  });
}