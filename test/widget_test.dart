import 'package:cupon/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App bootstrap renders', (tester) async {
    await tester.pumpWidget(const KurukshetraDemoApp());
    expect(find.textContaining('Kurukshetra'), findsWidgets);
  });
}

