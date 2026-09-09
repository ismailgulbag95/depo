import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Copy brain assets to project assets', () {
    final brainDir = r'C:\Users\ismai\.gemini\antigravity-ide\brain\1f78ed8c-6d6b-47a6-b83d-5f60a5878aa6';
    
    final copyMap = {
      'tavern_panoramic_interior_1788639577458.jpg': 'assets/backgrounds/bg_tavern_panoramic.jpg',
      'tactical_city_map_table_1788640859109.jpg': 'assets/backgrounds/bg_city_map_tactical.jpg',
      'home_storage_workshop_bg_1788640356325.jpg': 'assets/backgrounds/bg_home_workshop.jpg',
      'barracks_empty_dual_beds_1788640106211.jpg': 'assets/backgrounds/bg_barracks_empty.jpg',
      'barracks_left_warrior_1788640127482.jpg': 'assets/backgrounds/bg_barracks_warrior.jpg',
      'barracks_left_assassin_1788640148145.jpg': 'assets/backgrounds/bg_barracks_assassin.jpg',
      'barracks_left_archer_1788640169342.jpg': 'assets/backgrounds/bg_barracks_archer.jpg',
      'barracks_left_mage_1788640192029.jpg': 'assets/backgrounds/bg_barracks_mage.jpg',
      'barracks_left_knight_1788640214848.jpg': 'assets/backgrounds/bg_barracks_knight.jpg',
      'merc_warrior_tank_1788638984884.jpg': 'assets/characters/merc_warrior.jpg',
      'merc_rogue_assassin_1788639053773.jpg': 'assets/characters/merc_assassin.jpg',
    };

    int copiedCount = 0;
    for (final entry in copyMap.entries) {
      final srcPath = '$brainDir\\${entry.key}';
      final srcFile = File(srcPath);
      final destPath = entry.value;
      final destFile = File(destPath);
      if (destFile.existsSync()) {
        copiedCount++;
      } else if (srcFile.existsSync()) {
        destFile.parent.createSync(recursive: true);
        srcFile.copySync(destPath);
        if (destFile.existsSync()) copiedCount++;
      }
    }
    expect(copiedCount, greaterThanOrEqualTo(9));
  });
}
