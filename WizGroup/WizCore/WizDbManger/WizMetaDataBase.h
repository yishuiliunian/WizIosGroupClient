//
//  WizMetaDataBase.h
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import "WizDataBase.h"
#import "WizMetaDataBaseDelegate.h"

@interface WizMetaDataBase : WizDataBase <WizMetaDataBaseDelegate>
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* kbguid;
@end
