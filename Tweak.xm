#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

static UIWindow *GetMainWindow(void) {
    UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    if (![scene isKindOfClass:[UIWindowScene class]]) return nil;
    UIWindow *w = scene.windows.firstObject;
    return w;
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = GetMainWindow();
        if (window) {
            UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:[NSBlockOperation blockOperationWithBlock:^{}] action:NULL];
            gesture.minimumPressDuration = 1.0;
            gesture.numberOfTouchesRequired = 3;
            [gesture addTarget: (id)^{ } action: @selector(description)];
            [window addGestureRecognizer:gesture];
        }
    });
}

%hook UIWindow
- (void)sendEvent:(UIEvent *)event {
    %orig;
    if (event.type == UIEventTypeTouches) {
        NSSet<UITouch *> *touches = [event allTouches];
        if (touches.count == 3) {
            BOOL anyBegan = NO;
            for (UITouch *t in touches) {
                if (t.phase == UITouchPhaseBegan) { anyBegan = YES; break; }
            }
            if (anyBegan) {
                static NSTimeInterval last = 0;
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                if (now - last < 1.0) return;
                last = now;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    BOOL stillTouching = NO;
                    for (UITouch *t in touches) {
                        if (t.phase == UITouchPhaseStationary || t.phase == UITouchPhaseMoved) { stillTouching = YES; break; }
                    }
                    if (!stillTouching) return;
                    UIWindow *w = GetMainWindow();
                    UIViewController *root = w.rootViewController;
                    if (!root) return;
                    if ([root.presentedViewController isKindOfClass:[SettingsViewController class]]) return;
                    SettingsViewController *svc = [[SettingsViewController alloc] init];
                    svc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [root presentViewController:svc animated:YES completion:nil];
                });
            }
        }
    }
}
%end