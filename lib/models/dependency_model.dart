class Dependency {
  final String name;
  final String description;
  final bool isDev;

  Dependency({
    required this.name,
    required this.description,
    this.isDev = false,
  });
}
