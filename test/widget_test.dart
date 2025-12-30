import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_ai/main.dart'; 

void main() {
  // Fungsi untuk menyiapkan lingkungan testing
  setUpAll(() async {
    // Memberikan nilai default palsu agar dotenv tidak error saat testing
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=test_key');
  });

  testWidgets('Memastikan UI Info Kedinasan muncul dengan benar', (WidgetTester tester) async {
    // 1. Jalankan aplikasi
    await tester.pumpWidget(const InfoKedinasanApp());

    // 2. Verifikasi judul di AppBar sesuai main.dart terbaru
    expect(find.text('Info Kedinasan AI'), findsOneWidget);

    // 3. Verifikasi bahwa TextField tersedia
    expect(find.byType(TextField), findsOneWidget);

    // 4. Verifikasi tombol kirim (Icons.send_rounded)
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });

  testWidgets('Simulasi mengetik pertanyaan kedinasan', (WidgetTester tester) async {
    await tester.pumpWidget(const InfoKedinasanApp());

    // Ketik pertanyaan
    await tester.enterText(find.byType(TextField), 'Apa syarat masuk STAN?');
    
    // Pastikan teks muncul di layar
    expect(find.text('Apa syarat masuk STAN?'), findsOneWidget);
    
    // Simulasi tekan tombol kirim
    await tester.tap(find.byIcon(Icons.send_rounded));
    
    // Rebuild UI setelah aksi
    await tester.pump();
  });
}