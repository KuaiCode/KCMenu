#import "MainViewController.h"
#import "../SettingsViewController.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置渐变背景
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithRed:0.1 green:0.1 blue:0.15 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:1.0].CGColor
    ];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"KCMenu 测试";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];
    
    // 副标题
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"点击按钮打开设置面板";
    subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subtitleLabel];
    
    // 打开设置按钮
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [settingsButton setTitle:@"打开 KCMenu 设置" forState:UIControlStateNormal];
    settingsButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    settingsButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.5 alpha:1.0];
    settingsButton.layer.cornerRadius = 12;
    settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [settingsButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingsButton];
    
    // 作者信息
    UILabel *authorLabel = [[UILabel alloc] init];
    authorLabel.text = @"KCMenu Demo | KuaiCode";
    authorLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    authorLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    authorLabel.textAlignment = NSTextAlignmentCenter;
    authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:authorLabel];
    
    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:subtitleLabel.topAnchor constant:-8],
        
        [subtitleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [subtitleLabel.bottomAnchor constraintEqualToAnchor:settingsButton.topAnchor constant:-40],
        
        [settingsButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [settingsButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [settingsButton.widthAnchor constraintEqualToConstant:220],
        [settingsButton.heightAnchor constraintEqualToConstant:50],
        
        [authorLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [authorLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
    ]];
}

- (void)openSettings {
    SettingsViewController *svc = [[SettingsViewController alloc] init];
    svc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:svc animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
