#import <UIKit/UIKit.h>
#import "Menu.h"

%hook UIWindow
- (void)makeKeyAndVisible {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[Menu sharedInstance] showMenuOnWindow:self];
    });
}
%end

