#import "SettingsViewController.h"
#import <unistd.h>

// MARK: - 全局常量定义
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

// MARK: - 设置项类型枚举
typedef NS_ENUM(NSUInteger, SettingType) {
    SettingTypeSwitch,    // 开关类型
    SettingTypeButton,    // 按钮类型
    SettingTypeSlider,    // 滑块类型
    SettingTypeSegmented, // 分段控制类型
    SettingTypeInfo       // 信息展示类型
};

@interface SettingsViewController ()
@property (nonatomic, strong) UIVisualEffectView *blurView;       // 毛玻璃效果视图
@property (nonatomic, strong) UIView *settingsCard;               // 设置卡片容器
@property (nonatomic, strong) UITableView *tableView;            // 设置项表格
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *menuSections; // 菜单数据源
@property (nonatomic, strong) UILabel *authorLabel;               // 作者信息标签
@end

@implementation SettingsViewController

#pragma mark - 生命周期方法
// 视图布局完成后的回调
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 允许表格垂直弹性滚动
    self.tableView.alwaysBounceVertical = YES;
}

// 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置半透明黑色背景
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.22];
    
    // MARK: - 卡片尺寸计算
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat cardWidth = MIN(screenWidth - 60, 700);      // 卡片宽度(最大700)
    CGFloat cardHeight = MIN(screenHeight * 0.68, 540);  // 卡片高度(最大540)
    
    // 创建设置卡片
    CGRect cardFrame = CGRectMake((screenWidth - cardWidth)/2.0, (screenHeight - cardHeight)/2.0, cardWidth, cardHeight);
    self.settingsCard = [[UIView alloc] initWithFrame:cardFrame];
    self.settingsCard.layer.cornerRadius = kCardCornerRadius;
    self.settingsCard.layer.masksToBounds = YES;
    [self.view addSubview:self.settingsCard];

    // MARK: - 毛玻璃效果
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.blurView.frame = self.settingsCard.bounds;
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.settingsCard addSubview:self.blurView];

    // MARK: - 顶部导航栏
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.settingsCard.bounds), kTableCellHeight + 10)];
    [self.blurView.contentView addSubview:topBar];

    // 退出按钮
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    exitButton.frame = CGRectMake(12, 8, 52, 36);
    [exitButton setTitle:@"退出" forState:UIControlStateNormal];
    exitButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [exitButton setTitleColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.7 alpha:1.0] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitApp) forControlEvents:UIControlEventTouchUpInside];
    [self.blurView.contentView addSubview:exitButton];

    // 标题
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, CGRectGetWidth(self.settingsCard.bounds), 36)];
    title.text = @"Tweak";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    title.textColor = [UIColor labelColor];
    [self.blurView.contentView addSubview:title];

    // 关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(CGRectGetWidth(self.settingsCard.bounds)-60, 8, 52, 36);
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [closeButton addTarget:self action:@selector(didTapCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [self.blurView.contentView addSubview:closeButton];

    // MARK: - 表格容器
    CGFloat topBarHeight = CGRectGetHeight(topBar.frame);
    CGFloat tableContainerHeight = cardHeight - topBarHeight - 16 - 28;
    UIView *tableContainer = [[UIView alloc] initWithFrame:CGRectMake(12, CGRectGetMaxY(topBar.frame)+8, 
                                                                     CGRectGetWidth(self.settingsCard.bounds)-24, 
                                                                     tableContainerHeight)];
    tableContainer.layer.cornerRadius = 12;
    tableContainer.layer.masksToBounds = YES;
    [self.blurView.contentView addSubview:tableContainer];
    
    // 作者信息标签
    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tableContainer.frame) + 8, 
                                                               CGRectGetWidth(self.settingsCard.bounds), 20)];
    self.authorLabel.text = @"KCMenu's Demo | KuaiCode";
    self.authorLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    self.authorLabel.textColor = [UIColor secondaryLabelColor];
    self.authorLabel.textAlignment = NSTextAlignmentCenter;
    [self.blurView.contentView addSubview:self.authorLabel];
    
    // MARK: - 表格头部视图 (用户信息卡片)
    UIView *headerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableContainer.bounds.size.width, kTableHeaderHeight)];
    
    UIView *infoCard = [[UIView alloc] initWithFrame:CGRectMake(0, 16, headerContainer.bounds.size.width, kInfoCardHeight)];
    infoCard.backgroundColor = [[UIColor secondarySystemBackgroundColor] colorWithAlphaComponent:0.68];
    infoCard.layer.cornerRadius = 12;
    infoCard.layer.masksToBounds = YES;

    // 用户头像
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 60, 60)];
    avatar.layer.cornerRadius = 30;
    avatar.layer.masksToBounds = YES;
    avatar.backgroundColor = [UIColor systemGray5Color];
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    avatar.image = [self placeholderAvatar];
    [infoCard addSubview:avatar];

    // 用户信息标签
    CGFloat labelWidth = infoCard.bounds.size.width - 96;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 12, labelWidth, 22)];
    nameLabel.text = @"KuaiCode";
    nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    nameLabel.textColor = [UIColor labelColor];
    [infoCard addSubview:nameLabel];

    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 32, labelWidth, 18)];
    idLabel.text = @"KCMenu's Demo";
    idLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    idLabel.textColor = [UIColor secondaryLabelColor];
    [infoCard addSubview:idLabel];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(84, 50, labelWidth, 16)];
    hint.text = @"本插件免费分享 仅测试使用";
    hint.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
    hint.textColor = [UIColor tertiaryLabelColor];
    [infoCard addSubview:hint];
    
    [headerContainer addSubview:infoCard];
    
    // MARK: - 表格视图初始化
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                  tableContainer.bounds.size.width, 
                                                                  tableContainer.bounds.size.height)
                                                 style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 无分隔线
    self.tableView.rowHeight = kTableCellHeight; // 默认行高
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.showsVerticalScrollIndicator = NO; // 隐藏垂直滚动条
    
    self.tableView.tableHeaderView = headerContainer; // 设置头部视图
    [tableContainer addSubview:self.tableView];

    // MARK: - 表格底部视图
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), kTableFooterHeight)];
    
    UIView *bottomBox = [[UIView alloc] initWithFrame:CGRectMake(0, 12, CGRectGetWidth(footerView.bounds), kTableFooterHeight - 12)];
    bottomBox.backgroundColor = [[UIColor secondarySystemBackgroundColor] colorWithAlphaComponent:0.68];
    bottomBox.layer.cornerRadius = 12;
    bottomBox.layer.masksToBounds = YES;
    [footerView addSubview:bottomBox];
    
    self.tableView.tableFooterView = footerView;

    // 底部信息项 (版本/更新日志/Github)
    NSArray *infoTitles = @[@"插件版本", @"更新日志", @"Github"];
    for (int i = 0; i < infoTitles.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, i * kTableCellHeight, CGRectGetWidth(bottomBox.bounds)-100, kTableCellHeight)];
        label.text = infoTitles[i];
        label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        label.textColor = [UIColor systemBlueColor];
        [bottomBox addSubview:label];
        
        // 添加分隔线
        if (i < infoTitles.count - 1) {
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(12, (i+1)*kTableCellHeight - 0.5, CGRectGetWidth(bottomBox.bounds)-24, 0.5)];
            separator.backgroundColor = [[UIColor separatorColor] colorWithAlphaComponent:0.15];
            [bottomBox addSubview:separator];
        }

        // 版本号标签
        if (i == 0) {
            UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(bottomBox.bounds)-100, i * kTableCellHeight, 84, kTableCellHeight)];
            versionLabel.text = @"0.0.1";
            versionLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
            versionLabel.textAlignment = NSTextAlignmentRight;
            versionLabel.textColor = [UIColor secondaryLabelColor];
            [bottomBox addSubview:versionLabel];
        } else {
            // 右侧箭头指示器
            UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
            chevron.tintColor = [UIColor secondaryLabelColor];
            chevron.frame = CGRectMake(CGRectGetWidth(bottomBox.bounds)-28, 
                                      i * kTableCellHeight + (kTableCellHeight - 12)/2, 
                                      8, 
                                      12);
            [bottomBox addSubview:chevron];
        }
        
        // 添加点击按钮
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        itemButton.frame = CGRectMake(0, i * kTableCellHeight, CGRectGetWidth(bottomBox.bounds), kTableCellHeight);
        [itemButton setBackgroundImage:[self imageWithColor:[[UIColor systemGrayColor] colorWithAlphaComponent:0.2]] 
                          forState:UIControlStateHighlighted];
        [bottomBox addSubview:itemButton];
    }

    // MARK: - 菜单数据结构初始化
    // 使用可变数组存储分组的菜单项
    self.menuSections = [NSMutableArray arrayWithArray:@[
        [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"透明度设置", @"expanded":@NO, @"subitems":@[ 
            @{@"title":@"开启半透明", @"detail":@"启用界面透明效果", @"type":@(SettingTypeSwitch), @"key":@"alpha_enable"}, 
            @{@"title":@"模糊增强", @"detail":@"增强背景模糊效果", @"type":@(SettingTypeSwitch), @"key":@"blur_enhance"},
            @{@"title":@"透明度级别", @"detail":@"调整透明程度", @"type":@(SettingTypeSlider), @"key":@"alpha_level"},
            @{@"title":@"保存设置", @"detail":@"保存当前配置", @"type":@(SettingTypeButton), @"key":@"save_settings"}
        ]}],
        [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"移除功能", @"expanded":@NO, @"subitems":@[ 
            @{@"title":@"移除右侧收藏", @"detail":@"隐藏收藏按钮", @"type":@(SettingTypeSwitch), @"key":@"remove_fav"}, 
            @{@"title":@"移除右侧点赞", @"detail":@"隐藏点赞按钮", @"type":@(SettingTypeSwitch), @"key":@"remove_like"},
            @{@"title":@"移除广告", @"detail":@"屏蔽所有广告内容", @"type":@(SettingTypeSwitch), @"key":@"remove_ads"},
            @{@"title":@"无水印解析保存", @"detail":@"选择保存方式", @"type":@(SettingTypeSegmented), @"key":@"remove_watermark", 
              @"options":@[@"关闭", @"长按", @"双击"]}
        ]}],
        [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"隐藏功能", @"expanded":@NO, @"subitems":@[ 
            @{@"title":@"隐藏评论区", @"detail":@"关闭评论区显示", @"type":@(SettingTypeSwitch), @"key":@"hide_comments"}, 
            @{@"title":@"隐藏分享按钮", @"detail":@"隐藏分享功能", @"type":@(SettingTypeSwitch), @"key":@"hide_share"},
            @{@"title":@"隐藏推荐", @"detail":@"关闭相关推荐", @"type":@(SettingTypeSwitch), @"key":@"hide_recommend"},
            @{@"title":@"隐藏状态栏", @"detail":@"VIP专属功能", @"type":@(SettingTypeInfo), @"key":@"hide_statusbar", @"value":@"VIP功能"}
        ]}],
        [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"增强功能", @"expanded":@NO, @"subitems":@[ 
            @{@"title":@"增强清晰度", @"detail":@"提升画质清晰度", @"type":@(SettingTypeSwitch), @"key":@"enhance_quality"}, 
            @{@"title":@"帧率解锁", @"detail":@"解锁更高帧率", @"type":@(SettingTypeSwitch), @"key":@"unlock_fps"},
            @{@"title":@"画质增强", @"detail":@"调节画质级别", @"type":@(SettingTypeSlider), @"key":@"quality_level"},
            @{@"title":@"高级设置", @"detail":@"更多高级选项", @"type":@(SettingTypeButton), @"key":@"advanced_settings"}
        ]}]
    ]];

    // 添加背景点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - UITableView 数据源方法
