import 'package:flutter_test/flutter_test.dart';
import 'package:fodo/core/constants/app_constants.dart';

void main() {
  group('Donation Service Tests', () {
    test('DonationStatus enum values are correct', () {
      expect(DonationStatus.created.value, 'created');
      expect(DonationStatus.pending.value, 'pending');
      expect(DonationStatus.accepted.value, 'accepted');
      expect(DonationStatus.onTheWay.value, 'on_the_way');
      expect(DonationStatus.reached.value, 'reached');
      expect(DonationStatus.collected.value, 'collected');
      expect(DonationStatus.completed.value, 'completed');
      expect(DonationStatus.cancelled.value, 'cancelled');
    });

    test('FoodType enum values are correct', () {
      expect(FoodType.cookedFood.value, 'cooked_food');
      expect(FoodType.packagedFood.value, 'packaged_food');
      expect(FoodType.fruitsAndVegetables.value, 'fruits_and_vegetables');
      expect(FoodType.bakeryItems.value, 'bakery_items');
      expect(FoodType.other.value, 'other');
    });

    test('FoodType fromString returns correct enum', () {
      expect(FoodType.fromString('cooked_food'), FoodType.cookedFood);
      expect(FoodType.fromString('packaged_food'), FoodType.packagedFood);
      expect(FoodType.fromString('invalid'), FoodType.other);
    });

    test('DonationStatus fromString returns correct enum', () {
      expect(DonationStatus.fromString('created'), DonationStatus.created);
      expect(DonationStatus.fromString('accepted'), DonationStatus.accepted);
      expect(DonationStatus.fromString('invalid'), DonationStatus.created);
    });

    test('UserType enum values are correct', () {
      expect(UserType.donor.value, 'donor');
      expect(UserType.ngo.value, 'ngo');
      expect(UserType.admin.value, 'admin');
    });
  });
}
