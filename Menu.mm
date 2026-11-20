#import <UIKit/UIKit.h>
#import "Menu.h"
#import <mach/mach.h>

#define OFF_SCORE 0x1F777B64
#define BASE_ADDR 0x100000000

@implementation Menu

+ (instancetype)sharedInstance {
    static Menu *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[Menu alloc] init]; });
    return instance;
}

- (void)writeMemoryAt:(uint64_t)addr value:(int)val {
    vm_address_t page = addr & ~(vm_address_t)0xFFF;
    vm_protect(mach_task_self(), page, 0x1000, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY | VM_PROT_EXECUTE);
    vm_write(mach_task_self(), (vm_address_t)addr, (vm_offset_t)&val, sizeof(int));
}

- (void)showMenuOnWindow:(UIWindow *)window {
    UIWindow *overlay = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlay.windowLevel = UIWindowLevelAlert + 1;
    overlay.rootViewController = [UIViewController new];
    overlay.rootViewController.view.backgroundColor = [UIColor clearColor];
    overlay.hidden = NO;

   
