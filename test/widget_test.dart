import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_003_navigasi/main.dart';
import 'package:_003_navigasi/pages/form_mahasiswa_page.dart';

void main() {
  testWidgets('Drawer dan bottom nav menghubungkan daftar dan form', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('3 dari 3 mahasiswa'), findsOneWidget);
    await tester.tap(find.text('Input Mahasiswa'));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(Tab), findsNWidgets(4));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'NIM'),
      '2301001',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Akademik'));
    await tester.pumpAndSettle();
    expect(find.text('Program Studi'), findsOneWidget);
    await tester.tap(find.text('Data Pribadi'));
    await tester.pumpAndSettle();
    expect(find.text('2301001'), findsOneWidget);
    await tester.tap(find.text('Daftar Mahasiswa'));
    await tester.pumpAndSettle();
    expect(find.text('3 dari 3 mahasiswa'), findsOneWidget);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Input Form Mahasiswa'));
    await tester.pumpAndSettle();
    expect(find.byType(FormMahasiswaPage), findsOneWidget);
  });

  testWidgets('Validasi kosong dan NIM duplikat', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Input Mahasiswa'));
    await tester.pumpAndSettle();
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Data'));
    await tester.pumpAndSettle();
    expect(find.text('NIM tidak boleh kosong'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'NIM'),
      '2026001',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Data'));
    await tester.pumpAndSettle();
    expect(find.text('NIM sudah digunakan'), findsOneWidget);
  });

  testWidgets('Simpan seluruh tab menjadi mahasiswa dan edit data', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Input Mahasiswa'));
    await tester.pumpAndSettle();
    Future<void> fill(String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
    }

    await fill('NIM', '2301001');
    await fill('Nama Lengkap', 'Dewi Lestari');
    await fill('Tempat Lahir', 'Bogor');
    await tester.ensureVisible(find.text('Pilih Tanggal Lahir'));
    await tester.tap(find.text('Pilih Tanggal Lahir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kontak & Alamat'));
    await tester.pumpAndSettle();
    await fill('Email', 'dewi@kampus.ac.id');
    await fill('No. HP', '081234567890');
    await fill('Password Portal', 'password123');
    await fill('Alamat', 'Jl. Bogor 10');
    await tester.ensureVisible(find.text('Provinsi'));
    await tester.tap(find.text('Provinsi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jawa Barat').last);
    await tester.pumpAndSettle();
    final city = find.byType(DropdownButtonFormField<String>).last;
    await tester.ensureVisible(city);
    await tester.tap(city);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bogor').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preferensi & Dokumen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile'));
    await tester.ensureVisible(
      find.text('Saya menyetujui pengolahan data mahasiswa'),
    );
    await tester.tap(find.text('Saya menyetujui pengolahan data mahasiswa'));
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Data'));
    await tester.pumpAndSettle();
    expect(find.text('Dewi Lestari'), findsOneWidget);
    await tester.tap(find.text('Dewi Lestari'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Data'));
    await tester.pumpAndSettle();
    expect(find.text('2301001'), findsOneWidget);
    await tester.tap(find.text('Preferensi & Dokumen'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Mobile'))
          .selected,
      isTrue,
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Data'));
    await tester.pumpAndSettle();
    expect(find.text('Dewi Lestari'), findsOneWidget);
  });
}
