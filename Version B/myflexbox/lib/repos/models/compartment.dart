

class Compartment {
  final int compartmentId;
  final String number;
  final String size;
  final double length;
  final double height;
  final double depth;
  final String type;

  Compartment(
      {this.compartmentId,
        this.number,
        this.size,
        this.length,
        this.height,
        this.depth,
        this.type});

  factory Compartment.fromJson(Map<String, dynamic> json) {
    return Compartment(
      compartmentId: json['compartmentId'] as int,
      number: json['number'] as String,
      size: json['size'] as String,
      length: json['length'] as double,
      height: json['height'] as double,
      depth: json['depth'] as double,
      type: json['type'] as String,
    );
  }
}
