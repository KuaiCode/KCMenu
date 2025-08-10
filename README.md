# KCMenu

AI写的仿图层的插件设置模板，使用说明是AI生成的，使用过程中遇到的问题请自行咨询AI

## SettingsViewController 使用说明

### 概述
`SettingsViewController` 是一个高度可定制的设置界面控制器，采用现代 iOS 设计风格，包含毛玻璃效果、卡片式布局和丰富的设置项类型。该控制器提供了多种设置项（开关、按钮、滑块、分段控制和信息展示），支持分组展开/折叠功能，并包含用户信息卡片和底部操作区域。

### 功能特性

1. **现代化界面设计**：
   - 毛玻璃效果背景（系统薄材质风格）
   - 自适应卡片布局（最大宽度 700px，最大高度 540px）
   - 圆角卡片设计（18px 圆角）
   - 半透明元素和阴影效果

2. **设置项类型**：
   - 开关（Switch）
   - 按钮（Button）
   - 滑块（Slider）
   - 分段控制（Segmented Control）
   - 信息展示（Info）

3. **分组功能**：
   - 可展开/折叠的分组
   - 分组标题带指示图标
   - 动画展开/折叠效果

4. **其他元素**：
   - 用户信息卡片（头像、名称、ID）
   - 底部操作区域（版本信息、更新日志、GitHub）
   - 作者信息标签

5. **交互功能**：
   - 点击背景关闭设置
   - 退出应用功能
   - 设置项值持久化存储（NSUserDefaults）

### 集成步骤

#### 1. 添加文件到项目
将 `SettingsViewController.h` 和 `SettingsViewController.m` 文件添加到您的 Xcode 项目中。

#### 2. 导入头文件
在需要显示设置界面的地方导入头文件：

```objective-c
#import "SettingsViewController.h"
```

#### 3. 显示设置界面
使用模态方式呈现设置视图控制器：

```objective-c
SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
// 可选：设置模态呈现样式
settingsVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
settingsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
[self presentViewController:settingsVC animated:YES completion:nil];
```

### 自定义配置

#### 1. 修改界面常量
在文件顶部的全局常量区域修改界面尺寸：

```objective-c
// 卡片圆角半径
static const CGFloat kCardCornerRadius = 18.0;
// 表格行高
static const CGFloat kTableCellHeight = 38.0;
// 表格头部高度
static const CGFloat kTableHeaderHeight = 112.0;
// 表格底部高度
static const CGFloat kTableFooterHeight = 124.0;
// 信息卡片高度
static const CGFloat kInfoCardHeight = 80.0;
```

#### 2. 配置菜单数据结构
在 `viewDidLoad` 方法中修改 `menuSections` 数组来自定义设置项：

```objective-c
self.menuSections = [NSMutableArray arrayWithArray:@[
    [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"透明度设置", @"expanded":@NO, @"subitems":@[ 
        @{@"title":@"开启半透明", @"detail":@"启用界面透明效果", @"type":@(SettingTypeSwitch), @"key":@"alpha_enable"}, 
        @{@"title":@"模糊增强", @"detail":@"增强背景模糊效果", @"type":@(SettingTypeSwitch), @"key":@"blur_enhance"},
        // ... 其他设置项
    ]}],
    // ... 其他分组
]];
```

#### 3. 自定义用户信息
修改用户信息卡片内容：

```objective-c
// 用户头像
avatar.image = [self placeholderAvatar]; // 替换为您自己的头像

// 用户信息标签
nameLabel.text = @"KuaiCode"; // 用户名
idLabel.text = @"KCMenu's Demo"; // 用户ID
hint.text = @"本插件免费分享 仅测试使用"; // 提示信息
```

#### 4. 修改底部信息
更新底部操作区域的信息：

```objective-c
// 版本号
versionLabel.text = @"0.0.1"; // 您的版本号

// 信息项标题
NSArray *infoTitles = @[@"插件版本", @"更新日志", @"Github"];
```

#### 5. 自定义作者信息
修改作者标签内容：

```objective-c
self.authorLabel.text = @"KCMenu's Demo | KuaiCode"; // 您的作者信息
```

### 事件处理

#### 1. 开关状态变化
当开关状态变化时，会触发 `switchChanged:` 方法：