// 分组数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuSections.count;
}

// 每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.menuSections[section];
    BOOL expanded = [sectionData[@"expanded"] boolValue]; // 是否展开
    NSArray *subitems = sectionData[@"subitems"];
    return expanded ? (1 + subitems.count) : 1; // 展开时显示所有行，否则只显示标题行
}

// 分组头部高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8.0;
}

// 分组头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.bounds.size.width,8)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

// 分组底部高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionData = self.menuSections[indexPath.section];
    NSArray *subitems = sectionData[@"subitems"];
    
    // 标题行高度
    if (indexPath.row == 0) {
        return kTableCellHeight;
    }
    
    // 内容行高度
    NSDictionary *item = subitems[indexPath.row - 1];
    if ([item[@"type"] integerValue] == SettingTypeSlider) {
        return 70; // 滑块类型行高较大
    }
    return item[@"detail"] ? 54 : kTableCellHeight; // 有详细说明的行更高
}

// 单元格配置
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionData = self.menuSections[indexPath.section];
    BOOL expanded = [sectionData[@"expanded"] boolValue];
    NSArray *subitems = sectionData[@"subitems"];

    // 分组标题行
    if (indexPath.row == 0) {
        return [self headerCellForTableView:tableView sectionData:sectionData expanded:expanded];
    }
    
    // 设置项内容行
    return [self settingItemCellForTableView:tableView 
                                  indexPath:indexPath 
                                      item:subitems[indexPath.row - 1]];
}

