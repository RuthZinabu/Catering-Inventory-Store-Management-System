import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'scan_result.dart';

const supportedBarcodeFormats = <BarcodeFormat>[
  BarcodeFormat.qrCode,
  BarcodeFormat.ean13,
  BarcodeFormat.ean8,
  BarcodeFormat.upcA,
  BarcodeFormat.upcE,
  BarcodeFormat.code128,
  BarcodeFormat.code39,
  BarcodeFormat.code93,
  BarcodeFormat.itf14,
  BarcodeFormat.itf2of5,
  BarcodeFormat.itf2of5WithChecksum,
  BarcodeFormat.codabar,
  BarcodeFormat.pdf417,
  BarcodeFormat.dataMatrix,
  BarcodeFormat.aztec,
];

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late final MobileScannerController _controller;
  final ScanDuplicateGuard _duplicateGuard = ScanDuplicateGuard();
  ScanResult? _result;
  String? _feedback;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      autoStart: true,
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      formats: supportedBarcodeFormats,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _result != null) return;

    Barcode? detected;
    String? value;
    for (final barcode in capture.barcodes) {
      final candidate = barcode.rawValue?.trim();
      if (candidate == null || candidate.isEmpty) continue;
      detected = barcode;
      value = candidate;
      break;
    }
    if (detected == null || value == null) return;
    if (!_duplicateGuard.shouldAccept(value)) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _feedback = null;
    });
    HapticFeedback.selectionClick();
    try {
      await _controller.stop();
    } catch (_) {
      // The scan result is still valid if the camera has already stopped.
    }
    if (!mounted) return;
    setState(() {
      _result = ScanResult(value: value!, format: detected!.format);
      _isProcessing = false;
    });
  }

  void _onDetectError(Object error, StackTrace stackTrace) {
    if (!mounted || _result != null) return;
    setState(() => _feedback = 'Could not read that code. Adjust it and try again.');
  }

  Widget _cameraErrorBuilder(
    BuildContext context,
    MobileScannerException exception,
  ) {
    final message = switch (exception.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Camera access is blocked. Allow camera permission in your device or browser settings, then retry.',
      MobileScannerErrorCode.unsupported =>
        'A camera is not available on this device or browser.',
      _ => 'The camera could not start. Check camera access and try again.',
    };

    return ColoredBox(
      color: const Color(0xFF101820),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  color: Colors.white, size: 42),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _retryCamera,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _retryCamera() async {
    if (_isProcessing) return;
    try {
      await _controller.start();
      if (mounted) setState(() => _feedback = null);
    } catch (_) {
      if (mounted) {
        setState(() => _feedback = 'Camera is still unavailable. Check permissions and retry.');
      }
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {
      if (mounted) setState(() => _feedback = 'The torch is not available on this camera.');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller.switchCamera();
    } catch (_) {
      if (mounted) setState(() => _feedback = 'Could not switch cameras.');
    }
  }

  Future<void> _scanAgain() async {
    if (!mounted) return;
    setState(() {
      _result = null;
      _feedback = null;
      _isProcessing = false;
    });
    await WidgetsBinding.instance.endOfFrame;
    await _retryCamera();
  }

  String _formatLabel(BarcodeFormat format) => switch (format) {
        BarcodeFormat.qrCode => 'QR Code',
        BarcodeFormat.ean13 => 'EAN-13',
        BarcodeFormat.ean8 => 'EAN-8',
        BarcodeFormat.upcA => 'UPC-A',
        BarcodeFormat.upcE => 'UPC-E',
        BarcodeFormat.code128 => 'Code 128',
        BarcodeFormat.code39 => 'Code 39',
        BarcodeFormat.code93 => 'Code 93',
        BarcodeFormat.itf14 ||
        BarcodeFormat.itf2of5 ||
        BarcodeFormat.itf2of5WithChecksum => 'ITF',
        BarcodeFormat.codabar => 'Codabar',
        BarcodeFormat.pdf417 => 'PDF417',
        BarcodeFormat.dataMatrix => 'Data Matrix',
        BarcodeFormat.aztec => 'Aztec',
        _ => format.name,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: const Color(0xFF101820),
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) => IconButton(
              tooltip: state.torchState == TorchState.on
                  ? 'Turn torch off'
                  : 'Turn torch on',
              onPressed: state.torchState == TorchState.unavailable ||
                      _result != null
                  ? null
                  : _toggleTorch,
              icon: Icon(state.torchState == TorchState.on
                  ? Icons.flashlight_off
                  : Icons.flashlight_on),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) => IconButton(
              tooltip: 'Switch camera',
              onPressed: _result != null ? null : _switchCamera,
              icon: Icon(state.cameraDirection == CameraFacing.back
                  ? Icons.camera_front_outlined
                  : Icons.camera_rear_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        useAppLifecycleState: true,
                        onDetect: _onDetect,
                        onDetectError: _onDetectError,
                        errorBuilder: _cameraErrorBuilder,
                      ),
                      if (_result == null)
                        IgnorePointer(
                          child: CustomPaint(painter: _ScanFramePainter()),
                        ),
                      if (_isProcessing)
                        const ColoredBox(
                          color: Color(0x66000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, state, child) =>
                            !state.isInitialized && state.error == null
                                ? const ColoredBox(
                                    color: Color(0x44000000),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Align barcode within the frame',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (_feedback != null && _result == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_feedback!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFFFD7D7))),
              ),
            if (_result case final result?)
              _buildResultPanel(result)
            else
              const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel(ScanResult result) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF16834A)),
              SizedBox(width: 8),
              Text('Barcode captured', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(result.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(_formatLabel(result.format),
              style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Scan Again'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(result),
                  icon: const Icon(Icons.check),
                  label: const Text('Use Result'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frame = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.78,
      height: size.height * 0.28,
    );
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(14)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}