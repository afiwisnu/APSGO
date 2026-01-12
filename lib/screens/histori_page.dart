import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class HistoriPage extends StatefulWidget {
  const HistoriPage({super.key});

  @override
  State<HistoriPage> createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPot = 'Semua Pot';

  final List<String> _potOptions = [
    'Semua Pot',
    'Pot 1',
    'Pot 2',
    'Pot 3',
    'Pot 4',
    'Pot 5',
  ];

  // Data dummy untuk monitoring
  final Map<String, Map<String, double>> _potAverages = {
    'Pot 1': {'temp': 28.5, 'humidity': 65.3, 'soil': 45.2, 'light': 82.1},
    'Pot 2': {'temp': 29.1, 'humidity': 68.7, 'soil': 52.8, 'light': 85.3},
    'Pot 3': {'temp': 27.8, 'humidity': 63.2, 'soil': 38.5, 'light': 79.6},
    'Pot 4': {'temp': 30.2, 'humidity': 71.5, 'soil': 61.3, 'light': 88.2},
    'Pot 5': {'temp': 28.9, 'humidity': 66.8, 'soil': 48.7, 'light': 83.9},
  };

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hasil Monitoring',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.textDark,
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

          // Overall Averages Section
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
            value: '28.9 °C',
            icon: Icons.thermostat_outlined,
            color: Colors.orange,
          ),
          _buildAverageCard(
            title: 'Kelembaban Udara Rata-Rata',
            value: '67.1 %',
            icon: Icons.water_drop_outlined,
            color: Colors.blue,
          ),
          _buildAverageCard(
            title: 'LDR Rata-Rata',
            value: '83.8',
            icon: Icons.wb_sunny_outlined,
            color: Colors.amber,
          ),
          const SizedBox(height: 20),

          // Per Pot Averages
          if (_selectedPot != 'Semua Pot') ...[
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
          ] else ...[
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
    final data = _potAverages[potName]!;
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
                  '${data['temp']} °C',
                  Icons.thermostat,
                  Colors.orange,
                ),
                const Divider(),
                _buildDetailRow(
                  'Kelembaban',
                  '${data['humidity']} %',
                  Icons.water_drop,
                  Colors.blue,
                ),
                const Divider(),
                _buildDetailRow(
                  'Soil Moisture',
                  '${data['soil']} %',
                  Icons.grass,
                  Colors.green,
                ),
                const Divider(),
                _buildDetailRow(
                  'Light',
                  '${data['light']}',
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
