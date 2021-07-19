//
//  ContactsManager.m
//  ContactsTest
//
//  Created by 李泽萌 on 2021/7/16.
//

#import "ContactsManager.h"
#import <ContactsUI/ContactsUI.h>/// iOS 9的新框架
#import "UIViewController+Extension.h"
@interface ContactsManager ()<CNContactPickerDelegate>

@end
@implementation ContactsManager
- (instancetype)init {
    self = [super init];
    return self;
}

//检查通讯录权限
- (BOOL)checkContactsAuthorization {
    __block BOOL hasAuthorized = NO;
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        dispatch_semaphore_t sem;
        sem = dispatch_semaphore_create(0);
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error) {
                hasAuthorized = NO;
            }else{
                hasAuthorized = granted;
            }
            dispatch_semaphore_signal(sem);
        }];
        //获取通知设置的过程是异步的，这里需要等待
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    else if(status == CNAuthorizationStatusAuthorized) {
        hasAuthorized = YES;
    }
    else {
        hasAuthorized = NO;
    }
    return hasAuthorized;
}

//显示联系人列表
-(void)showContactsList {
    CNContactPickerViewController * picker = [[CNContactPickerViewController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    picker.delegate=self;
    [[UIViewController currentViewController] presentViewController:picker animated:YES completion:^{}];
}

#pragma mark -CNContactPickerDelegate
/*
//获取某一点中的联系人的所有信息
//如果实现了本方法 在点击时候就不会进入联系人详情页 也就不会调用下面选取某一项标签方法
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSLog(@"name:%@%@",contact.familyName,contact.givenName);
    NSLog(@"公司: %@",contact.organizationName);
    //获取通讯录某个人所有电话并存入数组中 需要哪个取哪个
    NSMutableArray * arrMPhoneNums = [NSMutableArray array];
    for (CNLabeledValue * labValue in contact.phoneNumbers) {
        NSString * strPhoneNums = [labValue.value stringValue];
        NSLog(@"所有电话是: %@",strPhoneNums);
        [arrMPhoneNums addObject:strPhoneNums];
    }
    //所有邮件地址数组
    NSMutableArray * arrMEmails = [NSMutableArray array];
    for (CNLabeledValue * labValue in contact.emailAddresses) {
        NSLog(@"email : %@",labValue.value);
        [arrMEmails addObject:labValue.value];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
 */
//某一选中联系人的某一标签信息
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    CNPhoneNumber *number=contactProperty.value;
    NSString * numStr = [number stringValue];
    if (self.selectPhoneNumBlock) {
        self.selectPhoneNumBlock([self formatPhoneNumber:numStr]);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//获取通讯录列表
- (NSMutableArray *)getContactsList {
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    //要获取的内容的key
    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        NSString *name = [NSString stringWithFormat:@"%@%@", contact.familyName, contact.givenName];
        NSArray *phoneNumbers = contact.phoneNumbers;
        for (CNLabeledValue *labelValue in phoneNumbers) {
            //遍历一个人名下的多个电话号码
            CNPhoneNumber *phoneNumber = labelValue.value;
            NSString *phone = phoneNumber.stringValue;
            //去掉电话中的特殊字符
            phone = [self formatPhoneNumber:phone];
            NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", phone, @"phone", nil];
            [contacts addObject:contact];
        }
    }];
    return contacts;
}

//去掉特殊符号
- (NSString *)formatPhoneNumber:(NSString *)number {
    number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@"(" withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@")" withString:@""];
    number = [number stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    return number;
}

- (void)showNotAuthorizedAlert {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要授权才能获取您的通讯录信息" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) { }];
            }else{
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [[UIViewController currentViewController] presentViewController:alert animated:YES completion:^{
    }];
}
@end
