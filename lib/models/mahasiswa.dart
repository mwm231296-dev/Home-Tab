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
