# KCMenu

一个现代化的 iOS 越狱插件设置界面模板，采用毛玻璃卡片式设计。

<div align="center">
  <img src="https://github.com/user-attachments/assets/fbc226ff-289e-4320-bf3d-8879780f1713" width="35%" />
  <img src="https://github.com/user-attachments/assets/24692957-d349-4a10-a849-43e6cf64a7cb" width="35%" />
</div>

## ✨ 特性

- 🎨 毛玻璃效果 + 卡片式布局
- 🔍 设置项搜索功能
- 📂 可折叠分组
- 🎛️ 多种控件类型：开关、按钮、滑块、分段选择
- 💾 自动持久化存储 (NSUserDefaults)

## 📦 项目结构

```
KCMenu/
├── SettingsViewController.h/m   # 核心设置界面
├── Tweak.xm                     # Hook 入口（抖音长按面板示例）
├── Makefile                     # Tweak 编译配置
└── TestApp/                     # 独立测试 App
    ├── main.m
    ├── AppDelegate.h/m
    ├── MainViewController.h/m
    ├── Makefile
    └── Resources/
```

## 🚀 快速开始

### 作为 Tweak 使用

1. 复制 `SettingsViewController.h/m` 到你的项目
2. 在 Hook 中调用：

```objc
#import "SettingsViewController.h"

SettingsViewController *svc = [[SettingsViewController alloc] init];
svc.modalPresentationStyle = UIModalPresentationOverFullScreen;
[viewController presentViewController:svc animated:YES completion:nil];
```

### 测试 App（无需安装宿主应用）

```bash
cd TestApp
make package
```

生成的 IPA 可通过 TrollStore / AltStore 安装测试。

## ⚙️ 自定义设置项

修改 `menuSections` 数组：

```objc
self.menuSections = @[
    @{@"title": @"分组名称", @"expanded": @NO, @"subitems": @[
        @{@"title": @"开关项", @"detail": @"描述", @"type": @(SettingTypeSwitch), @"key": @"switch_key"},
        @{@"title": @"滑块项", @"type": @(SettingTypeSlider), @"key": @"slider_key"},
        @{@"title": @"按钮项", @"type": @(SettingTypeButton), @"key": @"button_key"},
        @{@"title": @"分段项", @"type": @(SettingTypeSegmented), @"key": @"seg_key", @"options": @[@"A", @"B", @"C"]},
    ]}
];
```

**设置项类型：**

| 类型 | 枚举值 | 说明 |
|------|--------|------|
| 开关 | `SettingTypeSwitch` | 布尔值开关 |
| 按钮 | `SettingTypeButton` | 点击触发动作 |
| 滑块 | `SettingTypeSlider` | 数值调节 (0-100) |
| 分段 | `SettingTypeSegmented` | 多选一，需提供 `options` |
| 信息 | `SettingTypeInfo` | 纯展示，需提供 `value` |

## 🙏 致谢

- [图层](https://t.me/DouYinHook) - UI 设计灵感来源

## 📄 License

MIT
