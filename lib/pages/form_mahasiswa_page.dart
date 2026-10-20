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
