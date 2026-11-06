import '../models/pickup_req_model.dart';

/// Contract for Pickup Request / Pengaduan operations
abstract class IPickupService {
  Future<List<PickupReqModel>> getAllPickupRequests();
  Future<List<PickupReqModel>> getPickupRequestsByUserId(int userId);
  Future<PickupReqModel> createPickupRequest(PickupReqModel request);
  Future<void> updatePickupStatus(int idPickup, String newStatus);
  Future<void> deletePickupRequest(int idPickup);
}
