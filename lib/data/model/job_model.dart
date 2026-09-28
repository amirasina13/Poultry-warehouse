import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../config/config.dart';

part 'job_model.g.dart';

// Get Date and Time
DateTime currentDateAndTime = DateTime.now();
var getDateAndTime =
    DateFormat("yyyy-MM-dd").add_Hms().format(currentDateAndTime); // Get date

@JsonSerializable()
class JobModel {
  /// The generated code assumes these values exist in JSON.
  @JsonKey(name: 'j_status')
  final String jobStatus;

  @JsonKey(name: 'pll_id')
  final int pickingListLocationId;

  @JsonKey(name: 'pl_location')
  final String pickingListLocation;

  @JsonKey(name: 'tr_id')
  final String transactionID;

  @JsonKey(name: 't')
  final String type;

  @JsonKey(name: 'd_time')
  final String dateTime;

  @JsonKey(name: 'pl_id')
  final int pickingListID;

  @JsonKey(name: 'pl_no')
  final String pickingListNo;

  @JsonKey(name: 'sd_id')
  final int selectDocumentID;

  @JsonKey(name: 's_document')
  final String selectDocument;

  @JsonKey(name: 'd_no')
  final String documentNo;

  @JsonKey(name: 'tt_id')
  final int typeOfTransferId;

  @JsonKey(name: 't_type')
  final String typeOfTransfer;

  @JsonKey(name: 'fl_id')
  final int fromLocationID;

  @JsonKey(name: 'fl_name')
  final String fromLocationName;

  @JsonKey(name: 'tl_id')
  final int toLocationID;

  @JsonKey(name: 'tl_name')
  final String toLocationName;

  @JsonKey(name: 'fa_id')
  final int fromAreaID;

  @JsonKey(name: 'fa_name')
  final String fromAreaName;

  @JsonKey(name: 'ta_id')
  final int toAreaID;

  @JsonKey(name: 'ta_name')
  final String toAreaName;

  @JsonKey(name: 'reasonId', defaultValue: 0)
  final int reasonId;

  @JsonKey(name: 'reasonName', defaultValue: '')
  final String reasonName;

  @JsonKey(name: 'remark')
  final String remark;

  @JsonKey(name: 'iby_id')
  final int issuedByID;

  @JsonKey(name: 'i_by')
  final String issuedBy;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  JobModel({
    required this.jobStatus,
    required this.pickingListLocationId,
    required this.pickingListLocation,
    required this.transactionID,
    required this.type,
    required this.dateTime,
    required this.pickingListID,
    required this.pickingListNo,
    required this.selectDocumentID,
    required this.selectDocument,
    required this.documentNo,
    required this.typeOfTransferId,
    required this.typeOfTransfer,
    required this.fromLocationID,
    required this.fromLocationName,
    required this.toLocationID,
    required this.toLocationName,
    required this.fromAreaID,
    required this.fromAreaName,
    required this.toAreaID,
    required this.toAreaName,
    required this.reasonId,
    required this.reasonName,
    required this.remark,
    required this.issuedByID,
    required this.issuedBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory JobModel.fromJson(Map<String, dynamic> json) =>
      _$JobModelFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$JobModelToJson(this);

  /// Default (new) job
  factory JobModel.defaultData() {
    return JobModel(
      jobStatus: '',
      pickingListLocationId: Storage().selectedLocationID,
      pickingListID: 0,
      pickingListLocation: '',
      transactionID: Storage().transactionNo,
      type: '',
      dateTime: getDateAndTime,
      pickingListNo: '',
      selectDocumentID: 0,
      selectDocument: '',
      documentNo: '',
      typeOfTransferId: 0,
      typeOfTransfer: '',
      fromLocationID: 0,
      fromLocationName: '',
      toLocationID: 0,
      toLocationName: '',
      fromAreaID: 0,
      fromAreaName: '',
      toAreaID: 0,
      toAreaName: '',
      issuedByID: 0,
      issuedBy: '',
      reasonId: 0,
      reasonName: '',
      remark: '',
      createdAt: '',
      updatedAt: '',
    );
  }

  /// Merge DB data onto defaults (so missing fields don’t cause nulls)
  JobModel merge(JobModel job) {
    return JobModel(
      jobStatus: job.jobStatus.isNotEmpty ? job.jobStatus : jobStatus,
      pickingListID: job.pickingListID != 0 ? job.pickingListID : pickingListID,
      pickingListLocationId: job.pickingListLocationId != 0
          ? job.pickingListLocationId
          : pickingListLocationId,
      pickingListLocation: job.pickingListLocation.isNotEmpty
          ? job.pickingListLocation
          : pickingListLocation,
      transactionID:
          job.transactionID.isNotEmpty ? job.transactionID : transactionID,
      type: job.type.isNotEmpty ? job.type : type,
      dateTime: job.dateTime.isNotEmpty ? job.dateTime : dateTime,
      pickingListNo:
          job.pickingListNo.isNotEmpty ? job.pickingListNo : pickingListNo,
      selectDocumentID:
          job.selectDocumentID != 0 ? job.selectDocumentID : selectDocumentID,
      selectDocument:
          job.selectDocument.isNotEmpty ? job.selectDocument : selectDocument,
      documentNo: job.documentNo.isNotEmpty ? job.documentNo : documentNo,
      typeOfTransferId:
          job.typeOfTransferId != 0 ? job.typeOfTransferId : typeOfTransferId,
      typeOfTransfer:
          job.typeOfTransfer.isNotEmpty ? job.typeOfTransfer : typeOfTransfer,
      fromLocationID:
          job.fromLocationID != 0 ? job.fromLocationID : fromLocationID,
      fromLocationName: job.fromLocationName.isNotEmpty
          ? job.fromLocationName
          : fromLocationName,
      toLocationID: job.toLocationID != 0 ? job.toLocationID : toLocationID,
      toLocationName:
          job.toLocationName.isNotEmpty ? job.toLocationName : toLocationName,
      fromAreaID: job.fromAreaID != 0 ? job.fromAreaID : fromAreaID,
      fromAreaName:
          job.fromAreaName.isNotEmpty ? job.fromAreaName : fromAreaName,
      toAreaID: job.toAreaID != 0 ? job.toAreaID : toAreaID,
      toAreaName: job.toAreaName.isNotEmpty ? job.toAreaName : toAreaName,
      issuedByID: job.issuedByID != 0 ? job.issuedByID : issuedByID,
      issuedBy: job.issuedBy.isNotEmpty ? job.issuedBy : issuedBy,
      reasonId: job.reasonId != 0 ? job.reasonId : reasonId,
      reasonName: job.reasonName.isNotEmpty ? job.reasonName : reasonName,
      remark: job.remark.isNotEmpty ? job.remark : remark,
      createdAt:
          (job.createdAt?.isNotEmpty ?? false) ? job.createdAt : createdAt,
      updatedAt:
          (job.updatedAt?.isNotEmpty ?? false) ? job.updatedAt : updatedAt,
    );
  }
}
