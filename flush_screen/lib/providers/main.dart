import './provider.dart';

class ProviderInfo extends CombinedProdsUserModel with UserModel, UtilityModel {
  ProviderInfo() {
    this.resume();
    this.getUserSubject.listen((bool isAuth) {
      this.setIsAuthenticated(isAuth);
    });
  }
}
