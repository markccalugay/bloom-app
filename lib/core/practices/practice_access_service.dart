import '../../data/practices/practice_model.dart';

class PracticeAccessService {
  const PracticeAccessService();

  bool canAccess(Practice practice) {
    if (practice.tier == PracticeTier.free) return true;

    // MVP: no purchases yet
    return false;
  }
}