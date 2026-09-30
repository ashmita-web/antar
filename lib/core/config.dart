enum AppMode { citizen, official }

enum AppRegion {
  india('India', 'IN', '₹'),
  brazil('Brazil', 'BR', 'R\$');

  const AppRegion(this.label, this.code, this.currency);
  final String label;
  final String code;
  final String currency;
}
