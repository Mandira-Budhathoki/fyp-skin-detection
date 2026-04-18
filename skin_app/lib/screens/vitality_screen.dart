import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/api_service.dart';

class VitalityScreen extends StatefulWidget {
  const VitalityScreen({Key? key}) : super(key: key);

  @override
  State<VitalityScreen> createState() => _VitalityScreenState();
}

class _VitalityScreenState extends State<VitalityScreen> with TickerProviderStateMixin {
  // Balanced Earthy Palette
  static const Color cDarkTeal = Color(0xFF1F6F5F);
  static const Color cOlive = Color(0xFF9AB17A);
  static const Color cSage = Color(0xFFC3CC9B);
  static const Color cPale = Color(0xFFE4DFB5);
  static const Color bg = Color(0xFFF8FAFB);

  // States
  DateTime _selectedDate = DateTime.now();
  int _steps = 0;
  int _stepGoal = 8000;
  String _pedestrianStatus = 'stopped';
  int _waterGlasses = 0; // 1 glass = 250ml
  int _waterGoal = 10; // 2.5L

  bool _isSaving = false;
  bool _isLoadingHistory = true;
  String? _userId;

  // Chart
  List<FlSpot> _waterSpots = [];
  List<FlSpot> _stepSpots = [];
  List<String> _chartDays = [];
  List<dynamic> _backendHistory = [];

  // Streams
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _pedStatusSub;
  late AnimationController _waterAnimCtrl;

  @override
  void initState() {
    super.initState();
    _waterAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _initPedometer();
    _loadUserAndHistory();
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _pedStatusSub?.cancel();
    _waterAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId');
    setState(() => _userId = uid);

    if (uid != null) {
      _backendHistory = await ApiService.getVitalityHistory(uid);
      _processHistoryChart();
    } else {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
    _loadDataForSelectedDate();
  }

  // Parses historical data and maps it to the currently selected Date
  void _loadDataForSelectedDate() {
    final selStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Look for records matching selStr in backend
    bool found = false;
    for (var h in _backendHistory.reversed) {
      if (h['timestamp'] != null && h['timestamp'].startsWith(selStr)) {
        setState(() {
          _waterGlasses = ((h['waterIntake'] ?? 0) / 0.25).round();
          _steps = h['steps'] ?? 0;
        });
        found = true;
        break; // take most recent of that day
      }
    }

    if (!found) {
      setState(() {
        _waterGlasses = 0;
        if (selStr != todayStr) {
          _steps = 0; // Past day without record
        }
      });
    }

    // If viewing TODAY, try applying local live stats for water & sun if backend is stale
    if (selStr == todayStr) {
      _loadLocalLiveStats();
    }
  }

  Future<void> _loadLocalLiveStats() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (prefs.getString('vit_date') == todayStr) {
      setState(() {
        _waterGlasses = math.max(_waterGlasses, prefs.getInt('vit_water') ?? 0);
      });
    }
  }

