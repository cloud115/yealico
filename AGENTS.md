# 仓库协作规范

## 沟通与语言规范
- 默认沟通语言为简体中文；除非用户明确要求，禁止切换为其他语言。  
- 解释说明、问题定位、错误原因、命令说明、代码注释、示例输出等说明性文字均使用中文。  
- Git 提交信息默认使用中文（建议 `type: 中文摘要`，如 `docs: 同步 1.0.1 文档口径`）。  
- 新增或更新 Markdown 文档（`.md`）时，正文内容默认中文优先；如需保留英文术语，需配套中文语义说明。  

## 项目结构与模块组织
`lib/` 是主代码目录：`core/` 放配置、模型、存储、错误与日志；`features/` 按功能拆分并遵循 `data/domain/presentation` 分层；`app/` 与 `bootstrap/` 负责应用装配；入口文件为 `main.dart`、`main_dev.dart`、`main_prod.dart`。  
`test/` 与 `lib/` 对齐，当前以 `test/core/` 和 `test/features/` 为主。  
`scripts/dev/` 放本地调试工具（如 Web 代理），`scripts/release/` 放发布脚本。  
`docs/` 采用版本化归档，统一结构为 `docs/<version>/<category>/...`；当前版本索引见 `docs/README.md`，规则样例在 `docs/rules/samples/`。  
平台工程目录为 `android/` 与 `web/`。

## 文档结构规范
- 根索引：`docs/README.md`。  
- 版本索引：`docs/<version>/README.md`（如 `docs/1.0.0/README.md`、`docs/1.0.1/README.md`）。  
- 每个 PRD 版本目录按以下分类组织：  
  - `PRD/`：需求文档与规则 schema（如 `prd.md`、`schema.md`）  
  - `architecture/`：按“长任务/核心动作”维护架构设计；单一主需求默认合并为一个文档，若同版本有多个核心动作则并列多个文档  
  - `progress/`：按“长任务目录 + 单任务文档”组织，目录格式 `l<nn>-<long-task-slug>/`，任务文档格式 `t<nn>-<task-slug>.md`  
  - `qa/`：验收标准、测试记录与测试报告  
  - `release/`：发布流程、检查单、交付说明与版本说明  
- 根目录 `README.md` 的“当前阶段”必须按“版本 -> 长任务（`Lxx`）-> 任务（`txx`）”展示，且任务编号必须与 `progress` 中实际文件一一对应。  
- 命名约束：  
  - `architecture/` 文档使用 `a<nn>-<topic-slug>.md`。  
  - `progress/` 长任务目录使用 `l<nn>-<long-task-slug>/`，任务文档使用 `t<nn>-<task-slug>.md`。  
  - `qa/` 与 `release/` 文档使用语义化文件名（如 `acceptance.md`、`test-report.md`、`process.md`、`checklist.md`、`notes.md`），禁止使用 `T16`、`T17`、`T18` 这类任务号前缀。  
- 标题约束：`architecture/progress/qa/release` 文档标题禁止使用 `Txx` 或 `Txx.x` 作为标题前缀。  
- 目录索引约束：  
  - 允许的索引文件仅限 `docs/README.md`、`docs/<version>/README.md`、`docs/<version>/progress/README.md`。  
  - `architecture/`、`qa/`、`release/` 目录下不新增 `README.md`。  
  - `progress/l<nn>-*/` 长任务目录下不新增 `README.md`。  
- 架构文档结构约束：`architecture/a<nn>-*.md` 默认采用统一结构：`目标`、`关键设计`、`向后兼容`、`已知限制`。  
- 新增文档优先放到对应版本目录；跨版本通用规则样例统一放在 `docs/rules/samples/`。  
- 若某分类暂未产出正文，保留目录/索引并在对应版本 `README.md` 标注“待补充”。

## 文档编码规范
- 文档读写默认编码统一为 UTF-8，不依赖系统 PowerShell 默认编码行为。  
- 读取文档时，必须显式指定：`Get-Content -Raw -Encoding UTF8 <path>`。  
- 写入/覆盖文档时，必须显式指定：`Set-Content -Encoding UTF8 <path> <content>`。  
- 追加文档内容时，必须显式指定：`Add-Content -Encoding UTF8 <path> <content>`。  
- 避免使用 `>`、`>>` 或未声明编码的输出方式处理文档文件，防止出现乱码或编码漂移。

## 版本规则
- PRD 版本是发布版本来源。  
- `pubspec.yaml` 的 `build-name` 必须与目标 PRD 版本一致。  
- `build-number` 按内部构建号持续递增。  
- 发布前需核对：发布脚本参数、应用版本号、目标文档版本三者一致。

