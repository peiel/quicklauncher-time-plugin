# QuickLauncher 时间格式插件

输入 `time` 查看多种常用时间格式，用方向键选择，按回车复制所选结果。所有格式基于同一个本地时间快照生成，避免结果跨秒不一致。

## 安装

需要 QuickLauncher 1.5 或支持多结果预览的更高版本，以及可用的 Ruby 运行环境。在“设置 → 插件 → 发现插件”中输入 `peiel/quicklauncher-time-plugin`，查看插件来源和文件后确认安装。也可从[插件展示站](https://plugin.quicklauncher.flyee.tech/)选择该插件，在 QuickLauncher 中审核安装。

安装后可在“设置 → 插件 → 已安装”修改触发词。插件会在触发词匹配时运行并展示结果；请在确认安装前检查并信任其代码。

## 格式

- `HH:mm:ss`：24 小时制，精确到秒。
- `HH:mm`：24 小时制，精确到分钟。
- `hh:mm:ss AM/PM`：12 小时制。
- ISO 8601：日期、时间及本地 UTC 偏移。
- Unix 时间戳：自 1970-01-01 00:00:00 UTC 起的整数秒。

显示时间使用系统本地时区。插件仅使用 Ruby 标准库，不联网、不读取选中文字或剪贴板；回车复制由 QuickLauncher 完成。

## 测试与协议

运行 `ruby tests/time_formats_test.rb`。插件读取版本为 1 的 JSON 请求，使用 `previewOnKeyword` 返回 `action: "list"` 和多项显示/复制结果。旧版 QuickLauncher 不支持该协议。源码使用 [MIT 协议](LICENSE)。
