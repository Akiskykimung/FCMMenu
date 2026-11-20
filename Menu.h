#import <UIKit/UIKit.h>

@interface Menu : NSObject
+ (instancetype)sharedInstance;
- (void)showMenuOnWindow:(UIWindow *)window;
@end
