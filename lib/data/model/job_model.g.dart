// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobModel _$JobModelFromJson(Map<String, dynamic> json) => JobModel(
      jobStatus: json['j_status'] as String,
      pickingListLocationId: (json['pll_id'] as num).toInt(),
      pickingListLocation: json['pl_location'] as String,
      transactionID: json['tr_id'] as String,
      type: json['t'] as String,
      dateTime: json['d_time'] as String,
      pickingListID: (json['pl_id'] as num).toInt(),
      pickingListNo: json['pl_no'] as String,
      selectDocumentID: (json['sd_id'] as num).toInt(),
      selectDocument: json['s_document'] as String,
      documentNo: json['d_no'] as String,
      typeOfTransferId: (json['tt_id'] as num).toInt(),
      typeOfTransfer: json['t_type'] as String,
      fromLocationID: (json['fl_id'] as num).toInt(),
      fromLocationName: json['fl_name'] as String,
      toLocationID: (json['tl_id'] as num).toInt(),
      toLocationName: json['tl_name'] as String,
      fromAreaID: (json['fa_id'] as num).toInt(),
      fromAreaName: json['fa_name'] as String,
      toAreaID: (json['ta_id'] as num).toInt(),
      toAreaName: json['ta_name'] as String,
      reasonId: (json['reasonId'] as num?)?.toInt() ?? 0,
      reasonName: json['reasonName'] as String? ?? '',
      remark: json['remark'] as String,
      issuedByID: (json['iby_id'] as num).toInt(),
      issuedBy: json['i_by'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
      'j_status': instance.jobStatus,
      'pll_id': instance.pickingListLocationId,
      'pl_location': instance.pickingListLocation,
      'tr_id': instance.transactionID,
      't': instance.type,
      'd_time': instance.dateTime,
      'pl_id': instance.pickingListID,
      'pl_no': instance.pickingListNo,
      'sd_id': instance.selectDocumentID,
      's_document': instance.selectDocument,
      'd_no': instance.documentNo,
      'tt_id': instance.typeOfTransferId,
      't_type': instance.typeOfTransfer,
      'fl_id': instance.fromLocationID,
      'fl_name': instance.fromLocationName,
      'tl_id': instance.toLocationID,
      'tl_name': instance.toLocationName,
      'fa_id': instance.fromAreaID,
      'fa_name': instance.fromAreaName,
      'ta_id': instance.toAreaID,
      'ta_name': instance.toAreaName,
      'reasonId': instance.reasonId,
      'reasonName': instance.reasonName,
      'remark': instance.remark,
      'iby_id': instance.issuedByID,
      'i_by': instance.issuedBy,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
