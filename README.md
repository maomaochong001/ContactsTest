# ContactsTest
iOS9以后出了一个新的ContactsUI来代替原来AddressBook用来获取通讯录内信息。
这个mode简单介绍下常用的获取通讯录内所有联系人以及选择某一个手机号方法。
首先需要先在Info里面加隐私声明：Privacy - Contacts Usage Description
![截屏2021-07-19 下午2.19.56.png](https://upload-images.jianshu.io/upload_images/5653025-acb6287065a60fd0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后在调起之前要先获取是否有权限：
```
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
```
这里要注意在CNAuthorizationStatusNotDetermined状态，也就是用户未决定是否授权时候，要加一个dispatch_semaphore_signal等待信号量，等用户决定是否授权点击以后，才把结果返回。要不就会直接返回NO，即使用户后面选择了允许。

获取通讯录：
```
//要获取的内容的key
    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        NSArray *phoneNumbers = contact.phoneNumbers;
        for (CNLabeledValue *labelValue in phoneNumbers) {
            //遍历一个人名下的多个电话号码
            CNPhoneNumber *phoneNumber = labelValue.value;
            NSString *phone = phoneNumber.stringValue;
        }
    }];
```

要获取某一联系人下的所有信息：
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact;
这个方法在点击通讯录列表里某一个联系人时候就会回调，这里可以获取到所有标签及信息。
```
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
```

某一选中联系人的某一标签信息：
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty;
这个方法是联系人详情里点击了某一标签后能得到点击的标签内容，比如联系人有多个手机号，点击其中的一个，就能返回那一个手机号；
此方法和上面方法不能同时实现，如果实现了上面的方法在点击时候就不会进入联系人详情页 也就不会回调本方法。
```
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    CNPhoneNumber *number=contactProperty.value;
    NSString * numStr = [number stringValue];
    if (self.selectPhoneNumBlock) {
        self.selectPhoneNumBlock([self formatPhoneNumber:numStr]);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
```

另外还有多选的回调方法，但是用到地方不多，和单选形式差不多只不过是在数组里返回的多个数据：
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact*> *)contacts;
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperties:(NSArray<CNContactProperty*> *)contactProperties;
