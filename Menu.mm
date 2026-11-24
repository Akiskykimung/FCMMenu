 #import <UIKit/UIKit.h>
#import "Menu.h"
#import <mach/mach.h>

#define OFF_SCORE 0x1F777B64
#define BASE_ADDR 0x100000000

@interface PassThroughWindow : UIWindow
@end

@implementation PassThroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || hitView == self.rootViewController.view) {
        return nil; 
    }
    return hitView;
}
- (BOOL)canBecomeKeyWindow {
    return NO; 
}
@end

@interface Menu ()
@property (nonatomic, strong) UIWindow *menuWindow;
@end

@implementation Menu

+ (instancetype)sharedInstance {
    static Menu *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ 
        instance = [[Menu alloc] init]; 
    });
    return instance;
}

- (void)writeMemoryAt:(uint64_t)addr value:(int)val {
    vm_address_t page = addr & ~(vm_address_t)0xFFF;
    vm_protect(mach_task_self(), page, 0x1000, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY | VM_PROT_EXECUTE);
    vm_write(mach_task_self(), (vm_address_t)addr, (vm_offset_t)&val, sizeof(int));
}

- (void)showMenuOnWindow:(UIWindow *)window {
    PassThroughWindow *overlay = [[PassThroughWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlay.windowLevel = UIWindowLevelAlert + 1;
    overlay.rootViewController = [UIViewController new];
    overlay.rootViewController.view.backgroundColor = [UIColor clearColor];
    [overlay setHidden:NO];
    
    self.menuWindow = overlay; 

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 100, 80, 50);
    btn.backgroundColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.6 alpha:0.9];
    btn.layer.cornerRadius = 12;
    [btn setTitle:@"SET SCORE" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [btn addTarget:self action:@selector(btnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [btn addGestureRecognizer:pan];
    
    [overlay.rootViewController.view addSubview:btn];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.menuWindow];
    pan.view.center = CGPointMake(pan.view.center.x + translation.x, pan.view.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.menuWindow];
}

- (void)btnTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FCMMenu" message:@"Nhập tỷ số bạn muốn:" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"Ví dụ: 99";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Áp dụng" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = alert.textFields.firstObject.text;
        int val = [input intValue];
        uint64_t finalAddr = BASE_ADDR + OFF_SCORE;
        [self writeMemoryAt:finalAddr value:val];
    }]];
    
    // Lấy cửa sổ chính của App để hiển thị (không dùng isKeyWindow nữa)
    UIWindow *mainWindow = [UIApplication sharedApplication].windows.firstObject;
    UIViewController *presenter = mainWindow.rootViewController;
    while (presenter.presentedViewController) {
        presenter = presenter.presentedViewController;
    }
    [presenter presentViewController:alert animated:YES completion:nil];
}

@end