import 'package:chipchop_seller/db/models/model.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/geopoint_data.dart';
import 'package:json_annotation/json_annotation.dart';
part 'order_delivery.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderDelivery extends Model {
  @JsonKey(name: 'delivered_at', nullable: true)
  int deliveredAt;
  @JsonKey(name: 'delivered_by', nullable: true)
  String deliveredBy;
  @JsonKey(name: 'delivered_to', nullable: true)
  String deliveredTo;
  @JsonKey(name: 'notes', nullable: true)
  String notes;
  @JsonKey(name: 'geo_point')
  GeoPointData geoPoint;
  @JsonKey(name: 'address')
  Address address;

  OrderDelivery();

  factory OrderDelivery.fromJson(Map<String, dynamic> json) => _$OrderDeliveryFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDeliveryToJson(this);

}
