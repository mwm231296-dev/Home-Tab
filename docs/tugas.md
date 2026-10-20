# Tugas: Profil Mahasiswa dan Widget Input Flutter

Untuk profil mahasiswa yang lebih lengkap, form-nya sebaiknya sengaja dibuat sebagai showcase berbagai jenis input widget Flutter, bukan hanya TextFormField.

## Field Profil Mahasiswa

Saya sarankan profil mahasiswa mencakup sekitar 20–25 field berikut:

| Field             | Contoh/Pilihan                                   | Widget Flutter                                 |
| ----------------- | ------------------------------------------------ | ---------------------------------------------- |
| NIM               | 2301001                                          | `TextFormField`                                |
| Nama Lengkap      | Ahmad Fauzan                                     | `TextFormField`                                |
| Nama Panggilan    | Fauzan                                           | `TextFormField`                                |
| Email             | mahasiswa@kampus.ac.id                           | `TextFormField` + `TextInputType.emailAddress` |
| No. HP            | 081234567890                                     | `TextFormField` + `TextInputType.phone`        |
| Password Portal   | ••••••••                                         | `TextFormField` + `obscureText`                |
| Jenis Kelamin     | Laki-laki / Perempuan                            | `Radio` / `RadioListTile`                      |
| Tanggal Lahir     | Date picker                                      | `showDatePicker()`                             |
| Tempat Lahir      | Bogor                                            | `TextFormField`                                |
| Agama             | Islam, Kristen, Katolik, Hindu, Buddha, Konghucu | `DropdownButtonFormField`                      |
| Program Studi     | TRM, TI, SI, dll.                                | `DropdownButtonFormField`                      |
| Semester          | 1–8                                              | `DropdownButtonFormField<int>`                 |
| Kelas             | A / B / C                                        | `SegmentedButton`                              |
| Status Mahasiswa  | Aktif / Cuti / Lulus                             | `ChoiceChip`                                   |
| IPK               | 0.00–4.00                                        | `Slider`                                       |
| Penerima Beasiswa | Ya/Tidak                                         | `SwitchListTile`                               |
| Bersedia Magang   | Ya/Tidak                                         | `CheckboxListTile`                             |
| Minat             | Mobile, Web, AI, UI/UX, Data                     | `FilterChip` multi-select                      |
| Alamat            | Alamat lengkap                                   | multiline `TextFormField`                      |
| Provinsi          | Jawa Barat, dll.                                 | `DropdownButtonFormField`                      |
| Kota/Kabupaten    | Bogor, Depok, dll.                               | `DropdownButtonFormField`                      |
| Foto Profil       | Pilih foto                                       | `CircleAvatar` + `ImagePicker`                 |
| Dokumen/KTM       | Pilih file                                       | button + file picker                           |
| Warna Profil      | Pilihan warna                                    | custom `Wrap` + selectable container           |
| Persetujuan Data  | Setuju/tidak                                     | `Checkbox`                                     |

## Widget yang Dipelajari

Dengan begitu mahasiswa tidak hanya belajar navigasi, tetapi sekaligus mengenal `Form`, `TextFormField`, `DropdownButtonFormField`, `RadioListTile`, `CheckboxListTile`, `SwitchListTile`, `Slider`, `ChoiceChip`, `FilterChip`, `SegmentedButton`, `showDatePicker`, `CircleAvatar`, `ListView`, `Card`, `Wrap`, `Row`, `Column`, `Expanded`, `Padding`, `SizedBox`, `FilledButton`, `IconButton`, `SnackBar`, `AlertDialog`, dan widget layout lainnya.
