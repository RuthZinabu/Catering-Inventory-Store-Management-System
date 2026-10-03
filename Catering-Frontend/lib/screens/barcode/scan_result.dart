import 'package:mobile_scanner/mobile_scanner.dart';

class ScanResult {
  final String value;
  final BarcodeFormat format;

  const ScanResult({required this.value, required this.format});
}

class ScanDuplicateGuard {
  final Duration cooldown;
  String? _lastValue;
  DateTime? _lastAcceptedAt;

  ScanDuplicateGuard({this.cooldown = const Duration(milliseconds: 1500)});

  bool shouldAccept(String value, {DateTime? now}) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;

    final currentTime = now ?? DateTime.now();
    final lastAcceptedAt = _lastAcceptedAt;
    if (_lastValue == normalized &&
        lastAcceptedAt != null &&
        currentTime.difference(lastAcceptedAt) < cooldown) {
      return false;
    }

    _lastValue = normalized;
    _lastAcceptedAt = currentTime;
    return true;
  }
}