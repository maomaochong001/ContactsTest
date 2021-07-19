//
//  UIViewController+Extension.m
//  ContactsTest
//
//  Created by 李泽萌 on 2021/7/16.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)
+ (UIViewController *)currentViewController {
    
    UIViewController *rootViewController = [self getRootViewController];
    return [self currentViewControllerFrom:rootViewController];
}

+ (UIViewController *)currentViewControllerFrom:(UIViewController*)viewController {
    
    // 如果传入的控制器是导航控制器,则返回最后一个
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self currentViewControllerFrom:navigationController.viewControllers.lastObject];
    }
    // 如果传入的控制器是tabBar控制器,则返回选中的那个
    else if([viewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self currentViewControllerFrom:tabBarController.selectedViewController];
    }
    // 如果传入的控制器发生了modal,则就可以拿到modal的那个控制器
    else if(viewController.presentedViewController != nil) {
        return [self currentViewControllerFrom:viewController.presentedViewController];
    }
    else {
        return viewController;
    }
}

+ (UIViewController *)getRootViewController{
    UIWindow* window = nil;
    if (@available(iOS 13.0, *)) {
       for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes){
           if (windowScene.activationState == UISceneActivationStateForegroundActive){
              window = windowScene.windows.firstObject;
               break;
          }
       }
   }else{
       #pragma clang diagnostic push
       #pragma clang diagnostic ignored "-Wdeprecated-declarations"
       // 这部分使用到的过期api
        window = [UIApplication sharedApplication].keyWindow;
       #pragma clang diagnostic pop
   }
    if([window.rootViewController isKindOfClass:NSNull.class]){
        return nil;
    }
    return window.rootViewController;
}
@end