// 创建分组标题单元格
- (UITableViewCell *)headerCellForTableView:(UITableView *)tableView 
                                sectionData:(NSDictionary *)sectionData
                                  expanded:(BOOL)expanded {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 折叠/展开指示图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    icon.tintColor = [UIColor systemBlueColor];
    icon.frame = CGRectMake(12, (kTableCellHeight-14)/2.0, 14, 14);
    [cell.contentView addSubview:icon];

    // 分组标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, tableView.bounds.size.width-60, kTableCellHeight)];
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.text = sectionData[@"title"];
    [cell.contentView addSubview:titleLabel];
    
    // 根据展开状态旋转图标
    icon.transform = expanded ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
    
    // 背景卡片视图
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, kTableCellHeight)];
    cardView.backgroundColor = [[UIColor secondarySystemBackgroundColor] colorWithAlphaComponent:0.68];
    cardView.layer.cornerRadius = 10;
    cardView.layer.masksToBounds = YES;
    
    // 根据展开状态设置圆角
    if (expanded) {
        cardView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner; // 只显示顶部圆角
    } else {
        cardView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | 
                                     kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner; // 显示所有圆角
    }
    
    // 添加阴影效果
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOffset = CGSizeMake(0, 1);
    cardView.layer.shadowOpacity = 0.05;
    cardView.layer.shadowRadius = 3;
    [cell.contentView insertSubview:cardView atIndex:0];
    [cell.contentView bringSubviewToFront:icon];
    [cell.contentView bringSubviewToFront:titleLabel];
    
    // 选中状态背景
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.2];
    cell.selectedBackgroundView = bgColorView;
    
    return cell;
}

