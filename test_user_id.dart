import 'lib/domain/models.dart';

void main() {
  // Test actual user IDs from your Firebase
  final testIds = [
    'guest_1757170673000_vsjTmW',
    'guest_1757170689075_7U9dw4',
    'guest_1757181539821_Q1zsiN',
    'guest_1757181951639_LfwLaq',
    'guest_1757250584073_vqBLlx'
  ];

  // Debug logging removed for production
  for (final id in testIds) {
    isValidUserId(id);
    // Debug logging removed for production
  }

  // Test with @ symbol
  // Debug logging removed for production
  for (final id in testIds) {
    final withAt = '@$id';
    isValidUserId(withAt);
    // Debug logging removed for production
  }
}
