import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../widgets/kontrol_widgets.dart';
import 'pot_selection_page.dart';
import '../services/kontrol_storage.dart';

class KontrolPage extends StatefulWidget {
  const KontrolPage({super.key});

  @override
  State<KontrolPage> createState() => _KontrolPageState();
}

class _KontrolPageState extends State<KontrolPage> {
  String _selectedMode = 'Manual';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Di halaman kontrol, biarkan navigasi normal (kembali 1 tahap)
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kontrol',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textDark,
                  ),
                ),
                const SizedBox(height: 20),

                // Mode Kontrol Selection
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
                      isSelected: _selectedMode == 'Manual',
                      onPressed: () {
                        setState(() {
                          _selectedMode = 'Manual';
                        });
                      },
                    ),
                    ModeButton(
                      mode: 'Waktu',
                      isSelected: _selectedMode == 'Waktu',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const PotSelectionPage(mode: 'Waktu'),
                          ),
                        );
                      },
                    ),
                    ModeButton(
                      mode: 'Sensor',
                      isSelected: _selectedMode == 'Sensor',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const PotSelectionPage(mode: 'Sensor'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Expanded(child: ManualControlPage()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Manual Control Page
class ManualControlPage extends StatefulWidget {
  const ManualControlPage({super.key});

  @override
  State<ManualControlPage> createState() => _ManualControlPageState();
}

class _ManualControlPageState extends State<ManualControlPage> {
  bool _pompaAir = false;
  bool _pompaNutrisi = false;

  // POT switches (5 POTs now)
  List<bool> _potStatus = [false, false, false, false, false];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final data = await KontrolStorage.loadManualControl();
    setState(() {
      _pompaAir = data['pompaAir'];
      _pompaNutrisi = data['pompaNutrisi'];
      _potStatus = data['pots'];
      _isLoading = false;
    });
  }

  Future<void> _jalankan() async {
    // Save state
    await KontrolStorage.saveManualControl(
      pompaAir: _pompaAir,
      pompaNutrisi: _pompaNutrisi,
      pots: _potStatus,
    );

    // Show which devices are running
    List<String> activeDevices = [];
    if (_pompaAir) activeDevices.add('Pompa Air');
    if (_pompaNutrisi) activeDevices.add('Pompa Nutrisi');
    for (int i = 0; i < _potStatus.length; i++) {
      if (_potStatus[i]) activeDevices.add('POT ${i + 1}');
    }

    if (activeDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada perangkat yang diaktifkan'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menjalankan: ${activeDevices.join(', ')}'),
          backgroundColor: AppColor.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pompa Controls
          ControlSwitchCard(
            title: 'Pompa Air',
            isActive: _pompaAir,
            onPressed: () {
              setState(() {
                _pompaAir = !_pompaAir;
              });
            },
          ),
          ControlSwitchCard(
            title: 'Pompa Nutrisi',
            isActive: _pompaNutrisi,
            onPressed: () {
              setState(() {
                _pompaNutrisi = !_pompaNutrisi;
              });
            },
          ),

          const SizedBox(height: 16),

          // POT Controls Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kontrol POT (Kran)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // POT switches (5 POTs)
          ...List.generate(5, (index) {
            return ControlSwitchCard(
              title: 'POT ${index + 1}',
              isActive: _potStatus[index],
              onPressed: () {
                setState(() {
                  _potStatus[index] = !_potStatus[index];
                });
              },
            );
          }),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _jalankan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Jalankan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