// 创建设置项单元格
- (UITableViewCell *)settingItemCellForTableView:(UITableView *)tableView 
                                      indexPath:(NSIndexPath *)indexPath 
                                          item:(NSDictionary *)item {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    BOOL hasDetail = item[@"detail"] != nil;
    
    // 背景卡片视图
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, cellHeight)];
    cardView.backgroundColor = [[UIColor secondarySystemBackgroundColor] colorWithAlphaComponent:0.68];
    
    // 根据位置设置圆角
    if (indexPath.row == 1) { 
        cardView.layer.cornerRadius = 0; // 分组内第一项
    } else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) { 
        cardView.layer.cornerRadius = 10; // 分组内最后一项
        cardView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner; // 底部圆角
    }
    cardView.layer.masksToBounds = YES;
    [cell.contentView insertSubview:cardView atIndex:0];
    
    // 添加分隔线 (非第一行)
    if (indexPath.row > 1) {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(12, 0, tableView.bounds.size.width - 24, 0.5)];
        separator.backgroundColor = [[UIColor separatorColor] colorWithAlphaComponent:0.3];
        [cell.contentView addSubview:separator];
    }
    
    // 标题标签
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, tableView.bounds.size.width-100, 20)];
    textLabel.text = item[@"title"];
    textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    textLabel.textColor = [UIColor labelColor];
    [cell.contentView addSubview:textLabel];
    
    // 详细说明标签 (如果有)
    if (hasDetail) {
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 26, tableView.bounds.size.width-100, 16)];
        detailLabel.text = item[@"detail"];
        detailLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
        detailLabel.textColor = [UIColor secondaryLabelColor];
        [cell.contentView addSubview:detailLabel];
    }
    
    // 根据设置项类型创建不同控件
    SettingType type = [item[@"type"] integerValue];
    switch (type) {
        case SettingTypeSwitch: {
            // 开关控件
            UISwitch *sw = [[UISwitch alloc] init];
            sw.transform = CGAffineTransformMakeScale(0.85, 0.85); // 缩小尺寸
            // 从UserDefaults读取状态
            BOOL on = [[NSUserDefaults standardUserDefaults] boolForKey:item[@"key"]];
            [sw setOn:on animated:NO];
            // 使用tag存储位置信息 (高位section, 低位row)
            sw.tag = (indexPath.section<<16) | (indexPath.row-1);
            [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            break;
        }
        case SettingTypeButton: {
            // 按钮控件
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:@"点击" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
            button.tag = (indexPath.section<<16) | (indexPath.row-1);
            [button addTarget:self action:@selector(subButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = button;
            break;
        }
        case SettingTypeSlider: {
            // 滑块控件 (无accessoryView)
            cell.accessoryView = nil;
            
            // 值标签
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 60, 8, 48, 20)];
            valueLabel.text = @"50%";
            valueLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
            valueLabel.textColor = [UIColor secondaryLabelColor];
            valueLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:valueLabel];
            
            // 滑块控件
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(12, hasDetail ? 42 : 32, tableView.bounds.size.width - 24, 20)];
            slider.minimumValue = 0;
            slider.maximumValue = 100;
            slider.value = 50;
            slider.tag = (indexPath.section<<16) | (indexPath.row-1);
            [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:slider];
            break;
        }
        case SettingTypeSegmented: {
            // 分段控制控件
            NSArray *options = item[@"options"];
            
            // 创建容器视图 (用于垂直居中)
            UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, cellHeight)];
            
            // 创建分段控件 (高度增加到36)
            UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:options];
            segControl.frame = CGRectMake(0, (cellHeight - 32) / 2, 140, 32); // 垂直居中
            
            // 配置分段控件
            segControl.selectedSegmentIndex = 0;
            segControl.tag = (indexPath.section<<16) | (indexPath.row-1);
            [segControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
            
            [container addSubview:segControl];
            cell.accessoryView = container; // 设置accessoryView
            break;
        }
        case SettingTypeInfo: {
            // 信息展示视图
            UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, kTableCellHeight)];
            
            // 信息标签
            UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 80, 20)];
            infoLabel.text = item[@"value"];
            infoLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
            infoLabel.textColor = [UIColor secondaryLabelColor];
            infoLabel.textAlignment = NSTextAlignmentRight;
            [container addSubview:infoLabel];
            
            cell.accessoryView = container;
            break;
        }
    }
    
    // 选中状态背景
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.2];
    cell.selectedBackgroundView = bgColorView;
    
    return cell;
}

