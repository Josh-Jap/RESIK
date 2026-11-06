import '../models/housing_model.dart';

/// Contract for Housing operations
abstract class IHousingService {
  Future<List<HousingModel>> getAllHousing();
  Future<HousingModel?> getHousingById(int idHouse);
  Future<HousingModel> addHousing(HousingModel housing);
  Future<bool> joinHousingForUser(int userId, dynamic houseCode);
}
