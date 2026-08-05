class BillItem {
  String name;
  double rate;
  double quantity;

  BillItem({
    required this.name,
    required this.rate,
    required this.quantity,
  });

  double get total => rate * quantity;

  Map<String, dynamic> toJson() => {
        'name': name,
        'rate': rate,
        'quantity': quantity,
      };

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      name: json['name'],
      rate: json['rate'],
      quantity: json['quantity'],
    );
  }
}
