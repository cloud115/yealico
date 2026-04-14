import '../models/reading_history_entry.dart';

abstract interface class ReadingHistoryStore {
  Future<List<ReadingHistoryEntry>> listBySite(String siteId);

  Future<ReadingHistoryEntry?> getEntry({
    required String siteId,
    required String itemId,
  });

  Future<void> upsertEntry(ReadingHistoryEntry entry);

  Future<void> removeEntry({required String siteId, required String itemId});

  Future<void> clearSite(String siteId);
}
