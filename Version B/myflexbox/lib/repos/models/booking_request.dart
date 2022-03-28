

class BookingRequest {
  final int lockerId;
  final int compartmentId;
  final String startTime;
  final String endTime;
  final String externalId; //firebase auth user id
  final String parcelNumber; //can be used for text message

  BookingRequest(this.lockerId, this.compartmentId, this.startTime,
      this.endTime, this.externalId, this.parcelNumber);

  Map<String, dynamic> toJson() => {
    'lockerId': lockerId,
    'compartmentId': compartmentId,
    'startTime': startTime,
    'endTime': endTime,
    'externalId': externalId,
    'parcelNumber': parcelNumber,
  };
}