import '../models/rule_snapshot.dart';

abstract interface class RuleStore {
  Future<RuleSnapshot?> getRule(String siteId);

  Future<void> saveRule({required String siteId, required RuleSnapshot rule});

  Future<void> removeRule(String siteId);
}
