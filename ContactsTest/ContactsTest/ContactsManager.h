//
//  ContactsManager.h
//  ContactsTest
//
//  Created by 李泽萌 on 2021/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ContactsManagerSelectPhoneNumBlock)(NSString *phoneNum);

@interface ContactsManager : NSObject
//检查通讯录权限
- (BOOL)checkContactsAuthorization;
//显示通讯录
-(void)showContactsList;
//获取通讯录列表
- (NSMutableArray *)getContactsList;
- (void)showNotAuthorizedAlert;
@property (nonatomic, copy)ContactsManagerSelectPhoneNumBlock selectPhoneNumBlock;
@end

NS_ASSUME_NONNULL_END
