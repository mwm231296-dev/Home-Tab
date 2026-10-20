import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import 'form_mahasiswa_page.dart';

class DetailResult {
  final Mahasiswa? mahasiswa;
  const DetailResult.updated(Mahasiswa this.mahasiswa);
  const DetailResult.deleted() : mahasiswa = null;
}

class DetailMahasiswaPage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  final Set<String> nimLain;

  const DetailMahasiswaPage({
    super.key,
    required this.mahasiswa,
    required this.nimLain,
  });

  @override
  State<DetailMahasiswaPage> createState() => _DetailMahasiswaPageState();
}

class _DetailMahasiswaPageState extends State<DetailMahasiswaPage> {
  Future<void> _edit() async {
    final result = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswaPage(
          mahasiswa: widget.mahasiswa,
          nimTerpakai: widget.nimLain,
        ),
      ),
    );
    if (!mounted || result == null) return;
    Navigator.pop(context, DetailResult.updated(result));
  }

  Future<void> _hapus() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus mahasiswa?'),
        content: Text(
          'Data ${widget.mahasiswa.nama} (${widget.mahasiswa.nim}) akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    Navigator.pop(context, const DetailResult.deleted());
  }

  Widget _section(String key, Map<String, String> values, {Widget? header}) {
    return ListView(
      key: PageStorageKey(key),
      padding: const EdgeInsets.all(24),
      children: [
        if (header != null) ...[header, const SizedBox(height: 24)],
        for (final entry in values.entries)
          ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value.isEmpty ? '—' : entry.value),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mahasiswa;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Mahasiswa'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.person_outline), text: 'Data Pribadi'),
              Tab(icon: Icon(Icons.school_outlined), text: 'Akademik'),
              Tab(
                icon: Icon(Icons.location_on_outlined),
                text: 'Kontak & Alamat',
              ),
              Tab(
                icon: Icon(Icons.settings_outlined),
                text: 'Preferensi & Dokumen',
              ),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      _section(
                        'pribadi',
                        {
                          'NIM': m.nim,
                          'Nama Lengkap': m.nama,
                          'Nama Panggilan': m.namaPanggilan,
                          'Jenis Kelamin': m.jenisKelamin,
                          'Tempat Lahir': m.tempatLahir,
                          'Tanggal Lahir': m.tanggalLahir == null
                              ? ''
                              : '${m.tanggalLahir!.day}/${m.tanggalLahir!.month}/${m.tanggalLahir!.year}',
                          'Agama': m.agama,
                        },
                        header: Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(m.warnaProfil),
                            backgroundImage: m.fotoProfil == null
                                ? null
                                : MemoryImage(m.fotoProfil!),
                            child: m.fotoProfil == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),
                      ),
                      _section('akademik', {
                        'Program Studi': m.prodi,
                        'Semester': '${m.semester}',
                        'Kelas': m.kelas,
                        'Status Mahasiswa': m.status,
                        'IPK': m.ipk.toStringAsFixed(2),
                        'Penerima Beasiswa': m.beasiswa ? 'Ya' : 'Tidak',
                        'Bersedia Magang': m.bersediaMagang ? 'Ya' : 'Tidak',
                      }),
                      _section('kontak', {
                        'Email': m.email,
                        'No. HP': m.phone,
                        'Password Portal': m.password.isEmpty ? '' : '••••••••',
                        'Alamat': m.alamat,
                        'Provinsi': m.provinsi,
                        'Kota/Kabupaten': m.kota,
                      }),
                      _section('preferensi', {
                        'Minat': m.minat.join(', '),
                        'Dokumen/KTM': m.namaDokumen ?? '',
                        'Warna Profil':
                            {
                              0xFF2196F3: 'Biru',
                              0xFF4CAF50: 'Hijau',
                              0xFF9C27B0: 'Ungu',
                            }[m.warnaProfil] ??
                            'Lainnya',
                        'Persetujuan Data': m.persetujuan
                            ? 'Setuju'
                            : 'Belum disetujui',
                      }),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _edit,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Data'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _hapus,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Hapus Data'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
