import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

enum MeasurementUnit { cm, m, inch, ft }
enum ActiveDrag { none, point1, point2 }

class CameraMeasurementScreen extends StatefulWidget {
  const CameraMeasurementScreen({super.key});

  @override
  State<CameraMeasurementScreen> createState() => _CameraMeasurementScreenState();
}

class _CameraMeasurementScreenState extends State<CameraMeasurementScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraDenied = false;

  // Absolute Screen Coordinates
  Offset _p1 = const Offset(100, 200);
  Offset _p2 = const Offset(200, 400);
  ActiveDrag _activeDrag = ActiveDrag.none;

  bool _isCalibrated = false;
  double _pixelsPerUnit = 1.0;
  double _referenceSize = 10.0;
  MeasurementUnit _selectedUnit = MeasurementUnit.cm;

  final TextEditingController _refSizeController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraController?.dispose();
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) setState(() => _isCameraDenied = true);
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final backCamera = _cameras!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _isCameraDenied = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _refSizeController.dispose();
    super.dispose();
  }

  double _getPixelDistance() {
    final dx = _p1.dx - _p2.dx;
    final dy = _p1.dy - _p2.dy;
    return sqrt(dx * dx + dy * dy);
  }

  void _calibrate() {
    FocusScope.of(context).unfocus();
    final double? ref = double.tryParse(_refSizeController.text);
    if (ref == null || ref <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid reference size.')));
      return;
    }

    final pDist = _getPixelDistance();
    if (pDist < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Points are too close.')));
      return;
    }

    setState(() {
      _referenceSize = ref;
      _pixelsPerUnit = pDist / ref;
      _isCalibrated = true;
    });
  }

  void _handlePanStart(DragStartDetails details) {
    final pos = details.localPosition;
    if ((pos - _p1).distance < 60) {
      _activeDrag = ActiveDrag.point1;
    } else if ((pos - _p2).distance < 60) {
      _activeDrag = ActiveDrag.point2;
    } else {
      _activeDrag = ActiveDrag.none;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_activeDrag == ActiveDrag.point1) {
      setState(() => _p1 += details.delta);
    } else if (_activeDrag == ActiveDrag.point2) {
      setState(() => _p2 += details.delta);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _activeDrag = ActiveDrag.none;
  }

  String _getUnitString(MeasurementUnit unit) {
    switch (unit) {
      case MeasurementUnit.cm: return 'cm';
      case MeasurementUnit.m: return 'm';
      case MeasurementUnit.inch: return 'in';
      case MeasurementUnit.ft: return 'ft';
    }
  }

  double _convert(double value, MeasurementUnit from, MeasurementUnit to) {
    if (from == to) return value;
    double cmVal = value;
    if (from == MeasurementUnit.m) cmVal = value * 100;
    if (from == MeasurementUnit.inch) cmVal = value * 2.54;
    if (from == MeasurementUnit.ft) cmVal = value * 30.48;

    if (to == MeasurementUnit.cm) return cmVal;
    if (to == MeasurementUnit.m) return cmVal / 100;
    if (to == MeasurementUnit.inch) return cmVal / 2.54;
    if (to == MeasurementUnit.ft) return cmVal / 30.48;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraDenied) {
      return Scaffold(
        appBar: AppBar(title: const Text('Measurement')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Camera Permission Denied', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => openAppSettings(), child: const Text('OPEN SETTINGS')),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Measurement')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    String resultText = 'Set reference size & calibrate';
    if (_isCalibrated) {
      final pDist = _getPixelDistance();
      final val = pDist / _pixelsPerUnit;
      resultText = '≈ ${val.toStringAsFixed(2)} ${_getUnitString(_selectedUnit)}';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1 / _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),

          // Full Screen Drag Layer
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _MeasurementPainter(p1: _p1, p2: _p2, isCalibrated: _isCalibrated),
                ),
                Positioned(
                  left: _p1.dx - 30, top: _p1.dy - 30,
                  child: _buildHandle('A'),
                ),
                Positioned(
                  left: _p2.dx - 30, top: _p2.dy - 30,
                  child: _buildHandle('B'),
                ),
              ],
            ),
          ),

          // Top Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      const Text('OPTICAL MEASUREMENT', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resultText,
                    style: TextStyle(color: _isCalibrated ? Colors.greenAccent : Colors.white, fontSize: _isCalibrated ? 32 : 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Measurements are approximate. Keep device parallel.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  if (!_isCalibrated) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _refSizeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Ref Size (e.g. 10)',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white12,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildUnitSelector(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _calibrate,
                        child: const Text('CALIBRATE SCALE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildUnitSelector(),
                        TextButton.icon(
                          onPressed: () => setState(() => _isCalibrated = false),
                          icon: const Icon(Icons.refresh, color: Colors.redAccent),
                          label: const Text('RECALIBRATE', style: TextStyle(color: Colors.redAccent)),
                        )
                      ],
                    )
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MeasurementUnit>(
          value: _selectedUnit,
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          items: MeasurementUnit.values.map((u) => DropdownMenuItem(value: u, child: Text(_getUnitString(u)))).toList(),
          onChanged: (newUnit) {
            if (newUnit != null) {
              if (_isCalibrated) {
                _pixelsPerUnit = _pixelsPerUnit * _convert(1, newUnit, _selectedUnit);
              }
              setState(() => _selectedUnit = newUnit);
            }
          },
        ),
      ),
    );
  }

  Widget _buildHandle(String label) {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        color: _isCalibrated ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: _isCalibrated ? Colors.greenAccent : Colors.blueAccent, width: 2),
      ),
      child: Center(
        child: Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: _isCalibrated ? Colors.greenAccent : Colors.blueAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _MeasurementPainter extends CustomPainter {
  final Offset p1, p2;
  final bool isCalibrated;

  _MeasurementPainter({required this.p1, required this.p2, required this.isCalibrated});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCalibrated ? Colors.greenAccent : Colors.orangeAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