```objective-c
- (void)switchChanged:(UISwitch *)sw {
    // 从tag中解析位置信息
    NSInteger section = sw.tag >> 16;
    NSInteger subIndex = sw.tag & 0xFFFF;
    NSDictionary *sectionData = self.menuSections[section];
    NSDictionary *item = sectionData[@"subitems"][subIndex];
    NSString *key = item[@"key"];
    
    // 保存到UserDefaults
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
```

#### 2. 按钮点击事件
当按钮被点击时，会触发 `subButtonTapped:` 方法：

```objective-c
- (void)subButtonTapped:(UIButton *)button {
    // 从tag中解析位置信息
    NSInteger section = button.tag >> 16;
    NSInteger subIndex = button.tag & 0xFFFF;
    NSDictionary *sectionData = self.menuSections[section];
    NSDictionary *item = sectionData[@"subitems"][subIndex];
    NSString *title = item[@"title"];
    
    // 显示提示框
    NSString *message = [NSString stringWithFormat:@"按钮被点击: %@", title];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"操作" 
                                                                 message:message 
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
```

#### 3. 滑块值变化
当滑块值变化时，会触发 `sliderValueChanged:` 方法：

```objective-c
- (void)sliderValueChanged:(UISlider *)slider {
    // 从tag中解析位置信息
    NSInteger section = slider.tag >> 16;
    NSInteger subIndex = slider.tag & 0xFFFF;
    NSDictionary *sectionData = self.menuSections[section];
    NSDictionary *item = sectionData[@"subitems"][subIndex];
    NSString *key = item[@"key"];
    
    // 更新值标签
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:subIndex+1 inSection:section]];
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UILabel class]] && CGRectGetWidth(view.frame) == 48) {
            UILabel *valueLabel = (UILabel *)view;
            valueLabel.text = [NSString stringWithFormat:@"%.0f%%", slider.value];
            break;
        }
    }
}
```

#### 4. 分段控件变化
当分段控件值变化时，会触发 `segmentedControlChanged:` 方法：

```objective-c
- (void)segmentedControlChanged:(UISegmentedControl *)seg {
    // 从tag中解析位置信息
    NSInteger section = seg.tag >> 16;
    NSInteger subIndex = seg.tag & 0xFFFF;
    NSDictionary *sectionData = self.menuSections[section];
    NSDictionary *item = sectionData[@"subitems"][subIndex];
    NSString *key = item[@"key"];
    
    NSLog(@"Segmented control changed to %ld for key: %@", (long)seg.selectedSegmentIndex, key);
}
```

### 高级定制

#### 1. 添加新的设置项类型
要添加新的设置项类型，需要：

1. 在 `SettingType` 枚举中添加新类型
2. 在 `settingItemCellForTableView:indexPath:item:` 方法中添加对应的控件创建逻辑
3. 在 `heightForRowAtIndexPath:` 方法中添加对应的行高计算

#### 2. 修改分组展开/折叠行为
分组展开/折叠逻辑在 `tableView:didSelectRowAtIndexPath:` 方法中实现：

```objective-c
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 点击分组标题行时切换展开/折叠状态
    if (indexPath.row == 0) {
        NSMutableDictionary *sectionData = [self.menuSections[indexPath.section] mutableCopy];
        BOOL expanded = [sectionData[@"expanded"] boolValue];
        sectionData[@"expanded"] = @(!expanded); // 切换状态
        [self.menuSections replaceObjectAtIndex:indexPath.section withObject:sectionData];
        
        // 刷新分组动画
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
        [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    }
}
```

#### 3. 自定义退出行为
退出应用的功能在 `exitApp` 方法中实现：

```objective-c
- (void)exitApp {
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)]; // 挂起应用
    [NSThread sleepForTimeInterval:0.3];      // 等待短暂时间
    exit(0);                                  // 退出进程
}
```

### 注意事项

1. 设置项的状态通过 `NSUserDefaults` 存储，键名由设置项字典中的 `key` 字段指定
2. 界面元素尺寸基于常量定义，修改时需确保整体布局协调
3. 分组展开状态保存在 `menuSections` 数组的 `expanded` 字段中
4. 用户头像使用 `placeholderAvatar` 方法生成默认头像，可替换为实际图片

此设置视图控制器提供了高度可定制的解决方案，适用于各种iOS应用的设置界面需求，特别适合越狱插件、高级设置面板等场景。