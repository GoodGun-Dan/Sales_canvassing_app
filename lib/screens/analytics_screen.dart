import 'package:flutter/material.dart';
import '../widgets/app_drawer_scaffold.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../models/sales_statistic.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<SalesStatistic> _dailySales = [];
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _topOutlets = [];
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _transactionList = [];
  bool _isLoading = true;
  bool _isLoadingProducts = true;
  bool _isLoadingOutlets = true;
  bool _isLoadingTransactions = true;
  String? _errorMessage;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  int _selectedRange = 0; // 0: 7 hari, 1: Custom

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadDailySales(),
        _loadSummary(),
        _loadTopProducts(),
        _loadTopOutlets(),
        _loadTransactions(),
      ]);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _loadDailySales() async {
    try {
      final data = await AnalyticsService.fetchDailySales(
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() => _dailySales = data);
    } catch (_) {}
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    try {
      final data = await AnalyticsService.fetchTransactions(
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _transactionList = data;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      setState(() => _isLoadingTransactions = false);
    }
  }

  Future<void> _loadSummary() async {
    try {
      final data = await AnalyticsService.fetchSummary();
      setState(() => _summary = data);
    } catch (_) {}
  }

  Future<void> _loadTopProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final data = await AnalyticsService.fetchTopProducts();
      setState(() {
        _topProducts = data;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _loadTopOutlets() async {
    setState(() => _isLoadingOutlets = true);
    try {
      final data = await AnalyticsService.fetchTopOutlets();
      setState(() {
        _topOutlets = data;
        _isLoadingOutlets = false;
      });
    } catch (e) {
      setState(() => _isLoadingOutlets = false);
    }
  }

  void _changeRange(int rangeIndex) {
    if (_selectedRange == rangeIndex) return;
    setState(() {
      _selectedRange = rangeIndex;
      if (rangeIndex == 0) {
        _startDate = DateTime.now().subtract(const Duration(days: 7));
        _endDate = DateTime.now();
      }
      _loadData();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.blue,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedRange = 1;
        _startDate = picked.start;
        _endDate = picked.end;
        _loadData();
      });
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    double numValue = (value is double)
        ? value
        : (value is int)
            ? value.toDouble()
            : double.tryParse(value.toString()) ?? 0.0;
    return 'Rp ${numValue.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  String _formatNumber(dynamic value) {
    return (value ?? 0).toString();
  }

  @override
  Widget build(BuildContext context) {
    return AppDrawerScaffold(
      title: 'Analytics',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadData, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Period Selector (BCA Style)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildRangeChip(0, '7 Hari Terakhir'),
                                  const SizedBox(width: 8),
                                  _buildRangeChip(1, 'Pilih Periode'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Transaction List (BCA Style)
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Mutasi Penjualan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_isLoadingTransactions)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                  ],
                                ),
                              ),
                              _isLoadingTransactions
                                  ? const Padding(
                                      padding: EdgeInsets.all(32),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : _transactionList.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Center(
                                              child:
                                                  Text('Tidak ada transaksi')),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _transactionList.length,
                                          separatorBuilder: (context, index) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final transaction =
                                                _transactionList[index];
                                            return ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              leading: Container(
                                                width: 50,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  DateFormat('dd/MM').format(
                                                    DateTime.parse(transaction[
                                                            'date'] ??
                                                        DateTime.now()
                                                            .toIso8601String()),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                transaction['description'] ??
                                                    '-',
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              ),
                                              subtitle: Text(
                                                transaction['outlet_name'] ??
                                                    '',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _formatCurrency(
                                                        transaction['amount']),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                  if (transaction['status'] !=
                                                      null)
                                                    Text(
                                                      transaction['status'],
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Summary Cards
                        Row(
                          children: [
                            _buildSummaryCard(
                                'Total Sales',
                                _formatCurrency(_summary['total_sales']),
                                Icons.attach_money,
                                Colors.blue),
                            _buildSummaryCard(
                                'Total Orders',
                                _formatNumber(_summary['total_orders']),
                                Icons.shopping_cart,
                                Colors.green),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSummaryCard(
                                'Total Visits',
                                _formatNumber(_summary['total_visits']),
                                Icons.location_on,
                                Colors.orange),
                            _buildSummaryCard(
                                'Strike Rate',
                                '${_formatNumber(_summary['strike_rate'])}%',
                                Icons.percent,
                                Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Sales Chart
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Daily Sales Trend',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 250,
                                  child: _dailySales.isEmpty
                                      ? const Center(
                                          child: Text('Tidak ada data'))
                                      : BarChart(
                                          BarChartData(
                                            alignment:
                                                BarChartAlignment.spaceAround,
                                            maxY: _dailySales.isEmpty
                                                ? 0
                                                : (_dailySales
                                                        .map(
                                                            (e) => e.totalSales)
                                                        .reduce((a, b) =>
                                                            a > b ? a : b) *
                                                    1.2),
                                            barGroups: _dailySales
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final index = entry.key;
                                              final data = entry.value;
                                              return BarChartGroupData(
                                                x: index,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: data.totalSales,
                                                    color: Colors.blue,
                                                    width: 20,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  // PERBAIKAN: date adalah DateTime, bukan String
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    if (value.toInt() >= 0 &&
                                                        value.toInt() <
                                                            _dailySales
                                                                .length) {
                                                      final date = _dailySales[
                                                              value.toInt()]
                                                          .date;
                                                      return Text(
                                                        '${date.day}/${date.month}',
                                                        style: const TextStyle(
                                                            fontSize: 10),
                                                      );
                                                    }
                                                    return const Text('');
                                                  },
                                                  reservedSize: 30,
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 50,
                                                  getTitlesWidget:
                                                      (value, meta) => Text(
                                                          _formatCurrency(
                                                              value),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      10)),
                                                ),
                                              ),
                                              topTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              rightTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                            ),
                                            borderData:
                                                FlBorderData(show: false),
                                            gridData:
                                                const FlGridData(show: true),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Top Products
                        const Text('Top Products',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _isLoadingProducts
                            ? const Center(child: CircularProgressIndicator())
                            : _topProducts.isEmpty
                                ? const Center(child: Text('No data'))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _topProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = _topProducts[index];
                                      return Card(
                                        child: ListTile(
                                          leading: CircleAvatar(
                                              child: Text('${index + 1}')),
                                          title: Text(
                                              product['product_name'] ?? ''),
                                          subtitle: Text(
                                              '${_formatNumber(product['total_quantity'])} units'),
                                          trailing: Text(_formatCurrency(
                                              product['total_sales'])),
                                        ),
                                      );
                                    },
                                  ),
                        const SizedBox(height: 16),
                        // Top Outlets
                        const Text('Top Outlets',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _isLoadingOutlets
                            ? const Center(child: CircularProgressIndicator())
                            : _topOutlets.isEmpty
                                ? const Center(child: Text('No data'))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _topOutlets.length,
                                    itemBuilder: (context, index) {
                                      final outlet = _topOutlets[index];
                                      return Card(
                                        child: ListTile(
                                          leading: CircleAvatar(
                                              child: Text('${index + 1}')),
                                          title:
                                              Text(outlet['outlet_name'] ?? ''),
                                          subtitle: Text(
                                              '${_formatNumber(outlet['total_visits'])} visits'),
                                          trailing: Text(_formatCurrency(
                                              outlet['total_sales'])),
                                        ),
                                      );
                                    },
                                  ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildRangeChip(int rangeIndex, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedRange == rangeIndex,
      onSelected: (_) {
        if (rangeIndex == 1) {
          _selectDateRange();
        } else {
          _changeRange(rangeIndex);
        }
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
