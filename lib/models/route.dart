class Route {
  final String name;
  final double length;
  final int elevationGain;
  final int elevationLoss;
  final String GPXData;

  Route(this.name, this.length, this.elevationGain, this.elevationLoss, this.GPXData);

  Map<String, dynamic> toMap() {
    return  {
      'name': name,
      'length': length,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'GPXData': GPXData
    };
  }

  @override
  String toString() {
    return "$Route({name} | ${length} km)";
  }
}