#pragma mark - UITableView 代理方法
// 行选中事件
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

#pragma mark - 控件事件处理
// 滑块值变化
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
    
    NSLog(@"Slider value changed: %f for key: %@", slider.value, key);
}

// 按钮点击事件
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

// 开关状态变化
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

// 分段控件变化
- (void)segmentedControlChanged:(UISegmentedControl *)seg {
    // 从tag中解析位置信息
    NSInteger section = seg.tag >> 16;
    NSInteger subIndex = seg.tag & 0xFFFF;
    NSDictionary *sectionData = self.menuSections[section];
    NSDictionary *item = sectionData[@"subitems"][subIndex];
    NSString *key = item[@"key"];
    
    NSLog(@"Segmented control changed to %ld for key: %@", (long)seg.selectedSegmentIndex, key);
}

#pragma mark - 工具方法
// 创建纯色图片 (用于按钮高亮状态)
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 背景点击处理
- (void)handleBackgroundTap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.view];
    // 点击背景区域时关闭设置页
    if (!CGRectContainsPoint(self.settingsCard.frame, point)) {
        [self didTapCloseButton];
    }
}

// 关闭按钮事件
- (void)didTapCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 退出应用
- (void)exitApp {
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)]; // 挂起应用
    [NSThread sleepForTimeInterval:0.3];      // 等待短暂时间
    exit(0);                                  // 退出进程
}

// 生成占位头像
- (UIImage *)placeholderAvatar {
    CGSize size = CGSizeMake(60,60);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 白色圆形背景
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(0,0,60,60));
    
    // 黑色眼睛
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(16,18,6,6));
    CGContextFillEllipseInRect(ctx, CGRectMake(38,18,6,6));
    
    // 微笑嘴型
    CGContextSetLineWidth(ctx, 2.5);
    CGContextMoveToPoint(ctx, 18,40);
    CGContextAddArc(ctx, 30, 40, 10, M_PI*0.1, M_PI*0.9, 0);
    CGContextStrokePath(ctx);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end