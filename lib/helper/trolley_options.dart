class TrolleyOption {
  final int value;
  final String label;
  final String weight;

  const TrolleyOption({
    required this.value,
    required this.label,
    required this.weight,
  });
}

class TrolleyOptions {
  static const List<TrolleyOption> all = [
    TrolleyOption(value: 0, label: "None", weight: "0.00"),
    TrolleyOption(value: 1, label: "Small (5kg)", weight: "5.00"),
    TrolleyOption(value: 2, label: "Medium (5.5kg)", weight: "5.50"),
    TrolleyOption(value: 3, label: "Big (6kg)", weight: "6.00"),
    TrolleyOption(value: 4, label: "Special (6.8kg)", weight: "6.80"),
  ];
}
