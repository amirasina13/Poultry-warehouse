import 'package:json_annotation/json_annotation.dart';

part 'goods_model.g.dart';

@JsonSerializable()
class GoodsModel {
  /// The generated code assumes these values exist in JSON.
  @JsonKey(name: 'list_index')
  final int listIndex;

  @JsonKey(name: 'g_type')
  final String goodsType;

  @JsonKey(name: 'ct_id')
  final int goodsCategoryId;

  @JsonKey(name: 'ct_name')
  final String goodsCategoryName;

  @JsonKey(name: 'gs_id')
  final int goodsSKUID;

  @JsonKey(name: 'gs_name')
  final String goodsSKUName;

  @JsonKey(name: 'sku_name')
  final String skuDisplayName;

  @JsonKey(name: 't_quantity')
  final int totalQuantity;

  @JsonKey(name: 't_weight')
  final double totalWeight;

  @JsonKey(name: 'tt_tray')
  final int totalTray;

  @JsonKey(name: 'tray_weight')
  final double trayWeight;

  @JsonKey(name: 's_trolley')
  final int selectTrolley;

  @JsonKey(name: 'st_weight')
  final double trolleyWeight;

  @JsonKey(name: 'nt_weight')
  final double nettWeight;

  @JsonKey(name: 'uq_id')
  final int uomQtyID;

  @JsonKey(name: 'uq_name')
  final String uomQtyName;

  @JsonKey(name: 'uw_id')
  final int uomWeightID;

  @JsonKey(name: 'uw_name')
  final String uomWeightName;

  @JsonKey(name: 'q_control')
  final int qtyControl;

  @JsonKey(name: 'w_control')
  final int weightControl;

  @JsonKey(name: 'sb_id')
  final int stockBalanceID;

  @JsonKey(name: 'pb_no')
  final String productionBatchNo;

  @JsonKey(name: 'p_date')
  final String productionDate;

  @JsonKey(name: 'e_date')
  final String expirationDate;

  @JsonKey(name: 'expire_days')
  final int expireDays;

  @JsonKey(name: 'b_id')
  final int brandId;

  @JsonKey(name: 'b_name')
  final String brandName;

  @JsonKey(name: 'c_id')
  final int customerId;

  @JsonKey(name: 'c_name')
  final String customerName;

  @JsonKey(name: 'v_id')
  final int vendorId;

  @JsonKey(name: 'v_name')
  final String vendorName;

  @JsonKey(name: 'r_id')
  final int rackID;

  @JsonKey(name: 'r_name')
  final String rackName;

  @JsonKey(name: 'p_id')
  final int palletID;

  @JsonKey(name: 'p_name')
  final String palletName;

  @JsonKey(name: 'is_grouped')
  final int isGrouped;

  @JsonKey(name: 'grouped_ids')
  final String groupId;

  @JsonKey(name: 'status')
  final int status;

  @JsonKey(name: 'tr_id')
  final String transactionID;

  @JsonKey(name: 'pld_id')
  final int? plDetailID;

  @JsonKey(name: 'tq_max')
  final int? totalQuantityMax;

  @JsonKey(name: 'tqn_max')
  final int? totalQuantityNewMax;

  @JsonKey(name: 'tw_max')
  final double? totalWeightMax;

  @JsonKey(name: 'twn_max')
  final double? totalWeightNewMax;

  @JsonKey(name: 'remarks')
  final String? remarks;

  @JsonKey(name: 'j_id')
  final int jobId;

  @JsonKey(name: 'stockBalanceId')
  final int stockId;

  @JsonKey(name: 'stockBalanceQty')
  final int stockQty;

  @JsonKey(name: 'stockBalanceWeight')
  final double stockWeight;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  GoodsModel({
    required this.listIndex,
    required this.goodsType,
    required this.goodsCategoryId,
    required this.goodsCategoryName,
    required this.goodsSKUID,
    required this.goodsSKUName,
    required this.skuDisplayName,
    required this.totalQuantity,
    required this.totalWeight,
    required this.totalTray,
    required this.trayWeight,
    required this.selectTrolley,
    required this.trolleyWeight,
    required this.nettWeight,
    required this.uomQtyID,
    required this.uomQtyName,
    required this.uomWeightID,
    required this.uomWeightName,
    required this.qtyControl,
    required this.weightControl,
    required this.stockBalanceID,
    required this.productionBatchNo,
    required this.productionDate,
    required this.expirationDate,
    required this.expireDays,
    required this.brandId,
    required this.brandName,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.vendorName,
    required this.rackID,
    required this.rackName,
    required this.palletID,
    required this.palletName,
    required this.isGrouped,
    required this.groupId,
    required this.status,
    required this.jobId,
    required this.transactionID,
    this.plDetailID,
    this.totalQuantityMax,
    this.totalQuantityNewMax,
    this.totalWeightMax,
    this.totalWeightNewMax,
    this.remarks,
    required this.stockId,
    required this.stockQty,
    required this.stockWeight,
    this.createdAt,
    this.updatedAt,
  });

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory GoodsModel.fromJson(Map<String, dynamic> json) =>
      _$GoodsModelFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$GoodsModelToJson(this);
}
