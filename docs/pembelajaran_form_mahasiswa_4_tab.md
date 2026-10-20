# Modul Praktikum Flutter: Form Mahasiswa dengan 4 Tab

Modul ini menjelaskan cara mengubah form panjang berisi 25 field menjadi empat kelompok input. Contoh mengikuti implementasi di proyek `_003_navigasi`, sehingga hasilnya dapat dicoba langsung melalui halaman **Input Mahasiswa**.

**Sasaran:** mahasiswa yang sudah mengenal widget dasar, variabel Dart, fungsi, dan `setState()`.

**Hasil praktikum:** aplikasi dapat menerima data melalui empat tab, menjaga input ketika tab berpindah, memvalidasi seluruh form, lalu mengembalikan satu object `Mahasiswa` ke halaman daftar. Halaman yang sama dapat dipakai untuk mengedit data.

> Contoh menyimpan data dalam memori aplikasi. Menutup atau menjalankan ulang aplikasi akan mengembalikan data awal. Belum ada database, API, atau upload berkas ke server.

## Daftar isi

1. [Pembagian field](#1-pembagian-25-field)
2. [Persiapan proyek](#2-persiapan-proyek)
3. [Memahami tab](#3-memahami-tabbar-tabbarview-dan-tabcontroller)
4. [Model Mahasiswa](#4-model-mahasiswa)
5. [State dan controller](#5-state-dan-controller)
6. [Form untuk setiap tab](#6-form-untuk-setiap-tab)
7. [Data pribadi](#7-tab-data-pribadi)
8. [Akademik](#8-tab-akademik)
9. [Kontak dan alamat](#9-tab-kontak--alamat)
10. [Preferensi dan dokumen](#10-tab-preferensi--dokumen)
11. [Menjaga state](#11-menjaga-input-saat-berpindah-tab)
12. [Validasi dan simpan](#12-validasi-semua-tab-dan-simpan)
13. [Menerima hasil dan edit](#13-menerima-hasil-di-halaman-daftar-dan-mengedit)
14. [Langkah pengujian](#14-langkah-pengujian)
15. [Kesalahan umum](#15-kesalahan-umum-dan-cara-memperbaikinya)
16. [Latihan dan evaluasi](#16-latihan-dan-evaluasi)
17. [Kode lengkap](#17-kode-lengkap-yang-digunakan-proyek)

## 1. Pembagian 25 field

| Tab | Field | Widget | Bentuk data |
| --- | --- | --- | --- |
| Data Pribadi | NIM | TextFormField | String |
| Data Pribadi | Nama Lengkap | TextFormField | String |
| Data Pribadi | Nama Panggilan | TextFormField | String |
| Data Pribadi | Jenis Kelamin | RadioGroup + RadioListTile | String |
| Data Pribadi | Tempat Lahir | TextFormField | String |
| Data Pribadi | Tanggal Lahir | showDatePicker + FormField | DateTime? |
| Data Pribadi | Agama | DropdownButtonFormField | String |
| Data Pribadi | Foto Profil | CircleAvatar + ImagePicker | Uint8List? |
| Akademik | Program Studi | DropdownButtonFormField | String |
| Akademik | Semester | DropdownButtonFormField<int> | int |
| Akademik | Kelas | SegmentedButton | String |
| Akademik | Status Mahasiswa | ChoiceChip | String |
| Akademik | IPK | Slider | double |
| Akademik | Penerima Beasiswa | SwitchListTile | bool |
| Akademik | Bersedia Magang | CheckboxListTile | bool |
| Kontak & Alamat | Email | TextFormField | String |
| Kontak & Alamat | No. HP | TextFormField | String |
| Kontak & Alamat | Password Portal | TextFormField | String |
| Kontak & Alamat | Alamat | TextFormField multiline | String |
| Kontak & Alamat | Provinsi | DropdownButtonFormField | String? |
| Kontak & Alamat | Kota/Kabupaten | DropdownButtonFormField | String? |
| Preferensi & Dokumen | Minat | FilterChip | Set<String> |
| Preferensi & Dokumen | Dokumen/KTM | Button + FilePicker | nama + Uint8List? |
| Preferensi & Dokumen | Warna Profil | Wrap + Container | int |
| Preferensi & Dokumen | Persetujuan Data | CheckboxListTile + FormField | bool |

Total: **8 + 7 + 6 + 4 = 25 field**. Nama dan isi dokumen adalah dua properti untuk satu input dokumen.

NIM dan nomor HP disimpan sebagai `String`: keduanya identitas, bukan angka untuk operasi matematika. Jika nomor `081234567890` dijadikan angka, nol di depan bisa hilang.

## 2. Persiapan proyek

Jalankan perintah dari folder proyek:

```bash
flutter pub get
flutter run
```

Paket pemilih gambar dan berkas sudah tercatat dalam `pubspec.yaml`. Untuk proyek latihan baru, tambahkan:

```bash
flutter pub add image_picker file_picker
```

Kode lengkap di modul ini mengikuti versi yang dipakai proyek: `image_picker` 1.2.4 dan `file_picker` 13.1.0, dengan constraint versi pada `pubspec.yaml`. Khusus `file_picker` dalam proyek ini, pemanggilannya adalah `FilePicker.pickFiles()` dan hasilnya berupa daftar berkas. Jangan mencampurnya dengan contoh versi lain yang menggunakan `FilePicker.platform` atau `result.files`.

Struktur file yang berkaitan:

```text
lib/
├── main.dart
├── models/
│   └── mahasiswa.dart
└── pages/
    ├── form_mahasiswa_page.dart
    ├── list_mahasiswa_page.dart
    ├── detail_mahasiswa_page.dart
    └── student_navigation.dart
```

Import yang diperlukan pada form:

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/mahasiswa.dart';
import 'student_navigation.dart';
```

`Uint8List` menyimpan byte gambar dan dokumen. Ini memungkinkan foto ditampilkan melalui `MemoryImage`, tanpa bergantung pada `dart:io`.

Pada iOS, proyek menambahkan `NSPhotoLibraryUsageDescription` di `ios/Runner/Info.plist` untuk menjelaskan akses galeri. Pada macOS, entitlement `com.apple.security.files.user-selected.read-only` ditambahkan pada konfigurasi Debug/Profile dan Release. Pemilih berkas native perlu dicoba pada perangkat atau platform target; pengujian widget tidak membuka dialog sistem.

## 3. Memahami TabBar, TabBarView, dan TabController

Tiga komponen memiliki tugas berbeda:

| Komponen | Tugas |
| --- | --- |
| `TabBar` | Menampilkan pilihan tab yang dapat ditekan |
| `TabBarView` | Menampilkan isi tab dan mendukung geser horizontal |
| `TabController` | Menyamakan tab terpilih dengan isi yang ditampilkan |

Mulai dari contoh kecil berikut. Contoh ini dapat dijalankan sebagai `main.dart` di proyek latihan terpisah:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ContohTab()));

class ContohTab extends StatelessWidget {
  const ContohTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Mahasiswa'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Pribadi'),
              Tab(icon: Icon(Icons.school), text: 'Akademik'),
              Tab(icon: Icon(Icons.location_on), text: 'Kontak'),
              Tab(icon: Icon(Icons.settings), text: 'Lainnya'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Isi data pribadi')),
            Center(child: Text('Isi data akademik')),
            Center(child: Text('Isi kontak dan alamat')),
            Center(child: Text('Isi preferensi dan dokumen')),
          ],
        ),
      ),
    );
  }
}
```

`length`, jumlah `Tab`, dan jumlah `children` pada `TabBarView` harus sama: semuanya **4**. Urutannya juga harus sesuai. Isi indeks 0 adalah Pribadi, indeks 1 Akademik, dan seterusnya.

`isScrollable: true` memberi ruang untuk label panjang pada layar kecil.

### Mengapa form proyek memakai TabController sendiri?

`DefaultTabController` menyediakan controller secara otomatis. Pada form ini kita perlu berpindah tab melalui kode ketika memvalidasi data, sehingga controller disimpan langsung dalam `State`:

```dart
class _FormMahasiswaPageState extends State<FormMahasiswaPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}
```

`late final` berarti variabel diisi sekali setelah deklarasi. `vsync: this` memakai penyedia ticker dari mixin untuk animasi tab. Controller yang sama diberikan ke `TabBar` dan `TabBarView` melalui `controller: _tabs`.

Potongan ini hanya menunjukkan lifecycle controller; implementasi lengkap juga memiliki controller teks dan variabel data.

## 4. Model Mahasiswa

Model mengelompokkan data menjadi satu object. Tanpa model, halaman daftar harus menerima banyak nilai terpisah yang mudah tertukar.

Contoh pemakaian:

```dart
final mahasiswa = Mahasiswa(
  nim: '2301001',
  nama: 'Ahmad Fauzan',
  prodi: 'TI',
  phone: '081234567890',
  semester: 4,
  ipk: 3.75,
  minat: {'Mobile', 'AI'},
);
```

Empat parameter pertama bertanda `required`. Field lain memiliki nilai awal atau menerima `null` agar data contoh lama tetap dapat digunakan. Ini tidak berarti form boleh melewati validasi field yang diwajibkan; aturan form ditentukan oleh validator.

`final` mencegah properti ditugaskan ulang setelah object dibuat. Untuk koleksi, `final` sendiri belum membuat isi koleksi kebal perubahan. Saat menyimpan, proyek menggunakan `Set.unmodifiable(_minat)` agar daftar minat hasil simpan tidak berubah karena state form dimodifikasi.

Kode model lengkap tersedia pada bagian 17.

## 5. State dan controller

Form memakai `StatefulWidget` karena tampilan berubah ketika pengguna mengetik, memilih chip, mengatur slider, atau mengganti foto.

Ada dua cara menyimpan nilai di form ini:

| Input | Penyimpanan |
| --- | --- |
| NIM, nama, email, HP, password, alamat | TextEditingController |
| Dropdown, radio, chip, slider, checkbox | Variabel pada State |

Contoh controller teks:

```dart
final Map<String, TextEditingController> _text = {};

// Di initState():
_text['NIM'] = TextEditingController(text: widget.mahasiswa?.nim);
_text['Nama Lengkap'] = TextEditingController(text: widget.mahasiswa?.nama);
```

`widget.mahasiswa` berisi data saat edit. Jika sedang menambah, nilainya `null`, sehingga controller dimulai dengan teks kosong.

Contoh state pilihan:

```dart
_gender = m?.jenisKelamin ?? 'Laki-laki';
_semester = m?.semester ?? 1;
_ipk = m?.ipk ?? 0;
_beasiswa = m?.beasiswa ?? false;
_minat = {...?m?.minat};
```

`?.` mengakses properti jika object tidak null. `??` memberi nilai pengganti jika hasil di kiri null. `{...?m?.minat}` membuat set baru dari minat lama, atau set kosong jika data lama tidak ada. Salinan ini mencegah pilihan di form mengubah koleksi milik object lama.

Untuk mengubah input pilihan:

```dart
onChanged: (value) {
  setState(() => _beasiswa = value);
}
```

`setState()` memberi tahu Flutter bahwa tampilan perlu dibangun ulang. Jangan membuat controller di `build()`, karena `build()` dapat berjalan berkali-kali dan input bisa ter-reset.

Selalu lepaskan sumber daya ketika halaman ditutup:

```dart
@override
void dispose() {
  _tabs.dispose();
  for (final controller in _text.values) {
    controller.dispose();
  }
  super.dispose();
}
```

## 6. Form untuk setiap tab

Proyek menggunakan satu `Form` per tab, sehingga terdapat empat key yang berbeda:

```dart
final _keys = List.generate(4, (_) => GlobalKey<FormState>());
```

`_keys[0]` mengakses form Pribadi dan `_keys[3]` mengakses form Preferensi. Jangan memakai satu `GlobalKey` untuk beberapa widget sekaligus.

Helper berikut membungkus isi setiap tab:

```dart
Widget _tab(int i, List<Widget> children) => _KeepTab(
  child: Form(
    key: _keys[i],
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: child,
            ),
        ],
      ),
    ),
  ),
);
```

Penjelasan lapisannya:

1. `_KeepTab` mempertahankan state tab yang sudah dibangun.
2. `Form` mengelompokkan field yang akan divalidasi.
3. `SingleChildScrollView` membuat isi bisa digulir ketika layar pendek atau keyboard muncul.
4. `Column` membangun seluruh field dalam tab tersebut.
5. `Padding` memberi jarak antarkomponen.

Untuk jumlah field yang kecil seperti praktikum ini, `SingleChildScrollView + Column` membantu memastikan validator seluruh field dalam tab terdaftar, termasuk yang berada di bawah layar. List yang membangun anak secara malas bisa belum memasang field yang jauh di luar layar, sehingga validasi hanya berdasarkan widget perlu lebih hati-hati.

Di dalam body, letakkan `TabBarView` dalam `Expanded` jika ia menjadi anak `Column`:

```dart
Column(
  children: [
    Expanded(
      child: TabBarView(
        controller: _tabs,
        children: [
          _tab(0, [/* widget pribadi */]),
          _tab(1, [/* widget akademik */]),
          _tab(2, [/* widget kontak */]),
          _tab(3, [/* widget preferensi */]),
        ],
      ),
    ),
    FilledButton.icon(
      onPressed: _save,
      icon: const Icon(Icons.save_outlined),
      label: const Text('Simpan Data'),
    ),
  ],
)
```

Potongan di atas adalah pola penempatan, bukan file lengkap. `Expanded` memberi batas tinggi pada area tab. Tombol simpan berada di luar isi tab agar tersedia dari tab mana pun.

## 7. Tab Data Pribadi

### 7.1 TextFormField dan validator

```dart
TextFormField(
  controller: _text['NIM'],
  decoration: const InputDecoration(labelText: 'NIM'),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIM tidak boleh kosong';
    }
    if (widget.nimTerpakai.contains(value.trim().toLowerCase())) {
      return 'NIM sudah digunakan';
    }
    return null;
  },
)
```

Validator mengembalikan pesan `String` jika salah, atau `null` jika benar. `trim()` menghapus spasi di awal/akhir. Pemeriksaan NIM menggunakan himpunan NIM yang sudah dipakai dari halaman daftar.

Proyek membungkus pola text field dalam helper `_field()` agar dekorasi dan aturan umum tidak diulang. Contoh:

```dart
_field('NIM'),
_field('Nama Lengkap'),
_field('Nama Panggilan', optional: true),
_field('Tempat Lahir'),
```

Nama panggilan opsional; tiga input lainnya wajib diisi.

### 7.2 Radio untuk satu pilihan

```dart
RadioGroup<String>(
  groupValue: _gender,
  onChanged: (value) => setState(() => _gender = value!),
  child: Column(
    children: [
      for (final gender in ['Laki-laki', 'Perempuan'])
        RadioListTile(value: gender, title: Text(gender)),
    ],
  ),
)
```

Semua radio berada dalam satu `RadioGroup`. Memilih Perempuan menggantikan Laki-laki; keduanya tidak bisa aktif bersamaan. Bentuk radio ini mengikuti Flutter yang digunakan proyek.

### 7.3 Tanggal lahir dan FormField

Date picker menghasilkan `Future<DateTime?>` karena pengguna bisa memilih tanggal atau membatalkan dialog.

```dart
final date = await showDatePicker(
  context: context,
  initialDate: _birth ?? DateTime(2004, 2, 14),
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
);
if (date != null && mounted) {
  setState(() => _birth = date);
}
```

`lastDate` membatasi pilihan sampai hari ini. `mounted` memeriksa halaman masih ada setelah proses asinkron selesai.

Tombol tanggal tidak mempunyai validator bawaan. Karena itu, proyek membungkusnya dengan `FormField<DateTime>`:

```dart
FormField<DateTime>(
  validator: (_) => _birth == null ? 'Tanggal lahir wajib diisi' : null,
  builder: (state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OutlinedButton(
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _birth ?? DateTime(2004, 2, 14),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null && mounted) {
            setState(() => _birth = date);
            state.didChange(date);
          }
        },
        child: Text(_birth == null
            ? 'Pilih Tanggal Lahir'
            : '${_birth!.day}/${_birth!.month}/${_birth!.year}'),
      ),
      if (state.hasError) Text(state.errorText!),
    ],
  ),
)
```

`state.didChange(date)` memperbarui nilai internal `FormField`, sedangkan `_birth` menyimpan tanggal yang akan masuk ke model.

### 7.4 Dropdown agama

```dart
_dropdown(
  'Agama',
  _agama,
  ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'],
  (value) => setState(() => _agama = value!),
)
```

Helper `_dropdown()` menghasilkan `DropdownButtonFormField<String>`. `initialValue` harus cocok dengan salah satu item, atau bernilai null jika belum dipilih.

### 7.5 Foto profil

```dart
final file = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 1000,
  imageQuality: 85,
);
if (file == null) return;
final bytes = await file.readAsBytes();
if (mounted) setState(() => _photo = bytes);
```

Setelah dipilih, tampilkan byte gambar:

```dart
CircleAvatar(
  radius: 40,
  backgroundColor: Color(_color),
  backgroundImage: _photo == null ? null : MemoryImage(_photo!),
  child: _photo == null ? const Icon(Icons.person, size: 40) : null,
)
```

Jika foto belum dipilih, avatar menampilkan ikon orang. Implementasi lengkap membungkus pemilihan dengan `try/catch` untuk menampilkan pesan jika picker gagal. Foto bersifat opsional pada praktikum ini.

## 8. Tab Akademik

Tab ini membandingkan **satu pilihan**, **nilai boolean**, dan **nilai rentang**.

### 8.1 Program studi dan semester

```dart
_dropdown('Program Studi', _prodi, ['TRM', 'TI', 'SI'],
    (value) => setState(() => _prodi = value!)),

DropdownButtonFormField<int>(
  initialValue: _semester,
  decoration: const InputDecoration(labelText: 'Semester'),
  items: List.generate(8, (i) => DropdownMenuItem(
    value: i + 1,
    child: Text('${i + 1}'),
  )),
  onChanged: (value) => setState(() => _semester = value!),
),
```

`List.generate` memakai indeks 0–7. Tambahan `+ 1` menghasilkan semester 1–8. Nilai semester tetap `int`; `Text` menampilkan bentuk string-nya.

Kode lengkap menambahkan prodi dari data lama ke pilihan dropdown bila diperlukan agar data contoh lama tetap dapat diedit.

### 8.2 Kelas dengan SegmentedButton

```dart
SegmentedButton<String>(
  segments: [
    for (final kelas in ['A', 'B', 'C'])
      ButtonSegment(value: kelas, label: Text(kelas)),
  ],
  selected: {_kelas},
  onSelectionChanged: (values) => setState(() => _kelas = values.single),
)
```

API `SegmentedButton` menerima set untuk pilihan aktif. Pada contoh single selection ini, set berisi satu kelas. `values.single` mengambil satu nilai tersebut.

### 8.3 Status dengan ChoiceChip

```dart
Wrap(
  spacing: 8,
  children: [
    for (final status in ['Aktif', 'Cuti', 'Lulus'])
      ChoiceChip(
        label: Text(status),
        selected: _status == status,
        onSelected: (_) => setState(() => _status = status),
      ),
  ],
)
```

Satu variabel `_status` membuat hanya satu chip aktif. `Wrap` memindahkan chip ke baris berikutnya ketika ruang horizontal kurang.

### 8.4 IPK dengan Slider

```dart
Text('IPK: ${_ipk.toStringAsFixed(2)}'),
Slider(
  value: _ipk,
  min: 0,
  max: 4,
  divisions: 400,
  label: _ipk.toStringAsFixed(2),
  onChanged: (value) => setState(() => _ipk = value),
),
```

Rentang 0–4 dibagi menjadi 400 langkah, sehingga satu langkah bernilai 0,01. `toStringAsFixed(2)` menampilkan dua angka di belakang desimal; nilai state tetap bertipe `double`.

### 8.5 Boolean dengan switch dan checkbox

```dart
SwitchListTile(
  title: const Text('Penerima Beasiswa'),
  value: _beasiswa,
  onChanged: (value) => setState(() => _beasiswa = value),
),
CheckboxListTile(
  title: const Text('Bersedia Magang'),
  value: _magang,
  onChanged: (value) => setState(() => _magang = value!),
),
```

Keduanya menyimpan `true` atau `false`. Nilai false tetap jawaban yang sah; tidak semua checkbox harus dicentang. Persetujuan data nanti memiliki aturan berbeda: wajib true.

## 9. Tab Kontak & Alamat

### 9.1 Email, HP, password, dan alamat

```dart
_field('Email', keyboard: TextInputType.emailAddress),
_field('No. HP', keyboard: TextInputType.phone),
_field('Password Portal'),
_field('Alamat', lines: 3),
```

Tipe keyboard membantu pengguna mengetik, tetapi tidak memvalidasi data. Contohnya, keyboard telepon tetap perlu validator nomor HP.

Aturan helper `_field()` pada proyek:

| Field | Aturan |
| --- | --- |
| Email | Wajib dan memenuhi pola email sederhana |
| No. HP | 8–15 digit, boleh diawali `+` |
| Password Portal | Minimal 8 karakter |
| Alamat | Wajib, tampil dalam beberapa baris |

Contoh pola email hanya memeriksa bentuk dasar seperti `nama@kampus.ac.id`; pola ini tidak membuktikan alamat email benar-benar ada.

Password memakai `obscureText` dan tombol mata untuk mengubah visibilitas. Ini hanya menyamarkan tampilan. Pada proyek pembelajaran, password masih berada di object dalam memori; untuk aplikasi akun sungguhan, alur autentikasi perlu dirancang terpisah dan password tidak ditampilkan pada halaman detail atau log.

### 9.2 Dependent dropdown provinsi → kota

Data contoh menggunakan map:

```dart
static const _cities = {
  'Jawa Barat': ['Bogor', 'Bandung', 'Depok', 'Bekasi'],
  'Jawa Tengah': ['Semarang', 'Solo', 'Magelang'],
};
```

Map ini hanya daftar contoh untuk praktikum, bukan daftar wilayah Indonesia yang lengkap.

Ketika provinsi berubah, hapus pilihan kota lama:

```dart
_dropdown('Provinsi', _provinsi, _cities.keys.toList(), (value) {
  setState(() {
    _provinsi = value;
    _kota = null;
  });
}),
```

Dropdown kota:

```dart
DropdownButtonFormField<String>(
  key: ValueKey(_provinsi),
  initialValue: _kota,
  decoration: const InputDecoration(labelText: 'Kota/Kabupaten'),
  hint: Text(_provinsi == null ? 'Pilih provinsi dahulu' : 'Pilih kota/kabupaten'),
  items: (_cities[_provinsi] ?? []).map((kota) => DropdownMenuItem(
    value: kota,
    child: Text(kota),
  )).toList(),
  onChanged: _provinsi == null ? null : (value) {
    setState(() => _kota = value);
  },
  validator: _required,
)
```

Urutan kejadian:

1. Sebelum memilih provinsi, dropdown kota nonaktif karena `onChanged` null.
2. Memilih Jawa Barat membuat item kota berasal dari `_cities['Jawa Barat']`.
3. Pengguna memilih Bogor.
4. Jika provinsi diganti, `_kota = null` menghapus Bogor dari state.
5. `ValueKey(_provinsi)` membuat state dropdown kota diganti saat provinsi berubah, sehingga nilai internal field ikut ter-reset.

Mengganti daftar item saja belum cukup jika nilai lama masih tersimpan. Nilai dropdown harus selalu cocok dengan salah satu item yang tersedia.

## 10. Tab Preferensi & Dokumen

### 10.1 Minat sebagai multi-select

```dart
Wrap(
  spacing: 8,
  children: [
    for (final minat in ['Mobile', 'Web', 'AI', 'UI/UX', 'Data'])
      FilterChip(
        label: Text(minat),
        selected: _minat.contains(minat),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _minat.add(minat);
            } else {
              _minat.remove(minat);
            }
          });
        },
      ),
  ],
)
```

`Set<String>` bisa menyimpan beberapa pilihan tanpa duplikat. Berbeda dari status mahasiswa yang hanya memakai satu `String`, memilih AI tidak menghapus Mobile.

### 10.2 Dokumen/KTM

```dart
final result = await FilePicker.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
);
if (!mounted || result.isEmpty) return;
final file = result.single;
final bytes = await file.readAsBytes();
if (!mounted) return;
setState(() {
  _filename = file.name;
  _document = bytes;
});
```

Jika pengguna membatalkan, daftar hasil kosong dan fungsi berhenti. Nama berkas digunakan pada tampilan; byte berkas masuk ke object. Pemilihan ini belum mengunggah dokumen ke server. Implementasi lengkap menangani error dengan `try/catch`.

Untuk latihan lanjutan, tambahkan batas ukuran sebelum membaca seluruh berkas, karena contoh ini membaca berkas ke memori.

### 10.3 Warna profil

Warna disimpan sebagai bilangan ARGB, misalnya `0xFF2196F3` untuk biru. Bagian `FF` menyatakan opasitas penuh.

```dart
InkWell(
  onTap: () => setState(() => _color = 0xFF2196F3),
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF2196F3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text('Biru', style: TextStyle(color: Colors.white)),
  ),
)
```

Kode lengkap menyusun tiga pilihan dengan `Wrap`, memberi tanda centang pada warna aktif, dan menambahkan `Semantics` agar pilihan mempunyai label dan status terpilih.

### 10.4 Persetujuan data wajib

```dart
FormField<bool>(
  initialValue: _setuju,
  validator: (_) => !_setuju ? 'Persetujuan data wajib dicentang' : null,
  builder: (state) => Column(
    children: [
      CheckboxListTile(
        title: const Text('Saya menyetujui pengolahan data mahasiswa'),
        value: _setuju,
        onChanged: (value) {
          setState(() => _setuju = value!);
          state.didChange(value);
        },
      ),
      if (state.hasError) Text(state.errorText!),
    ],
  ),
)
```

Checkbox biasa tidak otomatis ikut `Form.validate()`. `FormField<bool>` mendaftarkan aturan persetujuan pada form tab terakhir.

## 11. Menjaga input saat berpindah tab

Ada dua lapisan state yang perlu dipahami:

- Nilai utama seperti `_ipk`, `_minat`, dan controller teks berada pada State halaman induk.
- State widget, misalnya pesan error dan posisi scroll, berada pada isi tab.

`TabBarView` dapat membangun anak sesuai kebutuhan. Proyek mempertahankan tab yang sudah dibuat dengan widget berikut:

```dart
class _KeepTab extends StatefulWidget {
  final Widget child;
  const _KeepTab({required this.child});

  @override
  State<_KeepTab> createState() => _KeepTabState();
}

class _KeepTabState extends State<_KeepTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
```

`wantKeepAlive` meminta isi tab dipertahankan. Pemanggilan `super.build(context)` diperlukan oleh mixin. Ini tidak menyimpan data ke disk, dan tidak membuat semua tab langsung dibangun saat halaman pertama dibuka.

Skenario uji sederhana: isi nama, pindah ke Akademik, pilih semester 4, lalu kembali ke Pribadi. Nama harus tetap ada. Kembali ke Akademik dan pastikan semester tetap 4.

## 12. Validasi semua tab dan simpan

### Aturan yang diterapkan

| Kelompok | Ketentuan |
| --- | --- |
| Pribadi | NIM unik dan wajib, nama lengkap wajib, tempat/tanggal lahir wajib |
| Pilihan awal | Gender, agama, prodi, semester, kelas, status, IPK, warna memiliki nilai awal |
| Kontak | Email valid secara bentuk, HP 8–15 digit, password minimal 8 karakter, alamat wajib |
| Wilayah | Provinsi dan kota wajib dipilih |
| Persetujuan | Wajib dicentang |
| Opsional | Nama panggilan, foto, dokumen, dan minat |
| Boolean akademik | Beasiswa dan magang boleh true maupun false |

Validasi tab yang sedang terbuka saja tidak cukup. Pengguna dapat membuka tab terakhir dan langsung menekan Simpan.

Kode proyek mengunjungi setiap tab dan menjalankan validasi berurutan:

```dart
for (var i = 0; i < 4; i++) {
  _tabs.index = i;
  await WidgetsBinding.instance.endOfFrame;
  await WidgetsBinding.instance.endOfFrame;
  if (!mounted) return;
  if (!(_keys[i].currentState?.validate() ?? false)) {
    _message('Lengkapi data pada tab ini.');
    return;
  }
}
```

Penjelasan langkah demi langkah:

1. Ubah tab aktif ke indeks `i`.
2. Tunggu frame agar perpindahan dan pembangunan isi tab diproses. Implementasi proyek menunggu dua frame; tanpa waktu untuk memasang isi tab, key form tujuan bisa belum mempunyai `currentState`.
3. Periksa halaman masih aktif sebelum memakai context atau state setelah `await`.
4. Jalankan `validate()` terhadap form tab itu.
5. Jika form belum tersedia, `?? false` memperlakukan validasi sebagai gagal.
6. Jika ada kesalahan, hentikan proses dan biarkan tab bermasalah terbuka.
7. Jika semua benar, buat object `Mahasiswa` dan kembalikan ke halaman pemanggil.

Konsekuensinya, tab dapat berpindah selama proses simpan. Menunggu frame adalah penanganan lifecycle widget dalam implementasi ini, bukan aturan validasi bisnis. Pada pengembangan lebih lanjut, aturan data dapat dipisahkan ke object draft/validator agar pemeriksaan data tidak tergantung apakah widget tab sudah dibangun.

Contoh inti pembentukan object:

```dart
final hasil = Mahasiswa(
  nim: _value('NIM'),
  nama: _value('Nama Lengkap'),
  prodi: _prodi,
  phone: _value('No. HP'),
  semester: _semester,
  ipk: _ipk,
  minat: Set.unmodifiable(_minat),
  persetujuan: _setuju,
);
Navigator.pop(context, hasil);
```

Potongan ini hanya menampilkan sebagian properti untuk memperjelas alur. `_save()` lengkap pada bagian 17 mengisi seluruh data.

`_value()` mengambil teks controller dan memangkas spasi di tepinya:

```dart
String _value(String name) => _text[name]!.text.trim();
```

Password diambil melalui `.text` langsung pada kode lengkap agar spasi password tidak diam-diam dihapus.

`Navigator.pop(context, hasil)` menutup halaman form dan mengirim hasil kembali. Perintah ini **belum menyimpan ke database**.

## 13. Menerima hasil di halaman daftar dan mengedit

Halaman daftar membuka form dan menunggu hasilnya:

```dart
final result = await Navigator.push<Mahasiswa>(
  context,
  MaterialPageRoute(
    builder: (_) => FormMahasiswaPage(nimTerpakai: _nimTerpakai()),
  ),
);
if (!mounted || result == null) return;
setState(() => _mahasiswa.add(result));
```

`Navigator.push<Mahasiswa>` menyatakan tipe hasil route. Hasil null berarti pengguna kembali tanpa menyimpan. Daftar baru ditambah ketika ada hasil yang valid.

Untuk edit, kirim object lama:

```dart
FormMahasiswaPage(
  mahasiswa: mahasiswaLama,
  nimTerpakai: nimMahasiswaLain,
)
```

Potongan ini memakai nama variabel ilustratif. Dalam proyek, halaman detail mengirim `widget.mahasiswa` dan `widget.nimLain`.

NIM mahasiswa yang sedang diedit harus dikeluarkan dari himpunan NIM terpakai. Jika tidak, menyimpan dengan NIM yang sama akan dianggap duplikat terhadap dirinya sendiri.

Alur proyek:

```text
Daftar → Form tambah → Mahasiswa baru → Tambahkan ke daftar
Daftar → Detail → Form edit → Mahasiswa hasil edit → Ganti data pada daftar
```

Drawer dan bottom navigation menyediakan pintasan ke Daftar dan Input. `TabBar` berfungsi mengubah kelompok input di dalam satu halaman; drawer dan bottom navigation mengubah tujuan halaman aplikasi.

## 14. Langkah pengujian

### Uji manual

| Langkah | Hasil yang diharapkan |
| --- | --- |
| Buka Input Mahasiswa | Ada 4 tab dengan ikon |
| Simpan tanpa mengisi | Tab Pribadi menunjukkan pesan wajib |
| Isi NIM yang sudah ada | Muncul “NIM sudah digunakan” |
| Isi nama lalu pindah tab dan kembali | Nama tetap tersimpan di form |
| Buka Kontak, pilih provinsi lalu kota | Kota mengikuti provinsi |
| Ganti provinsi setelah memilih kota | Pilihan kota lama hilang |
| Masukkan email `abc` | Form menolak email |
| Masukkan HP `123` | Form menolak nomor terlalu pendek |
| Masukkan password 7 karakter | Form menolak password |
| Pilih dua minat | Kedua chip aktif bersamaan |
| Ganti kelas dari A ke B | Hanya B terpilih |
| Simpan tanpa persetujuan | Tab Preferensi menampilkan error |
| Pilih lalu batalkan picker | Form tetap dapat digunakan, pilihan lama tetap ada |
| Lengkapi semua data wajib dan simpan | Mahasiswa muncul di daftar |
| Buka detail lalu edit | Nilai sebelumnya terisi kembali |
| Jalankan ulang aplikasi | Data tambahan hilang karena penyimpanan masih di memori |

Jalankan verifikasi proyek:

```bash
flutter test
flutter analyze
```

Pengujian widget proyek mencakup navigasi, validasi NIM, penyimpanan lintas-tab, dan pengisian kembali saat edit. Dialog galeri dan dokumen perlu diuji manual di platform target. Analyzer proyek masih melaporkan informasi penamaan package `_003_navigasi`; itu terpisah dari logika form.

## 15. Kesalahan umum dan cara memperbaikinya

| Gejala | Penyebab yang perlu diperiksa | Perbaikan |
| --- | --- | --- |
| Jumlah tab memicu assertion | Panjang controller berbeda dari daftar tab/halaman | Samakan semuanya menjadi 4 |
| Input kembali kosong setelah build | Controller dibuat dalam build | Buat controller di initState |
| Beberapa field kosong lolos simpan | Hanya form aktif yang divalidasi atau field belum dibangun | Validasi seluruh tab dan perhatikan lifecycle |
| `currentState` null | Form tujuan belum terpasang | Tunggu pembangunan tab; jangan langsung memakai `!` |
| Checkbox persetujuan tidak menampilkan error | Checkbox belum terhubung ke FormField | Bungkus dengan FormField<bool> |
| Kota lama muncul setelah provinsi berubah | State pilihan lama belum dihapus | Set kota null dan ganti ValueKey provinsi |
| Dropdown gagal saat edit | Nilai awal tidak ada di items | Pastikan item mencakup data lama atau normalisasi nilainya |
| TabBarView mendapat tinggi tak terbatas | Diletakkan dalam Column tanpa batas tinggi | Gunakan Expanded dalam body yang memiliki tinggi terbatas |
| Error setState setelah halaman ditutup | Proses picker selesai setelah navigasi | Periksa mounted setelah await |
| Edit NIM sendiri dianggap duplikat | NIM lama ikut dalam daftar pembanding | Kecualikan mahasiswa yang diedit |
| API picker tidak dikenali | Menyalin contoh untuk versi paket lain | Cocokkan kode dengan dependency proyek |

## 16. Latihan dan evaluasi

Kerjakan bertahap agar setiap konsep dapat dibuktikan:

1. **Dasar:** tampilkan empat tab dengan ikon dan judul, lalu jelaskan hubungan controller dengan TabBarView.
2. **State:** isi nama dan IPK; buktikan keduanya tidak hilang setelah berpindah tab.
3. **Validasi:** tambahkan aturan NIM hanya digit. Jelaskan alasan NIM tetap disimpan sebagai String.
4. **Pilihan:** tambahkan satu minat baru dan jelaskan perbedaan ChoiceChip dengan FilterChip.
5. **Dependensi:** tambahkan provinsi contoh beserta tiga kota; buktikan kota di-reset ketika provinsi berganti.
6. **Aturan bisnis:** wajibkan minimal satu minat dengan FormField<Set<String>> dan validator.
7. **Penyimpanan:** tambahkan ringkasan sebelum simpan yang menampilkan NIM, nama, prodi, dan minat, tanpa menampilkan password.
8. **Lanjutan:** pisahkan data draft dan validasinya dari widget, lalu bandingkan alur simpan dengan implementasi berbasis form key.

Pertanyaan pemahaman:

- Mengapa TextInputType.emailAddress belum cukup untuk memeriksa email?
- Mengapa field tanggal perlu FormField?
- Apa perbedaan null, string kosong, dan false pada data form?
- Mengapa state input disimpan di induk halaman?
- Apa yang dikembalikan Navigator.push ketika pengguna menekan tombol kembali?
- Mengapa foto yang sudah dipilih belum berarti sudah di-upload?

Kriteria praktikum selesai: keempat tab dapat digunakan, input bertahan selama berpindah tab, data wajib yang salah ditolak, kota mengikuti provinsi, dan data valid kembali ke daftar sebagai satu object Mahasiswa.

## 17. Kode lengkap yang digunakan proyek

Bagian ini berisi salinan file proyek pada saat modul dibuat. Potongan di bagian sebelumnya adalah penjelasan terfokus; gunakan kode lengkap di bawah jika ingin melihat letak setiap deklarasi dan method.

Untuk menjalankan di proyek ini, tidak perlu menempel ulang kode. Jalankan `flutter pub get` lalu `flutter run`. Untuk memindahkan ke proyek lain, gunakan ketiga file berikut beserta dependency pada bagian 2, dan buka form melalui `Navigator.push` agar `Navigator.pop` mempunyai halaman pemanggil.

### 17.1 Model data

Sumber: [`lib/models/mahasiswa.dart`](../lib/models/mahasiswa.dart)

```dart
import 'dart:typed_data';

class Mahasiswa {
  final String nim, nama, prodi, phone;
  final String namaPanggilan, jenisKelamin, tempatLahir, agama;
  final DateTime? tanggalLahir;
  final Uint8List? fotoProfil, dokumen;
  final String? namaDokumen;
  final int semester, warnaProfil;
  final String kelas, status, email, password, alamat, provinsi, kota;
  final double ipk;
  final bool beasiswa, bersediaMagang, persetujuan;
  final Set<String> minat;

  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.phone,
    this.namaPanggilan = '',
    this.jenisKelamin = 'Laki-laki',
    this.tempatLahir = '',
    this.agama = 'Islam',
    this.tanggalLahir,
    this.fotoProfil,
    this.dokumen,
    this.namaDokumen,
    this.semester = 1,
    this.warnaProfil = 0xFF2196F3,
    this.kelas = 'A',
    this.status = 'Aktif',
    this.email = '',
    this.password = '',
    this.alamat = '',
    this.provinsi = '',
    this.kota = '',
    this.ipk = 0,
    this.beasiswa = false,
    this.bersediaMagang = false,
    this.persetujuan = false,
    this.minat = const {},
  });
}
```

### 17.2 Navigasi drawer dan bottom navigation

Sumber: [`lib/pages/student_navigation.dart`](../lib/pages/student_navigation.dart)

```dart
import 'package:flutter/material.dart';

class StudentDrawer extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const StudentDrawer({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 48),
                SizedBox(height: 12),
                Text('Manajemen Mahasiswa'),
              ],
            ),
          ),
          for (var i = 0; i < 2; i++)
            ListTile(
              selected: selected == i,
              leading: Icon(
                i == 0 ? Icons.people_outline : Icons.person_add_outlined,
              ),
              title: Text(i == 0 ? 'Daftar Mahasiswa' : 'Input Form Mahasiswa'),
              onTap: () {
                Navigator.pop(context);
                onSelect(i);
              },
            ),
        ],
      ),
    ),
  );
}

class StudentBottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const StudentBottomNav({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selected,
    onDestinationSelected: onSelect,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: 'Daftar Mahasiswa',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_add_outlined),
        selectedIcon: Icon(Icons.person_add),
        label: 'Input Mahasiswa',
      ),
    ],
  );
}
```

### 17.3 Form mahasiswa empat tab

Sumber: [`lib/pages/form_mahasiswa_page.dart`](../lib/pages/form_mahasiswa_page.dart)

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../models/mahasiswa.dart';
import 'student_navigation.dart';

class FormMahasiswaPage extends StatefulWidget {
  final Mahasiswa? mahasiswa;
  final Set<String> nimTerpakai;
  const FormMahasiswaPage({
    super.key,
    this.mahasiswa,
    required this.nimTerpakai,
  });
  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _keys = List.generate(4, (_) => GlobalKey<FormState>());
  final Map<String, TextEditingController> _text = {};
  static const _cities = {
    'Jawa Barat': ['Bogor', 'Bandung', 'Depok', 'Bekasi'],
    'DKI Jakarta': [
      'Jakarta Pusat',
      'Jakarta Selatan',
      'Jakarta Timur',
      'Jakarta Barat',
      'Jakarta Utara',
    ],
    'Jawa Tengah': ['Semarang', 'Solo', 'Magelang'],
    'Jawa Timur': ['Surabaya', 'Malang', 'Kediri'],
    'Banten': ['Tangerang', 'Serang', 'Cilegon'],
  };
  late String _gender, _agama, _prodi, _kelas, _status;
  String? _provinsi, _kota, _filename;
  late int _semester, _color;
  late double _ipk;
  late bool _beasiswa, _magang, _setuju;
  bool _hidePassword = true;
  late Set<String> _minat;
  DateTime? _birth;
  Uint8List? _photo, _document;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    final m = widget.mahasiswa;
    final values = {
      'NIM': m?.nim,
      'Nama Lengkap': m?.nama,
      'Nama Panggilan': m?.namaPanggilan,
      'Tempat Lahir': m?.tempatLahir,
      'Email': m?.email,
      'No. HP': m?.phone,
      'Password Portal': m?.password,
      'Alamat': m?.alamat,
    };
    for (final entry in values.entries) {
      _text[entry.key] = TextEditingController(text: entry.value);
    }
    _gender = m?.jenisKelamin ?? 'Laki-laki';
    _agama = m?.agama ?? 'Islam';
    _prodi = m?.prodi ?? 'TI';
    _kelas = m?.kelas ?? 'A';
    _status = m?.status ?? 'Aktif';
    _semester = m?.semester ?? 1;
    _color = m?.warnaProfil ?? 0xFF2196F3;
    _ipk = m?.ipk ?? 0;
    _beasiswa = m?.beasiswa ?? false;
    _magang = m?.bersediaMagang ?? false;
    _setuju = m?.persetujuan ?? false;
    _minat = {...?m?.minat};
    _birth = m?.tanggalLahir;
    _photo = m?.fotoProfil;
    _document = m?.dokumen;
    _filename = m?.namaDokumen;
    _provinsi = m?.provinsi.isNotEmpty == true ? m!.provinsi : null;
    _kota = m?.kota.isNotEmpty == true ? m!.kota : null;
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _value(String name) => _text[name]!.text.trim();
  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Wajib diisi' : null;
  Widget _field(
    String name, {
    TextInputType? keyboard,
    bool optional = false,
    int lines = 1,
  }) => TextFormField(
    controller: _text[name],
    keyboardType: keyboard,
    maxLines: lines,
    obscureText: name == 'Password Portal' && _hidePassword,
    decoration: InputDecoration(
      labelText: name,
      suffixIcon: name == 'Password Portal'
          ? IconButton(
              tooltip: 'Tampilkan/sembunyikan password',
              icon: Icon(
                _hidePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            )
          : null,
    ),
    validator: (v) {
      if (!optional && _required(v) != null) return '$name tidak boleh kosong';
      if (name == 'NIM' &&
          widget.nimTerpakai.contains(v!.trim().toLowerCase())) {
        return 'NIM sudah digunakan';
      }
      if (name == 'Email' &&
          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v!.trim())) {
        return 'Email tidak valid';
      }
      if (name == 'No. HP' &&
          !RegExp(r'^\+?[0-9]{8,15}$').hasMatch(v!.trim())) {
        return 'Nomor HP harus 8–15 digit';
      }
      if (name == 'Password Portal' && (v?.length ?? 0) < 8) {
        return 'Password minimal 8 karakter';
      }
      return null;
    },
  );
  Widget _dropdown(
    String label,
    String? value,
    List<String> choices,
    ValueChanged<String?> change,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: choices
        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
        .toList(),
    onChanged: change,
    validator: _required,
  );
  Widget _tab(int i, List<Widget> children) => _KeepTab(
    child: Form(
      key: _keys[i],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final child in children)
              Padding(padding: const EdgeInsets.only(bottom: 18), child: child),
          ],
        ),
      ),
    ),
  );
  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _photo = bytes);
    } catch (_) {
      if (mounted) _message('Foto tidak dapat dipilih. Periksa izin galeri.');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (!mounted || result.isEmpty) return;
      final file = result.single;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _filename = file.name;
        _document = bytes;
      });
    } catch (_) {
      if (mounted) _message('Dokumen tidak dapat dipilih. Silakan coba lagi.');
    }
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  Future<void> _save() async {
    // Visit each tab so lazy TabBarView children register every validator.
    for (var i = 0; i < 4; i++) {
      _tabs.index = i;
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      if (!(_keys[i].currentState?.validate() ?? false)) {
        _message('Lengkapi data pada tab ini.');
        return;
      }
    }
    Navigator.pop(
      context,
      Mahasiswa(
        nim: _value('NIM'),
        nama: _value('Nama Lengkap'),
        prodi: _prodi,
        phone: _value('No. HP'),
        namaPanggilan: _value('Nama Panggilan'),
        tempatLahir: _value('Tempat Lahir'),
        jenisKelamin: _gender,
        tanggalLahir: _birth,
        agama: _agama,
        fotoProfil: _photo,
        semester: _semester,
        kelas: _kelas,
        status: _status,
        ipk: _ipk,
        beasiswa: _beasiswa,
        bersediaMagang: _magang,
        email: _value('Email'),
        password: _text['Password Portal']!.text,
        alamat: _value('Alamat'),
        provinsi: _provinsi!,
        kota: _kota!,
        minat: Set.unmodifiable(_minat),
        namaDokumen: _filename,
        dokumen: _document,
        warnaProfil: _color,
        persetujuan: _setuju,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
      ),
      bottom: TabBar(
        controller: _tabs,
        isScrollable: true,
        tabs: const [
          Tab(icon: Icon(Icons.person_outline), text: 'Data Pribadi'),
          Tab(icon: Icon(Icons.school_outlined), text: 'Akademik'),
          Tab(icon: Icon(Icons.location_on_outlined), text: 'Kontak & Alamat'),
          Tab(
            icon: Icon(Icons.settings_outlined),
            text: 'Preferensi & Dokumen',
          ),
        ],
      ),
    ),
    drawer: StudentDrawer(
      selected: 1,
      onSelect: (i) {
        if (i == 0) Navigator.pop(context);
      },
    ),
    bottomNavigationBar: StudentBottomNav(
      selected: 1,
      onSelect: (i) {
        if (i == 0) Navigator.pop(context);
      },
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _tab(0, [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(_color),
                            backgroundImage: _photo == null
                                ? null
                                : MemoryImage(_photo!),
                            child: _photo == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          TextButton.icon(
                            onPressed: _pickPhoto,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Pilih Foto Profil'),
                          ),
                        ],
                      ),
                    ),
                    _field('NIM'),
                    _field('Nama Lengkap'),
                    _field('Nama Panggilan', optional: true),
                    const Text('Jenis Kelamin'),
                    RadioGroup<String>(
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v!),
                      child: Column(
                        children: [
                          for (final gender in ['Laki-laki', 'Perempuan'])
                            RadioListTile(value: gender, title: Text(gender)),
                        ],
                      ),
                    ),
                    _field('Tempat Lahir'),
                    FormField<DateTime>(
                      validator: (_) =>
                          _birth == null ? 'Tanggal lahir wajib diisi' : null,
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month),
                            label: Text(
                              _birth == null
                                  ? 'Pilih Tanggal Lahir'
                                  : '${_birth!.day}/${_birth!.month}/${_birth!.year}',
                            ),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _birth ?? DateTime(2004, 2, 14),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (date != null && mounted) {
                                setState(() => _birth = date);
                                state.didChange(date);
                              }
                            },
                          ),
                          if (state.hasError)
                            Text(
                              state.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _dropdown('Agama', _agama, [
                      'Islam',
                      'Kristen',
                      'Katolik',
                      'Hindu',
                      'Buddha',
                      'Konghucu',
                    ], (v) => setState(() => _agama = v!)),
                  ]),
                  _tab(1, [
                    _dropdown(
                      'Program Studi',
                      _prodi,
                      {
                        ...['TRM', 'TI', 'SI'],
                        _prodi,
                      }.toList(),
                      (v) => setState(() => _prodi = v!),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: _semester,
                      decoration: const InputDecoration(labelText: 'Semester'),
                      items: List.generate(
                        8,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}'),
                        ),
                      ),
                      onChanged: (v) => setState(() => _semester = v!),
                    ),
                    const Text('Kelas'),
                    SegmentedButton<String>(
                      segments: [
                        for (final c in ['A', 'B', 'C'])
                          ButtonSegment(value: c, label: Text(c)),
                      ],
                      selected: {_kelas},
                      onSelectionChanged: (v) =>
                          setState(() => _kelas = v.single),
                    ),
                    const Text('Status Mahasiswa'),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final s in ['Aktif', 'Cuti', 'Lulus'])
                          ChoiceChip(
                            label: Text(s),
                            selected: _status == s,
                            onSelected: (_) => setState(() => _status = s),
                          ),
                      ],
                    ),
                    Text('IPK: ${_ipk.toStringAsFixed(2)}'),
                    Slider(
                      value: _ipk,
                      min: 0,
                      max: 4,
                      divisions: 400,
                      label: _ipk.toStringAsFixed(2),
                      onChanged: (v) => setState(() => _ipk = v),
                    ),
                    SwitchListTile(
                      title: const Text('Penerima Beasiswa'),
                      value: _beasiswa,
                      onChanged: (v) => setState(() => _beasiswa = v),
                    ),
                    CheckboxListTile(
                      title: const Text('Bersedia Magang'),
                      value: _magang,
                      onChanged: (v) => setState(() => _magang = v!),
                    ),
                  ]),
                  _tab(2, [
                    _field('Email', keyboard: TextInputType.emailAddress),
                    _field('No. HP', keyboard: TextInputType.phone),
                    _field('Password Portal'),
                    _field('Alamat', lines: 3),
                    _dropdown(
                      'Provinsi',
                      _provinsi,
                      _cities.keys.toList(),
                      (v) => setState(() {
                        _provinsi = v;
                        _kota = null;
                      }),
                    ),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_provinsi),
                      initialValue: _kota,
                      decoration: const InputDecoration(
                        labelText: 'Kota/Kabupaten',
                      ),
                      hint: Text(
                        _provinsi == null
                            ? 'Pilih provinsi dahulu'
                            : 'Pilih kota/kabupaten',
                      ),
                      items: (_cities[_provinsi] ?? [])
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: _provinsi == null
                          ? null
                          : (v) => setState(() => _kota = v),
                      validator: _required,
                    ),
                  ]),
                  _tab(3, [
                    const Text('Minat'),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final m in [
                          'Mobile',
                          'Web',
                          'AI',
                          'UI/UX',
                          'Data',
                        ])
                          FilterChip(
                            label: Text(m),
                            selected: _minat.contains(m),
                            onSelected: (v) => setState(() {
                              v ? _minat.add(m) : _minat.remove(m);
                            }),
                          ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Pilih Dokumen/KTM'),
                    ),
                    if (_filename != null) Text(_filename!),
                    const Text('Warna Profil'),
                    Wrap(
                      spacing: 12,
                      children: [
                        for (final entry in {
                          'Biru': 0xFF2196F3,
                          'Hijau': 0xFF4CAF50,
                          'Ungu': 0xFF9C27B0,
                        }.entries)
                          Semantics(
                            button: true,
                            selected: _color == entry.value,
                            label: entry.key,
                            child: InkWell(
                              onTap: () => setState(() => _color = entry.value),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(entry.value),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_color == entry.value)
                                      const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    FormField<bool>(
                      initialValue: _setuju,
                      validator: (_) =>
                          !_setuju ? 'Persetujuan data wajib dicentang' : null,
                      builder: (state) => Column(
                        children: [
                          CheckboxListTile(
                            title: const Text(
                              'Saya menyetujui pengolahan data mahasiswa',
                            ),
                            value: _setuju,
                            onChanged: (v) {
                              setState(() => _setuju = v!);
                              state.didChange(v);
                            },
                          ),
                          if (state.hasError)
                            Text(
                              state.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Data'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _KeepTab extends StatefulWidget {
  final Widget child;
  const _KeepTab({required this.child});
  @override
  State<_KeepTab> createState() => _KeepTabState();
}

class _KeepTabState extends State<_KeepTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
```

## Referensi dalam proyek

- [Halaman daftar](../lib/pages/list_mahasiswa_page.dart): menerima hasil tambah dan memperbarui data.
- [Halaman detail](../lib/pages/detail_mahasiswa_page.dart): menampilkan data dalam empat tab dan membuka form edit.
- [Pengujian widget](../test/widget_test.dart): contoh menjalankan interaksi melalui WidgetTester.
- [Dependency proyek](../pubspec.yaml): konfigurasi Flutter dan paket yang digunakan.
