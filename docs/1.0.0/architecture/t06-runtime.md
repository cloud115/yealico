# T06 HTML 运行时引擎

## 目标

实现 MVP 运行时执行能力：

- 按规则配置发起统一 HTTP 请求
- HTML 解析
- 基于选择器的提取
- URL 归一化

## 已实现组件

- `HtmlPageFetcher`
  - 执行 GET 请求
  - 可选 headers/timeout/charset 处理
  - 规范化响应体输出
- `ExtractorEngine`
  - 支持字段：
    - `selector`
    - `function`（`text`/`html`/`attr`）
    - `param`
    - `regex` + `replacement`
    - `trim`
    - `absoluteUrl`
- `RuleRuntimeEngine`
  - `parseIndex`
  - `parseDetail`
  - `parseContent`（`comic/gallery/video`）
- `RuleRuntimeService`
  - 按请求配置加载页面
  - 委派运行时引擎解析

## 边界

- 暂不执行二级请求链。
- 暂不接入列表/详情/阅读器 UI。
- 暂不接入持久化。
