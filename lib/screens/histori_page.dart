import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../services/firebase_database_service.dart';
import '../services/history_logging_service.dart';

class HistoriPage extends StatefulWidget {
  const HistoriPage({super.key});

  @override
  State<HistoriPage> createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage> {
  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();
  final HistoryLoggingService _loggingService = HistoryLoggingService();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPot = 'Semua Pot';
  bool _isLoading = false;

  Map<String, double> _averages = {};
  Map<String, Map<String, double>> _potAverages = {};

  final List<String> _potOptions = [
    'Semua Pot',
    'Pot 1',
    'Pot 2',
    'Pot 3',
    'Pot 4',
    'Pot 5',
  ];

  @override
  void initState() {
    super.initState();
    // Start logging service if not already running
    if (!_loggingService.isActive) {
      _loggingService.start();
    }
    // Load initial data (last 7 days)
    _loadDefaultData();
  }

  Future<void> _loadDefaultData() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));

    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });

    await _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    if (_startDate == null || _endDate == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _dbService.getHistoryByDateRange(
        _startDate!,
        _endDate!,
      );

      if (data.isEmpty) {
        // No history yet, use current data
        final currentData = await _dbService.getSensorData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Belum ada data histori. Menampilkan data saat ini.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _calculateAveragesFromCurrent(currentData);
      } else {
        _calculateAverages(data);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _calculateAverages(Map<String, dynamic> historyData) {
    double totalTemp = 0;
    double totalHumidity = 0;
    double totalLdr = 0;
    Map<int, double> totalSoil = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    int count = 0;
    Map<int, int> soilCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    historyData.forEach((dateKey, dateData) {
      if (dateData is Map) {
        dateData.forEach((timeKey, timeData) {
          if (timeData is Map) {
            count++;

            totalTemp +=
                double.tryParse(timeData['suhu']?.toString() ?? '0') ?? 0;
            totalHumidity +=
                double.tryParse(timeData['kelembapan']?.toString() ?? '0') ?? 0;
            totalLdr +=
                double.tryParse(timeData['ldr']?.toString() ?? '0') ?? 0;

            for (int i = 1; i <= 5; i++) {
              final soil =
                  double.tryParse(timeData['soil_$i']?.toString() ?? '0') ?? 0;
              if (soil > 0) {
                totalSoil[i] = (totalSoil[i] ?? 0) + soil;
                soilCount[i] = (soilCount[i] ?? 0) + 1;
              }
            }
          }
        });
      }
    });

    if (count > 0) {
      _averages = {
        'temp': totalTemp / count,
        'humidity': totalHumidity / count,
        'ldr': totalLdr / count,
      };

      _potAverages = {};
      for (int i = 1; i <= 5; i++) {
        final potCount = soilCount[i] ?? 0;
        _potAverages['Pot $i'] = {
          'temp': totalTemp / count,
          'humidity': totalHumidity / count,
          'soil': potCount > 0 ? (totalSoil[i] ?? 0) / potCount : 0,
          'light': totalLdr / count,
        };
      }
    }
  }

  void _calculateAveragesFromCurrent(Map<String, dynamic> currentData) {
    _averages = {
      'temp': double.tryParse(currentData['suhu']?.toString() ?? '0') ?? 0,
      'humidity':
          double.tryParse(currentData['kelembapan']?.toString() ?? '0') ?? 0,
      'ldr': double.tryParse(currentData['ldr']?.toString() ?? '0') ?? 0,
    };

    _potAverages = {};
    for (int i = 1; i <= 5; i++) {
      final soil =
          double.tryParse(currentData['soil_$i']?.toString() ?? '0') ?? 0;
      _potAverages['Pot $i'] = {
        'temp': _averages['temp']!,
        'humidity': _averages['humidity']!,
        'soil': soil,
        'light': _averages['ldr']!,
      };
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: AppColor.primary)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      // Reload data with new date range
      await _loadHistoryData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hasil Monitoring',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textDark,
                ),
              ),
              // Manual refresh button
              IconButton(
                icon: Icon(Icons.refresh, color: AppColor.primary),
                onPressed: _isLoading ? null : _loadHistoryData,
                tooltip: 'Refresh data',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Info text
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data disimpan setiap ${_loggingService.interval.inMinutes} menit',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter Section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date Range Filter
                  InkWell(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColor.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _startDate == null
                                  ? 'Pilih Rentang Tanggal'
                                  : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    _startDate == null
                                        ? Colors.grey[600]
                                        : Colors.black87,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pot Filter
                  DropdownButtonFormField<String>(
                    value: _selectedPot,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.filter_list,
                        color: AppColor.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items:
                        _potOptions.map((String pot) {
                          return DropdownMenuItem<String>(
                            value: pot,
                            child: Text(pot),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPot = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),

          // Data display
          if (!_isLoading && _averages.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada data histori',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data akan tersimpan otomatis setiap ${_loggingService.interval.inMinutes} menit',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Overall Averages Section
          if (!_isLoading && _averages.isNotEmpty) ...[
            Text(
              'Rata-Rata Keseluruhan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildAverageCard(
              title: 'Suhu Rata-Rata',
              value: '${_averages['temp']?.toStringAsFixed(1) ?? '0'} °C',
              icon: Icons.thermostat_outlined,
              color: Colors.orange,
            ),
            _buildAverageCard(
              title: 'Kelembaban Udara Rata-Rata',
              value: '${_averages['humidity']?.toStringAsFixed(1) ?? '0'} %',
              icon: Icons.water_drop_outlined,
              color: Colors.blue,
            ),
            _buildAverageCard(
              title: 'LDR Rata-Rata',
              value: _averages['ldr']?.toStringAsFixed(1) ?? '0',
              icon: Icons.wb_sunny_outlined,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),

            // Per Pot Averages
            if (_selectedPot != 'Semua Pot' &&
                _potAverages.containsKey(_selectedPot)) ...[
              Text(
                'Rata-Rata $_selectedPot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildPotAverageCard(_selectedPot),
            ] else if (_selectedPot == 'Semua Pot' &&
                _potAverages.isNotEmpty) ...[
              Text(
                'Rata-Rata Per Pot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ..._potAverages.keys.map((pot) => _buildPotAverageCard(pot)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAverageCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotAverageCard(String potName) {
    final data = _potAverages[potName];
    if (data == null) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.yard, color: Colors.green, size: 24),
        ),
        title: Text(
          potName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Klik untuk detail',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  'Suhu',
                  '${data['temp']?.toStringAsFixed(1) ?? '0'} °C',
                  Icons.thermostat,
                  Colors.orange,
                ),
                const Divider(),
                _buildDetailRow(
                  'Kelembaban',
                  '${data['humidity']?.toStringAsFixed(1) ?? '0'} %',
                  Icons.water_drop,
                  Colors.blue,
                ),
                const Divider(),
                _buildDetailRow(
                  'Soil Moisture',
                  '${data['soil']?.toStringAsFixed(1) ?? '0'} %',
                  Icons.grass,
                  Colors.green,
                ),
                const Divider(),
                _buildDetailRow(
                  'Light',
                  data['light']?.toStringAsFixed(1) ?? '0',
                  Icons.wb_sunny,
                  Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
