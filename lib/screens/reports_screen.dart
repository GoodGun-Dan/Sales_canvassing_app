import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';
import '../widgets/app_drawer_scaffold.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _type = 'Sales';
  bool _loading = false;
  Map<String, dynamic>? _report;
  bool _isDownloading = false;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final report = switch (_type) {
        'Visits' => await ReportService.visits(
            startDate: _formatDate(_dateRange.start), endDate: _formatDate(_dateRange.end)),
        'Performance' => await ReportService.performance(
            startDate: _formatDate(_dateRange.start), endDate: _formatDate(_dateRange.end)),
        _ => await ReportService.sales(
            startDate: _formatDate(_dateRange.start), endDate: _formatDate(_dateRange.end)),
      };
      if (mounted) setState(() => _report = report);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load report: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

  Future<void> _download(String format) async {
    setState(() => _isDownloading = true);
    try {
      final path = await ReportService.download(
        type: _type,
        format: format,
        startDate: _formatDate(_dateRange.start),
        endDate: _formatDate(_dateRange.end),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan $format tersimpan di: $path'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh laporan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (selected == null || !mounted) return;
    setState(() => _dateRange = selected);
    await _load();
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) => buildScreenShell(
    context,
    title: 'Reports',
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Report type'),
              items: const ['Sales', 'Visits', 'Performance'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (value) { if (value != null) { setState(() => _type = value); _load(); } },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading ? null : _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text('${DateFormat('dd MMM yyyy').format(_dateRange.start)} – ${DateFormat('dd MMM yyyy').format(_dateRange.end)}'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _isDownloading ? null : () => _download('xlsx'),
                  icon: const Icon(Icons.table_view),
                  label: const Text('Download Excel'),
                ),
                OutlinedButton.icon(
                  onPressed: _isDownloading ? null : () => _download('pdf'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Download PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
      if (_loading) const LinearProgressIndicator(),
      Expanded(child: _report == null ? const SizedBox() : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...Map<String, dynamic>.from(_report!['summary'] ?? {}).entries.map((e) => ListTile(title: Text(e.key), trailing: Text(e.value.toString()))),
        ],
      )),
    ]),
  );
}
