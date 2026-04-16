# 任务 01：扩展规则契约与请求画像

## 目标

让校验器接受新增可选字段，并提供统一请求头计算能力。

## 关键改动

- 修改 `rule_validator.dart`
- 新增 `request_profile_resolver.dart`
- 更新 `schema.md` 与样例 JSON
- 补充测试：`rule_validator_test.dart`、`request_profile_resolver_test.dart`

## 验证命令

```bash
flutter test test/features/rule_validator_test.dart test/features/request_profile_resolver_test.dart
```

