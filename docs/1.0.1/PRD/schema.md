# 规则 Schema v1（MVP 冻结）

本文档冻结 Yealico Flutter MVP 使用的 JSON 规则契约。

## 范围

- 格式：仅支持 JSON。
- 一个规则文件对应一个站点。
- MVP 仅覆盖不依赖浏览器端 JavaScript 的站点。
- DRM 内容不在范围内。
- 解析失败后回退原网页/WebView 不在范围内。

## 根对象

根对象必填字段：

- `version`
- `meta`
- `request`
- `routes`
- `indexRule`
- `detailRule`
- `contentRule`

### `version`

- 类型：`string`
- 本文档固定值：`"1.0"`

### `meta`

- 类型：`object`
- 必填字段：
  - `siteId`（`string`，唯一标识）
  - `siteName`（`string`）
  - `baseUrl`（`string`，绝对 URL）
  - `contentType`（`string`，取值：`comic`、`gallery`、`video`）

### `request`

- 类型：`object`
- 必填字段：
  - `method`（`string`，MVP 固定为 `GET`）
- 可选字段：
  - `charset`（`string`）
  - `timeoutMs`（`integer`，> 0）
  - `headers`（`object`，key/value 字符串对）
  - `userAgent`（`string`，可选运行时覆盖）
  - `refererPolicy`（`string`，`origin`、`page`、`none` 之一；默认 `origin`）

### `routes`

- 类型：`object`
- 必填字段：
  - `indexUrl`（`string`，绝对 URL）
  - `detailUrlMode`（`string`，MVP 固定为 `direct`）

## Extractor 对象

任意 extractor 字段使用同一结构：

- `selector`（`string`，CSS 选择器）必填
- `function`（`string`，`text`、`html`、`attr` 之一）必填
- `param`（`string`，当 `function` 为 `attr` 时必填）
- `regex`（`string`，可选）
- `replacement`（`string`，可选；仅与 `regex` 联动）
- `trim`（`boolean`，可选）
- `absoluteUrl`（`boolean`，可选）

## `indexRule`

- 类型：`object`
- 必填字段：
  - `item.selector`（`string`）
  - `fields.title`（`extractor`）
  - `fields.detailUrl`（`extractor`）
- 可选字段：
  - `fields.id`（`extractor`）
  - `fields.cover`（`extractor`）

## `detailRule`

- 类型：`object`
- 必填字段：
  - `item.selector`（`string`）
  - `fields.title`（`extractor`）
  - `fields.url`（`extractor`）
- 可选字段：
  - `title`（`extractor`）

## `contentRule`

`contentRule` 依赖 `meta.contentType`：

- 当为 `comic` 或 `gallery`：
  - `images.item.selector`（`string`）必填
  - `images.fields.url`（`extractor`）必填
- 当为 `video`：
  - `video.url`（`extractor`）必填

所有类型的可选字段：

- `decryptScript`（`string`）
  - 在加固运行时中，页面渲染完成后执行。
  - 若出现，必须为非空字符串。
- `secondLevel`（`object`）
  - 最多允许一次额外页面请求。
  - 不允许定义嵌套的二级链路。

## MVP 校验规则

- `request.method != "GET"` 时拒绝。
- `routes.detailUrlMode != "direct"` 时拒绝。
- 必填字段缺失时拒绝。
- extractor 的 `function = "attr"` 但缺少 `param` 时拒绝。
- `contentRule` 分支与 `meta.contentType` 不匹配时拒绝。
- `request.userAgent` 存在但为空或非字符串时拒绝。
- `request.refererPolicy` 存在但不在 `origin/page/none` 中时拒绝。
- `contentRule.decryptScript` 存在但为空或非字符串时拒绝。

## 向后兼容

- 现有 `version: "1.0"` 规则继续有效。
- 加固运行时相关字段均为可选，可渐进式引入。
- 省略这些字段的规则继续沿用原请求形态。

## 非目标（明确）

- 浏览器上下文中的 JavaScript 执行
- Cookie/登录态同步与浏览器会话连续性
- 内置规则市场
- 单规则文件合并多站点
- 与复杂 Yealico 规则格式的完全兼容

## 样例文件

样例位于 `docs/rules/samples/`：

- `valid-comic-rule.json`
- `valid-video-rule.json`
- `invalid-missing-required-field.json`
- `invalid-unsupported-method.json`
- `invalid-unsupported-detail-url-mode.json`

