class Ingredient {
  final int id;
  final String name;
  final num weight;
  final num percent;
  final bool isFlour;

//<editor-fold desc="Data Methods">
  const Ingredient({
    required this.id,
    required this.name,
    required this.weight,
    required this.percent,
    required this.isFlour,
  });

  factory Ingredient.empty(int id) {
    return Ingredient(
      id: id,
      name: '',
      weight: 0,
      percent: 0,
      isFlour: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          weight == other.weight &&
          percent == other.percent);

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ weight.hashCode ^ percent.hashCode;

  @override
  String toString() {
    return 'Ingredient{ id: $id, name: $name, weight: $weight, percent: $percent,}';
  }

  Ingredient copyWith({
    int? id,
    String? name,
    num? weight,
    num? percent,
    bool? isFlour,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      percent: percent ?? this.percent,
      isFlour: isFlour ?? this.isFlour,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'percent': percent,
      'isFlour': isFlour,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      weight: json['weight'] as num,
      percent: json['percent'] as num,
      isFlour: json['isFlour'] as bool,
    );
  }

//</editor-fold>
}
