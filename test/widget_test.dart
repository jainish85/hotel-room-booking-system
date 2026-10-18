import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_room_booking_system/app.dart';

void main() {
  testWidgets(
    'Hotel Room Booking System loads',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const HotelRoomBookingSystem(),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Welcome to Our Hotel'),
        findsOneWidget,
      );
    },
  );
}