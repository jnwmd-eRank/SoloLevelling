import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/hunter_provider.dart';
import '../theme/system_theme.dart';

class WorkoutTimerScreen extends StatefulWidget {
  const WorkoutTimerScreen({super.key});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  // Modes: 'countdown', 'stopwatch', 'interval'
  String _mode = 'countdown';

  // Countdown state
  int _initialSeconds = 60;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isRunning = false;

  // Interval state
  int _workSeconds = 40;
  int _restSeconds = 20;
  int _totalSets = 4;
  int _currentSet = 1;
  bool _isWorkPhase = true;

  // Stopwatch state
  int _stopwatchSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mode == 'countdown') {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _timerCompleted();
        }
      } else if (_mode == 'stopwatch') {
        setState(() {
          _stopwatchSeconds++;
        });
      } else if (_mode == 'interval') {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _nextIntervalPhase();
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_mode == 'countdown') {
        _secondsRemaining = _initialSeconds;
      } else if (_mode == 'stopwatch') {
        _stopwatchSeconds = 0;
      } else if (_mode == 'interval') {
        _currentSet = 1;
        _isWorkPhase = true;
        _secondsRemaining = _workSeconds;
      }
    });
  }

  void _addThirtySeconds() {
    setState(() {
      _secondsRemaining += 30;
      if (_secondsRemaining > _initialSeconds) {
        _initialSeconds = _secondsRemaining;
      }
    });
  }

  void _timerCompleted() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _initialSeconds;
    });

    // Reward player with XP
    context.read<HunterProvider>().addXp(15);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: SystemTheme.electricBlue,
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'SET COMPLETE! +15 XP Granted.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _nextIntervalPhase() {
    if (_isWorkPhase) {
      // Transition to rest
      setState(() {
        _isWorkPhase = false;
        _secondsRemaining = _restSeconds;
      });
    } else {
      // Transition to next set work phase
      if (_currentSet < _totalSets) {
        setState(() {
          _currentSet++;
          _isWorkPhase = true;
          _secondsRemaining = _workSeconds;
        });
      } else {
        // Interval workout completed!
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _currentSet = 1;
          _isWorkPhase = true;
          _secondsRemaining = _workSeconds;
        });
        context.read<HunterProvider>().addXp(40);
        _showIntervalCompleteDialog();
      }
    }
  }

  void _showIntervalCompleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SystemTheme.primaryCyan, width: 2),
        ),
        title: const Text(
          'INTERVAL SESSION CLEARED',
          style: TextStyle(
            color: SystemTheme.primaryCyan,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Outstanding discipline! You conquered all rounds.\n+40 XP Awarded.',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SystemTheme.primaryCyan,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CONTINUE',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _setPreset(int seconds) {
    _timer?.cancel();
    setState(() {
      _mode = 'countdown';
      _isRunning = false;
      _initialSeconds = seconds;
      _secondsRemaining = seconds;
    });
  }

  void _selectIntervalPreset(int work, int rest, int sets) {
    _timer?.cancel();
    setState(() {
      _mode = 'interval';
      _isRunning = false;
      _workSeconds = work;
      _restSeconds = rest;
      _totalSets = sets;
      _currentSet = 1;
      _isWorkPhase = true;
      _secondsRemaining = work;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double percent = 1.0;
    if (_mode == 'countdown') {
      percent = _initialSeconds == 0
          ? 0.0
          : (_secondsRemaining / _initialSeconds).clamp(0.0, 1.0);
    } else if (_mode == 'interval') {
      final total = _isWorkPhase ? _workSeconds : _restSeconds;
      percent = total == 0 ? 0.0 : (_secondsRemaining / total).clamp(0.0, 1.0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TRAINING TIMER',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mode Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SystemTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SystemTheme.border),
              ),
              child: Row(
                children: [
                  _buildModeTab('countdown', 'REST TIMER'),
                  _buildModeTab('interval', 'HIIT / TABATA'),
                  _buildModeTab('stopwatch', 'STOPWATCH'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Interval Info Banner (if in interval mode)
            if (_mode == 'interval') ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isWorkPhase
                      ? SystemTheme.alertRed.withValues(alpha: 0.2)
                      : SystemTheme.successGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isWorkPhase
                        ? SystemTheme.alertRed
                        : SystemTheme.successGreen,
                  ),
                ),
                child: Text(
                  _isWorkPhase
                      ? 'WORK PHASE • SET $_currentSet OF $_totalSets'
                      : 'REST PHASE • RECOVER',
                  style: TextStyle(
                    color: _isWorkPhase
                        ? SystemTheme.alertRed
                        : SystemTheme.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Circular Timer
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 14.0,
              percent: _mode == 'stopwatch' ? 1.0 : percent,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: SystemTheme.surfaceElevated,
              progressColor: _mode == 'interval'
                  ? (_isWorkPhase
                      ? SystemTheme.alertRed
                      : SystemTheme.successGreen)
                  : SystemTheme.primaryCyan,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _mode == 'stopwatch'
                        ? _formatTime(_stopwatchSeconds)
                        : _formatTime(_secondsRemaining),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'monospace',
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRunning ? 'RUNNING' : 'PAUSED',
                    style: TextStyle(
                      color: _isRunning
                          ? SystemTheme.primaryCyan
                          : SystemTheme.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Timer Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset Button
                IconButton.filledTonal(
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    backgroundColor: SystemTheme.surfaceElevated,
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.all(14),
                  ),
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetTimer,
                  tooltip: 'Reset',
                ),
                const SizedBox(width: 20),

                // Main Play/Pause Button
                GestureDetector(
                  onTap: _isRunning ? _pauseTimer : _startTimer,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          SystemTheme.primaryCyan,
                          SystemTheme.electricBlue
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: SystemTheme.primaryCyan.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // +30s Button
                IconButton.filledTonal(
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    backgroundColor: SystemTheme.surfaceElevated,
                    foregroundColor: SystemTheme.primaryCyan,
                    padding: const EdgeInsets.all(14),
                  ),
                  icon: const Icon(Icons.add),
                  onPressed: _addThirtySeconds,
                  tooltip: '+30 Seconds',
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Presets Header
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'QUICK PRESETS',
                style: TextStyle(
                  color: SystemTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Preset Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('30s Rest', () => _setPreset(30)),
                _buildPresetChip('60s Standard', () => _setPreset(60)),
                _buildPresetChip('90s Heavy Rest', () => _setPreset(90)),
                _buildPresetChip('2m Recovery', () => _setPreset(120)),
                _buildPresetChip(
                    'HIIT 4x (40s/20s)', () => _selectIntervalPreset(40, 20, 4)),
                _buildPresetChip(
                    'Tabata 8x (20s/10s)', () => _selectIntervalPreset(20, 10, 8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(String modeKey, String label) {
    final isSelected = _mode == modeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _timer?.cancel();
          setState(() {
            _mode = modeKey;
            _isRunning = false;
            _resetTimer();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? SystemTheme.primaryCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : SystemTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          color: SystemTheme.primaryCyan,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: SystemTheme.surface,
      side: const BorderSide(color: SystemTheme.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: onTap,
    );
  }
}
