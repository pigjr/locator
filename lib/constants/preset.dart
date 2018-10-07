class Preset {
  final rooms = [
    'Bedroom',
    'Washroom',
    'Living Room',
    'Kitchen',
    'Lounge',
    'Games Room',
    'Box Room',
    'Utility Room',
  ]; // More at https://www.learnenglish.de/vocabulary/rooms.html
  final stories = [
    'Second Floor',
    'First Floor',
    'Basement',
  ];
  final houseTypes = {
    'Condo/Apartment': {
      'First Floor': [
        'Bedroom',
        'Washroom',
        'Living Room',
        'Kitchen',
        'Lounge'
      ]
    },
    'One-story House': {
      'Basement': [
        'Games Room',
        'Box Room',
        'Utility Room',
      ],
      'First Floor': [
        'Bedroom',
        'Washroom',
        'Living Room',
        'Kitchen',
        'Lounge'
      ]
    },
    'Two-story House': {
      'Second Floor': [
        'Bedroom',
        'Washroom',
      ],
      'First Floor': [
        'Bedroom',
        'Washroom',
        'Living Room',
        'Kitchen',
        'Lounge'
      ],
      'Basement': [
        'Games Room',
        'Box Room',
        'Utility Room',
      ],
    }
  };
}
