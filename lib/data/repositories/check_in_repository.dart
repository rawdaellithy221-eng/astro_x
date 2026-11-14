import '../mock/mock_check_in.dart';
import '../models/check_in_step.dart';

class CheckInRepository {
  const CheckInRepository();

  List<CheckInStep> steps() => MockCheckIn.steps;
}
