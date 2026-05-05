import 'package:flutter_test/flutter_test.dart';
import 'package:stat_tracker/features/stats/domain/rank.dart';

void main() {
  test('rank thresholds advance through stages', () {
    expect(rankFor(0).name, 'Bronze III');
    expect(rankFor(10).name, 'Bronze II');
    expect(rankFor(20).name, 'Bronze I');
    expect(rankFor(110).name, 'Gold III');
    expect(rankFor(200).name, 'Gold I');
    expect(rankFor(420).name, 'Diamond I');
  });
}
