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
  
  print('Testing isValidUserId function:');
  for (final id in testIds) {
    final result = isValidUserId(id);
    print('$id -> $result');
  }
  
  // Test with @ symbol
  print('\nTesting with @ symbol:');
  for (final id in testIds) {
    final withAt = '@$id';
    final result = isValidUserId(withAt);
    print('$withAt -> $result');
  }
}
