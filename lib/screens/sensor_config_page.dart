import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../widgets/kontrol_widgets.dart';
import '../services/kontrol_storage.dart';

class SensorConfigPage extends StatefulWidget {
  final String potName;
  final String selectedMode;

  const SensorConfigPage({
    super.key,
    required this.potName,
    this.selectedMode = 'Sensor',
  });

  @override
  State<SensorConfigPage> createState() => _SensorConfigPageState();
}

class _SensorConfigPageState extends State<SensorConfigPage> {
  bool _isSaved = false;
  bool _isLoading = true;

  // Konfigurasi sensor untuk pot ini
  Map<String, dynamic> _sensorConfig = {
    'batasMinimal': '30',
    'batasMaksimal': '80',
    'durasi': '10',
    'durasiUnit': 'menit',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final loadedData = await KontrolStorage.loadSensorConfig(widget.potName);

    // Convert old format to new format if needed for durasi
    if (loadedData['durasi'] is String) {
      final durasiStr = loadedData['durasi'] as String;
      // Check if it contains unit (e.g., "10 menit")
      if (durasiStr.contains(' ')) {
        final parts = durasiStr.split(' ');
        loadedData['durasi'] = parts[0]; // Extract number
        loadedData['durasiUnit'] =
            parts.length > 1 ? parts[1] : 'menit'; // Extract unit
      } else {
        // If no unit, ensure durasiUnit exists
        loadedData['durasiUnit'] = loadedData['durasiUnit'] ?? 'menit';
      }
    }

    setState(() {
      _sensorConfig = loadedData;
      _isLoading = false;
      // Check if data was previously saved
      _isSaved =
          loadedData['batasMinimal'] != '30' ||
          loadedData['batasMaksimal'] != '80';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Biarkan navigasi normal (kembali ke pot selection)
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColor.background,
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          title: const Text('Kontrol'),
          centerTitle: true,
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mode Kontrol Selection (persistent)
                        Text(
                          'Mode Kontrol',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ModeButton(
                              mode: 'Manual',
                              isSelected: widget.selectedMode == 'Manual',
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              },
                            ),
                            ModeButton(
                              mode: 'Waktu',
                              isSelected: widget.selectedMode == 'Waktu',
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Will navigate to waktu mode from pot selection
                              },
                            ),
                            ModeButton(
                              mode: 'Sensor',
                              isSelected: widget.selectedMode == 'Sensor',
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Konfigurasi ${widget.potName}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildSensorConfigCard(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Button Salin ke Semua POT
                        OutlinedButton.icon(
                          onPressed: _copyToAllPots,
                          icon: const Icon(Icons.content_copy),
                          label: const Text('Salin ke Semua POT'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.primary,
                            side: BorderSide(color: AppColor.primary),
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleSaveOrUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _isSaved ? 'Update' : 'Simpan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildSensorConfigCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Sensor Kelembaban',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Batas Minimal
          _buildEditableField(
            label: 'Batas Minimal (%)',
            value: _sensorConfig['batasMinimal']!,
            onTap: () => _editField('batasMinimal', 'Batas Minimal'),
            icon: Icons.arrow_downward,
          ),

          const SizedBox(height: 16),

          // Batas Maksimal
          _buildEditableField(
            label: 'Batas Maksimal (%)',
            value: _sensorConfig['batasMaksimal']!,
            onTap: () => _editField('batasMaksimal', 'Batas Maksimal'),
            icon: Icons.arrow_upward,
          ),

          const SizedBox(height: 16),

          // Durasi Penyiraman
          _buildEditableField(
            label: 'Durasi Penyiraman',
            value:
                '${_sensorConfig['durasi']} ${_sensorConfig['durasiUnit'] ?? 'menit'}',
            onTap: () => _editDurationField(),
            icon: Icons.timer,
          ),

          const SizedBox(height: 20),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColor.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pompa akan aktif otomatis jika kelembaban di bawah batas minimal',
                    style: TextStyle(fontSize: 12, color: AppColor.textDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColor.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: AppColor.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _editField(String field, String fieldName) async {
    final TextEditingController controller = TextEditingController(
      text: _sensorConfig[field],
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ubah $fieldName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Masukkan nilai',
              border: OutlineInputBorder(),
              suffixText: '%',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _sensorConfig[field] = result;
      });
    }
  }

  Future<void> _editDurationField() async {
    final TextEditingController controller = TextEditingController(
      text: _sensorConfig['durasi'].toString(),
    );
    String selectedUnit = _sensorConfig['durasiUnit'] ?? 'menit';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ubah Durasi Penyiraman'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan durasi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Detik'),
                          value: 'detik',
                          groupValue: selectedUnit,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedUnit = value!;
                            });
                          },
                          activeColor: AppColor.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Menit'),
                          value: 'menit',
                          groupValue: selectedUnit,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedUnit = value!;
                            });
                          },
                          activeColor: AppColor.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'durasi': controller.text,
                      'unit': selectedUnit,
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null &&
        result['durasi'] != null &&
        result['durasi'].isNotEmpty) {
      setState(() {
        _sensorConfig['durasi'] = result['durasi'];
        _sensorConfig['durasiUnit'] = result['unit'];
      });
    }
  }

  Future<void> _handleSaveOrUpdate() async {
    // Save to storage
    await KontrolStorage.saveSensorConfig(widget.potName, _sensorConfig);

    setState(() {
      _isSaved = true;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Konfigurasi ${widget.potName} berhasil ${_isSaved ? 'diupdate' : 'disimpan'}',
        ),
        backgroundColor: AppColor.primary,
      ),
    );
  }

  Future<void> _copyToAllPots() async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: Text(
              'Salin konfigurasi ${widget.potName} ke semua POT (1-5)?\\n\\nSemua POT akan memiliki konfigurasi yang sama.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salin'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Copy to all pots
    for (int i = 1; i <= 5; i++) {
      await KontrolStorage.saveSensorConfig('POT $i', _sensorConfig);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Konfigurasi berhasil disalin ke semua POT'),
        backgroundColor: AppColor.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
