#import <UIKit/UIKit.h>
#import "Menu.h"
#import <mach/mach.h>

#define OFF_SCORE 0x1F777B64
#define BASE_ADDR 0x100000000

// Class này giúp cửa sổ trong suốt, cho phép chạm xuyên qua
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
    // Dùng PassThroughWindow thay vì UIWindow
    PassThroughWindow *overlay = [[PassThroughWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlay.windowLevel = UIWindowLevelAlert + 1;
    overlay.rootViewController = [UIViewController new];
    overlay.rootViewController.view.backgroundColor = [UIColor clearColor];
    [overlay setHidden:NO];
    
    self.menuWindow = overlay; 

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 100, 60, 60);
    btn.backgroundColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.6 alpha:0.8];
    btn.layer.cornerRadius = 30;
    [btn setTitle:@"99" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [btn addTarget:self action:@selector(btnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [overlay.rootViewController.view addSubview:btn];
}

- (void)btnTapped {
    uint64_t finalAddr = BASE_ADDR + OFF_SCORE;
    [self writeMemoryAt:finalAddr value:99];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FCMMenu" message:@"Đã đẩy tỷ số!" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    if (self.menuWindow) {
        [self.menuWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

@end