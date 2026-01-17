import '../models/word_pack.dart';
import '../models/word_pair.dart';

// Helper class for custom packs requiring conversion from raw words to pairs
class CustomCategoryPack extends WordPack {
  final List<String> words;

  CustomCategoryPack({required String categoryName, required this.words}) 
      : super(categoryName: categoryName, pairs: _generatePairs(words));

  static List<WordPair> _generatePairs(List<String> words) {
    if (words.length < 2) return [];
    List<WordPair> pairs = [];
    // Generate all unique pairs
    for (int i = 0; i < words.length; i++) {
        for (int j = i + 1; j < words.length; j++) {
            pairs.add(WordPair(civilian: words[i], imposter: words[j]));
            pairs.add(WordPair(civilian: words[j], imposter: words[i])); // Add reverse too? Or just one way?
            // Usually just one is fine, shuffling handles assignment.
        }
    }
    return pairs;
  }
}

class WordRepository {
  static const List<WordPack> wordPacks = [
    WordPack(
      categoryName: 'Food & Drinks',
      pairs: [
        WordPair(civilian: 'Coffee', imposter: 'Tea'),
        WordPair(civilian: 'Pizza', imposter: 'Burger'),
        WordPair(civilian: 'Apple', imposter: 'Orange'),
        WordPair(civilian: 'Chocolate', imposter: 'Candy'),
        WordPair(civilian: 'Pasta', imposter: 'Noodles'),
        WordPair(civilian: 'Bread', imposter: 'Toast'),
        WordPair(civilian: 'Cake', imposter: 'Pie'),
        WordPair(civilian: 'Sushi', imposter: 'Sashimi'),
        WordPair(civilian: 'Wine', imposter: 'Beer'),
        WordPair(civilian: 'Ice Cream', imposter: 'Frozen Yogurt'),
        WordPair(civilian: 'Steak', imposter: 'Ribs'),
        WordPair(civilian: 'Salad', imposter: 'Soup'),
        WordPair(civilian: 'Bacon', imposter: 'Sausage'),
        WordPair(civilian: 'Cheese', imposter: 'Butter'),
        WordPair(civilian: 'Milk', imposter: 'Cream'),
        WordPair(civilian: 'Potato', imposter: 'Yam'),
        WordPair(civilian: 'Rice', imposter: 'Quinoa'),
        WordPair(civilian: 'Chicken', imposter: 'Turkey'),
        WordPair(civilian: 'Honey', imposter: 'Syrup'),
        WordPair(civilian: 'Donut', imposter: 'Croissant'),
      ],
    ),
    WordPack(
      categoryName: 'Animals',
      pairs: [
        WordPair(civilian: 'Cat', imposter: 'Dog'),
        WordPair(civilian: 'Lion', imposter: 'Tiger'),
        WordPair(civilian: 'Elephant', imposter: 'Rhino'),
        WordPair(civilian: 'Shark', imposter: 'Whale'),
        WordPair(civilian: 'Eagle', imposter: 'Hawk'),
        WordPair(civilian: 'Horse', imposter: 'Zebra'),
        WordPair(civilian: 'Bear', imposter: 'Wolf'),
        WordPair(civilian: 'Rabbit', imposter: 'Hare'),
        WordPair(civilian: 'Penguin', imposter: 'Puffin'),
        WordPair(civilian: 'Monkey', imposter: 'Ape'),
        WordPair(civilian: 'Deer', imposter: 'Moose'),
        WordPair(civilian: 'Frog', imposter: 'Toad'),
        WordPair(civilian: 'Butterfly', imposter: 'Moth'),
        WordPair(civilian: 'Snake', imposter: 'Lizard'),
        WordPair(civilian: 'Crocodile', imposter: 'Alligator'),
        WordPair(civilian: 'Owl', imposter: 'Raven'),
        WordPair(civilian: 'Dolphin', imposter: 'Porpoise'),
        WordPair(civilian: 'Bee', imposter: 'Wasp'),
        WordPair(civilian: 'Spider', imposter: 'Scorpion'),
        WordPair(civilian: 'Turtle', imposter: 'Tortoise'),
      ],
    ),
    WordPack(
      categoryName: 'Sports & Games',
      pairs: [
        WordPair(civilian: 'Soccer', imposter: 'Football'),
        WordPair(civilian: 'Basketball', imposter: 'Volleyball'),
        WordPair(civilian: 'Tennis', imposter: 'Badminton'),
        WordPair(civilian: 'Swimming', imposter: 'Diving'),
        WordPair(civilian: 'Boxing', imposter: 'Wrestling'),
        WordPair(civilian: 'Golf', imposter: 'Mini Golf'),
        WordPair(civilian: 'Hockey', imposter: 'Lacrosse'),
        WordPair(civilian: 'Skiing', imposter: 'Snowboarding'),
        WordPair(civilian: 'Running', imposter: 'Jogging'),
        WordPair(civilian: 'Chess', imposter: 'Checkers'),
        WordPair(civilian: 'Poker', imposter: 'Blackjack'),
        WordPair(civilian: 'Bowling', imposter: 'Curling'),
        WordPair(civilian: 'Surfing', imposter: 'Skateboarding'),
        WordPair(civilian: 'Archery', imposter: 'Darts'),
        WordPair(civilian: 'Baseball', imposter: 'Cricket'),
        WordPair(civilian: 'Cycling', imposter: 'Motorcycling'),
        WordPair(civilian: 'Yoga', imposter: 'Pilates'),
        WordPair(civilian: 'Karate', imposter: 'Judo'),
        WordPair(civilian: 'Fishing', imposter: 'Hunting'),
        WordPair(civilian: 'Billiards', imposter: 'Snooker'),
      ],
    ),
    WordPack(
      categoryName: 'Technology',
      pairs: [
        WordPair(civilian: 'Laptop', imposter: 'Desktop'),
        WordPair(civilian: 'Phone', imposter: 'Tablet'),
        WordPair(civilian: 'Mouse', imposter: 'Trackpad'),
        WordPair(civilian: 'Keyboard', imposter: 'Typewriter'),
        WordPair(civilian: 'Monitor', imposter: 'TV'),
        WordPair(civilian: 'Email', imposter: 'Text Message'),
        WordPair(civilian: 'Browser', imposter: 'App'),
        WordPair(civilian: 'Wi-Fi', imposter: 'Bluetooth'),
        WordPair(civilian: 'Printer', imposter: 'Scanner'),
        WordPair(civilian: 'Camera', imposter: 'Webcam'),
        WordPair(civilian: 'Headphones', imposter: 'Earbuds'),
        WordPair(civilian: 'Router', imposter: 'Modem'),
        WordPair(civilian: 'USB', imposter: 'SD Card'),
        WordPair(civilian: 'Charger', imposter: 'Battery'),
        WordPair(civilian: 'Microphone', imposter: 'Speaker'),
        WordPair(civilian: 'Smartwatch', imposter: 'Fitness Tracker'),
        WordPair(civilian: 'VR Headset', imposter: 'AR Glasses'),
        WordPair(civilian: 'Drone', imposter: 'Helicopter'),
        WordPair(civilian: 'GPS', imposter: 'Compass'),
        WordPair(civilian: 'Hard Drive', imposter: 'SSD'),
      ],
    ),
    WordPack(
      categoryName: 'Movies & Entertainment',
      pairs: [
        WordPair(civilian: 'Actor', imposter: 'Actress'),
        WordPair(civilian: 'Comedy', imposter: 'Sitcom'),
        WordPair(civilian: 'Horror', imposter: 'Thriller'),
        WordPair(civilian: 'Action', imposter: 'Adventure'),
        WordPair(civilian: 'Drama', imposter: 'Romance'),
        WordPair(civilian: 'Movie', imposter: 'TV Show'),
        WordPair(civilian: 'Cinema', imposter: 'Theater'),
        WordPair(civilian: 'Director', imposter: 'Producer'),
        WordPair(civilian: 'Hero', imposter: 'Villain'),
        WordPair(civilian: 'Sequel', imposter: 'Prequel'),
        WordPair(civilian: 'Popcorn', imposter: 'Nachos'),
        WordPair(civilian: 'Trailer', imposter: 'Teaser'),
        WordPair(civilian: 'Oscar', imposter: 'Emmy'),
        WordPair(civilian: 'Script', imposter: 'Screenplay'),
        WordPair(civilian: 'Scene', imposter: 'Shot'),
        WordPair(civilian: 'Premiere', imposter: 'Release'),
        WordPair(civilian: 'Netflix', imposter: 'Hulu'),
        WordPair(civilian: 'Cartoon', imposter: 'Anime'),
        WordPair(civilian: 'Documentary', imposter: 'Biopic'),
        WordPair(civilian: 'Blockbuster', imposter: 'Indie Film'),
      ],
    ),
    WordPack(
      categoryName: 'Travel & Places',
      pairs: [
        WordPair(civilian: 'Beach', imposter: 'Coast'),
        WordPair(civilian: 'Mountain', imposter: 'Hill'),
        WordPair(civilian: 'Hotel', imposter: 'Motel'),
        WordPair(civilian: 'Airport', imposter: 'Station'),
        WordPair(civilian: 'Airplane', imposter: 'Helicopter'),
        WordPair(civilian: 'Train', imposter: 'Subway'),
        WordPair(civilian: 'Car', imposter: 'Truck'),
        WordPair(civilian: 'Bus', imposter: 'Van'),
        WordPair(civilian: 'Passport', imposter: 'Visa'),
        WordPair(civilian: 'Suitcase', imposter: 'Backpack'),
        WordPair(civilian: 'Map', imposter: 'GPS'),
        WordPair(civilian: 'Restaurant', imposter: 'Cafe'),
        WordPair(civilian: 'Museum', imposter: 'Gallery'),
        WordPair(civilian: 'Park', imposter: 'Garden'),
        WordPair(civilian: 'City', imposter: 'Town'),
        WordPair(civilian: 'Bridge', imposter: 'Tunnel'),
        WordPair(civilian: 'Lake', imposter: 'River'),
        WordPair(civilian: 'Island', imposter: 'Peninsula'),
        WordPair(civilian: 'Desert', imposter: 'Savanna'),
        WordPair(civilian: 'Forest', imposter: 'Jungle'),
      ],
    ),
    WordPack(
      categoryName: 'Everyday Objects',
      pairs: [
        WordPair(civilian: 'Chair', imposter: 'Stool'),
        WordPair(civilian: 'Table', imposter: 'Desk'),
        WordPair(civilian: 'Pen', imposter: 'Pencil'),
        WordPair(civilian: 'Book', imposter: 'Magazine'),
        WordPair(civilian: 'Lamp', imposter: 'Candle'),
        WordPair(civilian: 'Mirror', imposter: 'Window'),
        WordPair(civilian: 'Clock', imposter: 'Watch'),
        WordPair(civilian: 'Pillow', imposter: 'Cushion'),
        WordPair(civilian: 'Blanket', imposter: 'Sheet'),
        WordPair(civilian: 'Sofa', imposter: 'Couch'),
        WordPair(civilian: 'Cup', imposter: 'Mug'),
        WordPair(civilian: 'Plate', imposter: 'Bowl'),
        WordPair(civilian: 'Fork', imposter: 'Spoon'),
        WordPair(civilian: 'Knife', imposter: 'Scissors'),
        WordPair(civilian: 'Towel', imposter: 'Cloth'),
        WordPair(civilian: 'Umbrella', imposter: 'Raincoat'),
        WordPair(civilian: 'Bag', imposter: 'Purse'),
        WordPair(civilian: 'Wallet', imposter: 'Pouch'),
        WordPair(civilian: 'Key', imposter: 'Lock'),
        WordPair(civilian: 'Shoe', imposter: 'Boot'),
      ],
    ),
    WordPack(
      categoryName: 'Professions',
      pairs: [
        WordPair(civilian: 'Doctor', imposter: 'Nurse'),
        WordPair(civilian: 'Teacher', imposter: 'Professor'),
        WordPair(civilian: 'Chef', imposter: 'Cook'),
        WordPair(civilian: 'Police', imposter: 'Security Guard'),
        WordPair(civilian: 'Lawyer', imposter: 'Judge'),
        WordPair(civilian: 'Engineer', imposter: 'Architect'),
        WordPair(civilian: 'Artist', imposter: 'Designer'),
        WordPair(civilian: 'Pilot', imposter: 'Flight Attendant'),
        WordPair(civilian: 'Firefighter', imposter: 'Paramedic'),
        WordPair(civilian: 'Scientist', imposter: 'Researcher'),
        WordPair(civilian: 'Writer', imposter: 'Journalist'),
        WordPair(civilian: 'Musician', imposter: 'Singer'),
        WordPair(civilian: 'Photographer', imposter: 'Videographer'),
        WordPair(civilian: 'Barber', imposter: 'Hairstylist'),
        WordPair(civilian: 'Dentist', imposter: 'Orthodontist'),
        WordPair(civilian: 'Mechanic', imposter: 'Technician'),
        WordPair(civilian: 'Farmer', imposter: 'Gardener'),
        WordPair(civilian: 'Banker', imposter: 'Accountant'),
        WordPair(civilian: 'Waiter', imposter: 'Bartender'),
        WordPair(civilian: 'Plumber', imposter: 'Electrician'),
      ],
    ),
  ];

