# KCMenu 测试 App

这是一个空壳 App，专门用于测试 KCMenu 界面。

## 编译方法

```bash
cd TestApp
make package
```

编译完成后会在 `packages/` 目录下生成 `.ipa` 文件。

## 安装

可以使用以下方式安装 IPA：
- TrollStore 直接安装
- AltStore 侧载
- 其他签名工具签名后安装

## 使用

打开 App 后，点击「打开 KCMenu 设置」按钮即可打开设置面板。

## 注意事项

- 此 App 仅用于 UI 测试，不包含任何 Hook 功能
- 修改 `SettingsViewController` 后重新编译即可测试新效果
- 无需越狱环境，普通设备侧载即可使用