  Future<void> _saveLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vit_date', DateFormat('yyyy-MM-dd').format(DateTime.now()));
    await prefs.setInt('vit_water', _waterGlasses);
  }

  // --- REVISED PEDOMETER LOGIC ---
  void _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      // 1. Pedestrian Status
      _pedStatusSub = Pedometer.pedestrianStatusStream.listen((event) {
        if (mounted) setState(() => _pedestrianStatus = event.status);
      }, onError: (e) => setState(() => _pedestrianStatus = 'unknown'));

      // 2. Step Count (Smart baseline subtraction)
      _stepSub = Pedometer.stepCountStream.listen((event) async {
        final prefs = await SharedPreferences.getInstance();
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final savedDate = prefs.getString('ped_date') ?? '';
        final lastRebootSteps = prefs.getInt('ped_last_reboot') ?? 0;

        // Phone rebooted since last event?
        int baseline = prefs.getInt('ped_baseline') ?? event.steps;
        if (event.steps < lastRebootSteps) {
            baseline = 0;
        }

        // New day? Reset baseline
        if (savedDate != todayStr) {
          baseline = event.steps;
          await prefs.setInt('ped_baseline', baseline);
          await prefs.setString('ped_date', todayStr);
        }
        
        await prefs.setInt('ped_last_reboot', event.steps);
        int realSteps = event.steps - baseline;

        // Apply to UI if viewing "Today"
        if (_selectedDate.day == DateTime.now().day) {
           if (mounted) {
             setState(() => _steps = math.max(_steps, realSteps)); // Don't shrink if backend has more
           }
        }
      }, onError: (e) {
        print('Pedometer block: $e');
      });
    } else {
      if (mounted) setState(() => _pedestrianStatus = 'Permission denied');
    }
  }

  void _processHistoryChart() {
    List<FlSpot> wSpots = [];
    List<FlSpot> sSpots = [];
    List<String> days = [];
    
    if (_backendHistory.isEmpty) {
      wSpots = const [FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0)];
      sSpots = const [FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0)];
      days = ['Mon', 'Tue', 'Wed'];
    } else {
      for (int i = 0; i < _backendHistory.length; i++) {
        var h = _backendHistory[i];
        double w = (h['waterIntake'] ?? 0) / 2.5 * 100; // Normalize 0 - 100%
        double s = (h['steps'] ?? 0) / _stepGoal * 100; // Normalize 0 - 100%
        
        wSpots.add(FlSpot(i.toDouble(), w.clamp(0.0, 100.0)));
        sSpots.add(FlSpot(i.toDouble(), s.clamp(0.0, 100.0)));
        try {
          DateTime dt = DateTime.parse(h['timestamp']).toLocal();
          days.add(DateFormat('E').format(dt)); // 'Mon', 'Tue'
        } catch (_) { days.add('-'); }
      }
    }

    if (mounted) {
      setState(() {
        _waterSpots = wSpots;
        _stepSpots = sSpots;
        _chartDays = days;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: cDarkTeal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoadingHistory = true; // Temporary UX blink
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        _loadDataForSelectedDate();
        setState(() => _isLoadingHistory = false);
      });
    }
  }

  Future<void> _saveToBackend() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ApiService.analyzeVitality({
        'userId': _userId,
        'date': _selectedDate.toIso8601String(), // Send custom date
        'height': 170.0,
        'weight': 70.0,
        'steps': _steps,
        'sleepHours': 8.0,
        'waterIntake': _waterGlasses * 0.25,
      });
      if (mounted) {
        _loadUserAndHistory(); // Refresh chart
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: cOlive,
          content: Text('Saved history for ${DateFormat('MMM dd').format(_selectedDate)}!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync failed. Check connection.')));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  void _addWater() {
    if (_waterGlasses < 20) {
      setState(() => _waterGlasses++);
      if (_selectedDate.day == DateTime.now().day) _saveLocalStats();
      _waterAnimCtrl.forward(from: 0.0);
    }
  }
  void _removeWater() {
    if (_waterGlasses > 0) {
      setState(() => _waterGlasses--);
      if (_selectedDate.day == DateTime.now().day) _saveLocalStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isToday = _selectedDate.day == DateTime.now().day;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month_rounded, color: cOlive, size: 18),
                const SizedBox(width: 8),
                Text(
                  isToday ? 'Today' : DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(color: cDarkTeal, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down_rounded, color: cDarkTeal),
              ],
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: cDarkTeal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 0. INSTRUCTION BANNER ──
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cPale.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, color: cOlive, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap the date above to jump back and view your 7-day step and hydration history!',
                      style: TextStyle(color: cDarkTeal.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            // ── 1. REAL-TIME PEDOMETER ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: Text('EVERY STEP COUNTS! KEEP WALKING FOR BETTER HEALTH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: cOlive, letterSpacing: 1.0))),
                if (!isToday) 
                  const Text('HISTORY MODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: cSage, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 12),
            _buildStepCounter(isToday),

            const SizedBox(height: 32),

            // ── 2. INTERACTIVE WATER TRACKER ──
            const Text('STAY HYDRATED! TAP THE + TO LOG A GLASS OF WATER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: cOlive, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            _buildWaterTracker(),

            const SizedBox(height: 36),

            // ── 3. HISTORICAL CHART ──
            const Text('WEEKLY PROGRESS: WATER INTAKE vs. ACTIVE STEPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: cOlive, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildHistoryChart(),

            const SizedBox(height: 30),

            // ── SAVE BUTTON ──
            GestureDetector(
              onTap: _isSaving ? null : _saveToBackend,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [cOlive, cDarkTeal]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: cDarkTeal.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text('SYNC FOR ${DateFormat('MMM dd').format(_selectedDate).toUpperCase()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // COMPONENTS
  // -----------------------------------------------------------------
  
  Widget _buildStepCounter(bool isToday) {
    double progress = (_steps / _stepGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80, height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: cPale,
                  valueColor: const AlwaysStoppedAnimation(cOlive),
                ),
                Icon(
                  (!isToday) ? Icons.history_rounded : (_pedestrianStatus == 'walking' ? Icons.directions_walk_rounded : Icons.accessibility_new_rounded),
                  color: cOlive,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isToday ? 'Live Sensor Data' : 'Archived Record', style: TextStyle(color: isToday ? cSage : cSage, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text('$_steps', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: cDarkTeal, height: 1.0)),
                Text('/ $_stepGoal steps goal', style: const TextStyle(fontSize: 13, color: cSage, fontWeight: FontWeight.w600)),
                if (isToday) ...[
                  const SizedBox(height: 8),
                  Text('Sensor: $_pedestrianStatus', style: TextStyle(fontSize: 11, color: cDarkTeal.withOpacity(0.5), fontWeight: FontWeight.w500)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker() {
    double progress = (_waterGlasses / _waterGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Water Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: cDarkTeal)),
                  Text('${(_waterGlasses * 250)} ml intakes', style: const TextStyle(fontSize: 12, color: cSage, fontWeight: FontWeight.w600)),
                ],
              ),
              Row(
                children: [
                  IconButton(onPressed: _removeWater, icon: Icon(Icons.remove_circle_outline_rounded, color: cSage.withOpacity(0.8))),
                  Text('$_waterGlasses / $_waterGoal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: cOlive)),
                  IconButton(onPressed: _addWater, icon: const Icon(Icons.add_circle_rounded, color: cOlive, size: 32)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _waterAnimCtrl,
            builder: (context, child) {
              return Wrap(
                spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                children: List.generate(math.max(_waterGoal, _waterGlasses), (i) {
                  bool isFilled = i < _waterGlasses;
                  bool isAnimating = isFilled && i == _waterGlasses - 1 && _waterAnimCtrl.isAnimating;
                  return Transform.scale(
                    scale: isAnimating ? 1.0 + (_waterAnimCtrl.value * 0.2) : 1.0,
                    child: Container(
                      width: 24, height: 32,
                      decoration: BoxDecoration(
                        color: isFilled ? cSage : cPale,
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                      ),
                    ),
                  );
                }),
              );
            }
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: cPale, valueColor: const AlwaysStoppedAnimation(cSage)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChart() {
    if (_isLoadingHistory) {
      return Container(height: 220, alignment: Alignment.center, child: const CircularProgressIndicator(color: cOlive));
    }
    
    return Container(
      height: 220, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)]),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < _chartDays.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_chartDays[index], style: const TextStyle(color: cSage, fontSize: 11, fontWeight: FontWeight.bold)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0, maxX: math.max(2.0, _chartDays.length - 1.0), minY: 0, maxY: 120,
          lineBarsData: [
            // Water Line (Sage mapping)
            LineChartBarData(
              spots: _waterSpots, isCurved: true, color: cSage, barWidth: 4, isStrokeCapRound: true,
              belowBarData: BarAreaData(show: true, color: cSage.withOpacity(0.2)),
            ),
            // Steps Line (Olive mapping)
            LineChartBarData(
              spots: _stepSpots, isCurved: true, color: cOlive, barWidth: 4, isStrokeCapRound: true,
              belowBarData: BarAreaData(show: true, color: cOlive.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }
}