  static List<WordPack> getSelectedPacks(List<String> selectedCategories,
      {List<WordPack> customPacks = const []}) {
    final allPacks = [...wordPacks, ...customPacks];
    return allPacks
        .where((pack) => selectedCategories.contains(pack.categoryName))
        .toList();
  }

  static WordPair getRandomPair(List<String> selectedCategories,
      {List<WordPack> customPacks = const []}) {
    final selectedPacks = getSelectedPacks(selectedCategories, customPacks: customPacks);
    if (selectedPacks.isEmpty) {
      throw Exception('No categories selected');
    }

    final allPairs = selectedPacks.expand((pack) => pack.pairs).toList();
    if (allPairs.isEmpty) {
      throw Exception('No word pairs available');
    }

    allPairs.shuffle();
    return allPairs.first;
  }

  static List<String> getAllCategories({List<WordPack> customPacks = const []}) {
    final defaultCategories = wordPacks.map((pack) => pack.categoryName).toList();
    final customCategories = customPacks.map((pack) => pack.categoryName).toList();
    return [...defaultCategories, ...customCategories];
  }

  static List<String> getWordsForCategory(String category, {List<WordPack> customPacks = const []}) {
    final allPacks = [...wordPacks, ...customPacks];
    try {
        final pack = allPacks.firstWhere((p) => p.categoryName == category);
        // Extract unique words from pairs
        final words = <String>{};
        for (var pair in pack.pairs) {
            words.add(pair.civilian);
            words.add(pair.imposter);
        }
        return words.toList();
    } catch (e) {
        return [];
    }
  }
}
