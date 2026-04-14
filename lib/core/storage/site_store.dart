import '../models/site_record.dart';

abstract interface class SiteStore {
  Future<List<SiteRecord>> listSites();

  Future<SiteRecord?> getSiteById(String siteId);

  Future<void> upsertSite(SiteRecord site);

  Future<void> removeSite(String siteId);
}
