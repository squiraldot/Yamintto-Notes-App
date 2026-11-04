import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keep only genuinely application-wide providers here.
final appReadyProvider = Provider<bool>((ref) => true);
