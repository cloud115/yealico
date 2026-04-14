import 'reading_history_store.dart';
import 'rule_store.dart';
import 'site_store.dart';

abstract interface class AppStorage {
  SiteStore get sites;

  RuleStore get rules;

  ReadingHistoryStore get history;
}
