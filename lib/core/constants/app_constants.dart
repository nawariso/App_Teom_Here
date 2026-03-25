class AppConstants {
  AppConstants._();

  // App
  static const appName = 'Toem Here!';
  static const appVersion = '1.0.0';

  // Firebase Collections
  static const monitorsCollection = 'monitors';
  static const sightingsCollection = 'sightings';
  static const usersCollection = 'users';

  // Rarity thresholds (based on sighting frequency)
  static const legendaryThreshold = 5; // spotted < 5 times
  static const epicThreshold = 15;
  static const rareThreshold = 30;
  // common = spotted > 30 times

  // Gamification
  static const maxCollectionGoal = 50;
  static const xpPerSighting = 10;
  static const xpPerVote = 1;
  static const xpPerNewMonitor = 50;
  static const xpPerAchievement = 100;

  // Level thresholds
  static const levelThresholds = [
    0, // Level 1
    100, // Level 2
    300, // Level 3
    600, // Level 4
    1000, // Level 5
    1500, // Level 6
    2500, // Level 7
    4000, // Level 8
    6000, // Level 9
    10000, // Level 10
  ];

  // Bangkok park coordinates
  static const parks = {
    'สวนลุมพินี': {'lat': 13.7308, 'lng': 100.5412},
    'สวนเบญจกิติ': {'lat': 13.7226, 'lng': 100.5600},
    'สวนจตุจักร': {'lat': 13.8036, 'lng': 100.5536},
    'สวนรถไฟ': {'lat': 13.8120, 'lng': 100.5560},
    'สวนวชิรเบญจทัศ': {'lat': 13.8030, 'lng': 100.5530},
  };

  // Map defaults
  static const defaultMapLat = 13.7563;
  static const defaultMapLng = 100.5018;
  static const defaultMapZoom = 12.0;
}
