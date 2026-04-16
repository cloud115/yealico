# 进展 - 2026-04-15 （任务 08）

## 已完成

- 新增目录加载抽象与运行时实现：
  - `lib/features/catalog/domain/catalog_loader.dart`
- 新增目录页面 UI：
  - `lib/features/catalog/presentation/site_catalog_page.dart`
- 首页站点卡片接入目录页面跳转：
  - `lib/app/view/app_home_page.dart`
- 新增测试：
  - `test/features/catalog_loader_test.dart`
  - `test/features/site_catalog_page_test.dart`

## 验证

- 执行 `dart format`。
- 执行 `flutter test`（全部通过）。

## 范围控制

- 本步骤仅包含索引/目录渲染。
- 本步骤不包含详情/内容浏览实现。

