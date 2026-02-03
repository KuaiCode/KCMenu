#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

// 长按面板相关类声明
@interface AWELongPressPanelBaseViewModel : NSObject
@property(nonatomic, copy) NSString *describeString;
@property(nonatomic, assign) NSInteger actionType;
@property(nonatomic, copy) NSString *duxIconName;
@property(nonatomic, copy) void (^action)(void);
@property(nonatomic) BOOL isModern;
@end

@interface AWELongPressPanelViewGroupModel : NSObject
@property(nonatomic) unsigned long long groupType;
@property(nonatomic) NSArray *groupArr;
@property(nonatomic) BOOL isModern;
@end

@interface AWELongPressPanelManager : NSObject
+ (instancetype)shareInstance;
- (void)dismissWithAnimation:(BOOL)animated completion:(void (^)(void))completion;
@end

@interface AWEModernLongPressPanelTableViewController : UIViewController
@end

@interface AWELongPressPanelTableViewController : UIViewController
@end

static UIWindow *GetMainWindow(void) {
    UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    if (![scene isKindOfClass:[UIWindowScene class]]) return nil;
    UIWindow *w = scene.windows.firstObject;
    return w;
}

static void ShowSettingsViewController(void) {
    UIWindow *w = GetMainWindow();
    UIViewController *root = w.rootViewController;
    if (!root) return;
    
    // 查找最顶层的 ViewController
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }
    
    if ([root isKindOfClass:[SettingsViewController class]]) return;
    
    SettingsViewController *svc = [[SettingsViewController alloc] init];
    svc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [root presentViewController:svc animated:YES completion:nil];
}

// 创建 KCMenu 设置按钮
static AWELongPressPanelBaseViewModel *CreateKCMenuViewModel(BOOL isModern) {
    AWELongPressPanelBaseViewModel *kcMenuViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
    kcMenuViewModel.actionType = 8888;
    kcMenuViewModel.duxIconName = @"ic_setting_outlined";
    kcMenuViewModel.describeString = @"KCMenu 设置";
    kcMenuViewModel.isModern = isModern;
    kcMenuViewModel.action = ^{
        // 关闭长按面板
        AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
        [panelManager dismissWithAnimation:YES completion:^{
            // 显示设置页面
            ShowSettingsViewController();
        }];
    };
    return kcMenuViewModel;
}

// 创建包含 KCMenu 按钮的组
static AWELongPressPanelViewGroupModel *CreateKCMenuGroup(BOOL isModern) {
    AWELongPressPanelViewGroupModel *kcMenuGroup = [[%c(AWELongPressPanelViewGroupModel) alloc] init];
    kcMenuGroup.groupType = 0;
    kcMenuGroup.isModern = isModern;
    kcMenuGroup.groupArr = @[CreateKCMenuViewModel(isModern)];
    return kcMenuGroup;
}

// Hook 现代风格长按面板
%hook AWEModernLongPressPanelTableViewController
- (NSArray *)dataArray {
    NSArray *originalArray = %orig;
    if (!originalArray) {
        originalArray = @[];
    }
    
    // 将新组添加到原始数组最前面
    NSMutableArray *newArray = [NSMutableArray arrayWithObject:CreateKCMenuGroup(YES)];
    [newArray addObjectsFromArray:originalArray];
    
    return newArray;
}
%end

// Hook 经典风格长按面板
%hook AWELongPressPanelTableViewController
- (NSArray *)dataArray {
    NSArray *originalArray = %orig;
    if (!originalArray) {
        originalArray = @[];
    }
    
    // 将新组添加到原始数组最前面
    NSMutableArray *newArray = [NSMutableArray arrayWithObject:CreateKCMenuGroup(NO)];
    [newArray addObjectsFromArray:originalArray];
    
    return newArray;
}
%end