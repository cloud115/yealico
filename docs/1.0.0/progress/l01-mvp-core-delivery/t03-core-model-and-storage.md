# 进展 - 2026-04-14 （任务 03）

## 已完成

- 在 `lib/core/models/` 下新增核心数据模型：
  - `ContentType`
  - `RuleSnapshot`
  - `SiteRecord`
  - `CatalogEntry`
  - `DetailEntry`
  - `ContentPayload`
  - `ReadingHistoryEntry`
- 在 `lib/core/storage/` 下新增存储契约：
  - `SiteStore`
  - `RuleStore`
  - `ReadingHistoryStore`
  - `AppStorage`
- 新增架构说明：
  - `docs/1.0.0/architecture/a01-mvp-core-design.md`（数据模型章节）
- 新增模型测试：
  - `test/core/models_test.dart`

## 验证

- 执行 `dart format lib test docs`
- 执行 `flutter test`（全部通过）

## 范围控制

- 本步骤未引入具体数据库引擎。
- 本步骤未实现解析/网络/运行时功能。
- 本步骤未新增依赖。