## 构建、测试与开发命令
- `flutter pub get`：拉取依赖。  
- `flutter run -t lib/main_dev.dart`：启动开发入口。  
- `flutter run -t lib/main_prod.dart`：本地验证生产入口。  
- `flutter analyze`：运行静态检查（`flutter_lints`）。  
- `flutter test`：执行全部测试。  
- `flutter test test/features/rule_runtime_service_test.dart`：执行单个特性测试。  
- `powershell -ExecutionPolicy Bypass -File .\scripts\release\build_release_artifacts.ps1 -BuildName <PRD版本> -BuildNumber <构建号>`：生成 APK 与 Web 发布产物。

## 代码风格与命名约定
使用 Dart/Flutter 默认格式（2 空格缩进），提交前运行 `dart format .`。  
遵循 `analysis_options.yaml`（`package:flutter_lints/flutter.yaml`）。  
文件名使用 `snake_case.dart`，类名使用 `PascalCase`，方法/变量使用 `camelCase`，私有成员使用 `_` 前缀。  
新增功能优先放入对应 `features/<feature>/`，避免跨层直接依赖。

## 测试规范
测试框架为 `flutter_test`。测试文件统一以 `_test.dart` 结尾，按功能放到 `test/core/` 或 `test/features/`。  
对新增或修改的解析、抓取、映射逻辑，至少补充 1 个成功路径和 1 个失败路径测试。  
涉及页面行为时补充 widget 测试，重点覆盖错误态、空态与关键交互。

## 提交与 Pull Request 规范
提交信息遵循 Conventional Commits，历史中主要使用：`feat:`、`fix:`、`docs:`、`build:`（示例：`feat: 新增 Android 渲染抓取桥`）。  
单次提交聚焦单一变更，正文可补充影响范围。  
PR 需包含：变更摘要、影响模块、执行过的命令（如 `flutter analyze`、`flutter test`）及结果；UI 改动附截图；关联对应任务或 PRD 条目。

## Git 分支与标签规范
- 默认分支模型：  
  - 长期稳定分支：`main`  
  - 每个 PRD 版本建立一个主开发分支：`feat/prd-<major>.<minor>.<patch>/main`  
- 任务分支约束：  
  - 仅在“多 agent + git worktree 并行执行任务”场景，才允许从 PRD 主分支拆分任务分支：  
    `feat/prd-<major>.<minor>.<patch>/t<nn>-<task-slug>`  
  - 非并行场景下，直接在对应 PRD 主分支开发，不额外拆任务分支。  
- 其他分支命名：  
  - `release/v<major>.<minor>.<patch>`  
  - `fix/<slug>`、`hotfix/<slug>`、`docs/<slug>`、`chore/<slug>`、`refactor/<slug>`、`test/<slug>`  
  - `slug` 统一使用小写字母、数字、短横线。  
- 标签命名：  
  - 正式发布：`v<major>.<minor>.<patch>`（示例：`v1.0.0`）  
  - 预发布：`v<major>.<minor>.<patch>-rc.<n>` / `-beta.<n>` / `-alpha.<n>`  
  - 标签主版本必须与目标 PRD 版本一致（例如 PRD `1.0.1` 对应 `v1.0.1` 或 `v1.0.1-rc.1`）。  
  - 标签必须使用注解标签（annotated tag），禁止复用或强制重写已发布标签。  
- 本仓库提供命名校验脚本：  
  - `powershell -ExecutionPolicy Bypass -File .\\scripts\\dev\\validate_git_naming.ps1 -Type branch`  
  - `powershell -ExecutionPolicy Bypass -File .\\scripts\\dev\\validate_git_naming.ps1 -Type tag -Name v1.0.1`（默认自动按当前分支推断 PRD 版本并校验一致性）  
  - `powershell -ExecutionPolicy Bypass -File .\\scripts\\dev\\validate_git_naming.ps1 -Type all -PrdVersion 1.0.1`（全量标签格式 + 指定 PRD 一致性校验）  
  - 若为多 agent + worktree 场景校验任务分支，显式增加：`-AllowTaskBranch`。

## 安全与配置提示
受限网络下可设置 `HTTP_PROXY` 与 `HTTPS_PROXY`（见 `README.md` 与 `android/gradle.properties` 约定）。  
`scripts/dev/freeimages_proxy_server.mjs` 仅用于本地调试，不可作为生产流量方案。  
不要提交密钥、令牌或包含敏感信息的测试规则。
