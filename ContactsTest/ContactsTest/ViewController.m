//
//  ViewController.m
//  ContactsTest
//
//  Created by 李泽萌 on 2021/7/16.
//

#import "ViewController.h"
#import "ContactsManager.h"
@interface ViewController ()
@property (nonatomic, strong) ContactsManager * mContactsManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mContactsManager.selectPhoneNumBlock = ^(NSString * _Nonnull phoneNum) {
        NSLog(@"select Num:%@",phoneNum);
    };
}

- (IBAction)action2:(id)sender {
    if ([self.mContactsManager checkContactsAuthorization]) {
       [self.mContactsManager showContactsList];
    }else{
        [self.mContactsManager showNotAuthorizedAlert];
    }
}

- (IBAction)action1:(id)sender {
    if ([self.mContactsManager checkContactsAuthorization]) {
       NSMutableArray * contactsListArr = [self.mContactsManager getContactsList];
        NSLog(@"contactsListArr:%@",contactsListArr);
    }else{
        [self.mContactsManager showNotAuthorizedAlert];
    }
}


#pragma mark - Getter
- (ContactsManager *)mContactsManager {
    if (_mContactsManager == nil) {
        _mContactsManager = [[ContactsManager alloc] init];
    }
    return _mContactsManager;
}

@end
