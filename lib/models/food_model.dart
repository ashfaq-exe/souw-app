class FoodModel {
  final String id;
  final String foodName;
  final String description;
  final String quantity;
  final String location;
  final String donorId;
  final String donorName;
  final String status;

  FoodModel({
    required this.id,
    required this.foodName,
    required this.description,
    required this.quantity,
    required this.location,
    required this.donorId,
    required this.donorName,
    required this.status,
  });

  factory FoodModel.fromMap(String id, Map<String, dynamic> data) {
    return FoodModel(
      id: id,
      foodName: data['foodName'] ?? '',
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? '',
      location: data['location'] ?? '',
      donorId: data['donorId'] ?? '',
      donorName: data['donorName'] ?? '',
      status: data['status'] ?? 'Available',
    );
  }
}
