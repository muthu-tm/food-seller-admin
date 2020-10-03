import './user_locations.dart';
import 'package:json_annotation/json_annotation.dart';
part 'order_delivery.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderDelivery {
  @JsonKey(name: 'delivery_type', nullable: false)
  int deliveryType;   // 0 - Pickup from Store, 1 - Instant delivery, 2 -Same day, 3 - Schedules 
  @JsonKey(name: 'delivery_charge', nullable: false)
  double deliveryCharge;
  @JsonKey(name: 'delivery_contact', nullable: false)
  String deliveryContact;
  @JsonKey(name: 'delivered_at', nullable: true)
  int deliveredAt;
  @JsonKey(name: 'delivered_by', nullable: true)
  String deliveredBy;
  @JsonKey(name: 'delivered_to', nullable: true)
  String deliveredTo;
  @JsonKey(name: 'notes', nullable: true)
  String notes;
  @JsonKey(name: 'user_location')
  UserLocations userLocation;

  OrderDelivery();

  factory OrderDelivery.fromJson(Map<String, dynamic> json) => _$OrderDeliveryFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDeliveryToJson(this);

}
