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
    id: 'fire_forge',
    name: 'Fire Forge',
    assetPath: 'assets/sfx/ql_amb_fire_forge.wav',
    isPremium: false,
  ),
  Soundscape(
    id: 'river_steady',
    name: 'River Steady',
    assetPath: 'assets/sfx/ql_amb_river_steady.wav',
    isPremium: false,
  ),
  Soundscape(
    id: 'rain_shelter',
    name: 'Rain Shelter',
    assetPath: 'assets/sfx/ql_amb_rain_shelter.wav',
    isPremium: true,
  ),
  Soundscape(
    id: 'void_drone',
    name: 'Void Drone',
    assetPath: 'assets/sfx/ql_amb_void_drone.mp3',
    isPremium: true,
  ),
  Soundscape(
    id: 'wind_pass',
    name: 'Wind Pass',
    assetPath: 'assets/sfx/ql_amb_wind_pass.wav',
    isPremium: true,
  ),
];
