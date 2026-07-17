class AppConstants {
  AppConstants._();

  static const appName = 'Toem Here!';
  static const appVersion = '1.0.0';

  static const monitorsCollection = 'monitors';
  static const sightingsCollection = 'sightings';
  static const usersCollection = 'users';

  static const legendaryThreshold = 5;
  static const epicThreshold = 15;
  static const rareThreshold = 30;

  static const maxCollectionGoal = 50;
  static const xpPerSighting = 10;
  static const xpPerVote = 1;
  static const xpPerNewMonitor = 50;
  static const xpPerAchievement = 100;

  static const levelThresholds = [
    0,
    100,
    300,
    600,
    1000,
    1500,
    2500,
    4000,
    6000,
    10000,
  ];

  static const parks = {
    'Lumpini Park': {'lat': 13.7308, 'lng': 100.5412},
    'Benjakitti Park': {'lat': 13.7226, 'lng': 100.5600},
    'Chatuchak Park': {'lat': 13.8036, 'lng': 100.5536},
    'Wachirabenchathat Park': {'lat': 13.8120, 'lng': 100.5560},
    'Queen Sirikit Park': {'lat': 13.8030, 'lng': 100.5530},
  };

  static const defaultMapLat = 13.7563;
  static const defaultMapLng = 100.5018;
  static const defaultMapZoom = 12.0;
}
