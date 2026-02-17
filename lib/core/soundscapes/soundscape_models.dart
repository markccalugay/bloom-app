import 'package:quietline_app/core/app_assets.dart';

class Soundscape {
  final String id;
  final String name;
  final String assetPath;
  final bool isPremium;

  const Soundscape({
    required this.id,
    required this.name,
    required this.assetPath,
    this.isPremium = false,
  });
}

const List<Soundscape> allSoundscapes = [
  Soundscape(
    id: 'river_steady',
    name: 'River Steady',
    assetPath: AppAssets.riverSteady,
    isPremium: false,
  ),
  Soundscape(
    id: 'fire_forge',
    name: 'Fire Forge',
    assetPath: AppAssets.fireForge,
    isPremium: false,
  ),
  Soundscape(
    id: 'rain_shelter',
    name: 'Rain Shelter',
    assetPath: AppAssets.rainShelter,
    isPremium: true,
  ),
  Soundscape(
    id: 'void_drone',
    name: 'Void Drone',
    assetPath: AppAssets.voidDrone,
    isPremium: true,
  ),
  Soundscape(
    id: 'wind_pass',
    name: 'Wind Pass',
    assetPath: AppAssets.windPass,
    isPremium: true,
  ),
  Soundscape(
    id: 'ocean_depth',
    name: 'Ocean Depth',
    assetPath: AppAssets.oceanDepth,
    isPremium: true,
  ),
  Soundscape(
    id: 'deep_hall',
    name: 'Deep Hall',
    assetPath: AppAssets.deepHall,
    isPremium: true,
  ),
  Soundscape(
    id: 'forest_night',
    name: 'Forest Night',
    assetPath: AppAssets.forestNight,
    isPremium: true,
  ),
];
