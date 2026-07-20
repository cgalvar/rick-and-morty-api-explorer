enum CharacterStatus { alive, dead, unknown }

class CharacterLocation {
  const CharacterLocation(this.name, {this.id});
  final String name;
  final int? id;
}

class LocationDetail {
  const LocationDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residentCount,
  });

  final int id;
  final String name;
  final String type;
  final String dimension;
  final int residentCount;
}

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.type,
    required this.image,
    required this.origin,
    required this.location,
    required this.episodeCount,
  });
  final int id;
  final String name;
  final CharacterStatus status;
  final String species;
  final String gender;
  final String type;
  final String image;
  final CharacterLocation origin;
  final CharacterLocation location;
  final int episodeCount;
}

class CharacterPage {
  CharacterPage(List<Character> items, this.hasNext)
    : items = List.unmodifiable(items);
  final List<Character> items;
  final bool hasNext;
}
