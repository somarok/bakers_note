import 'package:bakers_note/presentation/bakers_calculator/bakers_percent_view_model.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void diSetup() {
  getIt.registerFactory<BakersPercentViewModel>(
    () => BakersPercentViewModel(),
  );
}
